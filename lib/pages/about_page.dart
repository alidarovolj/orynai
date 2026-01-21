import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';
import '../widgets/header.dart';
import '../widgets/contacts_block.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  bool _isScrolled = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
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
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                // Хэдер
                AppHeader(
                  isScrolled: _isScrolled,
                ),
                // Основной контент
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingMedium,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: AppSizes.paddingXLarge),
                          // Логотип Orynai
                          Center(
                            child: Image.asset(
                              'assets/images/logos/main.png',
                              height: 80,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Text(
                                  'ORYNAI',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1d1c1a),
                                    fontFamily: 'Manrope',
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingXLarge),
                          // Главный заголовок
                          const Text(
                            'Мы цифровой сервис ритуальных услуг, поиска захоронений и мемориалов',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1d1c1a),
                              fontFamily: 'Manrope',
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingXLarge),
                          // Вводный текст
                          const Text(
                            'ORYNAI - первая цифровая платформа в Казахстане, созданная для упрощения и систематизации ритуальных услуг, онлайн-поиска захоронений, бронирования мест на кладбищах и сохранения семейной истории в цифровом формате. Мы объединяем технологии, искусственный интеллект и уважение к памяти предков, чтобы каждый человек мог с удобством получить информацию и необходимые услуги онлайн.',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF4A4A4A),
                              fontFamily: 'Manrope',
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingXLarge),
                          // Блок "Наша цель"
                          Container(
                            padding: const EdgeInsets.all(AppSizes.paddingLarge),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4C4449),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.flag,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                const SizedBox(width: AppSizes.paddingMedium),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Наша цель —',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          fontFamily: 'Manrope',
                                        ),
                                      ),
                                      const SizedBox(height: AppSizes.paddingSmall),
                                      const Text(
                                        'оцифровать сферу памяти и ритуальных услуг в Казахстане, сделать ее прозрачной, доступной и технологичной.',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white,
                                          fontFamily: 'Manrope',
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingXLarge),
                          // Заголовок "Мы работаем, чтобы:"
                          const Text(
                            'Мы работаем, чтобы:',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1d1c1a),
                              fontFamily: 'Manrope',
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingLarge),
                          // Маркированный список
                          _buildBulletPoint(
                            'каждый человек мог найти место захоронения онлайн,',
                          ),
                          const SizedBox(height: AppSizes.paddingMedium),
                          _buildBulletPoint(
                            'города получили цифровые карты кладбищ и аналитические данные,',
                          ),
                          const SizedBox(height: AppSizes.paddingMedium),
                          _buildBulletPoint(
                            'оформление ритуальных услуг происходило в несколько кликов',
                          ),
                          const SizedBox(height: AppSizes.paddingMedium),
                          _buildBulletPoint(
                            'память о родных хранилась в цифровом мемориале навсегда',
                          ),
                          const SizedBox(height: AppSizes.paddingMedium),
                          _buildBulletPoint(
                            'ИИ помогал на каждом этапе — от поиска данных до выбора услуг.',
                          ),
                          const SizedBox(height: AppSizes.paddingXLarge),
                          // Центральный заголовок
                          const Text(
                            'ORYNAI – это место, где история семьи становится доступной, понятной и не теряется',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1d1c1a),
                              fontFamily: 'Manrope',
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingXLarge),
                          // Заголовок "Наша цель" (центрированный)
                          const Text(
                            'Наша цель',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1d1c1a),
                              fontFamily: 'Manrope',
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingLarge),
                          // Описательный текст
                          const Text(
                            'Сделать Казахстан первой страной, где:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF1d1c1a),
                              fontFamily: 'Manrope',
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingLarge),
                          // Карточки с целями
                          _buildGoalCard(
                            'все кладбища оцифрованы',
                          ),
                          const SizedBox(height: AppSizes.paddingMedium),
                          _buildGoalCard(
                            'память о людях сохраняется и передаётся поколениям',
                          ),
                          const SizedBox(height: AppSizes.paddingMedium),
                          _buildGoalCard(
                            'данные доступны онлайн',
                          ),
                          const SizedBox(height: AppSizes.paddingMedium),
                          _buildGoalCard(
                            'ритуальная сфера регулируется и прозрачна',
                          ),
                          const SizedBox(height: AppSizes.paddingMedium),
                          _buildGoalCard(
                            'искусственный интеллект делает сервис понятным и доступным каждому',
                          ),
                          const SizedBox(height: AppSizes.paddingXLarge),
                          // Блок контактов
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openPhone() async {
    final Uri phoneUrl = Uri.parse('tel:+77758100110');
    try {
      if (await canLaunchUrl(phoneUrl)) {
        await launchUrl(phoneUrl);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка открытия телефона')),
        );
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка открытия email')),
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка открытия ссылки')),
        );
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка открытия ссылки')),
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка открытия ссылки')),
        );
      }
    }
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 8, right: 12),
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: Color(0xFF1d1c1a),
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF1d1c1a),
              fontFamily: 'Manrope',
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingLarge,
        vertical: AppSizes.paddingMedium,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1), // Светло-золотистый цвет
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFFD54F), // Золотистая граница
          width: 1,
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Color(0xFF1d1c1a),
          fontFamily: 'Manrope',
        ),
      ),
    );
  }
}
