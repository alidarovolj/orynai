import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import '../constants.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../services/api_service.dart';
import '../services/auth_state_manager.dart';
import '../widgets/header.dart';
import '../widgets/product_card.dart';
import '../widgets/app_button.dart';
import '../widgets/order_payment_button.dart';
import '../widgets/login_modal.dart';
import 'product_details_page.dart';
import 'profile_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  List<CartItem> _cartItems = [];
  List<Product> _additionalProducts = [];
  bool _isLoading = true;
  bool _isScrolled = false;
  DateTime? _selectedDate;
  String _address = '';
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    _loadCart();
    _loadAdditionalProducts();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _addressController.dispose();
    _commentsController.dispose();
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

  Future<void> _loadCart() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.getCart();
      final items = response
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList();

      setState(() {
        _cartItems = items;
        if (items.isNotEmpty) {
          _selectedDate = DateTime.parse(items.first.deliveryArrivalTime);
          _address = items.first.deliveryDestinationAddress;
          _addressController.text = _address;
        }
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading cart: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('catalog.cart.loadError'.tr(namedArgs: {'error': e.toString()}))));
      }
    }
  }

  Future<void> _loadAdditionalProducts() async {
    try {
      final response = await _apiService.getProducts(
        categoryId: null,
        page: 1,
        limit: 20,
      );

      final productsResponse = ProductsResponse.fromJson(response);

      setState(() {
        _additionalProducts = productsResponse.items;
      });
    } catch (e) {
      debugPrint('Error loading additional products: $e');
    }
  }

  Future<void> _updateQuantity(CartItem item, int newQuantity) async {
    if (newQuantity < 1) {
      _removeItem(item);
      return;
    }

    try {
      // Отправляем запрос на обновление количества
      await _apiService.patch(
        '/api/v1/cart/${item.id}',
        body: {'quantity': newQuantity},
        requiresAuth: true,
      );

      // После успешного обновления загружаем корзину заново
      await _loadCart();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('catalog.cart.quantityUpdated'.tr())));
      }
    } catch (e) {
      debugPrint('Error updating quantity: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('catalog.cart.quantityUpdateError'.tr(namedArgs: {'error': e.toString()}))),
        );
      }
    }
  }

  Future<void> _removeItem(CartItem item) async {
    try {
      setState(() {
        _cartItems.removeWhere((i) => i.id == item.id);
      });
    } catch (e) {
      debugPrint('Error removing item: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('catalog.cart.removeError'.tr())));
      }
    }
  }

  Future<void> _createOrder() async {
    if (_cartItems.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('catalog.cart.emptyCart'.tr())));
      }
      return;
    }

    try {
      // Формируем массив order_items из элементов корзины
      final orderItems = _cartItems
          .map(
            (item) => {
              'delivery_arrival_time': item.deliveryArrivalTime,
              'delivery_destination_address': item.deliveryDestinationAddress,
              'product_id': item.productId,
              'quantity': item.quantity,
            },
          )
          .toList();

      // Отправляем запрос на создание заказа
      final response = await _apiService.post(
        '/api/v1/orders',
        body: {'order_items': orderItems},
        requiresAuth: true,
      );

      // API возвращает только {"id": 127}, нужно получить полный заказ
      final orderData = response as Map<String, dynamic>;
      final orderId = orderData['id'] as int;

      // Получаем полный заказ по ID
      final ordersResponse = await _apiService.get(
        '/api/v1/orders',
        queryParameters: {'page': '1', 'limit': '10'},
        requiresAuth: true,
      );

      final ordersData = OrdersResponse.fromJson(ordersResponse as Map<String, dynamic>);
      final order = ordersData.items.firstWhere(
        (o) => o.id == orderId,
        orElse: () => throw Exception('Заказ не найден'),
      );

      // Открываем модалку оплаты через переиспользуемый хелпер
      if (mounted) {
        OrderPaymentHelper.openPayment(
          context,
          order,
          onSuccess: () {
            // После успешной оплаты возвращаемся назад
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('catalog.cart.paymentSuccess'.tr()),
                backgroundColor: const Color(0xFF4CAF50),
              ),
            );
          },
        );
      }
    } catch (e) {
      debugPrint('Error creating order: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('catalog.cart.createOrderError'.tr(namedArgs: {'error': e.toString()}))));
      }
    }
  }

  void _openDatePicker() {
    DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      minTime: DateTime.now(),
      maxTime: DateTime.now().add(const Duration(days: 365)),
      currentTime: _selectedDate ?? DateTime.now(),
      locale: LocaleType.ru,
      onConfirm: (date) {
        setState(() {
          _selectedDate = date;
        });
      },
    );
  }

  void _editAddress() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('catalog.cart.editAddress'.tr()),
        content: TextField(
          controller: _addressController,
          decoration: InputDecoration(hintText: 'catalog.cart.enterAddress'.tr()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('catalog.cart.cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _address = _addressController.text;
              });
              Navigator.pop(context);
            },
            child: Text('catalog.cart.save'.tr()),
          ),
        ],
      ),
    );
  }

  int get _totalPrice {
    return _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('d MMMM, yyyy', 'ru').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              height: MediaQuery.of(context).padding.top,
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
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
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          controller: _scrollController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.all(
                                  AppSizes.paddingMedium,
                                ),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 10,
                                      offset: Offset(0, -2),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                    AppSizes.paddingMedium,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'catalog.cart.title'.tr(namedArgs: {'count': '${_cartItems.length}'}),
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1d1c1a),
                                          fontFamily: 'Manrope',
                                        ),
                                      ),
                                      const SizedBox(
                                        height: AppSizes.paddingLarge,
                                      ),
                                      Text(
                                        'catalog.cart.deliveryDate'.tr(),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF1d1c1a),
                                          fontFamily: 'Manrope',
                                        ),
                                      ),
                                      const SizedBox(
                                        height: AppSizes.paddingSmall,
                                      ),
                                      Text(
                                        _selectedDate != null
                                            ? _formatDate(_selectedDate)
                                            : '',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF1d1c1a),
                                          fontFamily: 'Manrope',
                                        ),
                                      ),
                                      const SizedBox(
                                        height: AppSizes.paddingLarge,
                                      ),
                                      if (_cartItems.isNotEmpty) ...[
                                        ..._cartItems.map(
                                          (item) => _buildCartItem(item),
                                        ),
                                        const SizedBox(
                                          height: AppSizes.paddingLarge,
                                        ),
                                      ],
                                      Text(
                                        'catalog.cart.address'.tr(),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF1d1c1a),
                                          fontFamily: 'Manrope',
                                        ),
                                      ),
                                      const SizedBox(
                                        height: AppSizes.paddingSmall,
                                      ),
                                      if (_address.isNotEmpty)
                                        Text(
                                          _address,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF1d1c1a),
                                            fontFamily: 'Manrope',
                                          ),
                                        ),
                                      const SizedBox(
                                        height: AppSizes.paddingLarge,
                                      ),
                                      Text(
                                        'catalog.cart.additionalComments'.tr(),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF1d1c1a),
                                          fontFamily: 'Manrope',
                                        ),
                                      ),
                                      const SizedBox(
                                        height: AppSizes.paddingSmall,
                                      ),
                                      TextField(
                                        controller: _commentsController,
                                        maxLines: 4,
                                        decoration: InputDecoration(
                                          hintText:
                                              'catalog.cart.additionalComments'.tr(),
                                          hintStyle: TextStyle(
                                            color: AppColors.accordionBorder,
                                            fontFamily: 'Manrope',
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide(
                                              color: AppColors.accordionBorder
                                                  .withOpacity(0.3),
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide(
                                              color: AppColors.accordionBorder
                                                  .withOpacity(0.3),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide(
                                              color: AppColors.accordionBorder
                                                  .withOpacity(0.3),
                                            ),
                                          ),
                                        ),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF1d1c1a),
                                          fontFamily: 'Manrope',
                                        ),
                                      ),
                                      const SizedBox(
                                        height: AppSizes.paddingLarge,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'catalog.cart.total'.tr(),
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF1d1c1a),
                                              fontFamily: 'Manrope',
                                            ),
                                          ),
                                          Text(
                                            '$_totalPrice 〒',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF1d1c1a),
                                              fontFamily: 'Manrope',
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: AppSizes.paddingLarge,
                                      ),
                                      AppButton(
                                        text: 'catalog.cart.pay'.tr(),
                                        onPressed: _createOrder,
                                        backgroundColor:
                                            AppColors.buttonBackground,
                                      ),
                                      const SizedBox(
                                        height: AppSizes.paddingMedium,
                                      ),
                                      AppButton(
                                        text: 'catalog.cart.back'.tr(),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        isOutlined: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (_additionalProducts.isNotEmpty) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSizes.paddingMedium,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: AppSizes.paddingLarge,
                                      ),
                                      Text(
                                        'catalog.cart.additionalServices'.tr(),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1d1c1a),
                                          fontFamily: 'Manrope',
                                        ),
                                      ),
                                      const SizedBox(
                                        height: AppSizes.paddingMedium,
                                      ),
                                      ..._additionalProducts.map(
                                        (product) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: AppSizes.paddingMedium,
                                          ),
                                          child: ProductCard(
                                            product: product,
                                            onDetailsTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProductDetailsPage(
                                                        product: product,
                                                      ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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

  Widget _buildCartItem(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
      padding: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: AppColors.accordionBorder.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.product.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1d1c1a),
              fontFamily: 'Manrope',
            ),
          ),
          if (item.product.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              item.product.description,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.accordionBorder,
                fontFamily: 'Manrope',
              ),
            ),
          ],
          const SizedBox(height: AppSizes.paddingMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(8),
                        ),
                        onTap: () {
                          _updateQuantity(item, item.quantity - 1);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.remove,
                            size: 20,
                            color: Color(0xFF1d1c1a),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1d1c1a),
                          fontFamily: 'Manrope',
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(8),
                        ),
                        onTap: () {
                          _updateQuantity(item, item.quantity + 1);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.add,
                            size: 20,
                            color: Color(0xFF1d1c1a),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${item.totalPrice} 〒',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1d1c1a),
                  fontFamily: 'Manrope',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
