import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/auth_state_manager.dart';
import '../widgets/header.dart';
import '../widgets/product_card.dart';
import '../widgets/login_modal.dart';
import '../widgets/add_to_cart_modal.dart';
import '../widgets/support_block.dart';
import '../widgets/contacts_block.dart';
import 'package:url_launcher/url_launcher.dart';
import 'profile_page.dart';

class ProductDetailsPage extends StatefulWidget {
  final Product product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  List<Product> _relatedProducts = [];
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    _loadRelatedProducts();
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
      'https://www.instagram.com/orynai.kz?igsh=c2VuMjdqcG9xOWYw',
    );
    try {
      if (await canLaunchUrl(instagramUrl)) {
        await launchUrl(instagramUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
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
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('errors.linkNotAvailable'.tr())));
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('errors.linkNotAvailable'.tr())));
      }
    }
  }

  Future<void> _loadRelatedProducts() async {
    try {
      // Загружаем продукты той же категории
      final response = await _apiService.getProducts(
        categoryId: widget.product.categoryId,
        page: 1,
        limit: 20, // Загружаем больше, чтобы было из чего выбрать
      );

      final productsResponse = ProductsResponse.fromJson(response);

      // Исключаем текущий продукт из списка
      final related = productsResponse.items
          .where((p) => p.id != widget.product.id)
          .take(4) // Берем первые 4
          .toList();

      setState(() {
        _relatedProducts = related;
      });
    } catch (e) {
      // Ошибка загрузки - просто оставляем список пустым
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
                      );
                    } else {
                      // Переходим на страницу профиля
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfilePage(),
                        ),
                      );
                    }
                  },
                ),
                // Основной контент с прокруткой
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Название продукта
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingMedium,
                            vertical: AppSizes.paddingLarge,
                          ),
                          child: Text(
                            widget.product.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.iconAndText,
                            ),
                          ),
                        ),
                        // Фото продукта
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingMedium,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: widget.product.imageUrls.isNotEmpty
                                  ? Image.network(
                                      widget.product.imageUrls.first,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Image.asset(
                                              'assets/images/logos/main.png',
                                              fit: BoxFit.contain,
                                            );
                                          },
                                    )
                                  : Image.asset(
                                      'assets/images/logos/main.png',
                                      fit: BoxFit.contain,
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingMedium),
                        // Кнопка "Добавить"
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingMedium,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {
                                final authManager = AuthStateManager();
                                if (!authManager.isAuthenticated) {
                                  showModalBottomSheet(
                                    context: context,
                                    backgroundColor: Colors.transparent,
                                    isScrollControlled: true,
                                    builder: (context) => const LoginModal(),
                                  );
                                } else {
                                  showModalBottomSheet(
                                    context: context,
                                    backgroundColor: Colors.transparent,
                                    isScrollControlled: true,
                                    builder: (context) => AddToCartModal(
                                      productName: widget.product.name,
                                      productPrice: widget.product.price,
                                      productId: widget.product.id,
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.buttonBackground,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.shopping_cart_outlined,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'catalog.productDetails.add'.tr(),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingLarge),
                        // Описание
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingMedium,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'catalog.productDetails.description'.tr(),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1d1c1a),
                                  fontFamily: 'Manrope',
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildDescriptionRow(
                                'catalog.productDetails.category'.tr(),
                                widget.product.description,
                                isLast: false,
                              ),
                              _buildDescriptionRow(
                                'catalog.productDetails.productType'.tr(),
                                widget.product.type == 'product'
                                    ? 'catalog.productDetails.product'.tr()
                                    : 'catalog.productDetails.service'.tr(),
                                isLast: false,
                              ),
                              if (widget.product.deliveryMethod != null)
                                _buildDescriptionRow(
                                  'catalog.productDetails.deliveryMethod'.tr(),
                                  widget.product.deliveryMethod!.name,
                                  isLast: false,
                                ),
                              if (widget.product.serviceTime.isNotEmpty)
                                _buildDescriptionRow(
                                  'catalog.productDetails.executionTime'.tr(),
                                  widget.product.serviceTime,
                                  isLast: false,
                                ),
                              _buildDescriptionRow(
                                'catalog.productDetails.country'.tr(),
                                widget.product.country,
                                isLast: false,
                              ),
                              _buildDescriptionRow(
                                'catalog.productDetails.city'.tr(),
                                widget.product.city,
                                isLast: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingLarge),
                        // Отзывы
                        Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingMedium,
                          ),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline,
                                    size: 20,
                                    color: AppColors.iconAndText.withOpacity(
                                      0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'catalog.productDetails.reviewsCount'.tr(
                                      namedArgs: {'count': '0'},
                                    ),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1d1c1a),
                                      fontFamily: 'Manrope',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 40),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 40,
                                  ),
                                  child: Text(
                                    'catalog.productDetails.noReviews'.tr(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF6b7280),
                                      fontFamily: 'Manrope',
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingLarge),
                        // Блок "С этим товаром чаще всего берут"
                        if (_relatedProducts.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.paddingMedium,
                            ),
                            child: Text(
                              'catalog.productDetails.oftenBoughtWith'.tr(),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1d1c1a),
                                fontFamily: 'Manrope',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _relatedProducts.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  left: AppSizes.paddingMedium,
                                  right: AppSizes.paddingMedium,
                                  bottom: AppSizes.paddingMedium,
                                ),
                                child: ProductCard(
                                  product: _relatedProducts[index],
                                  onDetailsTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ProductDetailsPage(
                                              product: _relatedProducts[index],
                                            ),
                                      ),
                                    );
                                  },
                                  onAddTap: () {
                                    // TODO: Добавить в корзину
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                        // Блок "Помощь и поддержка"
                        const SupportBlock(),
                        const SizedBox(height: AppSizes.paddingLarge),
                        // Блок контактов
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingMedium,
                          ),
                          child: ContactsBlock(
                            onLocationTap: _open2GIS,
                            onPhoneTap: _openPhone,
                            onEmailTap: _openEmail,
                            onInstagramTap: _openInstagram,
                            onFacebookTap: _openFacebook,
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingLarge),
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

  Widget _buildDescriptionRow(
    String label,
    String value, {
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1d1c1a),
                    fontFamily: 'Manrope',
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6b6b6b),
                    fontFamily: 'Manrope',
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.accordionBorder.withOpacity(0.3),
          ),
      ],
    );
  }
}
