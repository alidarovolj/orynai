import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants.dart';
import '../services/api_service.dart';
import '../services/auth_state_manager.dart';
import '../widgets/header.dart';
import '../models/order.dart';
import '../models/burial_request.dart';
import '../models/notification.dart' as models;
import '../widgets/order_payment_button.dart';
import '../widgets/app_button.dart';
import 'create_memorial_page.dart';
import '../models/cemetery.dart';
import '../services/cemetery_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  final int? initialTab;

  const ProfilePage({super.key, this.initialTab});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late TabController _tabController;
  bool _isScrolled = false;
  final ScrollController _scrollController = ScrollController();

  String? _fullName;
  String? _iin;
  String? _phone;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 6,
      vsync: this,
      initialIndex: widget.initialTab ?? 0,
    );
    _scrollController.addListener(_onScroll);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
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

  Future<void> _loadUserData() async {
    try {
      final userData = await _apiService.getCurrentUser();

      // Формируем ФИО из отдельных полей
      final name = userData['name']?.toString() ?? '';
      final surname = userData['surname']?.toString() ?? '';
      final patronymic = userData['patronymic']?.toString() ?? '';

      final fullNameParts = <String>[];
      if (surname.isNotEmpty) fullNameParts.add(surname);
      if (name.isNotEmpty) fullNameParts.add(name);
      if (patronymic.isNotEmpty) fullNameParts.add(patronymic);

      setState(() {
        _fullName = fullNameParts.isNotEmpty ? fullNameParts.join(' ') : null;
        _iin = userData['iin']?.toString();
        _phone = userData['phone']?.toString();
      });
    } catch (e) {
      debugPrint('Error loading user data: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('profile.errors.loadData'.tr(namedArgs: {'error': e.toString()}))));
      }
    }
  }

  String _formatPhone(String? phone) {
    if (phone == null || phone.isEmpty) return '';

    // Убираем все нецифровые символы
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Форматируем как +7 (XXX) XXX XX XX
    if (digits.length >= 10) {
      final code = digits.substring(digits.length - 10, digits.length - 7);
      final first = digits.substring(digits.length - 7, digits.length - 4);
      final second = digits.substring(digits.length - 4, digits.length - 2);
      final third = digits.substring(digits.length - 2);

      return '+7 ($code) $first $second $third';
    }

    return phone;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                  // На странице профиля не нужно ничего делать при нажатии на имя
                  // Можно оставить null, чтобы использовалось дефолтное поведение
                  // или просто ничего не делать, так как мы уже на странице профиля
                ),
                // Вкладки
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: const Color(0xFF1d1c1a),
                    unselectedLabelColor: AppColors.accordionBorder,
                    indicatorColor: AppColors.buttonBackground,
                    labelStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Manrope',
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Manrope',
                    ),
                    tabAlignment: TabAlignment.start,
                    tabs: [
                      Tab(text: 'profile.tabs.personalData'.tr()),
                      Tab(text: 'profile.tabs.orders'.tr()),
                      Tab(text: 'profile.tabs.burialRequests'.tr()),
                      Tab(text: 'profile.tabs.notifications'.tr()),
                      Tab(text: 'profile.tabs.akimatAppeals'.tr()),
                      Tab(text: 'profile.tabs.reburialRequest'.tr()),
                    ],
                  ),
                ),
                // Контент вкладок
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPersonalDataTab(),
                      _buildOrdersTab(),
                      _buildBurialRequestsTab(),
                      _buildNotificationsTab(),
                      _buildAkimatAppealsTab(),
                      _buildReburialRequestTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalDataTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDataRow(label: 'profile.fullName'.tr(), value: _fullName ?? 'profile.emptyValue'.tr()),
          const SizedBox(height: AppSizes.paddingLarge),
          _buildDataRow(label: 'profile.iin'.tr(), value: _iin ?? 'profile.emptyValue'.tr()),
          const SizedBox(height: AppSizes.paddingLarge),
          _buildDataRow(label: 'profile.phone'.tr(), value: _formatPhone(_phone)),
        ],
      ),
    );
  }

  Widget _buildOrdersTab() {
    return OrdersListWidget(apiService: _apiService);
  }

  Widget _buildBurialRequestsTab() {
    return BurialRequestsListWidget(apiService: _apiService);
  }

  Widget _buildNotificationsTab() {
    return NotificationsListWidget(apiService: _apiService);
  }

  Widget _buildAkimatAppealsTab() {
    return AkimatAppealsWidget(apiService: _apiService);
  }

  Widget _buildReburialRequestTab() {
    return ReburialRequestWidget(apiService: _apiService);
  }

  Widget _buildDataRow({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.accordionBorder,
            fontFamily: 'Manrope',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1d1c1a),
            fontFamily: 'Manrope',
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(Order order) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    String createdAt = '';
    try {
      final date = DateTime.parse(order.createdAt);
      createdAt = dateFormat.format(date);
    } catch (e) {
      createdAt = order.createdAt;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.accordionBorder.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'profile.orderNumber'.tr(namedArgs: {'id': order.id.toString()}),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1d1c1a),
                  fontFamily: 'Manrope',
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: order.status == 'new'
                      ? const Color(0xFF4CAF50)
                      : order.status == 'pending_payment'
                          ? Colors.orange
                          : AppColors.accordionBorder,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  order.status == 'new'
                      ? 'profile.orderStatusNew'.tr()
                      : order.status == 'pending_payment'
                          ? 'profile.orderStatusPendingPayment'.tr()
                          : order.status,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontFamily: 'Manrope',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          Text(
            'profile.date'.tr(namedArgs: {'date': createdAt}),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.accordionBorder,
              fontFamily: 'Manrope',
            ),
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          Text(
            'profile.amount'.tr(namedArgs: {'amount': order.totalPrice.toString()}),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1d1c1a),
              fontFamily: 'Manrope',
            ),
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          // Список товаров
          ...order.items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${item.product?.name ?? 'profile.product'.tr()} x${item.quantity}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.accordionBorder,
                  fontFamily: 'Manrope',
                ),
              ),
            );
          }),
          const SizedBox(height: AppSizes.paddingMedium),
          // Кнопка "Оплатить" для заказов со статусом "Ожидает оплаты"
          const SizedBox(height: AppSizes.paddingMedium),
          OrderPaymentButton(
            order: order,
            onPaymentSuccess: () {
              // Обновляем список заказов после успешной оплаты
              _loadOrders();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(BurialRequest request) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    String createdAt = '';
    try {
      final date = DateTime.parse(request.createdAt);
      createdAt = dateFormat.format(date);
    } catch (e) {
      createdAt = request.createdAt;
    }

    String reservationExpires = '';
    if (request.reservationExpiresAt != null) {
      try {
        final date = DateTime.parse(request.reservationExpiresAt!);
        reservationExpires = dateFormat.format(date);
      } catch (e) {
        reservationExpires = request.reservationExpiresAt!;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.accordionBorder.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  request.requestNumber,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1d1c1a),
                    fontFamily: 'Manrope',
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: request.status == 'pending'
                      ? Colors.orange
                      : request.status == 'completed'
                          ? const Color(0xFF4CAF50)
                          : request.status == 'cancelled'
                              ? Colors.red
                              : AppColors.accordionBorder,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  request.status == 'pending'
                      ? 'profile.requestStatusPending'.tr()
                      : request.status == 'completed'
                          ? 'profile.requestStatusCompleted'.tr()
                          : request.status == 'cancelled'
                              ? 'profile.requestStatusCancelled'.tr()
                              : request.status,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontFamily: 'Manrope',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          _buildInfoRow('profile.cemetery'.tr(), request.cemeteryName),
          const SizedBox(height: AppSizes.paddingSmall),
          _buildInfoRow('profile.sector'.tr(), request.sectorNumber),
          const SizedBox(height: AppSizes.paddingSmall),
          _buildInfoRow('profile.row'.tr(), request.rowNumber),
          const SizedBox(height: AppSizes.paddingSmall),
          _buildInfoRow('profile.place'.tr(), request.graveNumber),
          if (request.deceased != null) ...[
            const SizedBox(height: AppSizes.paddingSmall),
            _buildInfoRow(
              'profile.deceased'.tr(),
              request.deceased!.fullName,
            ),
          ],
          const SizedBox(height: AppSizes.paddingSmall),
          _buildInfoRow('profile.createdAt'.tr(), createdAt),
          if (reservationExpires.isNotEmpty) ...[
            const SizedBox(height: AppSizes.paddingSmall),
            _buildInfoRow('profile.reservationUntil'.tr(), reservationExpires),
          ],
          // Кнопка "Создать мемориал" только для статуса "pending"
          if (request.status == 'pending') ...[
            const SizedBox(height: AppSizes.paddingMedium),
            AppButton(
              text: 'profile.createMemorial'.tr(),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateMemorialPage(
                      burialRequestId: request.id,
                    ),
                  ),
                );
              },
              backgroundColor: AppColors.buttonBackground,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.accordionBorder,
              fontFamily: 'Manrope',
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF1d1c1a),
              fontFamily: 'Manrope',
            ),
          ),
        ),
      ],
    );
  }

  void _loadOrders() {
    // Метод для обновления списка заказов
    // Будет вызван после успешной оплаты
  }
}

