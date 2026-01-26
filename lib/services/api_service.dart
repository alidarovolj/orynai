import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:chucker_flutter/chucker_flutter.dart';
import 'auth_state_manager.dart';

class ApiService {
  static ApiService? _instance;
  factory ApiService() => _instance ??= ApiService._internal();
  ApiService._internal();

  String? _baseUrl;
  String? _csrfToken;
  final Map<String, String> _cookies = {};
  http.Client? _httpClient;

  // Инициализация URL из .env
  Future<void> initialize() async {
    _baseUrl = dotenv.env['API_URL'];
    
    if (_baseUrl == null || _baseUrl!.isEmpty) {
      // Используем значение по умолчанию
      _baseUrl = 'https://stage.ripservice.kz';
      debugPrint('Warning: API_URL not found in .env, using default: $_baseUrl');
    }

    // Инициализация HTTP клиента с Chucker только в dev режиме
    final env = dotenv.env['ENV'];
    if (env == 'dev') {
      _httpClient = ChuckerHttpClient(http.Client());
      debugPrint('🔍 [API] Chucker Flutter включен для мониторинга HTTP запросов');
    } else {
      _httpClient = http.Client();
    }
  }

  // Получение HTTP клиента
  http.Client get _client => _httpClient ?? http.Client();

  String get baseUrl => _baseUrl ?? '';

  // Получение токена для авторизованных запросов
  Future<String?> _getAuthToken() async {
    final authManager = AuthStateManager();
    return authManager.currentUser?.token;
  }

  // Извлечение CSRF токена и cookies из ответа
  void _extractCsrfToken(http.Response response) {
    // Проверяем заголовки ответа
    final csrfHeader = response.headers['x-csrf-token'] ?? 
                       response.headers['X-CSRF-Token'] ??
                       response.headers['csrf-token'];
    
    if (csrfHeader != null && csrfHeader.isNotEmpty) {
      _csrfToken = csrfHeader;
      debugPrint('🔑 [API] CSRF токен получен из заголовка: $_csrfToken');
    }

    // Извлекаем все cookies из заголовка Set-Cookie
    final setCookieHeaders = response.headers['set-cookie'];
    if (setCookieHeaders != null) {
      // Обрабатываем множественные Set-Cookie заголовки
      final cookieStrings = setCookieHeaders.split(',').map((s) => s.trim());
      
      for (final cookieString in cookieStrings) {
        // Парсим cookie в формате "name=value; path=/; domain=..."
        final cookieMatch = RegExp(r'([^=]+)=([^;]+)').firstMatch(cookieString);
        if (cookieMatch != null) {
          final name = cookieMatch.group(1)!.trim();
          final value = cookieMatch.group(2)!.trim();
          _cookies[name] = value;
          
          // Проверяем, не является ли это CSRF токеном
          if (name.toLowerCase().contains('csrf') && _csrfToken == null) {
            _csrfToken = value;
            debugPrint('🔑 [API] CSRF токен получен из cookie: $_csrfToken');
          }
        }
      }
      
      if (_cookies.isNotEmpty) {
        debugPrint('🍪 [API] Сохранены cookies: ${_cookies.keys.join(", ")}');
      }
    }

    // Пытаемся извлечь из тела ответа (если сервер возвращает его там)
    try {
      if (response.body.isNotEmpty && _csrfToken == null) {
        final decoded = json.decode(response.body);
        if (decoded is Map) {
          final csrf = decoded['csrf_token'] ?? decoded['csrftoken'] ?? decoded['csrf'];
          if (csrf != null && csrf is String) {
            _csrfToken = csrf;
            debugPrint('🔑 [API] CSRF токен получен из тела ответа: $_csrfToken');
          }
        }
      }
    } catch (e) {
      // Игнорируем ошибки парсинга
    }
  }

