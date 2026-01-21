import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../services/api_service.dart';
import '../services/auth_state_manager.dart';
import '../widgets/header.dart';
import '../models/order.dart';
import '../models/burial_request.dart';
import '../widgets/app_button.dart';
import 'create_memorial_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

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
    _tabController = TabController(length: 3, vsync: this);
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
                  onProfileTap: () {
                    final authManager = AuthStateManager();
                    if (!authManager.isAuthenticated) {
                      // TODO: Показать модалку авторизации
                    }
                  },
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
      controller: _scrollController,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок
            const Text(
              'ЛИЧНЫЕ ДАННЫЕ',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1d1c1a),
                fontFamily: 'Manrope',
              ),
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            // Разделитель
            Divider(
              color: AppColors.accordionBorder.withOpacity(0.3),
              thickness: 1,
            ),
            const SizedBox(height: AppSizes.paddingLarge),
            // ФИО
            _buildDataRow(label: 'ФИО:', value: _fullName ?? '—'),
            const SizedBox(height: AppSizes.paddingLarge),
            // ИИН
            _buildDataRow(label: 'ИИН:', value: _iin ?? '—'),
            const SizedBox(height: AppSizes.paddingLarge),
            // Номер телефона
            _buildDataRow(
              label: 'Номер телефона:',
              value: _formatPhone(_phone),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersTab() {
    return OrdersListWidget(apiService: _apiService);
  }

  Widget _buildBurialRequestsTab() {
    if (_phone == null || _phone!.isEmpty) {
      return const Center(
        child: Text(
          'Номер телефона не найден',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF1d1c1a),
            fontFamily: 'Manrope',
          ),
        ),
      );
    }
    return BurialRequestsListWidget(
      apiService: _apiService,
      userPhone: _phone!,
    );
  }

  Widget _buildDataRow({required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.accordionBorder,
              fontFamily: 'Manrope',
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.right,
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

class OrdersListWidget extends StatefulWidget {
  final ApiService apiService;

  const OrdersListWidget({super.key, required this.apiService});

  @override
  State<OrdersListWidget> createState() => _OrdersListWidgetState();
}

class _OrdersListWidgetState extends State<OrdersListWidget> {
  List<Order> _orders = [];
  bool _isLoading = true;
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders({bool loadMore = false}) async {
    if (!loadMore) {
      setState(() {
        _isLoading = true;
        _currentPage = 1;
      });
    }

    try {
      final response = await widget.apiService.getOrders(
        page: _currentPage,
        limit: 10,
      );

      final ordersResponse = OrdersResponse.fromJson(response);

      setState(() {
        if (loadMore) {
          _orders.addAll(ordersResponse.items);
        } else {
          _orders = ordersResponse.items;
        }
        _hasMore = _currentPage < ordersResponse.totalPages;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading orders: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка загрузки заказов: $e')));
      }
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('d MMMM yyyy, HH:mm', 'ru').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_orders.isEmpty) {
      return Center(
        child: Text(
          'Заказы отсутствуют',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.accordionBorder,
            fontFamily: 'Manrope',
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      itemCount: _orders.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _orders.length) {
          // Кнопка загрузки еще
          return Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: TextButton(
              onPressed: () {
                setState(() {
                  _currentPage++;
                });
                _loadOrders(loadMore: true);
              },
              child: const Text('Загрузить еще'),
            ),
          );
        }

        final order = _orders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accordionBorder.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок заказа
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Заказ #${order.id}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1d1c1a),
                  fontFamily: 'Manrope',
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.statusText,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1d1c1a),
                    fontFamily: 'Manrope',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          // Дата создания
          Text(
            _formatDate(order.createdAt),
            style: TextStyle(
              fontSize: 14,
              color: AppColors.accordionBorder,
              fontFamily: 'Manrope',
            ),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          // Список товаров
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Изображение товара
                  if (item.product.imageUrls.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.product.imageUrls.first,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 60,
                            color: AppColors.background,
                            child: const Icon(Icons.image),
                          );
                        },
                      ),
                    )
                  else
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.image),
                    ),
                  const SizedBox(width: AppSizes.paddingSmall),
                  // Информация о товаре
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1d1c1a),
                            fontFamily: 'Manrope',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Количество: ${item.quantity}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.accordionBorder,
                            fontFamily: 'Manrope',
                          ),
                        ),
                        Text(
                          '${item.totalPrice} 〒',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1d1c1a),
                            fontFamily: 'Manrope',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          // Итого
          Divider(
            color: AppColors.accordionBorder.withOpacity(0.3),
            thickness: 1,
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Итого:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1d1c1a),
                  fontFamily: 'Manrope',
                ),
              ),
              Text(
                '${order.totalPrice} 〒',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
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

class BurialRequestsListWidget extends StatefulWidget {
  final ApiService apiService;
  final String userPhone;

  const BurialRequestsListWidget({
    super.key,
    required this.apiService,
    required this.userPhone,
  });

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
    _loadBurialRequests();
  }

  Future<void> _loadBurialRequests() async {
    if (widget.userPhone.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await widget.apiService.getBurialRequests(
        userPhone: widget.userPhone,
      );

      final requestsResponse = BurialRequestsResponse.fromJson(response);

      setState(() {
        _requests = requestsResponse.items;
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('d MMMM yyyy, HH:mm', 'ru').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _formatDateShort(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('d.MM.yyyy', 'ru').format(date);
    } catch (e) {
      return dateString;
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
          'Заявки отсутствуют',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.accordionBorder,
            fontFamily: 'Manrope',
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      itemCount: _requests.length,
      itemBuilder: (context, index) {
        final request = _requests[index];
        return _buildRequestCard(request);
      },
    );
  }

  Widget _buildRequestCard(BurialRequest request) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accordionBorder.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок заявки
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  request.requestNumber,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1d1c1a),
                    fontFamily: 'Manrope',
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  request.statusText,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1d1c1a),
                    fontFamily: 'Manrope',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          // Дата создания
          Text(
            'Создана: ${_formatDate(request.createdAt)}',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.accordionBorder,
              fontFamily: 'Manrope',
            ),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          // Информация о кладбище
          _buildInfoRow('Кладбище:', request.cemeteryName),
          const SizedBox(height: AppSizes.paddingSmall),
          // Информация о месте
          _buildInfoRow(
            'Место:',
            'Сектор ${request.sectorNumber}, Ряд ${request.rowNumber}, Место ${request.graveNumber}',
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          // Информация о покойном
          _buildInfoRow('Покойный:', request.deceased.fullName),
          const SizedBox(height: AppSizes.paddingSmall),
          _buildInfoRow('ИИН:', request.deceased.inn),
          const SizedBox(height: AppSizes.paddingSmall),
          // Срок резервации
          _buildInfoRow(
            'Резервация до:',
            _formatDateShort(request.reservationExpiresAt),
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          // Цена
          Divider(
            color: AppColors.accordionBorder.withOpacity(0.3),
            thickness: 1,
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Цена захоронения:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1d1c1a),
                  fontFamily: 'Manrope',
                ),
              ),
              Text(
                '${request.burialPrice} 〒',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1d1c1a),
                  fontFamily: 'Manrope',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          // Кнопка создания мемориала
          AppButton(
            text: 'Создать мемориал',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateMemorialPage(burialRequestId: request.id),
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
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.accordionBorder,
              fontFamily: 'Manrope',
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.right,
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
