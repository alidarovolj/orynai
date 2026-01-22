import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import 'dart:convert';
import '../constants.dart';
import '../services/api_service.dart';
import '../models/order.dart';

class PaymentModal extends StatefulWidget {
  final Order order;
  final VoidCallback? onSuccess;
  final VoidCallback? onClose;

  const PaymentModal({
    super.key,
    required this.order,
    this.onSuccess,
    this.onClose,
  });

  static void show(
    BuildContext context,
    Order order, {
    VoidCallback? onSuccess,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => PaymentModal(
        order: order,
        onSuccess: onSuccess,
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  @override
  State<PaymentModal> createState() => _PaymentModalState();
}

class _PaymentModalState extends State<PaymentModal> {
  final ApiService _apiService = ApiService();
  late WebViewController _webViewController;
  bool _isLoading = true;
  String? _paymentUrl;
  Timer? _paymentCheckTimer;
  String? _errorMessage;
  String? _paymentObjectJson;

  @override
  void initState() {
    super.initState();
    _initializePayment();
  }

  @override
  void dispose() {
    _paymentCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializePayment() async {
    try {
      setState(() {
        _errorMessage = null;
        _isLoading = true;
        _paymentUrl = null;
      });

      // 1. Создаем инвойс
      final invoiceResponse = await _apiService.createInvoice(
        orderId: widget.order.id,
        amount: widget.order.totalPrice,
      );

      // Извлекаем invoiceId из ответа
      final invoiceData = invoiceResponse['data'] as Map<String, dynamic>?;
      final invoiceId = invoiceData?['invoiceId']?.toString();

      if (invoiceId == null) {
        throw Exception('Не удалось создать инвойс');
      }

      debugPrint('📤 [Payment] Invoice ID: $invoiceId');

      // 2. Генерируем токен для оплаты
      final tokenResponse = await _apiService.generatePaymentToken(
        amount: widget.order.totalPrice,
        invoiceId: invoiceId,
        terminalType: 'shop',
      );

      // Извлекаем токен из ответа
      final tokenData = tokenResponse['data'] as Map<String, dynamic>?;
      final accessToken = tokenData?['accessToken']?.toString();

      if (accessToken == null) {
        throw Exception('Не удалось сгенерировать токен оплаты');
      }

      debugPrint('📤 [Payment] Access Token: $accessToken');

      // 3. Формируем объект для halyk виджета (как в веб-версии)
      // Определяем окружение на основе ENV из .env
      final env = dotenv.env['ENV']?.toLowerCase().trim() ?? 'prod';
      final isTest = env == 'dev';

      debugPrint(
        '📤 [Payment] ENV from .env: "$env" (raw: "${dotenv.env['ENV']}")',
      );
      debugPrint('📤 [Payment] isTest: $isTest');

      // Используем тестовый или продакшн URL в зависимости от окружения
      final baseUrl = isTest
          ? 'https://test-epay.epayment.kz/payform/'
          : 'https://epay.homebank.kz/payform/';

      // Terminal для тестового или продакшн окружения
      // Для тестового окружения может быть другой terminal, но пока используем тот же
      const terminal = '3eb45bdd-24a5-43f5-bbb8-49a7ce907ba0'; // Shop terminal

      debugPrint('📤 [Payment] Environment: ${isTest ? "TEST" : "PRODUCTION"}');
      debugPrint('📤 [Payment] Base URL: $baseUrl');

      // Формируем payment object как в веб-версии
      final paymentData = {
        'orderId': widget.order.id,
        'cartItems': widget.order.items
            .map(
              (item) => <String, dynamic>{
                'productId': item.productId,
                'productName': item.product.name,
                'quantity': item.quantity,
                'price': item.price,
              },
            )
            .toList(),
      };

      // Формируем auth объект
      final auth = <String, dynamic>{
        'access_token': accessToken,
        'expires_in': tokenData?['expiresIn']?.toString() ?? '14400',
        'refresh_token': '',
        'scope': tokenData?['scope']?.toString() ?? 'payment',
        'token_type': tokenData?['tokenType']?.toString() ?? 'Bearer',
      };

      // Формируем payment object как в веб-версии (для halyk.pay)
      // Согласно документации: https://epayment.kz/docs/platezhnyi-vidzhet
      // - auth должен передаваться как объект полностью (все данные от epay)
      // - data должен быть JSON строкой (необязательное поле)
      final paymentObject = <String, dynamic>{
        'invoiceId': invoiceId,
        'invoiceIdAlt': invoiceId,
        'backLink': 'https://stage.ripservice.kz/client/tickets?success=true',
        'failureBackLink':
            'https://stage.ripservice.kz/client/tickets?failure=true',
        'postLink':
            'https://stage.ripservice.kz/api/v1/payments/mobile/callback',
        'failurePostLink':
            'https://stage.ripservice.kz/api/v1/payments/mobile/callback',
        'language': 'RUS',
        'description': 'Оплата заказа #${widget.order.id}',
        'accountId': '',
        'terminal': terminal,
        'amount': widget.order.totalPrice,
        'name': '',
        'currency': 'KZT',
        'data': jsonEncode(
          paymentData,
        ), // data - JSON строка согласно документации
        'recurrent': false,
        'auth': auth, // auth - объект полностью, все данные от epay
      };

      // Согласно документации: https://epayment.kz/docs/platezhnaya-stranica
      // Загружаем реальную страницу Halyk ePay и инжектим JavaScript после загрузки
      final paymentObjectJson = jsonEncode(paymentObject);
      final jsLibraryUrl = isTest
          ? 'https://test-epay.epayment.kz/payform/payment-api.js'
          : 'https://epay.homebank.kz/payform/payment-api.js';

      debugPrint('📤 [Payment] Payment object JSON: $paymentObjectJson');
      debugPrint('📤 [Payment] JS Library URL: $jsLibraryUrl');

      // Сохраняем paymentObject для использования в JavaScript injection
      _paymentObjectJson = paymentObjectJson;

      // Создаем HTML страницу с подключенной библиотекой Halyk ePay
      // Используем loadHtmlString с правильным baseUrl для загрузки библиотеки
      final htmlContent =
          '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Оплата</title>
    <style>
        body { margin: 0; padding: 0; background: #f5f5f5; }
        #payment-container { width: 100%; height: 100vh; }
        .loading { 
          display: flex; 
          justify-content: center; 
          align-items: center; 
          height: 100vh; 
          font-family: Arial, sans-serif;
          color: #666;
        }
    </style>
</head>
<body>
    <div id="payment-container">
      <div class="loading">Загрузка платежной формы...</div>
    </div>
    <script src="$jsLibraryUrl"></script>
</body>
</html>
      ''';

      debugPrint(
        '📤 [Payment] Loading payment page with library: $jsLibraryUrl',
      );

      setState(() {
        _paymentUrl =
            'data:text/html;charset=utf-8,${Uri.encodeComponent(htmlContent)}';
      });

      // Инициализируем WebView
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              debugPrint('📤 [WebView] Page started: $url');
              setState(() {
                _isLoading = true;
              });
            },
            onPageFinished: (String url) async {
              debugPrint('✅ [WebView] Page finished: $url');

              // Инжектим JavaScript для инициализации платежа после загрузки библиотеки
              if (_paymentObjectJson != null) {
                // Экранируем JSON для безопасного использования в JavaScript
                final escapedJson = _paymentObjectJson!
                    .replaceAll('\\', '\\\\')
                    .replaceAll("'", "\\'")
                    .replaceAll('\n', '\\n')
                    .replaceAll('\r', '\\r')
                    .replaceAll('</', '<\\/'); // Экранируем закрывающие теги

                // Используем более надежный подход с проверкой загрузки библиотеки
                // Увеличиваем время ожидания и количество попыток, убираем показ ошибок
                final jsCode =
                    '''
                  (function() {
                    var maxAttempts = 30;
                    var attempt = 0;
                    var paymentObject = JSON.parse('$escapedJson');
                    console.log('Payment object:', paymentObject);
                    
                    function tryInitPayment() {
                      attempt++;
                      console.log('Attempt ' + attempt + ' to initialize payment');
                      
                      // Проверяем разные варианты методов
                      if (typeof halyk !== 'undefined' && halyk !== null) {
                        console.log('Halyk object found, checking methods...');
                        console.log('halyk.pay:', typeof halyk.pay);
                        console.log('halyk.showPaymentWidget:', typeof halyk.showPaymentWidget);
                        
                        if (typeof halyk.pay === 'function') {
                          console.log('Calling halyk.pay...');
                          try {
                            halyk.pay(paymentObject);
                            console.log('halyk.pay called successfully');
                            return;
                          } catch (error) {
                            console.error('Error calling halyk.pay:', error);
                            // Не показываем ошибку пользователю
                            return;
                          }
                        } else if (typeof halyk.showPaymentWidget === 'function') {
                          console.log('Calling halyk.showPaymentWidget...');
                          try {
                            halyk.showPaymentWidget(paymentObject, function(result) {
                              console.log('Payment widget callback:', result);
                            });
                            console.log('halyk.showPaymentWidget called successfully');
                            return;
                          } catch (error) {
                            console.error('Error calling halyk.showPaymentWidget:', error);
                            return;
                          }
                        } else {
                          console.log('Neither halyk.pay nor halyk.showPaymentWidget found');
                        }
                      } else {
                        console.log('Halyk object not found yet');
                      }
                      
                      // Продолжаем попытки
                      if (attempt < maxAttempts) {
                        setTimeout(tryInitPayment, 1000);
                      } else {
                        console.error('Halyk library failed to load after ' + maxAttempts + ' attempts');
                        // Не показываем ошибку пользователю
                      }
                    }
                    
                    // Начинаем попытки инициализации с задержкой
                    setTimeout(tryInitPayment, 2000);
                  })();
                ''';

                try {
                  // Небольшая задержка перед инжекцией, чтобы библиотека успела загрузиться
                  await Future.delayed(const Duration(milliseconds: 500));
                  await _webViewController.runJavaScript(jsCode);
                  debugPrint('✅ [WebView] JavaScript injected successfully');
                } catch (e) {
                  debugPrint('❌ [WebView] Error injecting JavaScript: $e');
                  if (mounted) {
                    setState(() {
                      _errorMessage = 'Ошибка инициализации платежа: $e';
                    });
                  }
                }
              }

              setState(() {
                _isLoading = false;
              });
            },
            onWebResourceError: (WebResourceError error) {
              debugPrint('❌ [WebView] Error: ${error.description}');
              debugPrint('   Error code: ${error.errorCode}');
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _errorMessage =
                      'Ошибка загрузки платежной формы: ${error.description}';
                });
              }
            },
            onUrlChange: (UrlChange change) {
              if (change.url != null) {
                debugPrint('🔄 [WebView] URL changed: ${change.url}');
                _handleUrlChange(change.url!);
              }
            },
            onHttpError: (HttpResponseError error) {
              debugPrint(
                '❌ [WebView] HTTP error: ${error.response?.statusCode}',
              );
            },
          ),
        )
        ..loadHtmlString(htmlContent, baseUrl: baseUrl);

      // Устанавливаем таймаут для загрузки
      Future.delayed(const Duration(seconds: 30), () {
        if (mounted && _isLoading) {
          debugPrint('⏱️ [WebView] Timeout after 30 seconds');
          setState(() {
            _isLoading = false;
            _errorMessage = 'Превышено время ожидания загрузки платежной формы';
          });
        }
      });

      // Запускаем периодическую проверку статуса оплаты
      _startPaymentCheck();
    } catch (e) {
      debugPrint('Error initializing payment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка инициализации оплаты: $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  void _handleUrlChange(String url) {
    debugPrint('URL changed: $url');

    // Проверяем, не вернулись ли мы на страницу успеха
    if (url.contains('success=true') || url.contains('payment=success')) {
      _handlePaymentSuccess();
    } else if (url.contains('error') || url.contains('cancel')) {
      _handlePaymentError();
    }
  }

  void _startPaymentCheck() {
    // Проверяем статус оплаты каждые 5 секунд
    _paymentCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      // Можно добавить проверку статуса заказа через API
      // Пока просто проверяем URL через onUrlChange
    });
  }

  Future<void> _handlePaymentSuccess() async {
    _paymentCheckTimer?.cancel();

    if (mounted) {
      Navigator.pop(context);
      widget.onSuccess?.call();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Оплата успешно завершена'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
    }
  }

  void _handlePaymentError() {
    _paymentCheckTimer?.cancel();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Оплата отменена'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Заголовок
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.accordionBorder.withOpacity(0.3),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Оплата заказа',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1d1c1a),
                    fontFamily: 'Manrope',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onClose?.call();
                  },
                ),
              ],
            ),
          ),
          // WebView
          Expanded(
            child: Stack(
              children: [
                if (_errorMessage != null)
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF1d1c1a),
                              fontFamily: 'Manrope',
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _errorMessage = null;
                                _isLoading = true;
                              });
                              _initializePayment();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD4AF37),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              'Повторить',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Manrope',
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_paymentUrl != null)
                  WebViewWidget(controller: _webViewController)
                else
                  const Center(child: CircularProgressIndicator()),
                if (_isLoading && _errorMessage == null)
                  Container(
                    color: Colors.white,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
