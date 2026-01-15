import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants.dart';
import '../models/cemetery.dart';
import '../models/grave.dart';
import '../widgets/header.dart';
import '../widgets/app_button.dart';

class BookingPage extends StatefulWidget {
  final Cemetery cemetery;
  final Grave grave;

  const BookingPage({
    super.key,
    required this.cemetery,
    required this.grave,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  bool _isScrolled = false;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _iinController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  bool _datesEnabled = false;

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
    _iinController.dispose();
    _fullNameController.dispose();
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

  String _getReligionIconPath() {
    return widget.cemetery.religion == 'Ислам'
        ? 'assets/icons/religions/003-islam.svg'
        : 'assets/icons/religions/christianity.svg';
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
                ),
                // Основной контент
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.paddingMedium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Заголовок
                          const Text(
                            'БРОНИРОВАНИЕ МЕСТА',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1d1c1a),
                              fontFamily: 'Manrope',
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingLarge),
                          // Карточка с информацией о месте
                          Container(
                            padding: const EdgeInsets.all(AppSizes.paddingMedium),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Название кладбища
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
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
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        widget.cemetery.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1d1c1a),
                                          fontFamily: 'Manrope',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSizes.paddingMedium),
                                // Срок брони
                                Row(
                                  children: [
                                    const Text(
                                      'Срок брони: ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF1d1c1a),
                                        fontFamily: 'Manrope',
                                      ),
                                    ),
                                    Text(
                                      '3 дня',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.accordionBorder,
                                        fontFamily: 'Manrope',
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.info_outline,
                                      size: 16,
                                      color: AppColors.accordionBorder,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSizes.paddingSmall),
                                // Сектор и место
                                Row(
                                  children: [
                                    const Text(
                                      'Сектор: ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF1d1c1a),
                                        fontFamily: 'Manrope',
                                      ),
                                    ),
                                    Text(
                                      widget.grave.sectorNumber,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.accordionBorder,
                                        fontFamily: 'Manrope',
                                      ),
                                    ),
                                    const SizedBox(width: AppSizes.paddingMedium),
                                    const Text(
                                      'Место: ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF1d1c1a),
                                        fontFamily: 'Manrope',
                                      ),
                                    ),
                                    Text(
                                      widget.grave.graveNumber,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.accordionBorder,
                                        fontFamily: 'Manrope',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSizes.paddingSmall),
                                // ФИО покойного
                                const Text(
                                  'ФИО покойного:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF1d1c1a),
                                    fontFamily: 'Manrope',
                                  ),
                                ),
                                const SizedBox(height: AppSizes.paddingSmall),
                                // Дата похорон
                                Row(
                                  children: [
                                    const Text(
                                      'Дата похорон: ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF1d1c1a),
                                        fontFamily: 'Manrope',
                                      ),
                                    ),
                                    Text(
                                      'Не указано',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.accordionBorder,
                                        fontFamily: 'Manrope',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingXLarge),
                          // Второй заголовок
                          const Text(
                            'БРОНИРОВАНИЕ МЕСТА',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1d1c1a),
                              fontFamily: 'Manrope',
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingLarge),
                          // Инструкция
                          const Text(
                            'Укажите данные покойного',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1d1c1a),
                              fontFamily: 'Manrope',
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingMedium),
                          // Поле ИИН
                          TextField(
                            controller: _iinController,
                            decoration: InputDecoration(
                              hintText: 'ИИН',
                              hintStyle: TextStyle(
                                color: AppColors.accordionBorder,
                                fontFamily: 'Manrope',
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.accordionBorder.withOpacity(0.3),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.accordionBorder.withOpacity(0.3),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.accordionBorder.withOpacity(0.3),
                                ),
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF1d1c1a),
                              fontFamily: 'Manrope',
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingMedium),
                          // Поле ФИО
                          TextField(
                            controller: _fullNameController,
                            decoration: InputDecoration(
                              hintText: 'ФИО',
                              hintStyle: TextStyle(
                                color: AppColors.accordionBorder,
                                fontFamily: 'Manrope',
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.accordionBorder.withOpacity(0.3),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.accordionBorder.withOpacity(0.3),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.accordionBorder.withOpacity(0.3),
                                ),
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF1d1c1a),
                              fontFamily: 'Manrope',
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingLarge),
                          // Переключатель Даты
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Даты',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF1d1c1a),
                                  fontFamily: 'Manrope',
                                ),
                              ),
                              Switch(
                                value: _datesEnabled,
                                onChanged: (value) {
                                  setState(() {
                                    _datesEnabled = value;
                                  });
                                },
                                activeColor: AppColors.buttonBackground,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.paddingXLarge),
                          // Кнопка "Забронировать место"
                          AppButton(
                            text: 'Забронировать место',
                            onPressed: () {
                              // TODO: Реализовать бронирование
                              debugPrint('Booking grave: ${widget.grave.id}');
                              debugPrint('IIN: ${_iinController.text}');
                              debugPrint('Full Name: ${_fullNameController.text}');
                            },
                            backgroundColor: AppColors.buttonBackground,
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 20,
                            ),
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
}