class OrdersListWidget extends StatefulWidget {
  final ApiService apiService;

  const OrdersListWidget({super.key, required this.apiService});

  @override
  State<OrdersListWidget> createState() => _OrdersListWidgetState();
}

class _OrdersListWidgetState extends State<OrdersListWidget> {
  List<Order> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await widget.apiService.get(
        '/api/v1/orders',
        queryParameters: {'page': '1', 'limit': '10'},
        requiresAuth: true,
      );

      final ordersData = OrdersResponse.fromJson(response as Map<String, dynamic>);

      setState(() {
        _orders = ordersData.items;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading orders: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('profile.errors.loadOrders'.tr(namedArgs: {'error': e.toString()}))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_orders.isEmpty) {
      return Center(
        child: Text(
          'profile.noOrders'.tr(),
          style: TextStyle(
            fontSize: 16,
            color: AppColors.accordionBorder,
            fontFamily: 'Manrope',
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    String createdAt = '';
    try {
      final date = DateTime.parse(order.createdAt);
      createdAt = dateFormat.format(date);
    } catch (e) {
      createdAt = order.createdAt;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.accordionBorder.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'profile.orderNumber'.tr(namedArgs: {'id': order.id.toString()}),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1d1c1a),
                  fontFamily: 'Manrope',
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: order.status == 'new'
                      ? const Color(0xFF4CAF50)
                      : order.status == 'pending_payment'
                          ? Colors.orange
                          : AppColors.accordionBorder,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  order.status == 'new'
                      ? 'profile.orderStatusNew'.tr()
                      : order.status == 'pending_payment'
                          ? 'profile.orderStatusPendingPayment'.tr()
                          : order.status,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontFamily: 'Manrope',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          Text(
            'profile.date'.tr(namedArgs: {'date': createdAt}),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.accordionBorder,
              fontFamily: 'Manrope',
            ),
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          Text(
            'profile.amount'.tr(namedArgs: {'amount': order.totalPrice.toString()}),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1d1c1a),
              fontFamily: 'Manrope',
            ),
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          // Список товаров
          ...order.items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${item.product?.name ?? 'profile.product'.tr()} x${item.quantity}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.accordionBorder,
                  fontFamily: 'Manrope',
                ),
              ),
            );
          }),
          const SizedBox(height: AppSizes.paddingMedium),
          // Кнопка "Оплатить" для заказов со статусом "Ожидает оплаты"
          OrderPaymentButton(
            order: order,
            onPaymentSuccess: () {
              // Обновляем список заказов после успешной оплаты
              _loadOrders();
            },
          ),
        ],
      ),
    );
  }
}

