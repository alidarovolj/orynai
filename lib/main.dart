import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('kk'), Locale('ru')],
      path: 'assets/translations',
      fallbackLocale: const Locale('kk'),
      startLocale: const Locale('kk'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final bool isScrolled = _scrollController.offset > 50;
    if (isScrolled != _isScrolled) {
      setState(() {
        _isScrolled = isScrolled;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final headerColor = _isScrolled
        ? AppColors.headerScrolled
        : Colors.transparent;
    final iconColor = _isScrolled ? Colors.white : AppColors.iconAndText;
    final safeAreaColor = _isScrolled
        ? AppColors.headerScrolled
        : AppColors.background;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Верхняя SafeArea с изменяющимся цветом
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              color: safeAreaColor,
              height: MediaQuery.of(context).padding.top,
            ),
          ),
          // Основной контент
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Заголовок с иконками
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  color: headerColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingMedium,
                    vertical: 12.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Логотип в левом верхнем углу
                      SvgPicture.asset(
                        'assets/images/logos/logo.svg',
                        width: AppSizes.headerLogoSize,
                        height: AppSizes.headerLogoSize,
                        colorFilter: ColorFilter.mode(
                          iconColor,
                          BlendMode.srcIn,
                        ),
                      ),
                      // Иконки справа
                      Row(
                        children: [
                          IconButton(
                            icon: SvgPicture.asset(
                              'assets/icons/phone.svg',
                              width: 24,
                              height: 24,
                              colorFilter: ColorFilter.mode(
                                iconColor,
                                BlendMode.srcIn,
                              ),
                            ),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: SvgPicture.asset(
                              'assets/icons/whatsapp.svg',
                              width: 24,
                              height: 24,
                              colorFilter: ColorFilter.mode(
                                iconColor,
                                BlendMode.srcIn,
                              ),
                            ),
                            onPressed: () {},
                          ),
                          Builder(
                            builder: (context) => IconButton(
                              icon: SvgPicture.asset(
                                'assets/icons/menu.svg',
                                width: 24,
                                height: 24,
                                colorFilter: ColorFilter.mode(
                                  iconColor,
                                  BlendMode.srcIn,
                                ),
                              ),
                              onPressed: () {
                                _showMenuModal(context);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
                                        _buildAppButton(
                                          text: 'buttons.callSpecialist'.tr(),
                                          onPressed: () {
                                            // TODO: Реализовать звонок специалисту
                                          },
                                          backgroundColor:
                                              AppColors.buttonBackground,
                                        ),
                                        const SizedBox(
                                          height: AppSizes.paddingMedium,
                                        ),
                                        // Вторая кнопка - "Жерлеуді ұйымдастыру"
                                        _buildAppButton(
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
                              _buildServiceCard(
                                iconPath: 'assets/icons/benefits/1.svg',
                                title: 'services.placeBooking.title'.tr(),
                                description: 'services.placeBooking.description'
                                    .tr(),
                                buttonText: 'buttons.go'.tr(),
                              ),
                              const SizedBox(height: AppSizes.paddingMedium),
                              _buildServiceCard(
                                iconPath: 'assets/icons/benefits/2.svg',
                                title: 'services.memorial.title'.tr(),
                                description: 'services.memorial.description'
                                    .tr(),
                                buttonText: 'buttons.go'.tr(),
                                showInfoText: true,
                              ),
                              const SizedBox(height: AppSizes.paddingMedium),
                              _buildServiceCard(
                                iconPath: 'assets/icons/benefits/3.svg',
                                title: 'services.goodsAndServices.title'.tr(),
                                description:
                                    'services.goodsAndServices.description'
                                        .tr(),
                                buttonText: 'buttons.go'.tr(),
                              ),
                              const SizedBox(height: AppSizes.paddingMedium),
                              _buildServiceCard(
                                iconPath: 'assets/icons/benefits/4.svg',
                                title: 'services.findBurial.title'.tr(),
                                description: 'services.findBurial.description'
                                    .tr(),
                                buttonText: 'buttons.search'.tr(),
                                showInfoText: true,
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
                              _buildStepCard(
                                title: 'steps.step1.title'.tr(),
                                paragraphs: [
                                  'steps.step1.paragraph1'.tr(),
                                  'steps.step1.paragraph2'.tr(),
                                ],
                                buttonText: 'buttons.support'.tr(),
                                buttonColor: AppColors.buttonBackground,
                                buttonIcon: Icons.phone,
                                isPhoneIcon: true,
                              ),
                              const SizedBox(height: AppSizes.paddingMedium),
                              _buildStepCard(
                                title: 'steps.step2.title'.tr(),
                                paragraphs: [
                                  'steps.step2.paragraph1'.tr(),
                                  'steps.step2.paragraph2'.tr(),
                                ],
                                buttonText: 'buttons.freeConsultation'.tr(),
                                buttonColor: AppColors.buttonBackground,
                                buttonIcon: Icons.phone,
                                isPhoneIcon: true,
                              ),
                              const SizedBox(height: AppSizes.paddingMedium),
                              _buildStepCard(
                                title: 'steps.step3.title'.tr(),
                                paragraphs: [
                                  'steps.step3.paragraph1'.tr(),
                                  'steps.step3.paragraph2'.tr(),
                                ],
                                buttonText: 'buttons.callSpecialist2'.tr(),
                                buttonColor: AppColors.buttonGreen,
                                buttonIcon: Icons.chat,
                                isWhatsApp: true,
                              ),
                              const SizedBox(height: AppSizes.paddingMedium),
                              _buildStepCard(
                                title: 'steps.step4.title'.tr(),
                                paragraphs: [
                                  'steps.step4.paragraph1'.tr(),
                                  'steps.step4.paragraph2'.tr(),
                                ],
                                buttonText: 'buttons.placeOrder'.tr(),
                                buttonColor: AppColors.buttonBackground,
                                buttonIcon: Icons.phone,
                                isPhoneIcon: true,
                                hasSecondButton: true,
                                secondButtonText: 'buttons.placeOrder'.tr(),
                                secondButtonColor: AppColors.buttonGreen,
                                secondButtonIcon: Icons.chat,
                                isSecondButtonWhatsApp: true,
                              ),
                              const SizedBox(height: AppSizes.paddingMedium),
                              _buildStepCard(
                                title: 'steps.step5.title'.tr(),
                                paragraphs: [
                                  'steps.step5.paragraph1'.tr(),
                                  'steps.step5.paragraph2'.tr(),
                                ],
                                buttonText: 'buttons.helpWithDocuments'.tr(),
                                buttonColor: AppColors.buttonGreen,
                                buttonIcon: Icons.chat,
                                isWhatsApp: true,
                              ),
                              const SizedBox(height: AppSizes.paddingMedium),
                              _buildStepCard(
                                title: 'steps.step6.title'.tr(),
                                paragraphs: [
                                  'steps.step6.paragraph1'.tr(),
                                  'steps.step6.paragraph2'.tr(),
                                ],
                                buttonText: 'buttons.orderCare'.tr(),
                                buttonColor: AppColors.buttonGreen,
                                buttonIcon: Icons.chat,
                                isWhatsApp: true,
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
                                    child: _buildAppButton(
                                      text: 'buttons.freeConsultation'.tr(),
                                      onPressed: () {
                                        // TODO: Реализовать действие
                                      },
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
                        // Блок контактов
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingMedium,
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: AppSizes.paddingXLarge),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.buttonBorderRadius,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: AppSizes.paddingXLarge,
                                    ),
                                    // Заголовок
                                    Text(
                                      'contacts.title'.tr(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.iconAndText,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: AppSizes.paddingSmall,
                                    ),
                                    // Подзаголовок
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSizes.paddingMedium,
                                      ),
                                      child: Text(
                                        'contacts.subtitle'.tr(),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.iconAndText,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: AppSizes.paddingXLarge,
                                    ),
                                    // Адрес
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 32,
                                      color: AppColors.iconAndText,
                                    ),
                                    const SizedBox(
                                      height: AppSizes.paddingSmall,
                                    ),
                                    Text(
                                      'contacts.city'.tr(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.iconAndText,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: AppSizes.paddingSmall,
                                    ),
                                    Text(
                                      'contacts.address'.tr(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.iconAndText,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: AppSizes.paddingLarge,
                                    ),
                                    // Разделительная линия
                                    Divider(
                                      color: AppColors.accordionBorder,
                                      thickness: 1,
                                      height: 1,
                                    ),
                                    const SizedBox(
                                      height: AppSizes.paddingLarge,
                                    ),
                                    // Телефон
                                    Icon(
                                      Icons.phone_outlined,
                                      size: 32,
                                      color: AppColors.iconAndText,
                                    ),
                                    const SizedBox(
                                      height: AppSizes.paddingSmall,
                                    ),
                                    Text(
                                      'contacts.phone'.tr(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.iconAndText,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: AppSizes.paddingMedium,
                                    ),
                                    // Социальные сети
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          icon: Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: AppColors.iconAndText,
                                                width: 1.5,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Center(
                                              child: Container(
                                                width: 12,
                                                height: 12,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color:
                                                        AppColors.iconAndText,
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
                                                          color: AppColors
                                                              .iconAndText,
                                                          shape:
                                                              BoxShape.circle,
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
                                          icon: Icon(
                                            Icons.facebook,
                                            color: AppColors.iconAndText,
                                          ),
                                          onPressed: () {
                                            // TODO: Открыть Facebook
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: AppSizes.paddingLarge,
                                    ),
                                    // Разделительная линия
                                    Divider(
                                      color: AppColors.accordionBorder,
                                      thickness: 1,
                                      height: 1,
                                    ),
                                    const SizedBox(
                                      height: AppSizes.paddingLarge,
                                    ),
                                    // Email
                                    Icon(
                                      Icons.email_outlined,
                                      size: 32,
                                      color: AppColors.iconAndText,
                                    ),
                                    const SizedBox(
                                      height: AppSizes.paddingSmall,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        // TODO: Открыть email
                                      },
                                      child: Text(
                                        'contacts.email'.tr(),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.iconAndText,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: AppSizes.paddingXLarge,
                                    ),
                                  ],
                                ),
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
                                    text: 'Біз туралы',
                                    onTap: () {
                                      // TODO: Навигация на "О нас"
                                    },
                                  ),
                                  const SizedBox(height: AppSizes.paddingSmall),
                                  _buildFooterLink(
                                    text: 'Мақалалар',
                                    onTap: () {
                                      // TODO: Навигация на "Статьи"
                                    },
                                  ),
                                  const SizedBox(height: AppSizes.paddingSmall),
                                  _buildFooterLink(
                                    text: 'Қазақстан зираттары',
                                    onTap: () {
                                      // TODO: Навигация на "Кладбища Казахстана"
                                    },
                                  ),
                                  const SizedBox(
                                    height: AppSizes.paddingMedium,
                                  ),
                                  // Ссылки на услуги/политику
                                  _buildFooterLink(
                                    text: 'Көмек',
                                    onTap: () {
                                      // TODO: Навигация на "Помощь"
                                    },
                                  ),
                                  const SizedBox(height: AppSizes.paddingSmall),
                                  _buildFooterLink(
                                    text: 'Тауарлар мен қызметтер',
                                    onTap: () {
                                      // TODO: Навигация на "Товары и услуги"
                                    },
                                  ),
                                  const SizedBox(height: AppSizes.paddingSmall),
                                  _buildFooterLink(
                                    text: 'Құпиялық саясаты',
                                    onTap: () {
                                      // TODO: Навигация на "Политика конфиденциальности"
                                    },
                                  ),
                                  const SizedBox(
                                    height: AppSizes.paddingMedium,
                                  ),
                                  // Контактная информация
                                  Text(
                                    'Алматы, Қазақстан',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: AppSizes.paddingSmall),
                                  Text(
                                    '+7 (775) 810-01-10',
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
                                      'info@orynai.kz',
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
  }

  Widget _buildStepCard({
    required String title,
    required List<String> paragraphs,
    required String buttonText,
    required Color buttonColor,
    required IconData buttonIcon,
    bool isPhoneIcon = false,
    bool isWhatsApp = false,
    bool hasSecondButton = false,
    String? secondButtonText,
    Color? secondButtonColor,
    IconData? secondButtonIcon,
    bool isSecondButtonWhatsApp = false,
  }) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMedium,
        vertical: AppSizes.paddingSmall,
      ),
      childrenPadding: const EdgeInsets.fromLTRB(
        AppSizes.paddingMedium,
        0,
        AppSizes.paddingMedium,
        AppSizes.paddingMedium,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.buttonBorderRadius),
        side: const BorderSide(color: AppColors.accordionBorder, width: 1),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.buttonBorderRadius),
        side: const BorderSide(color: AppColors.accordionBorder, width: 1),
      ),
      backgroundColor: Colors.white,
      collapsedBackgroundColor: Colors.white,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppColors.iconAndText,
        ),
      ),
      iconColor: AppColors.iconAndText,
      collapsedIconColor: AppColors.iconAndText,
      children: [
        // Текст параграфов
        ...paragraphs.map(
          (paragraph) => Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
            child: Text(
              paragraph,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.iconAndText,
                height: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.paddingMedium),
        // Кнопки
        if (hasSecondButton &&
            secondButtonText != null &&
            secondButtonColor != null &&
            secondButtonIcon != null)
          Column(
            children: [
              _buildActionButton(
                text: buttonText,
                color: buttonColor,
                icon: buttonIcon,
                isPhoneIcon: isPhoneIcon,
                isWhatsApp: false,
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              _buildActionButton(
                text: secondButtonText,
                color: secondButtonColor,
                icon: secondButtonIcon,
                isPhoneIcon: false,
                isWhatsApp: isSecondButtonWhatsApp,
              ),
            ],
          )
        else
          _buildActionButton(
            text: buttonText,
            color: buttonColor,
            icon: buttonIcon,
            isPhoneIcon: isPhoneIcon,
            isWhatsApp: isWhatsApp,
          ),
      ],
    );
  }

  // Глобальный виджет для унифицированных кнопок
  Widget _buildAppButton({
    required String text,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? borderColor,
    double? borderWidth,
    Widget? icon,
    bool isOutlined = false,
    double? fontSize,
    EdgeInsets? padding,
    double? height,
  }) {
    final buttonPadding = padding ?? const EdgeInsets.symmetric(vertical: 14);
    final buttonFontSize = fontSize ?? 14.0;
    final buttonHeight = height ?? AppSizes.buttonHeight;

    if (isOutlined) {
      return SizedBox(
        width: double.infinity,
        height: buttonHeight,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: foregroundColor ?? AppColors.border,
            padding: buttonPadding,
            side: BorderSide(
              color: borderColor ?? AppColors.border,
              width: borderWidth ?? 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon,
                const SizedBox(width: AppSizes.paddingSmall),
              ],
              Text(
                text,
                style: TextStyle(
                  fontSize: buttonFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return SizedBox(
        width: double.infinity,
        height: buttonHeight,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppColors.buttonBackground,
            foregroundColor: foregroundColor ?? Colors.white,
            padding: buttonPadding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon,
                const SizedBox(width: AppSizes.paddingSmall),
              ],
              Text(
                text,
                style: TextStyle(
                  fontSize: buttonFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildActionButton({
    required String text,
    required Color color,
    required IconData icon,
    bool isPhoneIcon = false,
    bool isWhatsApp = false,
  }) {
    Widget? iconWidget;
    if (isWhatsApp) {
      iconWidget = SvgPicture.asset(
        'assets/icons/whatsapp.svg',
        width: 20,
        height: 20,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      );
    } else {
      iconWidget = Icon(
        icon,
        size: 20,
        color: isPhoneIcon ? AppColors.iconAndText : Colors.white,
      );
    }

    return _buildAppButton(
      text: text,
      onPressed: () {
        // TODO: Реализовать действие
      },
      backgroundColor: color,
      icon: iconWidget,
      fontSize: 13,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  Widget _buildServiceCard({
    required String iconPath,
    required String title,
    required String description,
    required String buttonText,
    bool showInfoText = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.iconAndText,
        borderRadius: BorderRadius.circular(AppSizes.buttonBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Иконка
          SvgPicture.asset(iconPath, width: 50, height: 50),
          const SizedBox(height: AppSizes.paddingMedium),
          // Заголовок
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          // Описание
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          // Кнопка и информационная иконка
          Row(
            children: [
              Expanded(
                child: _buildAppButton(
                  text: buttonText,
                  onPressed: () {
                    // TODO: Реализовать навигацию
                  },
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.iconAndText,
                ),
              ),
              const SizedBox(width: AppSizes.paddingSmall),
              // Информационная иконка
              GestureDetector(
                onTap: () {
                  // TODO: Показать информацию
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      'i',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.iconAndText,
                      ),
                    ),
                  ),
                ),
              ),
              if (showInfoText) ...[
                const SizedBox(width: AppSizes.paddingSmall),
                Text(
                  'services.memorial.howItWorks'.tr(),
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showMenuModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Переключатель языка
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.accordionBorder.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          final isSelected =
                              context.locale.languageCode == 'ru';
                          return GestureDetector(
                            onTap: () {
                              context.setLocale(const Locale('ru'));
                              Navigator.pop(context);
                              _showMenuModal(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSizes.paddingSmall,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'РУ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isSelected
                                      ? AppColors.iconAndText
                                      : AppColors.accordionBorder,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          final isSelected =
                              context.locale.languageCode == 'kk';
                          return GestureDetector(
                            onTap: () {
                              context.setLocale(const Locale('kk'));
                              Navigator.pop(context);
                              _showMenuModal(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSizes.paddingSmall,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'ҚАЗ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isSelected
                                      ? AppColors.iconAndText
                                      : AppColors.accordionBorder,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.paddingXLarge),
              // Секция "КЛИЕНТТЕРГЕ"
              Text(
                'menu.forClients'.tr(),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.accordionBorder,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSizes.paddingSmall),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.person_outline,
                  color: AppColors.iconAndText,
                ),
                title: Text(
                  'menu.loginRegister'.tr(),
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.iconAndText,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Реализовать вход/регистрацию
                },
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              // Разделитель
              Divider(
                color: AppColors.accordionBorder,
                thickness: 1,
                height: 1,
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              // Секция "СЕРІКТЕСТЕРГЕ"
              Text(
                'menu.forPartners'.tr(),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.accordionBorder,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSizes.paddingSmall),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.business_outlined,
                  color: AppColors.iconAndText,
                ),
                title: Text(
                  'menu.loginAsProvider'.tr(),
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.iconAndText,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Реализовать вход для партнеров
                },
              ),
              const SizedBox(height: AppSizes.paddingLarge),
              // Разделитель
              Divider(
                color: AppColors.accordionBorder,
                thickness: 1,
                height: 1,
              ),
              const SizedBox(height: AppSizes.paddingLarge),
              // Навигационные ссылки
              _buildDrawerMenuItem(
                text: 'menu.home'.tr(),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Навигация на главную
                },
              ),
              const SizedBox(height: AppSizes.paddingSmall),
              _buildDrawerMenuItem(
                text: 'menu.catalog'.tr(),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Навигация в каталог
                },
              ),
              const SizedBox(height: AppSizes.paddingSmall),
              _buildDrawerMenuItem(
                text: 'menu.bookPlace'.tr(),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Навигация на бронирование
                },
              ),
              const SizedBox(height: AppSizes.paddingMedium),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerMenuItem({
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingSmall),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, color: AppColors.iconAndText),
        ),
      ),
    );
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
