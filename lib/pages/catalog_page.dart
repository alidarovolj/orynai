import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import '../services/auth_state_manager.dart';
import '../widgets/header.dart';
import '../widgets/login_modal.dart';
import '../widgets/support_block.dart';
import '../pages/cemeteries_page.dart';
import '../pages/products_page.dart';
import '../pages/about_page.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  List<Category> _categories = [];
  bool _isLoading = true;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    _loadCategories();
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

  Future<void> _loadCategories() async {
    try {
      final response = await _apiService.getCategories();
      setState(() {
        _categories = response
            .map((item) => Category.fromJson(item as Map<String, dynamic>))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки категорий: $e')),
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
        final Uri fallbackUrl = Uri.parse('https://wa.me/77758100110');
        if (await canLaunchUrl(fallbackUrl)) {
          await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
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
                          setState(() {});
                        }
                      });
                    }
                  },
                ),
                // Основной контент с прокруткой
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          controller: _scrollController,
                          child: Column(
                            children: [
                              // Заголовок
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSizes.paddingMedium,
                                  vertical: AppSizes.paddingLarge,
                                ),
                                child: const Text(
                                  'Каталог',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.iconAndText,
                                  ),
                                ),
                              ),
                              // Список категорий
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSizes.paddingMedium,
                                ),
                                child: Column(
                                  children: _categories.map((category) {
                                    return _CategoryCard(category: category);
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: AppSizes.paddingLarge),
                              // Блок "Помощь и поддержка"
                              const SupportBlock(),
                              const SizedBox(height: AppSizes.paddingXLarge),
                              // Футер
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(
                                  AppSizes.paddingXLarge,
                                ),
                                color: AppColors.headerScrolled,
                                child: Stack(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Навигационные ссылки
                                        _buildFooterLink(
                                          text: 'footer.aboutUs'.tr(),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const AboutPage(),
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(
                                          height: AppSizes.paddingSmall,
                                        ),
                                        _buildFooterLink(
                                          text: 'footer.articles'.tr(),
                                          onTap: () {
                                            // TODO: Навигация на "Статьи"
                                          },
                                        ),
                                        const SizedBox(
                                          height: AppSizes.paddingSmall,
                                        ),
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
                                        const SizedBox(
                                          height: AppSizes.paddingSmall,
                                        ),
                                        _buildFooterLink(
                                          text: 'footer.goodsAndServices'.tr(),
                                          onTap: () {
                                            // TODO: Навигация на "Товары и услуги"
                                          },
                                        ),
                                        const SizedBox(
                                          height: AppSizes.paddingSmall,
                                        ),
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
                                        const SizedBox(
                                          height: AppSizes.paddingSmall,
                                        ),
                                        Text(
                                          'contacts.phone'.tr(),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: AppSizes.paddingSmall,
                                        ),
                                        GestureDetector(
                                          onTap: _openEmail,
                                          child: Text(
                                            'contacts.email'.tr(),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                              decoration:
                                                  TextDecoration.underline,
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
                                                  borderRadius:
                                                      BorderRadius.circular(6),
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
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              onPressed: _openInstagram,
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.facebook,
                                                color: Colors.white,
                                              ),
                                              onPressed: _openFacebook,
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
                                        onPressed: _openWhatsApp,
                                        backgroundColor:
                                            AppColors.headerScrolled,
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

  // Метод удален - используется глобальный MenuModal через AppHeader
  // 
  Widget _buildFooterLink({
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, color: Colors.white),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(244, 240, 231, 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
          child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductsPage(category: category),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color.fromRGBO(5, 2, 2, 1),
                          height: 1.5,
                        ),
                      ),
                      if (category.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          category.description,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Color.fromRGBO(92, 103, 113, 1),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.iconAndText.withOpacity(0.3),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
