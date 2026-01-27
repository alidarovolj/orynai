import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import '../services/auth_state_manager.dart';
import '../widgets/header.dart';
import '../widgets/login_modal.dart';
import '../widgets/products_filter_block.dart';
import '../widgets/product_card.dart';
import 'product_details_page.dart';
import 'profile_page.dart';

class ProductsPage extends StatefulWidget {
  final Category category;

  const ProductsPage({
    super.key,
    required this.category,
  });

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  List<Product> _products = [];
  bool _isLoading = true;
  bool _isScrolled = false;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoadingMore = false;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    // При первой загрузке используем категорию страницы
    _selectedCategoryId = widget.category.id;
    _loadProducts();
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

    // Загрузка следующей страницы при прокрутке вниз
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoadingMore &&
        _currentPage < _totalPages) {
      _loadMoreProducts();
    }
  }

  Future<void> _loadProducts({bool loadMore = false}) async {
    if (loadMore) {
      setState(() {
        _isLoadingMore = true;
      });
    } else {
      setState(() {
        _isLoading = true;
        _currentPage = 1;
      });
    }

    try {
      // Если выбрано "Все категории" (_selectedCategoryId == null), отправляем запрос без category_id
      // Иначе используем выбранную категорию из фильтра
      final response = await _apiService.getProducts(
        categoryId: _selectedCategoryId,
        page: loadMore ? _currentPage : 1,
      );

      final productsResponse = ProductsResponse.fromJson(response);

      setState(() {
        if (loadMore) {
          _products.addAll(productsResponse.items);
        } else {
          _products = productsResponse.items;
        }
        _currentPage = productsResponse.page;
        _totalPages = productsResponse.totalPages;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('catalog.products.loadProductsError'.tr(namedArgs: {'error': e.toString()}))),
        );
      }
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_currentPage < _totalPages) {
      setState(() {
        _currentPage++;
      });
      await _loadProducts(loadMore: true);
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
                // Кнопка "Назад"
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingMedium,
                    vertical: 8,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                      color: AppColors.iconAndText,
                    ),
                  ),
                ),
                // Основной контент
                Expanded(
                  child: _isLoading && _products.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : _products.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.inbox_outlined,
                                    size: 64,
                                    color: AppColors.accordionBorder,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'catalog.products.noProducts'.tr(),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.iconAndText
                                          .withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: EdgeInsets.zero,
                              itemCount: _products.length +
                                  (_isLoadingMore ? 1 : 0) +
                                  2, // +1 для заголовка, +1 для фильтров
                              itemBuilder: (context, index) {
                                // Заголовок в начале списка
                                if (index == 0) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSizes.paddingMedium,
                                      vertical: AppSizes.paddingLarge,
                                    ),
                                    child: Text(
                                      widget.category.name,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.iconAndText,
                                      ),
                                    ),
                                  );
                                }
                                
                                // Блок фильтров
                                if (index == 1) {
                                  return ProductsFilterBlock(
                                    selectedCategoryId: widget.category.id,
                                    selectedCity: 'Алматы',
                                    onFiltersChanged: (categoryId, city, promotions, supplier, minPrice, maxPrice) {
                                      setState(() {
                                        _selectedCategoryId = categoryId;
                                        _currentPage = 1; // Сбрасываем на первую страницу при изменении фильтров
                                      });
                                      _loadProducts();
                                    },
                                  );
                                }
                                
                                // Индекс продукта (учитывая заголовок и фильтры)
                                final productIndex = index - 2;
                                
                                if (productIndex == _products.length) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                
                                return Padding(
                                  padding: EdgeInsets.only(
                                    left: AppSizes.paddingMedium,
                                    right: AppSizes.paddingMedium,
                                    bottom: 16,
                                  ),
                                  child: ProductCard(
                                    product: _products[productIndex],
                                    onDetailsTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ProductDetailsPage(
                                            product: _products[productIndex],
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

