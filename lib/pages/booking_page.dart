import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../constants.dart';
import '../models/cemetery.dart';
import '../models/grave.dart';
import '../widgets/header.dart';
import '../widgets/app_button.dart';
import '../services/api_service.dart';
import '../widgets/booking_success_modal.dart';

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
  final ApiService _apiService = ApiService();
  bool _isScrolled = false;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _iinController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _deathDateController = TextEditingController();
  final TextEditingController _burialDateController = TextEditingController();
  final TextEditingController _burialTimeController = TextEditingController();
  bool _datesEnabled = false;
  bool _isLoadingDeceased = false;
  String? _lastSearchedIin;
  DateTime? _deathDate;
  DateTime? _burialDate;
  TimeOfDay? _burialTime;
  File? _deathCertificateFile;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _iinController.addListener(_onIinChanged);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _iinController.removeListener(_onIinChanged);
    _scrollController.dispose();
    _iinController.dispose();
    _fullNameController.dispose();
    _deathDateController.dispose();
    _burialDateController.dispose();
    _burialTimeController.dispose();
    super.dispose();
  }

  void _onIinChanged() {
    final iin = _iinController.text.replaceAll(RegExp(r'[^\d]'), '');
    
    // Отправляем запрос когда ИИН содержит 12 символов
    if (iin.length == 12 && iin != _lastSearchedIin) {
      _lastSearchedIin = iin;
      _searchDeceasedByIin(iin);
    }
  }

  Future<void> _searchDeceasedByIin(String iin) async {
    setState(() {
      _isLoadingDeceased = true;
    });

    try {
      final response = await _apiService.searchDeceasedByIin(iin);
      
      // Проверяем, найдены ли данные
      if (response['code'] == null || response['code'] == 'FDTH_PERSON_NOT_FOUND') {
        // Данные не найдены, оставляем поле ФИО пустым
        debugPrint('Deceased not found for IIN: $iin');
      } else if (response['data'] != null) {
        // Данные найдены, заполняем ФИО
        final data = response['data'] as Map<String, dynamic>;
        final surname = data['surname']?.toString() ?? '';
        final name = data['name']?.toString() ?? '';
        final patronymic = data['patronymic']?.toString() ?? '';
        
        final fullNameParts = <String>[];
        if (surname.isNotEmpty) fullNameParts.add(surname);
        if (name.isNotEmpty) fullNameParts.add(name);
        if (patronymic.isNotEmpty) fullNameParts.add(patronymic);
        
        if (fullNameParts.isNotEmpty) {
          setState(() {
            _fullNameController.text = fullNameParts.join(' ');
          });
        }
      }
    } catch (e) {
      debugPrint('Error searching deceased: $e');
      // Не показываем ошибку пользователю, просто оставляем поле пустым
    } finally {
      setState(() {
        _isLoadingDeceased = false;
      });
    }
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

  Future<void> _selectDeathDate(BuildContext context) async {
    DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      minTime: DateTime(1900),
      maxTime: DateTime.now(),
      currentTime: _deathDate ?? DateTime.now(),
      locale: LocaleType.ru,
      onConfirm: (date) {
        setState(() {
          _deathDate = date;
          _deathDateController.text =
              '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
        });
      },
    );
  }

  Future<void> _selectBurialDate(BuildContext context) async {
    DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      minTime: DateTime.now(),
      maxTime: DateTime.now().add(const Duration(days: 365)),
      currentTime: _burialDate ?? DateTime.now(),
      locale: LocaleType.ru,
      onConfirm: (date) {
        setState(() {
          _burialDate = date;
          _burialDateController.text =
              '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
        });
      },
    );
  }

  Future<void> _selectBurialTime(BuildContext context) async {
    final currentTime = _burialTime != null
        ? DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            _burialTime!.hour,
            _burialTime!.minute,
          )
        : DateTime.now();

    DatePicker.showTimePicker(
      context,
      showTitleActions: true,
      currentTime: currentTime,
      locale: LocaleType.ru,
      onConfirm: (date) {
        setState(() {
          _burialTime = TimeOfDay(hour: date.hour, minute: date.minute);
          _burialTimeController.text =
              '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
        });
      },
    );
  }

  Future<void> _pickDeathCertificate() async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (file != null) {
        setState(() {
          _deathCertificateFile = File(file.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
      if (mounted) {
        String errorMessage = 'Ошибка выбора файла';
        
        // Более понятное сообщение для разных типов ошибок
        if (e.toString().contains('channel-error') || 
            e.toString().contains('Unable to establish connection')) {
          errorMessage = 'Не удалось открыть галерею. Проверьте разрешения приложения.';
        } else if (e.toString().contains('permission')) {
          errorMessage = 'Необходимо разрешение на доступ к галерее';
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

  void _removeDeathCertificate() {
    setState(() {
      _deathCertificateFile = null;
    });
  }

  Widget _buildFileUploadField() {
    if (_deathCertificateFile != null) {
      // Показываем загруженный файл
      final fileName = _deathCertificateFile!.path.split('/').last;
      final fileSize = _deathCertificateFile!.lengthSync() / 1024; // KB

      return Container(
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
                    fileName,
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
                    '${fileSize.toStringAsFixed(1)} KB',
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
              onPressed: _removeDeathCertificate,
            ),
          ],
        ),
      );
    } else {
      // Показываем кнопку загрузки
      return GestureDetector(
        onTap: _pickDeathCertificate,
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.accordionBorder.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.upload_file,
                color: AppColors.iconAndText,
                size: 24,
              ),
              const SizedBox(width: AppSizes.paddingSmall),
              const Text(
                'Загрузить файл',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1d1c1a),
                  fontFamily: 'Manrope',
                ),
              ),
            ],
          ),
        ),
      );
    }
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
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(12),
                            ],
                            decoration: InputDecoration(
                              hintText: 'ИИН',
                              hintStyle: TextStyle(
                                color: AppColors.accordionBorder,
                                fontFamily: 'Manrope',
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              suffixIcon: _isLoadingDeceased
                                  ? const Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    )
                                  : null,
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
                          // Поля дат (показываются при включенном переключателе)
                          if (_datesEnabled) ...[
                            const SizedBox(height: AppSizes.paddingLarge),
                            // Дата смерти
                            const Text(
                              'Дата смерти',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1d1c1a),
                                fontFamily: 'Manrope',
                              ),
                            ),
                            const SizedBox(height: AppSizes.paddingSmall),
                            GestureDetector(
                              onTap: () => _selectDeathDate(context),
                              child: TextField(
                                controller: _deathDateController,
                                enabled: false,
                                decoration: InputDecoration(
                                  hintText: 'ДД.ММ.ГГГГ',
                                  hintStyle: TextStyle(
                                    color: AppColors.accordionBorder,
                                    fontFamily: 'Manrope',
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  suffixIcon: Icon(
                                    Icons.calendar_today,
                                    color: AppColors.accordionBorder,
                                    size: 20,
                                  ),
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
                                  disabledBorder: OutlineInputBorder(
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
                            ),
                            const SizedBox(height: AppSizes.paddingLarge),
                            // Загрузка файла заключения о смерти
                            const Text(
                              'Заключение о смерти от мед учереждении:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1d1c1a),
                                fontFamily: 'Manrope',
                              ),
                            ),
                            const SizedBox(height: AppSizes.paddingSmall),
                            _buildFileUploadField(),
                            const SizedBox(height: AppSizes.paddingLarge),
                            // Дата похорон
                            const Text(
                              'Дата похорон:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1d1c1a),
                                fontFamily: 'Manrope',
                              ),
                            ),
                            const SizedBox(height: AppSizes.paddingSmall),
                            GestureDetector(
                              onTap: () => _selectBurialDate(context),
                              child: TextField(
                                controller: _burialDateController,
                                enabled: false,
                                decoration: InputDecoration(
                                  hintText: 'ДД.ММ.ГГГГ',
                                  hintStyle: TextStyle(
                                    color: AppColors.accordionBorder,
                                    fontFamily: 'Manrope',
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  suffixIcon: Icon(
                                    Icons.calendar_today,
                                    color: AppColors.accordionBorder,
                                    size: 20,
                                  ),
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
                                  disabledBorder: OutlineInputBorder(
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
                            ),
                            const SizedBox(height: AppSizes.paddingLarge),
                            // Время похорон
                            const Text(
                              'Время похорон',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1d1c1a),
                                fontFamily: 'Manrope',
                              ),
                            ),
                            const SizedBox(height: AppSizes.paddingSmall),
                            GestureDetector(
                              onTap: () => _selectBurialTime(context),
                              child: TextField(
                                controller: _burialTimeController,
                                enabled: false,
                                decoration: InputDecoration(
                                  hintText: '—:—',
                                  hintStyle: TextStyle(
                                    color: AppColors.accordionBorder,
                                    fontFamily: 'Manrope',
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  suffixIcon: Icon(
                                    Icons.access_time,
                                    color: AppColors.accordionBorder,
                                    size: 20,
                                  ),
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
                                  disabledBorder: OutlineInputBorder(
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
                            ),
                          ],
                          const SizedBox(height: AppSizes.paddingXLarge),
                          // Кнопка "Забронировать место"
                          AppButton(
                            text: 'Забронировать место',
                            onPressed: _handleBooking,
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

  Future<void> _handleBooking() async {
    // Проверяем обязательные поля
    final iin = _iinController.text.replaceAll(RegExp(r'[^\d]'), '');
    final fullName = _fullNameController.text.trim();

    if (iin.isEmpty || iin.length != 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите корректный ИИН (12 цифр)')),
      );
      return;
    }

    if (fullName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите ФИО покойного')),
      );
      return;
    }

    try {
      // Отправляем запрос на бронирование
      await _apiService.createBurialRequest(
        cemeteryId: widget.cemetery.id,
        fullName: fullName,
        inn: iin,
        graveId: widget.grave.id,
        deathCertUrl: null, // TODO: Загрузить файл на сервер и получить URL
      );

      // Показываем модалку успеха
      if (mounted) {
        BookingSuccessModal.show(context);
      }
    } catch (e) {
      debugPrint('Error creating burial request: $e');
      if (mounted) {
        String errorMessage = 'Ошибка бронирования';
        
        // Извлекаем понятное сообщение об ошибке
        if (e is ApiException) {
          errorMessage = e.message;
          // Если в теле ответа есть более детальное сообщение, используем его
          if (e.body != null && e.body!['message'] != null) {
            errorMessage = e.body!['message'].toString();
          }
        } else {
          errorMessage = 'Ошибка бронирования: ${e.toString()}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}
