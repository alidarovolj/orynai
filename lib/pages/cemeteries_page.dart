import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants.dart';
import '../models/cemetery.dart';
import '../services/cemetery_service.dart';
import '../services/auth_state_manager.dart';
import '../widgets/header.dart';
import '../widgets/cemetery_details_modal.dart';
import '../widgets/login_modal.dart';
import 'profile_page.dart';

class CemeteriesPage extends StatefulWidget {
  const CemeteriesPage({super.key});

  @override
  State<CemeteriesPage> createState() => _CemeteriesPageState();
}

class _CemeteriesPageState extends State<CemeteriesPage> {
  final CemeteryService _cemeteryService = CemeteryService();
  final ScrollController _scrollController = ScrollController();
  List<Cemetery> _allCemeteries = [];
  List<Cemetery> _filteredCemeteries = [];
  bool _isLoading = true;
  bool _isScrolled = false;
  String? _selectedReligion;
  final List<String> _religionKeys = ['all', 'islam', 'christianity'];
  
  String _getReligionDisplayName(String key) {
    switch (key) {
      case 'all':
        return 'booking.cemeteries.all'.tr();
      case 'islam':
        return 'booking.cemeteries.islam'.tr();
      case 'christianity':
        return 'booking.cemeteries.christianity'.tr();
      default:
        return key;
    }
  }
  
  String _getReligionApiValue(String key) {
    switch (key) {
      case 'islam':
        return 'Ислам';
      case 'christianity':
        return 'Христианство';
      default:
        return '';
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Устанавливаем черный статус-бар для белого фона
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    _loadCemeteries();
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
      // Статус-бар всегда черный для белого фона
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    }
  }

  Future<void> _loadCemeteries() async {
    try {
      final cemeteries = await _cemeteryService.getCemeteries();
      setState(() {
        _allCemeteries = cemeteries;
        _filteredCemeteries = cemeteries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('booking.cemeteries.loadError'.tr(namedArgs: {'error': e.toString()}))));
      }
    }
  }

  void _filterByReligion(String? religion) {
    setState(() {
      _selectedReligion = religion;
      if (religion == null || religion == 'all') {
        _filteredCemeteries = _allCemeteries;
      } else {
        final apiReligion = _getReligionApiValue(religion);
        _filteredCemeteries = _allCemeteries
            .where((cemetery) => cemetery.religion == apiReligion)
            .toList();
      }
    });
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
                // Хедер
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
                          setState(() {
                            // Обновляем UI после авторизации
                          });
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
                // Основной контент
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView(
                          controller: _scrollController,
                          padding: EdgeInsets.zero,
                          children: [
                            // Заголовок
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.paddingMedium,
                                vertical: AppSizes.paddingLarge,
                              ),
                              child: Text(
                                'booking.cemeteries.title'.tr(),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.iconAndText,
                                ),
                              ),
                            ),
                            // Город
                            // Container(
                            //   width: double.infinity,
                            //   color: Colors.white,
                            //   padding: const EdgeInsets.symmetric(
                            //     horizontal: AppSizes.paddingMedium,
                            //     vertical: 12,
                            //   ),
                            //   child: Row(
                            //     children: [
                            //       const Text(
                            //         'Город:',
                            //         style: TextStyle(
                            //           fontSize: 16,
                            //           fontWeight: FontWeight.w600,
                            //           color: AppColors.iconAndText,
                            //         ),
                            //       ),
                            //       const SizedBox(width: 8),
                            //       const Expanded(
                            //         child: Text(
                            //           'Не выбрано',
                            //           style: TextStyle(
                            //             fontSize: 16,
                            //             color: AppColors.iconAndText,
                            //           ),
                            //         ),
                            //       ),
                            //       Icon(
                            //         Icons.keyboard_arrow_down,
                            //         color: AppColors.iconAndText.withOpacity(
                            //           0.5,
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            // const SizedBox(height: 1),
                            // Фильтр по религии
                            Container(
                              color: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.paddingMedium,
                                vertical: 12,
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: _selectedReligion,
                                  hint: Text(
                                    'booking.cemeteries.religion'.tr(),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.iconAndText,
                                    ),
                                  ),
                                  icon: Icon(
                                    Icons.keyboard_arrow_down,
                                    color: AppColors.iconAndText.withOpacity(
                                      0.5,
                                    ),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AppColors.iconAndText,
                                  ),
                                  items: _religionKeys.map((String key) {
                                    return DropdownMenuItem<String>(
                                      value: key,
                                      child: Text(_getReligionDisplayName(key)),
                                    );
                                  }).toList(),
                                  onChanged: _filterByReligion,
                                ),
                              ),
                            ),
                            // Количество результатов
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.paddingMedium,
                                vertical: 16,
                              ),
                              child: Text(
                                'booking.cemeteries.results'.tr(namedArgs: {'count': _filteredCemeteries.length.toString()}),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color.fromRGBO(34, 34, 34, 1),
                                ),
                              ),
                            ),
                            // Список кладбищ
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.paddingMedium,
                              ),
                              child: Column(
                                children: _filteredCemeteries.map((cemetery) {
                                  return _CemeteryListItem(cemetery: cemetery);
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: AppSizes.paddingLarge),
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
}

class _CemeteryListItem extends StatelessWidget {
  final Cemetery cemetery;

  const _CemeteryListItem({required this.cemetery});

  String _getReligionIconPath() {
    return cemetery.religion == 'Ислам'
        ? 'assets/icons/religions/003-islam.svg'
        : 'assets/icons/religions/christianity.svg';
  }

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
                builder: (context) => CemeteryDetailsModal(cemetery: cemetery),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Иконка религии
                SizedBox(
                  width: 40,
                  height: 40,
                  child: Center(
                    child: SvgPicture.asset(
                      _getReligionIconPath(),
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(
                        AppColors.iconAndText,
                        BlendMode.srcIn,
                      ),
                      placeholderBuilder: (BuildContext context) => Container(
                        width: 24,
                        height: 24,
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Информация о кладбище
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cemetery.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color.fromRGBO(5, 2, 2, 1),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${cemetery.streetName}, ${cemetery.city}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Color.fromRGBO(92, 103, 113, 1),
                        ),
                      ),
                    ],
                  ),
                ),
                // Стрелка
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
