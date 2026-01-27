import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
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
                                return Text(
                                  'about.logoFallback'.tr(),
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
                          Text(
                            'about.mainHeadline'.tr(),
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
                          Text(
                            'about.intro'.tr(),
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
                                      Text(
                                        'about.ourGoalTitle'.tr(),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          fontFamily: 'Manrope',
                                        ),
                                      ),
                                      const SizedBox(height: AppSizes.paddingSmall),
                                      Text(
                                        'about.ourGoalText'.tr(),
                                        style: const TextStyle(
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
                          Text(
                            'about.weWorkTo'.tr(),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1d1c1a),
                              fontFamily: 'Manrope',
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingLarge),
                          // Маркированный список
                          _buildBulletPoint('about.bullet1'.tr()),
                          const SizedBox(height: AppSizes.paddingMedium),
                          _buildBulletPoint('about.bullet2'.tr()),
                          const SizedBox(height: AppSizes.paddingMedium),
                          _buildBulletPoint('about.bullet3'.tr()),
                          const SizedBox(height: AppSizes.paddingMedium),
                          _buildBulletPoint('about.bullet4'.tr()),
                          const SizedBox(height: AppSizes.paddingMedium),
                          _buildBulletPoint('about.bullet5'.tr()),
                          const SizedBox(height: AppSizes.paddingXLarge),
                          // Центральный заголовок
                          Text(
                            'about.familyHistoryHeadline'.tr(),
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
                          Text(
                            'about.ourGoal'.tr(),
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
                          Text(
                            'about.makeKzFirst'.tr(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF1d1c1a),
                              fontFamily: 'Manrope',
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingLarge),
                          // Карточки с целями
                          _buildGoalCard('about.goal1'.tr()),
                          const SizedBox(height: AppSizes.paddingMedium),
                          _buildGoalCard('about.goal2'.tr()),
                          const SizedBox(height: AppSizes.paddingMedium),
                          _buildGoalCard('about.goal3'.tr()),
                          const SizedBox(height: AppSizes.paddingMedium),
                          _buildGoalCard('about.goal4'.tr()),
                          const SizedBox(height: AppSizes.paddingMedium),
                          _buildGoalCard('about.goal5'.tr()),
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
          SnackBar(content: Text('errors.phoneNotAvailable'.tr())),
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
          SnackBar(content: Text('errors.emailNotAvailable'.tr())),
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
          SnackBar(content: Text('errors.linkNotAvailable'.tr())),
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
          SnackBar(content: Text('errors.linkNotAvailable'.tr())),
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
          SnackBar(content: Text('errors.linkNotAvailable'.tr())),
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