  // GET запрос
  Future<dynamic> get(
    String path, {
    Map<String, String>? queryParameters,
    bool requiresAuth = false,
  }) async {
    try {
      // Если путь начинается с http:// или https://, используем его как полный URL
      final fullPath = path.startsWith('http://') || path.startsWith('https://')
          ? path
          : '$baseUrl$path';
      var uri = Uri.parse(fullPath);

      if (queryParameters != null && queryParameters.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParameters);
      }

      final headers = <String, String>{
        'Accept': 'application/json, text/plain, */*',
        'Accept-Language': 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7',
      };

      if (requiresAuth) {
        final token = await _getAuthToken();
        if (token != null) {
          headers['Authorization'] = 'Bearer $token';
        }
        
        // Добавляем cookies если они есть
        if (_cookies.isNotEmpty) {
          final cookieString = _cookies.entries
              .map((e) => '${e.key}=${e.value}')
              .join('; ');
          headers['Cookie'] = cookieString;
        }
      }

      debugPrint('📤 [API] GET $fullPath');
      if (queryParameters != null && queryParameters.isNotEmpty) {
        debugPrint('   Query params: $queryParameters');
      }
      debugPrint('   Headers: $headers');

      final response = await _client.get(uri, headers: headers);

      // Извлекаем CSRF токен из cookies или заголовков ответа
      _extractCsrfToken(response);

      debugPrint('📥 [API] Response status: ${response.statusCode}');
      debugPrint('   Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = response.body.trim();
        if (responseBody.isEmpty || responseBody == 'OK') {
          return {'success': true, 'data': responseBody};
        }
        return json.decode(responseBody);
      } else {
        final errorBody = response.body.isNotEmpty
            ? json.decode(response.body)
            : {'error': 'Request failed with status ${response.statusCode}'};
        debugPrint('❌ [API] GET Error response:');
        debugPrint('   Status: ${response.statusCode}');
        debugPrint('   Body: $errorBody');
        throw ApiException(
          statusCode: response.statusCode,
          message: errorBody['description'] ?? errorBody['error'] ?? 'Unknown error',
          body: errorBody,
        );
      }
    } catch (e) {
      if (e is ApiException) {
        debugPrint('❌ [API] GET ApiException: ${e.message}');
        rethrow;
      }
      debugPrint('❌ [API] GET Network error: $e');
      throw ApiException(
        statusCode: 0,
        message: 'Network error: $e',
      );
    }
  }

  // POST запрос
  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    try {
      // Если путь начинается с http:// или https://, используем его как полный URL
      final fullPath = path.startsWith('http://') || path.startsWith('https://')
          ? path
          : '$baseUrl$path';
      final uri = Uri.parse(fullPath);

      final headers = <String, String>{
        'Accept': 'application/json, text/plain, */*',
        'Content-Type': 'application/json',
        'Accept-Language': 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7',
        'Origin': baseUrl,
        'Referer': '$baseUrl/',
      };

      if (requiresAuth) {
        final token = await _getAuthToken();
        if (token != null) {
          headers['Authorization'] = 'Bearer $token';
        }
        
        // Добавляем CSRF токен если он есть
        if (_csrfToken != null) {
          headers['X-CSRF-Token'] = _csrfToken!;
          debugPrint('🔑 [API] Добавлен CSRF токен в заголовки: $_csrfToken');
        }
        
        // Добавляем cookies если они есть
        if (_cookies.isNotEmpty) {
          final cookieString = _cookies.entries
              .map((e) => '${e.key}=${e.value}')
              .join('; ');
          headers['Cookie'] = cookieString;
          debugPrint('🍪 [API] Добавлены cookies: ${_cookies.keys.join(", ")}');
        }
      }

      final requestBody = body != null ? json.encode(body) : null;
      
      debugPrint('📤 [API] POST $fullPath');
      debugPrint('   Headers: $headers');
      if (requestBody != null) {
        debugPrint('   Body: $requestBody');
      }

      final response = await _client.post(
        uri,
        headers: headers,
        body: requestBody,
      );

      debugPrint('📥 [API] Response status: ${response.statusCode}');
      debugPrint('   Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = response.body.trim();
        if (responseBody.isEmpty || responseBody == 'OK') {
          return {'success': true, 'data': responseBody};
        }
        final decoded = json.decode(responseBody);
        // Возвращаем как есть (может быть Map или List)
        return decoded as Map<String, dynamic>;
      } else {
        final errorBody = response.body.isNotEmpty
            ? json.decode(response.body) as Map<String, dynamic>
            : {'error': 'Request failed with status ${response.statusCode}'};
        
        // Извлекаем сообщение об ошибке из разных возможных полей
        final errorMessage = errorBody['message'] ?? 
                            errorBody['description'] ?? 
                            errorBody['error'] ?? 
                            'Unknown error';
        
        throw ApiException(
          statusCode: response.statusCode,
          message: errorMessage.toString(),
          body: errorBody,
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        statusCode: 0,
        message: 'Network error: $e',
      );
    }
  }

  // PUT запрос
  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    try {
      // Если путь начинается с http:// или https://, используем его как полный URL
      final fullPath = path.startsWith('http://') || path.startsWith('https://')
          ? path
          : '$baseUrl$path';
      final uri = Uri.parse(fullPath);

      final headers = <String, String>{
        'Accept': 'application/json, text/plain, */*',
        'Accept-Language': 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7',
        'Content-Type': 'application/json',
        'Origin': baseUrl,
        'Referer': '$baseUrl/',
      };

      if (requiresAuth) {
        final token = await _getAuthToken();
        if (token != null) {
          headers['Authorization'] = 'Bearer $token';
        }
        
        // Добавляем cookies если они есть
        if (_cookies.isNotEmpty) {
          final cookieString = _cookies.entries
              .map((e) => '${e.key}=${e.value}')
              .join('; ');
          headers['Cookie'] = cookieString;
        }
      }

      final requestBody = body != null ? json.encode(body) : null;
      
      debugPrint('📤 [API] PUT $fullPath');
      debugPrint('   Headers: $headers');
      if (requestBody != null) {
        debugPrint('   Body: $requestBody');
      }

      final response = await _client.put(
        uri,
        headers: headers,
        body: requestBody,
      );

      debugPrint('📥 [API] Response status: ${response.statusCode}');
      debugPrint('   Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = response.body.trim();
        if (responseBody.isEmpty || responseBody == 'OK') {
          return {'success': true, 'data': responseBody};
        }
        final decoded = json.decode(responseBody);
        // Возвращаем как есть (может быть Map или List)
        return decoded as Map<String, dynamic>;
      } else {
        final errorBody = response.body.isNotEmpty
            ? json.decode(response.body) as Map<String, dynamic>
            : {'error': 'Request failed with status ${response.statusCode}'};
        
        // Извлекаем сообщение об ошибке из разных возможных полей
        final errorMessage = errorBody['message'] ?? 
                            errorBody['description'] ?? 
                            errorBody['error'] ?? 
                            'Unknown error';
        
        throw ApiException(
          statusCode: response.statusCode,
          message: errorMessage.toString(),
          body: errorBody,
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        statusCode: 0,
        message: 'Network error: $e',
      );
    }
  }

  // PATCH запрос
  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    try {
      // Если путь начинается с http:// или https://, используем его как полный URL
      final fullPath = path.startsWith('http://') || path.startsWith('https://')
          ? path
          : '$baseUrl$path';
      final uri = Uri.parse(fullPath);

      final headers = <String, String>{
        'Accept': 'application/json, text/plain, */*',
        'Content-Type': 'application/json',
        'Accept-Language': 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7',
        'Origin': baseUrl,
        'Referer': '$baseUrl/',
      };

      if (requiresAuth) {
        final token = await _getAuthToken();
        if (token != null) {
          headers['Authorization'] = 'Bearer $token';
        }
        
        // Добавляем CSRF токен если он есть
        if (_csrfToken != null) {
          headers['X-CSRF-Token'] = _csrfToken!;
          debugPrint('🔑 [API] Добавлен CSRF токен в заголовки: $_csrfToken');
        }
        
        // Добавляем cookies если они есть
        if (_cookies.isNotEmpty) {
          final cookieString = _cookies.entries
              .map((e) => '${e.key}=${e.value}')
              .join('; ');
          headers['Cookie'] = cookieString;
          debugPrint('🍪 [API] Добавлены cookies: ${_cookies.keys.join(", ")}');
        }
      }

      final requestBody = body != null ? json.encode(body) : null;
      
      debugPrint('📤 [API] PATCH $fullPath');
      debugPrint('   Headers: $headers');
      if (requestBody != null) {
        debugPrint('   Body: $requestBody');
      }

      final response = await _client.patch(
        uri,
        headers: headers,
        body: requestBody,
      );

      // Извлекаем CSRF токен из cookies или заголовков ответа
      _extractCsrfToken(response);

      debugPrint('📥 [API] Response status: ${response.statusCode}');
      debugPrint('   Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseBody = response.body.trim();
        if (responseBody.isEmpty || responseBody == 'OK') {
          return {'success': true};
        }
        try {
          return json.decode(responseBody);
        } catch (e) {
          return {'success': true, 'data': responseBody};
        }
      } else {
        final errorBody = response.body.isNotEmpty
            ? json.decode(response.body)
            : {'error': 'Request failed with status ${response.statusCode}'};
        debugPrint('❌ [API] PATCH Error response:');
        debugPrint('   Status: ${response.statusCode}');
        debugPrint('   Body: $errorBody');
        throw ApiException(
          statusCode: response.statusCode,
          message: errorBody['description'] ?? errorBody['error'] ?? 'Unknown error',
          body: errorBody,
        );
      }
    } catch (e) {
      if (e is ApiException) {
        debugPrint('❌ [API] PATCH ApiException: ${e.message}');
        rethrow;
      }
      debugPrint('❌ [API] PATCH Network error: $e');
      throw ApiException(
        statusCode: 0,
        message: 'Network error: $e',
      );
    }
  }

  // Получение списка категорий
  Future<List<dynamic>> getCategories() async {
    try {
      final response = await get('/api/v1/categories', requiresAuth: false);
      
      // Если ответ - список, возвращаем его
      if (response is List) {
        return response;
      }
      
      // Если ответ - объект с данными
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) {
          return data;
        }
      }
      
      return [];
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      rethrow;
    }
  }

  // Получение списка продуктов/услуг
  Future<Map<String, dynamic>> getProducts({
    int? categoryId,
    int page = 1,
    int limit = 12,
    String city = 'Алматы',
    String sortBy = 'created_at',
    String sortOrder = 'desc',
  }) async {
    try {
      final queryParameters = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        'city': city,
        'sort_by': sortBy,
        'sort_order': sortOrder,
      };
      
      // Добавляем category_id только если он указан
      if (categoryId != null) {
        queryParameters['category_id'] = categoryId.toString();
      }

      final response = await get(
        '/api/v1/products',
        queryParameters: queryParameters,
        requiresAuth: false,
      );

      // Если ответ - объект, возвращаем его
      if (response is Map<String, dynamic>) {
        return response;
      }

      return {
        'items': [],
        'total_count': 0,
        'page': page,
        'total_pages': 0,
        'limit': limit,
      };
    } catch (e) {
      debugPrint('Error fetching products: $e');
      rethrow;
    }
  }

  // Получение корзины
  Future<List<dynamic>> getCart() async {
    try {
      final response = await get('/api/v1/cart', requiresAuth: true);
      
      // Если ответ - список, возвращаем его
      if (response is List) {
        return response;
      }
      
      // Если ответ - объект с данными
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) {
          return data;
        }
      }
      
      return [];
    } catch (e) {
      debugPrint('Error fetching cart: $e');
      rethrow;
    }
  }

  // Получение текущего пользователя
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await get('/api/v2/user/current', requiresAuth: true);
      
      // Если ответ - объект, возвращаем его
      if (response is Map<String, dynamic>) {
        return response;
      }
      
      return {};
    } catch (e) {
      debugPrint('Error fetching current user: $e');
      rethrow;
    }
  }

  // Получение заказов пользователя
  Future<Map<String, dynamic>> getOrders({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await get(
        '/api/v1/orders',
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
        requiresAuth: true,
      );
      
      // Если ответ - объект, возвращаем его
      if (response is Map<String, dynamic>) {
        return response;
      }
      
      return {
        'items': [],
        'total_count': 0,
        'page': page,
        'total_pages': 0,
        'limit': limit,
      };
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      rethrow;
    }
  }

  // Поиск данных покойного по ИИН
  Future<Map<String, dynamic>> searchDeceasedByIin(String iin) async {
    try {
      final response = await get(
        '/rip-fcb/v1/deceased',
        queryParameters: {
          'iin': iin,
        },
        requiresAuth: true,
      );
      
      // Если ответ - объект, возвращаем его
      if (response is Map<String, dynamic>) {
        return response;
      }
      
      return {};
    } catch (e) {
      debugPrint('Error searching deceased by IIN: $e');
      rethrow;
    }
  }

  // Создание запроса на бронирование места
  Future<Map<String, dynamic>> createBurialRequest({
    required int cemeteryId,
    required String fullName,
    required String inn,
    required int graveId,
    String? deathCertUrl,
  }) async {
    try {
      final response = await post(
        '/api/v8/burial-requests',
        body: {
          'cemetery_id': cemeteryId,
          'full_name': fullName,
          'inn': inn,
          'grave_id': graveId,
          'death_cert_url': deathCertUrl ?? '',
        },
        requiresAuth: true,
      );
      
      // Если ответ - объект, возвращаем его
      if (response is Map<String, dynamic>) {
        return response;
      }
      
      return {};
    } catch (e) {
      debugPrint('Error creating burial request: $e');
      rethrow;
    }
  }

  // Получение заявок на захоронение пользователя
  Future<Map<String, dynamic>> getBurialRequests({
    required String userPhone,
  }) async {
    try {
      final response = await get(
        '/api/v8/burial-requests/my',
        queryParameters: {
          'user_phone': userPhone,
        },
        requiresAuth: true,
      );
      
      // Если ответ - объект, возвращаем его
      if (response is Map<String, dynamic>) {
        return response;
      }
      
      return {};
    } catch (e) {
      debugPrint('Error fetching burial requests: $e');
      rethrow;
    }
  }

  // Получение заявки на захоронение по ID
  Future<Map<String, dynamic>> getBurialRequestById(int id) async {
    try {
      final response = await get(
        '/api/v8/burial-requests/$id',
        requiresAuth: true,
      );
      
      // Если ответ - объект, возвращаем его
      if (response is Map<String, dynamic>) {
        return response;
      }
      
      return {};
    } catch (e) {
      debugPrint('Error fetching burial request by ID: $e');
      rethrow;
    }
  }

  // Обработка платежа картой
  Future<Map<String, dynamic>> processCardPayment({
    required int amount,
    required String cardNumber,
    required String cvc,
    required String email,
    required String expDate,
    String currency = 'KZT',
    String terminalType = 'shop',
  }) async {
    try {
      final response = await post(
        '/api/v1/payments/card',
        body: {
          'amount': amount,
          'cardNumber': cardNumber,
          'currency': currency,
          'cvc': cvc,
          'email': email,
          'expDate': expDate,
          'terminalType': terminalType,
        },
        requiresAuth: true,
      );
      
      // Если ответ - объект, возвращаем его
      if (response is Map<String, dynamic>) {
        return response;
      }
      
      return {};
    } catch (e) {
      debugPrint('Error processing card payment: $e');
      rethrow;
    }
  }

  // Подтверждение оплаты заказа
  Future<Map<String, dynamic>> confirmOrderPayment({
    required int orderId,
    required String transactionId,
  }) async {
    try {
      final response = await post(
        '/api/v1/orders/$orderId/confirm-payment',
        body: {
          'transaction_id': transactionId,
        },
        requiresAuth: true,
      );
      
      // Если ответ - объект, возвращаем его
      if (response is Map<String, dynamic>) {
        return response;
      }
      
      return {};
    } catch (e) {
      debugPrint('Error confirming order payment: $e');
      rethrow;
    }
  }

  // Подтверждение оплаты заявки на захоронение
  Future<Map<String, dynamic>> confirmBurialPayment({
    required int burialRequestId,
    required String transactionId,
  }) async {
    try {
      final response = await post(
        '/api/v8/burial-requests/$burialRequestId/confirm-payment',
        body: {
          'transaction_id': transactionId,
        },
        requiresAuth: true,
      );
      
      // Если ответ - объект, возвращаем его
      if (response is Map<String, dynamic>) {
        return response;
      }
      
      return {};
    } catch (e) {
      debugPrint('Error confirming burial payment: $e');
      rethrow;
    }
  }

  // Создание инвойса для оплаты
  Future<Map<String, dynamic>> createInvoice({
    required int orderId,
    required int amount,
    String currency = 'KZT',
    String? description,
  }) async {
    try {
      final response = await post(
        '/api/v1/payments/create-invoice',
        body: {
          'amount': amount,
          'currency': currency,
          'description': description ?? 'Оплата заказа #$orderId',
          'metadata': {
            'order_id': orderId,
            'service': 'supplier',
          },
        },
        requiresAuth: true,
      );
      
      // Если ответ - объект, возвращаем его
      if (response is Map<String, dynamic>) {
        return response;
      }
      
      return {};
    } catch (e) {
      debugPrint('Error creating invoice: $e');
      rethrow;
    }
  }

  // Генерация токена для оплаты
  Future<Map<String, dynamic>> generatePaymentToken({
    required int amount,
    required String invoiceId,
    String terminalType = 'shop',
  }) async {
    try {
      final response = await post(
        '/api/v1/payments/generate-token',
        body: {
          'amount': amount,
          'invoiceID': invoiceId,
          'terminalType': terminalType,
        },
        requiresAuth: true,
      );
      
      // Если ответ - объект, возвращаем его
      if (response is Map<String, dynamic>) {
        return response;
      }
      
      return {};
    } catch (e) {
      debugPrint('Error generating payment token: $e');
      rethrow;
    }
  }

  // Получение уведомлений
  Future<Map<String, dynamic>> getNotifications({
    int limit = 10,
    int offset = 0,
    String? serviceName,
  }) async {
    try {
      final queryParams = <String, String>{
        'channel': 'push',
        'limit': limit.toString(),
        'offset': offset.toString(),
      };
      
      if (serviceName != null && serviceName.isNotEmpty && serviceName != 'Все') {
        queryParams['service_name'] = serviceName;
      }

      final response = await get(
        '/api/v10/my/notifications',
        queryParameters: queryParams,
        requiresAuth: true,
      );

      if (response is Map<String, dynamic>) {
        return response;
      }

      return {};
    } catch (e) {
      debugPrint('Error getting notifications: $e');
      rethrow;
    }
  }

  // Пометка всех уведомлений как прочитанных
  Future<void> markAllNotificationsAsRead() async {
    try {
      await post(
        '/api/v1/notifications/mark-all-read',
        body: {},
        requiresAuth: true,
      );
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
      rethrow;
    }
  }

  // Пометка уведомления как прочитанного
  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      await post(
        '/api/v1/notifications/$notificationId/mark-read',
        body: {},
        requiresAuth: true,
      );
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      rethrow;
    }
  }

  // Создание обращения в акимат
  Future<Map<String, dynamic>> createAkimatAppeal({
    required String userPhone,
    required int typeId,
    required String content,
    required int akimatId,
  }) async {
    try {
      final response = await post(
        '/api/v3/rip-government/v1/appeal',
        body: {
          'userPhone': userPhone,
          'typeId': typeId,
          'content': content,
          'akimatId': akimatId,
        },
        requiresAuth: true,
      );
      
      return response;
    } catch (e) {
      debugPrint('Error creating akimat appeal: $e');
      rethrow;
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic>? body;

  ApiException({
    required this.statusCode,
    required this.message,
    this.body,
  });

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}
