import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orynai',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.buttonBackground,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
        textTheme: GoogleFonts.manropeTextTheme(),
        fontFamily: GoogleFonts.manrope().fontFamily,
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
  String _selectedLanguage = 'ҚАЗ'; // По умолчанию казахский

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
      drawer: _buildDrawer(),
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
                                Scaffold.of(context).openDrawer();
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
                          height: MediaQuery.of(context).size.height * 0.6,
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
                                    Image.asset(
                                      'assets/images/logos/main.png',
                                      height: AppSizes.mainLogoHeight,
                                      fit: BoxFit.contain,
                                    ),
                                    const SizedBox(
                                      height: AppSizes.paddingXLarge,
                                    ),
                                    // Описательный текст
                                    const Text(
                                      'Алматы қаласының\nэлектрондық зираттар базасы',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.iconAndText,
                                        height: 1.3,
                                      ),
                                    ),
                                    const Spacer(),
                                    // Кнопки
                                    Column(
                                      children: [
                                        // Первая кнопка - "Маманға қоңырау шалу"
                                        SizedBox(
                                          width: double.infinity,
                                          height: AppSizes.buttonHeight,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              // TODO: Реализовать звонок специалисту
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.buttonBackground,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppSizes
                                                          .buttonBorderRadius,
                                                    ),
                                              ),
                                              elevation: 0,
                                            ),
                                            child: const Text(
                                              'Маманға қоңырау шалу',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: AppSizes.paddingMedium,
                                        ),
                                        // Вторая кнопка - "Жерлеуді ұйымдастыру"
                                        SizedBox(
                                          width: double.infinity,
                                          height: AppSizes.buttonHeight,
                                          child: OutlinedButton(
                                            onPressed: () {
                                              // TODO: Реализовать организацию похорон
                                            },
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: AppColors.border,
                                              side: const BorderSide(
                                                color: AppColors.border,
                                                width: 1.5,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppSizes
                                                          .buttonBorderRadius,
                                                    ),
                                              ),
                                            ),
                                            child: const Text(
                                              'Жерлеуді ұйымдастыру',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: AppSizes.paddingXLarge,
                                    ),
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
                                title: 'ОРЫН БРОНДАУ',
                                description: 'Зиратта орынды онлайн брондаңыз',
                                buttonText: 'Өту',
                              ),
                              const SizedBox(height: AppSizes.paddingMedium),
                              _buildServiceCard(
                                iconPath: 'assets/icons/benefits/2.svg',
                                title: 'МЕМОРИАЛ',
                                description:
                                    'Мемориал мен өз отбасы ағашыңызды онлайн жасаңыз',
                                buttonText: 'Өту',
                                showInfoText: true,
                              ),
                              const SizedBox(height: AppSizes.paddingMedium),
                              _buildServiceCard(
                                iconPath: 'assets/icons/benefits/3.svg',
                                title: 'ТАУАРЛАР МЕН ҚЫЗМЕТТЕР',
                                description:
                                    'Барлық жерлеу қызметтерін жеткізушілерді бір жерде жинаған маркетплейс',
                                buttonText: 'Өту',
                              ),
                              const SizedBox(height: AppSizes.paddingMedium),
                              _buildServiceCard(
                                iconPath: 'assets/icons/benefits/4.svg',
                                title: 'ЖЕРЛЕУДІ ТАБУ',
                                description: 'Іздеу үшін деректерді енгізіңіз',
                                buttonText: 'Іздеу',
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
                              const Text(
                                'Қалай әрекет ету керек,\nқадамдық нұсқаулық',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.iconAndText,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: AppSizes.paddingXLarge),
                              // Карточки с шагами
                              _buildStepCard(
                                title: 'Көмек қажеттілігін түсіну',
                                paragraphs: [
                                  'Адам жерлеу қызметтері жақын арада қажет болатын жағдайға тап болады. Бұл туыстың жағдайының нашарлауы, ауруханадан қоңырау немесе дайындалу керектігін ішкі түсіну болуы мүмкін.',
                                  'Сұрақтар, алаңдаушылық және жауапкершілікті өз мойнына алып, бәрін дұрыс ұйымдастыруға көмектесетіндерді табу қажеттілігі туындайды.',
                                ],
                                buttonText: 'Қолдау',
                                buttonColor: AppColors.buttonBackground,
                                buttonIcon: Icons.phone,
                                isPhoneIcon: true,
                              ),
                              const SizedBox(height: AppSizes.paddingMedium),
                              _buildStepCard(
                                title: 'Алғашқы кеңес беру және дайындық',
                                paragraphs: [
                                  'Бұл кезеңде адам жауаптар іздейді: қандай құжаттар қажет, қайда жүгіну керек, алдын ала нені білу маңызды. Ол біздің қызметпен байланысады.',
                                  'Біз тегін түрде әрекет тәртібін түсіндіреміз, қандай кезеңдер болатынын айтамыз және маңызды сәтте бәрі түсінікті болуы үшін дайындалуға көмектесеміз.',
                                ],
                                buttonText: 'Тегін кеңес',
                                buttonColor: AppColors.buttonBackground,
                                buttonIcon: Icons.phone,
                                isPhoneIcon: true,
                              ),
                              const SizedBox(height: AppSizes.paddingMedium),
                              _buildStepCard(
                                title:
                                    'Қайтыс болу туралы хабарлау және жұмысты бастау',
                                paragraphs: [
                                  'Қайғылы оқиға болған кезде, отбасы кімге сенуге болатынын біледі. Олар бізге қоңырау шалады – және осы сәттен бастап біз жұмысқа кірісеміз.',
                                  'Біз кездесеміз, мәліметтерді келісеміз және процесті өз мойнымызға аламыз: құжаттарды рәсімдейміз, жерлеу орнын дайындаймыз, көлікті қамтамасыз етеміз және рәсімнің барлық кезеңдерін ұйымдастырамыз.',
                                ],
                                buttonText: 'Маманды шақыру',
                                buttonColor: AppColors.buttonGreen,
                                buttonIcon: Icons.chat,
                                isWhatsApp: true,
                              ),
                              const SizedBox(height: AppSizes.paddingMedium),
                              _buildStepCard(
                                title: 'Жерлеуді өткізу',
                                paragraphs: [
                                  'Белгіленген күні біз келісімге сәйкес рәсімді ұйымдастырамыз. Көлікті ұйымдастырудан бастап орынды дайындауға және рәсімдерді өткізуге дейін – бәрі мұқият, құрметпен және артық асығыссыз өтеді.',
                                  'Туыстар жанында болады, ұйымдастырушылық мәселелерге алаңдамай – біз процесті толық бақылаймыз.',
                                ],
                                buttonText: 'Тапсырыс беру',
                                buttonColor: AppColors.buttonBackground,
                                buttonIcon: Icons.phone,
                                isPhoneIcon: true,
                                hasSecondButton: true,
                                secondButtonText: 'Тапсырыс беру',
                                secondButtonColor: AppColors.buttonGreen,
                                secondButtonIcon: Icons.chat,
                                isSecondButtonWhatsApp: true,
                              ),
                              const SizedBox(height: AppSizes.paddingMedium),
                              _buildStepCard(
                                title: 'Рәсімнен кейінгі қолдау',
                                paragraphs: [
                                  'Жерлеуден кейін бірқатар заңды және тұрмыстық формальдіктер қалады. Біз қайтыс болу туралы куәлікті рәсімдеуге, тиесілі төлемдерді, анықтамалар мен құжаттарды алуға көмектесеміз.',
                                  'Отбасы бюрократиямен жалғыз қалмауы үшін барлық рәсімдер толық аяқталғанша сүйемелдейміз.',
                                ],
                                buttonText: 'Құжаттармен көмек',
                                buttonColor: AppColors.buttonGreen,
                                buttonIcon: Icons.chat,
                                isWhatsApp: true,
                              ),
                              const SizedBox(height: AppSizes.paddingMedium),
                              _buildStepCard(
                                title: 'Күтім және естелік сақтау',
                                paragraphs: [
                                  'Отбасының қалауы бойынша біз қабірге тұрақты күтім жасауды өз мойнымызға аламыз: тазалау, гүлдер, ескерткішті жаңарту, орынды абаттандыру.',
                                  'Сонымен адамның естелігі лайықты түрде сақталады, ал жерлеу орны — күтімді болады.',
                                ],
                                buttonText: 'Күтімге тапсырыс беру',
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
                                  const Padding(
                                    padding: EdgeInsets.only(
                                      top: AppSizes.paddingLarge,
                                      left: AppSizes.paddingMedium,
                                      right: AppSizes.paddingMedium,
                                    ),
                                    child: Text(
                                      'Бәріне алдын ала дайындалу',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
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
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: AppSizes.paddingMedium,
                                    ),
                                    child: Text(
                                      'Тәжірибе көрсеткендей, алдын ала дайындық процесті жеңілдетеді және шығындарды азайтады',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
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
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: AppSizes.buttonHeight,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          // TODO: Реализовать действие
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.buttonBackground,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              AppSizes.buttonBorderRadius,
                                            ),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: const Text(
                                          'Тегін кеңес',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSizes.paddingXLarge),
                          ],
                        ),
                        // Блок контактов
                        Column(
                          children: [
                            const SizedBox(height: AppSizes.paddingXLarge),
                            Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                              ),
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: AppSizes.paddingXLarge,
                                  ),
                                  // Заголовок
                                  const Text(
                                    'Байланыс',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.iconAndText,
                                    ),
                                  ),
                                  const SizedBox(height: AppSizes.paddingSmall),
                                  // Подзаголовок
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: AppSizes.paddingMedium,
                                    ),
                                    child: Text(
                                      'Біз күн сайын тәулік бойы кеңес береміз',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
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
                                  const SizedBox(height: AppSizes.paddingSmall),
                                  const Text(
                                    'Алматы қаласы',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.iconAndText,
                                    ),
                                  ),
                                  const SizedBox(height: AppSizes.paddingSmall),
                                  const Text(
                                    'Тимирязев көшесі, 428',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.iconAndText,
                                    ),
                                  ),
                                  const SizedBox(height: AppSizes.paddingLarge),
                                  // Разделительная линия
                                  Divider(
                                    color: AppColors.accordionBorder,
                                    thickness: 1,
                                    height: 1,
                                  ),
                                  const SizedBox(height: AppSizes.paddingLarge),
                                  // Телефон
                                  Icon(
                                    Icons.phone_outlined,
                                    size: 32,
                                    color: AppColors.iconAndText,
                                  ),
                                  const SizedBox(height: AppSizes.paddingSmall),
                                  const Text(
                                    '+7 (775) 810-01-10',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.iconAndText,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: AppSizes.paddingMedium,
                                  ),
                                  // Социальные сети
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                                  color: AppColors.iconAndText,
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
                                  const SizedBox(height: AppSizes.paddingLarge),
                                  // Разделительная линия
                                  Divider(
                                    color: AppColors.accordionBorder,
                                    thickness: 1,
                                    height: 1,
                                  ),
                                  const SizedBox(height: AppSizes.paddingLarge),
                                  // Email
                                  Icon(
                                    Icons.email_outlined,
                                    size: 32,
                                    color: AppColors.iconAndText,
                                  ),
                                  const SizedBox(height: AppSizes.paddingSmall),
                                  GestureDetector(
                                    onTap: () {
                                      // TODO: Открыть email
                                    },
                                    child: const Text(
                                      'info@orynai.kz',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
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
          fontSize: 16,
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

  Widget _buildActionButton({
    required String text,
    required Color color,
    required IconData icon,
    bool isPhoneIcon = false,
    bool isWhatsApp = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          // TODO: Реализовать действие
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.buttonBorderRadius),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isWhatsApp)
              SvgPicture.asset(
                'assets/icons/whatsapp.svg',
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              )
            else
              Icon(
                icon,
                size: 20,
                color: isPhoneIcon ? AppColors.iconAndText : Colors.white,
              ),
            const SizedBox(width: AppSizes.paddingSmall),
            Text(
              text,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
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
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          // Описание
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSizes.paddingLarge),
          // Кнопка и информационная иконка
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Реализовать навигацию
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.iconAndText,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSizes.buttonBorderRadius,
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
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
                const Text(
                  'Как это работает',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSizes.paddingLarge),
            // Переключатель языка
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMedium,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedLanguage = 'РУ';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSizes.paddingSmall,
                        ),
                        decoration: BoxDecoration(
                          color: _selectedLanguage == 'РУ'
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'РУ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: _selectedLanguage == 'РУ'
                                ? AppColors.iconAndText
                                : AppColors.accordionBorder,
                            fontWeight: _selectedLanguage == 'РУ'
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 20,
                    color: AppColors.accordionBorder,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedLanguage = 'ҚАЗ';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSizes.paddingSmall,
                        ),
                        decoration: BoxDecoration(
                          color: _selectedLanguage == 'ҚАЗ'
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'ҚАЗ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: _selectedLanguage == 'ҚАЗ'
                                ? AppColors.iconAndText
                                : AppColors.accordionBorder,
                            fontWeight: _selectedLanguage == 'ҚАЗ'
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.paddingXLarge),
            // Секция "КЛИЕНТТЕРГЕ"
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMedium,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'КЛИЕНТТЕРГЕ',
                    style: TextStyle(
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
                      'Кіру/Тіркелу',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.iconAndText,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Реализовать вход/регистрацию
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            // Разделитель
            Divider(color: AppColors.accordionBorder, thickness: 1, height: 1),
            const SizedBox(height: AppSizes.paddingMedium),
            // Секция "СЕРІКТЕСТЕРГЕ"
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMedium,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'СЕРІКТЕСТЕРГЕ',
                    style: TextStyle(
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
                      'Қызмет көрсетуші ретінде кіру',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.iconAndText,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Реализовать вход для партнеров
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.paddingLarge),
            // Навигационные ссылки
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMedium,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDrawerMenuItem(
                    text: 'Басты',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Навигация на главную
                    },
                  ),
                  const SizedBox(height: AppSizes.paddingSmall),
                  _buildDrawerMenuItem(
                    text: 'Каталог',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Навигация в каталог
                    },
                  ),
                  const SizedBox(height: AppSizes.paddingSmall),
                  _buildDrawerMenuItem(
                    text: 'Орнын брондау',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Навигация на бронирование
                    },
                  ),
                ],
              ),
            ),
          ],
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
}
