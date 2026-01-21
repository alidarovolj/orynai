import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'constants.dart';
import 'widgets/header.dart';
import 'widgets/service_card.dart';
import 'widgets/step_card.dart';
import 'widgets/info_block.dart';
import 'widgets/contacts_block.dart';
import 'widgets/app_button.dart';
import 'widgets/login_modal.dart';
import 'services/auth_state_manager.dart';
import 'services/api_service.dart';
import 'pages/cemeteries_page.dart';
import 'pages/catalog_page.dart';
import 'pages/about_page.dart';

void main() async {
  final appStartTime = DateTime.now();
  print('═══════════════════════════════════════════════════');
  print('🚀 [${_getTimestamp()}] APP START');
  print('═══════════════════════════════════════════════════');

  final bindingStart = DateTime.now();
  WidgetsFlutterBinding.ensureInitialized();
  print(
    '✅ [${_getTimestamp()}] WidgetsFlutterBinding: ${DateTime.now().difference(bindingStart).inMilliseconds}ms',
  );

  // Только критически важные инициализации - запускаем UI быстро
  try {
    final localizationStart = DateTime.now();
    print('⏳ [${_getTimestamp()}] Starting EasyLocalization...');
    await EasyLocalization.ensureInitialized();
    final locTime = DateTime.now().difference(localizationStart).inMilliseconds;
    print(
      '✅ [${_getTimestamp()}] EasyLocalization: ${locTime}ms ${locTime > 1000 ? "⚠️ SLOW!" : ""}',
    );
  } catch (e) {
    print('❌ [${_getTimestamp()}] Error initializing EasyLocalization: $e');
  }

  // Загрузка .env файла
  try {
    final envStart = DateTime.now();
    print('⏳ [${_getTimestamp()}] Loading .env...');
    await dotenv.load();
    final envTime = DateTime.now().difference(envStart).inMilliseconds;
    print('✅ [${_getTimestamp()}] .env loaded: ${envTime}ms');
  } catch (e) {
    print('⚠️  [${_getTimestamp()}] .env not found, using defaults');
    dotenv.env['API_URL'] = 'https://stage.ripservice.kz';
  }

  final totalInitTime = DateTime.now().difference(appStartTime).inMilliseconds;
  print('═══════════════════════════════════════════════════');
  print('🎯 [${_getTimestamp()}] MAIN INIT COMPLETE: ${totalInitTime}ms');
  print('═══════════════════════════════════════════════════');

  // Запускаем приложение сразу
  final runAppStart = DateTime.now();
  print('⏳ [${_getTimestamp()}] Running app...');

  // Отключаем debug логи EasyLocalization для ускорения
  EasyLocalization.logger.enableLevels = [];

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('kk'), Locale('ru')],
      path: 'assets/translations',
      fallbackLocale: const Locale('kk'),
      startLocale: const Locale('kk'),
      useOnlyLangCode: true,
      assetLoader:
          const RootBundleAssetLoader(), // Используем встроенный загрузчик
      child: const MyApp(),
    ),
  );
  print(
    '✅ [${_getTimestamp()}] runApp called: ${DateTime.now().difference(runAppStart).inMilliseconds}ms',
  );

  // Инициализируем тяжелые сервисы асинхронно в фоне после запуска UI
  _initializeServicesInBackground();
}

String _getTimestamp() {
  final now = DateTime.now();
  return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}.${now.millisecond.toString().padLeft(3, '0')}';
}