class BurialRequestsListWidget extends StatefulWidget {
  final ApiService apiService;

  const BurialRequestsListWidget({super.key, required this.apiService});

  @override
  State<BurialRequestsListWidget> createState() =>
      _BurialRequestsListWidgetState();
}

class _BurialRequestsListWidgetState extends State<BurialRequestsListWidget> {
  List<BurialRequest> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authManager = AuthStateManager();
      final userPhone = authManager.currentUser?.phone ?? '';

      final response = await widget.apiService.get(
        '/api/v8/burial-requests/my',
        queryParameters: {'user_phone': userPhone},
        requiresAuth: true,
      );

      final requestsData = BurialRequestsResponse.fromJson(
        response as Map<String, dynamic>,
      );

      setState(() {
        _requests = requestsData.items;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading burial requests: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('profile.errors.loadRequests'.tr(namedArgs: {'error': e.toString()}))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_requests.isEmpty) {
      return Center(
        child: Text(
          'profile.noBurialRequests'.tr(),
          style: TextStyle(
            fontSize: 16,
            color: AppColors.accordionBorder,
            fontFamily: 'Manrope',
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          final request = _requests[index];
          return _buildRequestCard(request);
        },
      ),
    );
  }

  Widget _buildRequestCard(BurialRequest request) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    String createdAt = '';
    try {
      final date = DateTime.parse(request.createdAt);
      createdAt = dateFormat.format(date);
    } catch (e) {
      createdAt = request.createdAt;
    }

    String reservationExpires = '';
    if (request.reservationExpiresAt != null) {
      try {
        final date = DateTime.parse(request.reservationExpiresAt!);
        reservationExpires = dateFormat.format(date);
      } catch (e) {
        reservationExpires = request.reservationExpiresAt!;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.accordionBorder.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  request.requestNumber,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1d1c1a),
                    fontFamily: 'Manrope',
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: request.status == 'pending'
                      ? Colors.orange
                      : request.status == 'completed'
                          ? const Color(0xFF4CAF50)
                          : request.status == 'cancelled'
                              ? Colors.red
                              : AppColors.accordionBorder,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  request.status == 'pending'
                      ? 'profile.requestStatusPending'.tr()
                      : request.status == 'completed'
                          ? 'profile.requestStatusCompleted'.tr()
                          : request.status == 'cancelled'
                              ? 'profile.requestStatusCancelled'.tr()
                              : request.status,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontFamily: 'Manrope',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          _buildInfoRow('profile.cemetery'.tr(), request.cemeteryName),
          const SizedBox(height: AppSizes.paddingSmall),
          _buildInfoRow('profile.sector'.tr(), request.sectorNumber),
          const SizedBox(height: AppSizes.paddingSmall),
          _buildInfoRow('profile.row'.tr(), request.rowNumber),
          const SizedBox(height: AppSizes.paddingSmall),
          _buildInfoRow('profile.place'.tr(), request.graveNumber),
          if (request.deceased != null) ...[
            const SizedBox(height: AppSizes.paddingSmall),
            _buildInfoRow(
              'profile.deceased'.tr(),
              request.deceased!.fullName,
            ),
          ],
          const SizedBox(height: AppSizes.paddingSmall),
          _buildInfoRow('profile.createdAt'.tr(), createdAt),
          if (reservationExpires.isNotEmpty) ...[
            const SizedBox(height: AppSizes.paddingSmall),
            _buildInfoRow('profile.reservationUntil'.tr(), reservationExpires),
          ],
          // Кнопка "Создать мемориал" только для статуса "pending"
          if (request.status == 'pending') ...[
            const SizedBox(height: AppSizes.paddingMedium),
            AppButton(
              text: 'profile.createMemorial'.tr(),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateMemorialPage(
                      burialRequestId: request.id,
                    ),
                  ),
                );
              },
              backgroundColor: AppColors.buttonBackground,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.accordionBorder,
              fontFamily: 'Manrope',
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF1d1c1a),
              fontFamily: 'Manrope',
            ),
          ),
        ),
      ],
    );
  }
}

