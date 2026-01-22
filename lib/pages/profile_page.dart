import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../services/api_service.dart';
import '../services/auth_state_manager.dart';
import '../widgets/header.dart';
import '../models/order.dart';
import '../models/burial_request.dart';
import '../models/notification.dart' as models;
import '../widgets/app_button.dart';
import '../widgets/order_payment_button.dart';
import 'create_memorial_page.dart';

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
      length: 4,
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
        ).showSnackBar(SnackBar(content: Text('Ошибка загрузки данных: $e')));
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
                    tabs: const [
                      Tab(text: 'Личные данные'),
                      Tab(text: 'Заказы'),
                      Tab(text: 'Заявки на захоронение'),
                      Tab(text: 'Уведомления'),
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
          _buildDataRow(label: 'ФИО', value: _fullName ?? '—'),
          const SizedBox(height: AppSizes.paddingLarge),
          _buildDataRow(label: 'ИИН', value: _iin ?? '—'),
          const SizedBox(height: AppSizes.paddingLarge),
          _buildDataRow(label: 'Телефон', value: _formatPhone(_phone)),
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
                'Заказ №${order.id}',
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
                      ? 'Новый'
                      : order.status == 'pending_payment'
                          ? 'Ожидает оплаты'
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
            'Дата: $createdAt',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.accordionBorder,
              fontFamily: 'Manrope',
            ),
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          Text(
            'Сумма: ${order.totalPrice} ₸',
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
                '${item.product?.name ?? 'Товар'} x${item.quantity}',
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
                          : AppColors.accordionBorder,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  request.status == 'pending'
                      ? 'Ожидает'
                      : request.status == 'completed'
                          ? 'Завершена'
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
          _buildInfoRow('Кладбище', request.cemeteryName),
          const SizedBox(height: AppSizes.paddingSmall),
          _buildInfoRow('Сектор', request.sectorNumber),
          const SizedBox(height: AppSizes.paddingSmall),
          _buildInfoRow('Ряд', request.rowNumber),
          const SizedBox(height: AppSizes.paddingSmall),
          _buildInfoRow('Место', request.graveNumber),
          if (request.deceased != null) ...[
            const SizedBox(height: AppSizes.paddingSmall),
            _buildInfoRow(
              'Умерший',
              request.deceased!.fullName,
            ),
          ],
          const SizedBox(height: AppSizes.paddingSmall),
          _buildInfoRow('Дата создания', createdAt),
          if (reservationExpires.isNotEmpty) ...[
            const SizedBox(height: AppSizes.paddingSmall),
            _buildInfoRow('Резервация до', reservationExpires),
          ],
          const SizedBox(height: AppSizes.paddingMedium),
          AppButton(
            text: 'Создать мемориал',
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
          SnackBar(content: Text('Ошибка загрузки заказов: $e')),
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
      return const Center(
        child: Text(
          'Заказов пока нет',
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
                'Заказ №${order.id}',
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
                      ? 'Новый'
                      : order.status == 'pending_payment'
                          ? 'Ожидает оплаты'
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
            'Дата: $createdAt',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.accordionBorder,
              fontFamily: 'Manrope',
            ),
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          Text(
            'Сумма: ${order.totalPrice} ₸',
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
                '${item.product?.name ?? 'Товар'} x${item.quantity}',
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
          SnackBar(content: Text('Ошибка загрузки заявок: $e')),
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
      return const Center(
        child: Text(
          'Заявок на захоронение пока нет',
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
                          : AppColors.accordionBorder,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  request.status == 'pending'
                      ? 'Ожидает'
                      : request.status == 'completed'
                          ? 'Завершена'
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
          _buildInfoRow('Кладбище', request.cemeteryName),
          const SizedBox(height: AppSizes.paddingSmall),
          _buildInfoRow('Сектор', request.sectorNumber),
          const SizedBox(height: AppSizes.paddingSmall),
          _buildInfoRow('Ряд', request.rowNumber),
          const SizedBox(height: AppSizes.paddingSmall),
          _buildInfoRow('Место', request.graveNumber),
          if (request.deceased != null) ...[
            const SizedBox(height: AppSizes.paddingSmall),
            _buildInfoRow(
              'Умерший',
              request.deceased!.fullName,
            ),
          ],
          const SizedBox(height: AppSizes.paddingSmall),
          _buildInfoRow('Дата создания', createdAt),
          if (reservationExpires.isNotEmpty) ...[
            const SizedBox(height: AppSizes.paddingSmall),
            _buildInfoRow('Резервация до', reservationExpires),
          ],
          const SizedBox(height: AppSizes.paddingMedium),
          AppButton(
            text: 'Создать мемориал',
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
  String _selectedServiceType = 'Все';
  int _limit = 10;
  int _offset = 0;
  int _total = 0;
  bool _hasMore = true;

  final List<String> _serviceTypes = ['Все', 'supplier-service', 'burial-request-service'];

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
      final serviceName = _selectedServiceType == 'Все' ? null : _selectedServiceType;
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
          SnackBar(content: Text('Ошибка загрузки уведомлений: $e')),
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
          const SnackBar(
            content: Text('Все уведомления помечены как прочитанные'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error marking all as read: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
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
    String title = 'Уведомление - ${notification.subject}';
    
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
              const Text(
                'УВЕДОМЛЕНИЯ',
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
                  child: const Text(
                    'Пометить все как прочитанные',
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
                        const Text(
                          'Тип сервиса:',
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
                                  type,
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
                        const Text(
                          'Показать по:',
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
                  ? const Center(
                      child: Text(
                        'Уведомлений пока нет',
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
                                  child: const Text(
                                    'Загрузить еще',
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
            child: const Text(
              'Все уведомления загружены',
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