// Асинхронная инициализация тяжелых сервисов
Future<void> _initializeServicesInBackground() async {
  print('═══════════════════════════════════════════════════');
  print('🔄 [${_getTimestamp()}] BACKGROUND SERVICES INIT START');
  print('═══════════════════════════════════════════════════');

  // Инициализация API сервиса
  try {
    final apiStart = DateTime.now();
    print('⏳ [${_getTimestamp()}] Initializing API service...');
    await ApiService().initialize();
    final apiTime = DateTime.now().difference(apiStart).inMilliseconds;
    print(
      '✅ [${_getTimestamp()}] API service: ${apiTime}ms ${apiTime > 1000 ? "⚠️ SLOW!" : ""}',
    );
  } catch (e) {
    print('❌ [${_getTimestamp()}] Error initializing API service: $e');
  }

  // Инициализация авторизации
  try {
    final authStart = DateTime.now();
    print('⏳ [${_getTimestamp()}] Initializing AuthStateManager...');
    await AuthStateManager().initialize();
    final authTime = DateTime.now().difference(authStart).inMilliseconds;
    print(
      '✅ [${_getTimestamp()}] AuthStateManager: ${authTime}ms ${authTime > 1000 ? "⚠️ SLOW!" : ""}',
    );
  } catch (e) {
    print('❌ [${_getTimestamp()}] Error initializing AuthStateManager: $e');
  }

  print('═══════════════════════════════════════════════════');
  print('✅ [${_getTimestamp()}] BACKGROUND SERVICES COMPLETE');
  print('═══════════════════════════════════════════════════');
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() {
    print('🔨 [${_getTimestamp()}] MyApp createState');
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    print('🔧 [${_getTimestamp()}] MyApp initState');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('🔄 [${_getTimestamp()}] MyApp didChangeDependencies');
  }

  @override
  Widget build(BuildContext context) {
    print('🏗️  [${_getTimestamp()}] MyApp build started');
    return MaterialApp(
      title: 'Orynai',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.buttonBackground,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
        fontFamily: 'Manrope',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Manrope'),
          displayMedium: TextStyle(fontFamily: 'Manrope'),
          displaySmall: TextStyle(fontFamily: 'Manrope'),
          headlineLarge: TextStyle(fontFamily: 'Manrope'),
          headlineMedium: TextStyle(fontFamily: 'Manrope'),
          headlineSmall: TextStyle(fontFamily: 'Manrope'),
          titleLarge: TextStyle(fontFamily: 'Manrope'),
          titleMedium: TextStyle(fontFamily: 'Manrope'),
          titleSmall: TextStyle(fontFamily: 'Manrope'),
          bodyLarge: TextStyle(fontFamily: 'Manrope'),
          bodyMedium: TextStyle(fontFamily: 'Manrope'),
          bodySmall: TextStyle(fontFamily: 'Manrope'),
          labelLarge: TextStyle(fontFamily: 'Manrope'),
          labelMedium: TextStyle(fontFamily: 'Manrope'),
          labelSmall: TextStyle(fontFamily: 'Manrope'),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isScrolled = false;
  final ScrollController _scrollController = ScrollController();
  String? _openTooltipId; // ID открытой подсказки

  @override
  void initState() {
    super.initState();
    print('═══════════════════════════════════════════════════');
    print('🏠 [${_getTimestamp()}] HomePage initState');
    print('═══════════════════════════════════════════════════');
    _scrollController.addListener(_onScroll);
    // Устанавливаем черный статус-бар для белого фона
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    // Восстанавливаем стандартный стиль статус-бара
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    super.dispose();
  }

  void _onScroll() {
    final bool isScrolled = _scrollController.offset > 50;
    if (isScrolled != _isScrolled) {
      setState(() {
        _isScrolled = isScrolled;
      });
      // Статус-бар всегда черный для белого фона
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    }
  }

  Future<void> _openPhone() async {
    final Uri phoneUrl = Uri.parse('tel:+77758100110');
    try {
      if (await canLaunchUrl(phoneUrl)) {
        await launchUrl(phoneUrl);
      }
    } catch (e) {
      // Обработка ошибки
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('errors.phoneNotAvailable'.tr())),
        );
      }
    }
  }

  Future<void> _openWhatsApp() async {
    final Uri whatsappUrl = Uri.parse(
      'https://api.whatsapp.com/send/?phone=77758100110&text&type=phone_number&app_absent=0',
    );
    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        // Если не удалось открыть, пробуем альтернативный способ
        final Uri fallbackUrl = Uri.parse('https://wa.me/77758100110');
        if (await canLaunchUrl(fallbackUrl)) {
          await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      // Обработка ошибки
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('errors.whatsappNotAvailable'.tr())),
        );
      }
    }
  }

  Future<void> _openInstagram() async {
    final Uri instagramUrl = Uri.parse(
      'https://www.instagram.com/ripservice.kz/',
    );
    try {
      if (await canLaunchUrl(instagramUrl)) {
        await launchUrl(instagramUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Обработка ошибки
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('errors.linkNotAvailable'.tr())));
      }
    }
  }

  Future<void> _openFacebook() async {
    final Uri facebookUrl = Uri.parse(
      'https://www.facebook.com/Orynai.kz/?rdid=fJcYNJaX2yFSqTvr',
    );
    try {
      if (await canLaunchUrl(facebookUrl)) {
        await launchUrl(facebookUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Обработка ошибки
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('errors.linkNotAvailable'.tr())));
      }
    }
  }

  Future<void> _openEmail() async {
    final Uri emailUrl = Uri.parse('mailto:info@orynai.kz');
    try {
      if (await canLaunchUrl(emailUrl)) {
        await launchUrl(emailUrl);
      }
    } catch (e) {
      // Обработка ошибки
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('errors.emailNotAvailable'.tr())),
        );
      }
    }
  }

  Future<void> _open2GIS() async {
    final Uri gisUrl = Uri.parse(
      'https://2gis.kz/almaty/firm/9429940000792308?m=76.915711%2C43.237625%2F16',
    );
    try {
      if (await canLaunchUrl(gisUrl)) {
        await launchUrl(gisUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Обработка ошибки
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('errors.linkNotAvailable'.tr())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 [${_getTimestamp()}] HomePage build started');
    final buildStart = DateTime.now();
    final scaffold = Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Верхняя SafeArea белого цвета
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              height: MediaQuery.of(context).padding.top,
            ),
          ),
          // Основной контент
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Заголовок с иконками
                AppHeader(
                  isScrolled: _isScrolled,
                  onProfileTap: () {
                    final authManager = AuthStateManager();
                    if (!authManager.isAuthenticated) {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (context) => const LoginModal(),
                      ).then((result) {
                        if (result != null) {
                          setState(() {
                            // Обновляем UI после авторизации
                          });
                        }
                      });
                    }
                  },
                ),
                // Основной контент с прокруткой
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      children: [
                        // Первый блок - логотип и текст
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.paddingMedium,
                            ),
                            child: Stack(
                              children: [
                                // Карта Казахстана как фон
                                Positioned.fill(
                                  child: Center(
                                    child: Opacity(
                                      opacity: 0.3,
                                      child: Image.asset(
                                        'assets/images/white_map.png',
                                        fit: BoxFit.contain,
                                        cacheWidth:
                                            400, // Уменьшаем разрешение для фона
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container();
                                            },
                                      ),
                                    ),
                                  ),
                                ),
                                // Контент поверх карты
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Логотип Orynai
                                    SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width *
                                          2 /
                                          3,
                                      child: Image.asset(
                                        'assets/images/logos/main.png',
                                        height: AppSizes.mainLogoHeight,
                                        fit: BoxFit.contain,
                                        cacheHeight:
                                            200, // Кэширование с оптимальным размером
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                height: AppSizes.mainLogoHeight,
                                              );
                                            },
                                      ),
                                    ),
                                    // Описательный текст
                                    Text(
                                      'app.subtitle'.tr(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.iconAndText,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    // Кнопки
                                    Column(
                                      children: [
                                        // Первая кнопка - "Маманға қоңырау шалу"
                                        AppButton(
                                          text: 'buttons.callSpecialist'.tr(),
                                          onPressed: _openWhatsApp,
                                          backgroundColor:
                                              AppColors.buttonBackground,
                                        ),
                                        const SizedBox(
                                          height: AppSizes.paddingMedium,
                                        ),
                                        // Вторая кнопка - "Жерлеуді ұйымдастыру"
                                        AppButton(
                                          text: 'buttons.organizeFuneral'.tr(),
                                          onPressed: () {
                                            // TODO: Реализовать организацию похорон
                                          },
                                          isOutlined: true,
                                          foregroundColor: AppColors.border,
                                          borderColor: AppColors.border,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 0),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Блок с карточками услуг
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingMedium,
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: AppSizes.paddingLarge),
                              ServiceCard(
                                iconPath: 'assets/icons/benefits/1.svg',
                                title: 'services.placeBooking.title'.tr(),
                                description: 'services.placeBooking.description'
                                    .tr(),
                                buttonText: 'buttons.go'.tr(),
                                tooltipKey: 'placeBooking',
                                tooltipText: 'services.placeBooking.tooltip'
                                    .tr(),
                                openTooltipId: _openTooltipId,
                                onInfoTap: () {
                                  setState(() {
                                    if (_openTooltipId == 'placeBooking') {
                                      _openTooltipId = null;
                                    } else {
                                      _openTooltipId = 'placeBooking';
                                    }
                                  });
                                },
                                onButtonPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CemeteriesPage(),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: AppSizes.paddingMedium),
                              ServiceCard(
                                iconPath: 'assets/icons/benefits/2.svg',
                                title: 'services.memorial.title'.tr(),
                                description: 'services.memorial.description'
                                    .tr(),
                                buttonText: 'buttons.go'.tr(),
                                showInfoText: true,
                                tooltipKey: 'memorial',
                                tooltipText: 'services.memorial.tooltip'.tr(),
                                openTooltipId: _openTooltipId,
                                onInfoTap: () {
                                  setState(() {
                                    if (_openTooltipId == 'memorial') {
                                      _openTooltipId = null;
                                    } else {
                                      _openTooltipId = 'memorial';
                                    }
                                  });
                                },
                              ),
                              const SizedBox(height: AppSizes.paddingMedium),
                              ServiceCard(
                                iconPath: 'assets/icons/benefits/3.svg',
                                title: 'services.goodsAndServices.title'.tr(),
                                description:
                                    'services.goodsAndServices.description'
                                        .tr(),
                                buttonText: 'buttons.go'.tr(),
                                tooltipKey: 'goodsAndServices',
                                tooltipText: 'services.goodsAndServices.tooltip'
                                    .tr(),
                                openTooltipId: _openTooltipId,
                                onInfoTap: () {
                                  setState(() {
                                    if (_openTooltipId == 'goodsAndServices') {
                                      _openTooltipId = null;
                                    } else {
                                      _openTooltipId = 'goodsAndServices';
                                    }
                                  });
                                },
                                onButtonPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const CatalogPage(),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: AppSizes.paddingMedium),
                              ServiceCard(
                                iconPath: 'assets/icons/benefits/4.svg',
                                title: 'services.findBurial.title'.tr(),
                                description: 'services.findBurial.description'
                                    .tr(),
                                buttonText: 'buttons.search'.tr(),
                                showInfoText: true,
                                tooltipKey: 'findBurial',
                                tooltipText: 'services.findBurial.tooltip'.tr(),
                                openTooltipId: _openTooltipId,
                                onInfoTap: () {
                                  setState(() {
                                    if (_openTooltipId == 'findBurial') {
                                      _openTooltipId = null;
                                    } else {
                                      _openTooltipId = 'findBurial';
                                    }
                                  });
                                },
                              ),
                              const SizedBox(height: AppSizes.paddingXLarge),
                            ],
                          ),
                        ),
                        // Блок с пошаговой инструкцией
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingMedium,
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: AppSizes.paddingXLarge),
                              // Заголовок
                              Text(
                                'steps.title'.tr(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.iconAndText,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 32),
                              // Карточки с шагами
                              StepCard(
                                title: 'steps.step1.title'.tr(),
                                paragraphs: [
                                  'steps.step1.paragraph1'.tr(),
                                  'steps.step1.paragraph2'.tr(),
                                ],
                                buttonText: 'buttons.support'.tr(),
                                buttonColor: AppColors.buttonBackground,
                                buttonIcon: Icons.phone,
                                isPhoneIcon: true,
                                onPhoneTap: _openPhone,
                              ),
                              const SizedBox(height: AppSizes.paddingMedium),
                              StepCard(
                                title: 'steps.step2.title'.tr(),
                                paragraphs: [
                                  'steps.step2.paragraph1'.tr(),
                                  'steps.step2.paragraph2'.tr(),
                                ],
                                buttonText: 'buttons.freeConsultation'.tr(),
                                buttonColor: AppColors.buttonBackground,
                                buttonIcon: Icons.phone,
                                isPhoneIcon: true,
                                onPhoneTap: _openPhone,
                              ),
                              const SizedBox(height: AppSizes.paddingMedium),
                              StepCard(
                                title: 'steps.step3.title'.tr(),
                                paragraphs: [
                                  'steps.step3.paragraph1'.tr(),
                                  'steps.step3.paragraph2'.tr(),
                                ],
                                buttonText: 'buttons.callSpecialist2'.tr(),
                                buttonColor: AppColors.buttonGreen,
                                buttonIcon: Icons.chat,
                                isWhatsApp: true,
                                onWhatsAppTap: _openWhatsApp,
                              ),
                              const SizedBox(height: AppSizes.paddingMedium),
                              StepCard(
                                title: 'steps.step4.title'.tr(),
                                paragraphs: [
                                  'steps.step4.paragraph1'.tr(),
                                  'steps.step4.paragraph2'.tr(),
                                ],
                                buttonText: 'buttons.order'.tr(),
                                buttonColor: AppColors.buttonBackground,
                                buttonIcon: Icons.phone,
                                isPhoneIcon: true,
                                hasSecondButton: true,
                                secondButtonText: 'buttons.order'.tr(),
                                secondButtonColor: AppColors.buttonGreen,
                                secondButtonIcon: Icons.chat,
                                isSecondButtonWhatsApp: true,
                                buttonsInRow: true,
                                onPhoneTap: _openPhone,
                                onWhatsAppTap: _openWhatsApp,
                              ),
                              const SizedBox(height: AppSizes.paddingMedium),
                              StepCard(
                                title: 'steps.step5.title'.tr(),
                                paragraphs: [
                                  'steps.step5.paragraph1'.tr(),
                                  'steps.step5.paragraph2'.tr(),
                                ],
                                buttonText: 'buttons.helpWithDocuments'.tr(),
                                buttonColor: AppColors.buttonGreen,
                                buttonIcon: Icons.chat,
                                isWhatsApp: true,
                                onWhatsAppTap: _openWhatsApp,
                              ),
                              const SizedBox(height: AppSizes.paddingMedium),
                              StepCard(
                                title: 'steps.step6.title'.tr(),
                                paragraphs: [
                                  'steps.step6.paragraph1'.tr(),
                                  'steps.step6.paragraph2'.tr(),
                                ],
                                buttonText: 'buttons.orderCare'.tr(),
                                buttonColor: AppColors.buttonGreen,
                                buttonIcon: Icons.chat,
                                isWhatsApp: true,
                                onWhatsAppTap: _openWhatsApp,
                              ),
                              const SizedBox(height: AppSizes.paddingXLarge),
                            ],
                          ),
                        ),
                        // Информационный блок
                        Column(
                          children: [
                            const SizedBox(height: AppSizes.paddingXLarge),
                            Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                              ),
                              child: Column(
                                children: [
                                  // Заголовок
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: AppSizes.paddingLarge,
                                      left: AppSizes.paddingMedium,
                                      right: AppSizes.paddingMedium,
                                    ),
                                    child: Text(
                                      'info.prepareTitle'.tr(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.iconAndText,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: AppSizes.paddingMedium,
                                  ),
                                  // Текст
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSizes.paddingMedium,
                                    ),
                                    child: Text(
                                      'info.prepareText'.tr(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.iconAndText,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: AppSizes.paddingLarge),
                                  // Кнопка
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      AppSizes.paddingMedium,
                                      0,
                                      AppSizes.paddingMedium,
                                      AppSizes.paddingLarge,
                                    ),
                                    child: AppButton(
                                      text: 'buttons.freeConsultation'.tr(),
                                      onPressed: _openWhatsApp,
                                      backgroundColor:
                                          AppColors.buttonBackground,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSizes.paddingXLarge),
                          ],
                        ),
                        // Блоки полезной информации
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingMedium,
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: AppSizes.paddingXLarge),
                              // Заголовок "Полезная информация"
                              Text(
                                'info.usefulInfo'.tr(),
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.iconAndText,
                                ),
                              ),
                              const SizedBox(height: AppSizes.paddingLarge),
                              // Первый блок - Стоимость похорон
                              InfoBlock(
                                backgroundImage: 'assets/images/block1.png',
                                title: 'infoBlocks.funeralCost.title'.tr(),
                                description:
                                    'infoBlocks.funeralCost.description'.tr(),
                                buttonText: 'infoBlocks.funeralCost.button'
                                    .tr(),
                                onButtonPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const CatalogPage(),
                                    ),
                                  );
                                },
                                tooltipKey: 'funeralCost',
                                tooltipText: 'infoBlocks.funeralCost.tooltip'
                                    .tr(),
                                openTooltipId: _openTooltipId,
                                onInfoTap: () {
                                  setState(() {
                                    if (_openTooltipId == 'funeralCost') {
                                      _openTooltipId = null;
                                    } else {
                                      _openTooltipId = 'funeralCost';
                                    }
                                  });
                                },
                              ),
                              const SizedBox(height: AppSizes.paddingMedium),
                              // Второй блок - Обращение в акимат
                              InfoBlock(
                                backgroundImage: 'assets/images/block2.png',
                                title: 'infoBlocks.akimatAppeal.title'.tr(),
                                description:
                                    'infoBlocks.akimatAppeal.description'.tr(),
                                buttonText: 'infoBlocks.akimatAppeal.button'
                                    .tr(),
                                onButtonPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const CatalogPage(),
                                    ),
                                  );
                                },
                                tooltipKey: 'akimatAppeal',
                                tooltipText: 'infoBlocks.akimatAppeal.tooltip'
                                    .tr(),
                                openTooltipId: _openTooltipId,
                                onInfoTap: () {
                                  setState(() {
                                    if (_openTooltipId == 'akimatAppeal') {
                                      _openTooltipId = null;
                                    } else {
                                      _openTooltipId = 'akimatAppeal';
                                    }
                                  });
                                },
                              ),
                              const SizedBox(height: AppSizes.paddingXLarge),
                            ],
                          ),
                        ),
                        // Блок контактов
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingMedium,
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: AppSizes.paddingXLarge),
                              ContactsBlock(
                                onLocationTap: _open2GIS,
                                onPhoneTap: _openPhone,
                                onEmailTap: _openEmail,
                                onInstagramTap: _openInstagram,
                                onFacebookTap: _openFacebook,
                              ),
                              const SizedBox(height: AppSizes.paddingXLarge),
                            ],
                          ),
                        ),
                        // Футер
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSizes.paddingXLarge),
                          color: AppColors.headerScrolled,
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Навигационные ссылки
                                  _buildFooterLink(
                                    text: 'footer.aboutUs'.tr(),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const AboutPage(),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: AppSizes.paddingSmall),
                                  _buildFooterLink(
                                    text: 'footer.articles'.tr(),
                                    onTap: () {
                                      // TODO: Навигация на "Статьи"
                                    },
                                  ),
                                  const SizedBox(height: AppSizes.paddingSmall),
                                  _buildFooterLink(
                                    text: 'footer.cemeteries'.tr(),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const CemeteriesPage(),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(
                                    height: AppSizes.paddingMedium,
                                  ),
                                  // Ссылки на услуги/политику
                                  _buildFooterLink(
                                    text: 'footer.help'.tr(),
                                    onTap: () {
                                      // TODO: Навигация на "Помощь"
                                    },
                                  ),
                                  const SizedBox(height: AppSizes.paddingSmall),
                                  _buildFooterLink(
                                    text: 'footer.goodsAndServices'.tr(),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const CatalogPage(),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: AppSizes.paddingSmall),
                                  _buildFooterLink(
                                    text: 'footer.privacyPolicy'.tr(),
                                    onTap: () {
                                      // TODO: Навигация на "Политика конфиденциальности"
                                    },
                                  ),
                                  const SizedBox(
                                    height: AppSizes.paddingMedium,
                                  ),
                                  // Контактная информация
                                  Text(
                                    'footer.city'.tr(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: AppSizes.paddingSmall),
                                  Text(
                                    'contacts.phone'.tr(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: AppSizes.paddingSmall),
                                  GestureDetector(
                                    onTap: () {
                                      // TODO: Открыть email
                                    },
                                    child: Text(
                                      'contacts.email'.tr(),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: AppSizes.paddingMedium,
                                  ),
                                  // Социальные сети
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1.5,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Center(
                                            child: Container(
                                              width: 12,
                                              height: 12,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 1.5,
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Container(
                                                  width: 3,
                                                  height: 3,
                                                  decoration:
                                                      const BoxDecoration(
                                                        color: Colors.white,
                                                        shape: BoxShape.circle,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          // TODO: Открыть Instagram
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.facebook,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          // TODO: Открыть Facebook
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              // Кнопка чата в правом нижнем углу
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: FloatingActionButton(
                                  onPressed: () {
                                    // TODO: Открыть чат
                                  },
                                  backgroundColor: AppColors.headerScrolled,
                                  child: const Icon(
                                    Icons.chat_bubble_outline,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    print(
      '✅ [${_getTimestamp()}] HomePage build complete: ${DateTime.now().difference(buildStart).inMilliseconds}ms',
    );
    return scaffold;
  }


  Widget _buildFooterLink({required String text, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, color: Colors.white),
      ),
    );
  }
}
