import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants.dart';
import '../services/api_service.dart';
import '../services/auth_state_manager.dart';
import '../widgets/header.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  bool _isScrolled = false;
  final ScrollController _scrollController = ScrollController();

  String? _fullName;
  String? _iin;
  String? _phone;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    _loadUserData();
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

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

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
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
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
                // Основной контент
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          controller: _scrollController,
                          child: Padding(
                            padding: const EdgeInsets.all(
                              AppSizes.paddingMedium,
                            ),
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
                                  color: AppColors.accordionBorder.withOpacity(
                                    0.3,
                                  ),
                                  thickness: 1,
                                ),
                                const SizedBox(height: AppSizes.paddingLarge),
                                // ФИО
                                _buildDataRow(
                                  label: 'ФИО:',
                                  value: _fullName ?? '—',
                                ),
                                const SizedBox(height: AppSizes.paddingLarge),
                                // ИИН
                                _buildDataRow(
                                  label: 'ИИН:',
                                  value: _iin ?? '—',
                                ),
                                const SizedBox(height: AppSizes.paddingLarge),
                                // Номер телефона
                                _buildDataRow(
                                  label: 'Номер телефона:',
                                  value: _formatPhone(_phone),
                                ),
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