class NotificationsListWidget extends StatefulWidget {
  final ApiService apiService;

  const NotificationsListWidget({super.key, required this.apiService});

  @override
  State<NotificationsListWidget> createState() =>
      _NotificationsListWidgetState();
}

class _NotificationsListWidgetState extends State<NotificationsListWidget> {
  List<models.Notification> _notifications = [];
  bool _isLoading = true;
  String _selectedServiceType = 'all';
  int _limit = 10;
  int _offset = 0;
  int _total = 0;
  bool _hasMore = true;

  final List<String> _serviceTypes = ['all', 'supplier-service', 'burial-request-service'];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications({bool loadMore = false}) async {
    if (!loadMore) {
      setState(() {
        _isLoading = true;
        _offset = 0;
      });
    }

    try {
      final serviceName = _selectedServiceType == 'all' ? null : _selectedServiceType;
      final response = await widget.apiService.getNotifications(
        limit: _limit,
        offset: loadMore ? _offset : 0,
        serviceName: serviceName,
      );

      final notificationsData = models.NotificationsResponse.fromJson(response);

      setState(() {
        if (loadMore) {
          _notifications.addAll(notificationsData.notifications);
        } else {
          _notifications = notificationsData.notifications;
        }
        _total = notificationsData.total;
        _offset = notificationsData.offset + notificationsData.notifications.length;
        _hasMore = _offset < _total;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('profile.errors.loadNotifications'.tr(namedArgs: {'error': e.toString()}))),
        );
      }
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await widget.apiService.markAllNotificationsAsRead();
      setState(() {
        for (var notification in _notifications) {
          // Обновляем статус локально
          // В реальном приложении нужно обновить модель
        }
      });
      await _loadNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('profile.allMarkedAsRead'.tr()),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error marking all as read: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('profile.errors.generic'.tr(namedArgs: {'error': e.toString()}))),
        );
      }
    }
  }

  Future<void> _markAsRead(models.Notification notification) async {
    if (notification.isRead) return;

    try {
      await widget.apiService.markNotificationAsRead(notification.id);
      setState(() {
        // Обновляем статус локально
        // В реальном приложении нужно обновить модель
      });
      await _loadNotifications();
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  String _formatDateTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final localDateTime = dateTime.toLocal();
      final dateFormat = DateFormat('dd.MM.yyyy, HH:mm');
      return dateFormat.format(localDateTime);
    } catch (e) {
      return dateTimeStr;
    }
  }

  String _getNotificationTitle(models.Notification notification) {
    // Формируем заголовок как "Уведомление - {subject} - {номер}"
    String title = 'profile.notificationTitle'.tr(namedArgs: {'subject': notification.subject});
    
    // Извлекаем номер из data
    if (notification.data.containsKey('order_id')) {
      title += ' - ${notification.data['order_id']}';
    } else if (notification.data.containsKey('request_number')) {
      title += ' - ${notification.data['request_number']}';
    }
    
    return title;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Заголовок и кнопка "Пометить все как прочитанные"
        Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'profile.notificationsTitle'.tr(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1d1c1a),
                  fontFamily: 'Manrope',
                ),
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              // Кнопка "Пометить все как прочитанные"
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _markAllAsRead,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'profile.markAllAsRead'.tr(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'Manrope',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              // Фильтры
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'profile.serviceType'.tr(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1d1c1a),
                            fontFamily: 'Manrope',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.accordionBorder.withOpacity(0.3),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: DropdownButton<String>(
                            value: _selectedServiceType,
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: _serviceTypes.map((String type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(
                                  type == 'all' ? 'profile.all'.tr() : type,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Manrope',
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedServiceType = newValue;
                                });
                                _loadNotifications();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'profile.showPer'.tr(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1d1c1a),
                            fontFamily: 'Manrope',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.accordionBorder.withOpacity(0.3),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: DropdownButton<int>(
                            value: _limit,
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: [10, 20, 50].map((int value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text(
                                  value.toString(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Manrope',
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (int? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _limit = newValue;
                                });
                                _loadNotifications();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Список уведомлений
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _notifications.isEmpty
                  ? Center(
                      child: Text(
                        'profile.noNotifications'.tr(),
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.accordionBorder,
                          fontFamily: 'Manrope',
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => _loadNotifications(),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingMedium,
                        ),
                        itemCount: _notifications.length + (_hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _notifications.length) {
                            // Кнопка "Загрузить еще"
                            return Padding(
                              padding: const EdgeInsets.all(AppSizes.paddingMedium),
                              child: Center(
                                child: TextButton(
                                  onPressed: () => _loadNotifications(loadMore: true),
                                  child: Text(
                                    'profile.loadMore'.tr(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Manrope',
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }

                          final notification = _notifications[index];
                          return _buildNotificationCard(notification);
                        },
                      ),
                    ),
        ),
        // Футер "Все уведомления загружены"
        if (!_isLoading && _notifications.isNotEmpty && !_hasMore)
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: Text(
              'profile.allNotificationsLoaded'.tr(),
              style: TextStyle(
                fontSize: 14,
                color: AppColors.accordionBorder,
                fontFamily: 'Manrope',
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNotificationCard(models.Notification notification) {
    return GestureDetector(
      onTap: () => _markAsRead(notification),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.accordionBorder.withOpacity(0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок
                  Text(
                    _getNotificationTitle(notification),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1d1c1a),
                      fontFamily: 'Manrope',
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Контент
                  Text(
                    notification.content,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF1d1c1a),
                      fontFamily: 'Manrope',
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Дата и время
                  Text(
                    _formatDateTime(notification.sentAt),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.accordionBorder,
                      fontFamily: 'Manrope',
                    ),
                  ),
                ],
              ),
            ),
            // Индикатор непрочитанного
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(left: 8, top: 4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class AkimatAppealsWidget extends StatefulWidget {
  final ApiService apiService;

  const AkimatAppealsWidget({super.key, required this.apiService});

  @override
  State<AkimatAppealsWidget> createState() => _AkimatAppealsWidgetState();
}

class _AkimatAppealsWidgetState extends State<AkimatAppealsWidget> {
  final TextEditingController _contentController = TextEditingController();
  int? _selectedTypeId;
  bool _isLoading = false;
  final int _maxContentLength = 3500;

  final List<Map<String, dynamic>> _appealTypes = [
    {'id': 1, 'nameKey': 'profile.appealTypes.complaint'},
    {'id': 2, 'nameKey': 'profile.appealTypes.suggestion'},
    {'id': 3, 'nameKey': 'profile.appealTypes.infoRequest'},
  ];

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _createAppeal() async {
    if (_selectedTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('profile.selectAppealType'.tr())),
      );
      return;
    }

    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('profile.enterAppealText'.tr())),
      );
      return;
    }

    if (content.length > _maxContentLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('profile.appealTextMaxLength'.tr(namedArgs: {'max': _maxContentLength.toString()}))),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authManager = AuthStateManager();
      final userPhone = authManager.currentUser?.phone ?? '';

      if (userPhone.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('profile.errors.userPhoneNotAvailable'.tr())),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      await widget.apiService.createAkimatAppeal(
        userPhone: userPhone,
        typeId: _selectedTypeId!,
        content: content,
        akimatId: 6, // Значение по умолчанию из примера
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('profile.appealCreatedSuccess'.tr()),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );
        
        // Очищаем форму
        setState(() {
          _selectedTypeId = null;
          _contentController.clear();
        });
      }
    } catch (e) {
      debugPrint('Error creating akimat appeal: $e');
      if (mounted) {
        String errorMessage = 'profile.errors.createAppeal'.tr();
        
        if (e is ApiException) {
          errorMessage = e.message;
          if (e.body != null && e.body!['message'] != null) {
            errorMessage = e.body!['message'].toString();
          }
        } else {
          errorMessage = 'profile.errors.createAppealWithError'.tr(namedArgs: {'error': e.toString()});
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок
          Text(
            'profile.createAkimatAppealTitle'.tr(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1d1c1a),
              fontFamily: 'Manrope',
            ),
          ),
          const SizedBox(height: AppSizes.paddingXLarge),
          // Поле "Тип обращения"
          Text(
            'profile.appealType'.tr(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1d1c1a),
              fontFamily: 'Manrope',
            ),
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.accordionBorder.withOpacity(0.3),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButton<int>(
              value: _selectedTypeId,
              isExpanded: true,
              underline: const SizedBox(),
              hint: Text(
                'profile.selectAppealType'.tr(),
                style: TextStyle(
                  color: AppColors.accordionBorder,
                  fontFamily: 'Manrope',
                ),
              ),
              items: _appealTypes.map((type) {
                return DropdownMenuItem<int>(
                  value: type['id'] as int,
                  child: Text(
                    (type['nameKey'] as String).tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1d1c1a),
                      fontFamily: 'Manrope',
                    ),
                  ),
                );
              }).toList(),
              onChanged: (int? value) {
                setState(() {
                  _selectedTypeId = value;
                });
              },
            ),
          ),
          const SizedBox(height: AppSizes.paddingXLarge),
          // Поле "Обращение"
          Text(
            'profile.appeal'.tr(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1d1c1a),
              fontFamily: 'Manrope',
            ),
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.accordionBorder.withOpacity(0.3),
              ),
            ),
            child: TextField(
              controller: _contentController,
              maxLines: 10,
              maxLength: _maxContentLength,
              decoration: InputDecoration(
                hintText: 'profile.enterAppealText'.tr(),
                hintStyle: TextStyle(
                  color: AppColors.accordionBorder,
                  fontFamily: 'Manrope',
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                counterStyle: TextStyle(
                  color: AppColors.accordionBorder,
                  fontFamily: 'Manrope',
                ),
              ),
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF1d1c1a),
                fontFamily: 'Manrope',
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          const SizedBox(height: AppSizes.paddingXLarge),
          // Кнопка "Создать обращение"
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _createAppeal,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonBackground,
                disabledBackgroundColor: AppColors.accordionBorder,
                padding: const EdgeInsets.symmetric(
                  vertical: AppSizes.paddingMedium,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'profile.createAppeal'.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: 'Manrope',
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReburialRequestWidget extends StatefulWidget {
  final ApiService apiService;

  const ReburialRequestWidget({super.key, required this.apiService});

  @override
  State<ReburialRequestWidget> createState() => _ReburialRequestWidgetState();
}

class _ReburialRequestWidgetState extends State<ReburialRequestWidget> {
  final CemeteryService _cemeteryService = CemeteryService();
  final TextEditingController _reasonController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  
  List<Cemetery> _cemeteries = [];
  Cemetery? _oldCemetery;
  Cemetery? _newCemetery;
  File? _deathCertificateFile;
  File? _kinshipConfirmationFile;
  File? _graveDocumentFile;
  bool _isLoadingCemeteries = true;
  bool _isSubmitting = false;
  final int _maxReasonLength = 500;

  @override
  void initState() {
    super.initState();
    _loadCemeteries();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadCemeteries() async {
    try {
      final cemeteries = await _cemeteryService.getCemeteries();
      setState(() {
        _cemeteries = cemeteries;
        _isLoadingCemeteries = false;
      });
    } catch (e) {
      debugPrint('Error loading cemeteries: $e');
      setState(() {
        _isLoadingCemeteries = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('profile.errors.loadCemeteries'.tr(namedArgs: {'error': e.toString()}))),
        );
      }
    }
  }

  Future<void> _pickFile(FileType type) async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (file != null) {
        setState(() {
          switch (type) {
            case FileType.deathCertificate:
              _deathCertificateFile = File(file.path);
              break;
            case FileType.kinshipConfirmation:
              _kinshipConfirmationFile = File(file.path);
              break;
            case FileType.graveDocument:
              _graveDocumentFile = File(file.path);
              break;
          }
        });
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
      if (mounted) {
        String errorMessage = 'profile.errors.filePick'.tr();
        
        if (e.toString().contains('channel-error') || 
            e.toString().contains('Unable to establish connection')) {
          errorMessage = 'profile.errors.galleryOpen'.tr();
        } else if (e.toString().contains('permission')) {
          errorMessage = 'profile.errors.galleryPermission'.tr();
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _removeFile(FileType type) {
    setState(() {
      switch (type) {
        case FileType.deathCertificate:
          _deathCertificateFile = null;
          break;
        case FileType.kinshipConfirmation:
          _kinshipConfirmationFile = null;
          break;
        case FileType.graveDocument:
          _graveDocumentFile = null;
          break;
      }
    });
  }

  Widget _buildFileUploadSection({
    required String title,
    required File? file,
    required VoidCallback onPickFile,
    required VoidCallback onRemoveFile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1d1c1a),
            fontFamily: 'Manrope',
          ),
        ),
        const SizedBox(height: AppSizes.paddingSmall),
        if (file != null)
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.accordionBorder.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.insert_drive_file,
                  color: AppColors.iconAndText,
                  size: 24,
                ),
                const SizedBox(width: AppSizes.paddingSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file.path.split('/').last,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1d1c1a),
                          fontFamily: 'Manrope',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${(file.lengthSync() / 1024).toStringAsFixed(1)} KB',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.accordionBorder,
                          fontFamily: 'Manrope',
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  color: AppColors.iconAndText,
                  onPressed: onRemoveFile,
                ),
              ],
            ),
          )
        else
          GestureDetector(
            onTap: onPickFile,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.paddingXLarge),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.accordionBorder.withOpacity(0.3),
                  style: BorderStyle.solid,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.upload_file,
                    size: 48,
                    color: AppColors.accordionBorder,
                  ),
                  const SizedBox(height: AppSizes.paddingMedium),
                  Text(
                    'profile.uploadFiles'.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1d1c1a),
                      fontFamily: 'Manrope',
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingSmall),
                  Text(
                    'profile.uploadFilesHint'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.accordionBorder,
                      fontFamily: 'Manrope',
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingMedium),
                  AppButton(
                    text: 'profile.upload'.tr(),
                    onPressed: onPickFile,
                    isOutlined: true,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _submitRequest() async {
    if (_oldCemetery == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('profile.errors.selectOldBurialPlace'.tr())),
      );
      return;
    }

    if (_newCemetery == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('profile.errors.selectNewBurialPlace'.tr())),
      );
      return;
    }

    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('profile.errors.enterReburialReason'.tr())),
      );
      return;
    }

    if (_deathCertificateFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('profile.errors.uploadDeathCertificate'.tr())),
      );
      return;
    }

    if (_kinshipConfirmationFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('profile.errors.uploadKinshipConfirmation'.tr())),
      );
      return;
    }

    if (_graveDocumentFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('profile.errors.uploadGraveDocument'.tr())),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // TODO: Реализовать отправку запроса на перезахоронение
      // await widget.apiService.createReburialRequest(...);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('profile.reburialRequestCreatedSuccess'.tr()),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );
        
        // Очищаем форму
        setState(() {
          _oldCemetery = null;
          _newCemetery = null;
          _reasonController.clear();
          _deathCertificateFile = null;
          _kinshipConfirmationFile = null;
          _graveDocumentFile = null;
        });
      }
    } catch (e) {
      debugPrint('Error creating reburial request: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('profile.errors.createRequest'.tr(namedArgs: {'error': e.toString()})),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок
          Text(
            'profile.createReburialTitle'.tr(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1d1c1a),
              fontFamily: 'Manrope',
            ),
          ),
          const SizedBox(height: AppSizes.paddingXLarge),
          // Старое место захоронения
          Text(
            'profile.oldBurialPlace'.tr(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1d1c1a),
              fontFamily: 'Manrope',
            ),
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.accordionBorder.withOpacity(0.3),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButton<Cemetery>(
              value: _oldCemetery,
              isExpanded: true,
              underline: const SizedBox(),
              hint: Text(
                'profile.selectCemetery'.tr(),
                style: TextStyle(
                  color: AppColors.accordionBorder,
                  fontFamily: 'Manrope',
                ),
              ),
              items: _cemeteries.map((cemetery) {
                return DropdownMenuItem<Cemetery>(
                  value: cemetery,
                  child: Text(
                    cemetery.name,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1d1c1a),
                      fontFamily: 'Manrope',
                    ),
                  ),
                );
              }).toList(),
              onChanged: _isLoadingCemeteries
                  ? null
                  : (Cemetery? value) {
                      setState(() {
                        _oldCemetery = value;
                      });
                    },
            ),
          ),
          const SizedBox(height: AppSizes.paddingXLarge),
          // Новое место захоронения
          Text(
            'profile.newBurialPlace'.tr(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1d1c1a),
              fontFamily: 'Manrope',
            ),
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.accordionBorder.withOpacity(0.3),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButton<Cemetery>(
              value: _newCemetery,
              isExpanded: true,
              underline: const SizedBox(),
              hint: Text(
                'profile.selectCemetery'.tr(),
                style: TextStyle(
                  color: AppColors.accordionBorder,
                  fontFamily: 'Manrope',
                ),
              ),
              items: _cemeteries.map((cemetery) {
                return DropdownMenuItem<Cemetery>(
                  value: cemetery,
                  child: Text(
                    cemetery.name,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1d1c1a),
                      fontFamily: 'Manrope',
                    ),
                  ),
                );
              }).toList(),
              onChanged: _isLoadingCemeteries
                  ? null
                  : (Cemetery? value) {
                      setState(() {
                        _newCemetery = value;
                      });
                    },
            ),
          ),
          const SizedBox(height: AppSizes.paddingXLarge),
          // Причина
          Text(
            'profile.reason'.tr(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1d1c1a),
              fontFamily: 'Manrope',
            ),
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.accordionBorder.withOpacity(0.3),
              ),
            ),
            child: TextField(
              controller: _reasonController,
              maxLines: 5,
              maxLength: _maxReasonLength,
              decoration: InputDecoration(
                hintText: 'profile.reasonHint'.tr(),
                hintStyle: TextStyle(
                  color: AppColors.accordionBorder,
                  fontFamily: 'Manrope',
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                counterStyle: TextStyle(
                  color: AppColors.accordionBorder,
                  fontFamily: 'Manrope',
                ),
              ),
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF1d1c1a),
                fontFamily: 'Manrope',
              ),
            ),
          ),
          const SizedBox(height: AppSizes.paddingXLarge),
          // Свидетельство о смерти
          _buildFileUploadSection(
            title: 'profile.deathCertificate'.tr(),
            file: _deathCertificateFile,
            onPickFile: () => _pickFile(FileType.deathCertificate),
            onRemoveFile: () => _removeFile(FileType.deathCertificate),
          ),
          const SizedBox(height: AppSizes.paddingXLarge),
          // Подтверждение родства заявителя
          _buildFileUploadSection(
            title: 'profile.kinshipConfirmation'.tr(),
            file: _kinshipConfirmationFile,
            onPickFile: () => _pickFile(FileType.kinshipConfirmation),
            onRemoveFile: () => _removeFile(FileType.kinshipConfirmation),
          ),
          const SizedBox(height: AppSizes.paddingXLarge),
          // Документ на могилу
          _buildFileUploadSection(
            title: 'profile.graveDocument'.tr(),
            file: _graveDocumentFile,
            onPickFile: () => _pickFile(FileType.graveDocument),
            onRemoveFile: () => _removeFile(FileType.graveDocument),
          ),
          const SizedBox(height: AppSizes.paddingXLarge),
          // Кнопка "Создать запрос в акимат"
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isSubmitting
                    ? AppColors.accordionBorder
                    : AppColors.buttonBackground,
                disabledBackgroundColor: AppColors.accordionBorder,
                padding: const EdgeInsets.symmetric(
                  vertical: AppSizes.paddingMedium,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'profile.createReburialRequest'.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: 'Manrope',
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

enum FileType {
  deathCertificate,
  kinshipConfirmation,
  graveDocument,
}

