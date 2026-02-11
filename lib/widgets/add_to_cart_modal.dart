import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as DatePicker;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../services/api_service.dart';

class AddToCartModal extends StatefulWidget {
  final String productName;
  final int productPrice;
  final int productId;

  const AddToCartModal({
    super.key,
    required this.productName,
    required this.productPrice,
    required this.productId,
  });

  @override
  State<AddToCartModal> createState() => _AddToCartModalState();
}

class _AddToCartModalState extends State<AddToCartModal> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final ApiService _apiService = ApiService();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;
  bool _isFormattingDate = false;
  bool _isFormattingTime = false;
  String? _savedAddress;

  bool get _isFormValid {
    return _addressController.text.trim().isNotEmpty &&
        _selectedDate != null &&
        _selectedTime != null;
  }

  @override
  void initState() {
    super.initState();
    _addressController.addListener(_onFieldChanged);
    _dateController.addListener(_onDateChanged);
    _timeController.addListener(_onTimeChanged);
    _loadSavedAddress();
  }

  Future<void> _loadSavedAddress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedAddress = prefs.getString('last_delivery_address');
      if (savedAddress != null && savedAddress.isNotEmpty) {
        setState(() {
          _savedAddress = savedAddress;
        });
      }
    } catch (e) {
      debugPrint('Ошибка загрузки сохраненного адреса: $e');
    }
  }

  Future<void> _saveAddress(String address) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_delivery_address', address);
      setState(() {
        _savedAddress = address;
      });
    } catch (e) {
      debugPrint('Ошибка сохранения адреса: $e');
    }
  }

  void _useSavedAddress() {
    if (_savedAddress != null && _savedAddress!.isNotEmpty) {
      _addressController.text = _savedAddress!;
      setState(() {});
    }
  }

  void _onFieldChanged() {
    setState(() {});
  }

  void _onDateChanged() {
    if (!_isFormattingDate) {
      _formatDate(_dateController.text);
    }
  }

  void _onTimeChanged() {
    if (!_isFormattingTime) {
      _formatTime(_timeController.text);
    }
  }

  @override
  void dispose() {
    _addressController.removeListener(_onFieldChanged);
    _dateController.removeListener(_onDateChanged);
    _timeController.removeListener(_onTimeChanged);
    _addressController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  void _formatDate(String value) {
    if (_isFormattingDate) return;

    _isFormattingDate = true;

    try {
      // Удаляем все нецифровые символы
      final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

      if (digitsOnly.isEmpty) {
        _dateController.value = TextEditingValue(
          text: '',
          selection: const TextSelection.collapsed(offset: 0),
        );
        _selectedDate = null;
        setState(() {});
        return;
      }

      String formatted = '';
      for (int i = 0; i < digitsOnly.length && i < 8; i++) {
        if (i == 2 || i == 4) {
          formatted += '.';
        }
        formatted += digitsOnly[i];
      }

      final newValue = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );

      if (_dateController.value.text != formatted) {
        _dateController.value = newValue;
      }

      // Парсим дату если она полная
      if (formatted.length == 10) {
        try {
          final parts = formatted.split('.');
          if (parts.length == 3) {
            final day = int.parse(parts[0]);
            final month = int.parse(parts[1]);
            final year = int.parse(parts[2]);
            if (day >= 1 &&
                day <= 31 &&
                month >= 1 &&
                month <= 12 &&
                year >= 2024) {
              _selectedDate = DateTime(year, month, day);
            } else {
              _selectedDate = null;
            }
          }
        } catch (e) {
          _selectedDate = null;
        }
      } else {
        _selectedDate = null;
      }
      setState(() {});
    } finally {
      _isFormattingDate = false;
    }
  }

  void _formatTime(String value) {
    if (_isFormattingTime) return;

    _isFormattingTime = true;

    try {
      // Удаляем все нецифровые символы
      final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

      if (digitsOnly.isEmpty) {
        _timeController.value = TextEditingValue(
          text: '',
          selection: const TextSelection.collapsed(offset: 0),
        );
        _selectedTime = null;
        setState(() {});
        return;
      }

      String formatted = '';
      for (int i = 0; i < digitsOnly.length && i < 4; i++) {
        if (i == 2) {
          formatted += ':';
        }
        formatted += digitsOnly[i];
      }

      final newValue = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );

      if (_timeController.value.text != formatted) {
        _timeController.value = newValue;
      }

      // Парсим время если оно полное
      if (formatted.length == 5) {
        try {
          final parts = formatted.split(':');
          if (parts.length == 2) {
            final hour = int.parse(parts[0]);
            final minute = int.parse(parts[1]);
            if (hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59) {
              _selectedTime = TimeOfDay(hour: hour, minute: minute);
            } else {
              _selectedTime = null;
            }
          }
        } catch (e) {
          _selectedTime = null;
        }
      } else {
        _selectedTime = null;
      }
      setState(() {});
    } finally {
      _isFormattingTime = false;
    }
  }

  Future<void> _openDatePicker(BuildContext context) async {
    DatePicker.DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      minTime: DateTime.now(),
      maxTime: DateTime.now().add(const Duration(days: 365)),
      currentTime: _selectedDate ?? DateTime.now(),
      locale: DatePicker.LocaleType.ru,
      onChanged: (date) {
        // Можно обработать изменение в реальном времени, если нужно
      },
      onConfirm: (date) {
        _isFormattingDate = true;
        try {
          _selectedDate = date;
          final formatted =
              '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
          _dateController.value = TextEditingValue(
            text: formatted,
            selection: TextSelection.collapsed(offset: formatted.length),
          );
          setState(() {});
        } finally {
          _isFormattingDate = false;
        }
      },
    );
  }

  Future<void> _openTimePicker(BuildContext context) async {
    final currentTime = _selectedTime != null
        ? DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            _selectedTime!.hour,
            _selectedTime!.minute,
          )
        : DateTime.now();

    DatePicker.DatePicker.showTimePicker(
      context,
      showTitleActions: true,
      currentTime: currentTime,
      locale: DatePicker.LocaleType.ru,
      onChanged: (date) {
        // Можно обработать изменение в реальном времени, если нужно
      },
      onConfirm: (date) {
        _isFormattingTime = true;
        try {
          _selectedTime = TimeOfDay(hour: date.hour, minute: date.minute);
          final formatted =
              '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
          _timeController.value = TextEditingValue(
            text: formatted,
            selection: TextSelection.collapsed(offset: formatted.length),
          );
          setState(() {});
        } finally {
          _isFormattingTime = false;
        }
      },
    );
  }

  Future<void> _handleConfirm() async {
    if (!_isFormValid) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Объединяем дату и время в один DateTime
      final dateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // Форматируем в ISO 8601 формат (UTC)
      final isoDateTime = dateTime.toUtc().toIso8601String();

      final requestBody = {
        'delivery_arrival_time': isoDateTime,
        'delivery_destination_address': _addressController.text.trim(),
        'product_id': widget.productId,
        'quantity': 1,
      };

      debugPrint('🛒 [AddToCart] Отправка запроса на добавление в корзину:');
      debugPrint('   URL: /api/v1/cart');
      debugPrint('   Body: $requestBody');

      // Отправляем запрос на добавление в корзину
      final response = await _apiService.post(
        '/api/v1/cart',
        body: requestBody,
        requiresAuth: true,
      );

      debugPrint('✅ [AddToCart] Ответ от сервера: $response');

      // Проверяем, что ответ содержит id (успешная отправка)
      if (response is Map && response.containsKey('id')) {
        final cartId = response['id'];
        debugPrint(
          '✅ [AddToCart] Товар успешно добавлен в корзину. ID: $cartId',
        );

        // Сохраняем адрес после успешного добавления
        final address = _addressController.text.trim();
        if (address.isNotEmpty) {
          await _saveAddress(address);
        }

        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'catalog.addToCart.successMessage'.tr(
                  namedArgs: {'id': cartId.toString()},
                ),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        debugPrint('❌ [AddToCart] Неожиданный формат ответа: $response');
        throw Exception('Неожиданный формат ответа от сервера: $response');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [AddToCart] Ошибка при добавлении в корзину:');
      debugPrint('   Ошибка: $e');
      debugPrint('   StackTrace: $stackTrace');

      String errorMessage = 'catalog.addToCart.errorAdd'.tr();

      if (e is ApiException) {
        errorMessage = 'catalog.addToCart.errorAddDetail'.tr(
          namedArgs: {'message': e.message},
        );
        debugPrint('   Status Code: ${e.statusCode}');
        debugPrint('   Body: ${e.body}');
      } else {
        errorMessage = 'catalog.addToCart.errorAddDetail'.tr(
          namedArgs: {'message': e.toString()},
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
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
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок и кнопка закрытия
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'catalog.addToCart.enterData'.tr(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.iconAndText,
                      fontFamily: 'Manrope',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    color: AppColors.iconAndText,
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingLarge),
              // Поле адреса
              Text(
                'catalog.addToCart.enterAddress'.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.iconAndText,
                  fontFamily: 'Manrope',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  hintText: 'catalog.addToCart.addressHint'.tr(),
                  hintStyle: TextStyle(
                    color: AppColors.iconAndText.withOpacity(0.5),
                    fontSize: 16,
                    fontFamily: 'Manrope',
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppColors.accordionBorder.withOpacity(0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppColors.accordionBorder.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.buttonBackground,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.iconAndText,
                  fontFamily: 'Manrope',
                ),
              ),
              // Кнопка "использовать прошлый адрес"
              if (_savedAddress != null && _savedAddress!.isNotEmpty) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _useSavedAddress,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.history,
                        size: 16,
                        color: AppColors.buttonBackground,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'catalog.addToCart.usePreviousAddress'.tr(),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.buttonBackground,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSizes.paddingMedium),
              // Поле даты
              Text(
                'catalog.addToCart.selectDate'.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.iconAndText,
                  fontFamily: 'Manrope',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _dateController,
                keyboardType: TextInputType.number,
                onTap: () => _openDatePicker(context),
                decoration: InputDecoration(
                  hintText: 'catalog.addToCart.dateHint'.tr(),
                  hintStyle: TextStyle(
                    color: AppColors.iconAndText.withOpacity(0.5),
                    fontSize: 16,
                    fontFamily: 'Manrope',
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () => _openDatePicker(context),
                    child: Icon(
                      Icons.calendar_today,
                      color: AppColors.iconAndText.withOpacity(0.5),
                      size: 20,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppColors.accordionBorder.withOpacity(0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppColors.accordionBorder.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.buttonBackground,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.iconAndText,
                  fontFamily: 'Manrope',
                ),
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              // Поле времени
              Text(
                'catalog.addToCart.selectTime'.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.iconAndText,
                  fontFamily: 'Manrope',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _timeController,
                keyboardType: TextInputType.number,
                onTap: () => _openTimePicker(context),
                decoration: InputDecoration(
                  hintText: 'catalog.addToCart.timeHint'.tr(),
                  hintStyle: TextStyle(
                    color: AppColors.iconAndText.withOpacity(0.5),
                    fontSize: 16,
                    fontFamily: 'Manrope',
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () => _openTimePicker(context),
                    child: Icon(
                      Icons.access_time,
                      color: AppColors.iconAndText.withOpacity(0.5),
                      size: 20,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppColors.accordionBorder.withOpacity(0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppColors.accordionBorder.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.buttonBackground,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.iconAndText,
                  fontFamily: 'Manrope',
                ),
              ),
              const SizedBox(height: AppSizes.paddingLarge),
              // Кнопка подтверждения
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isFormValid && !_isLoading
                      ? _handleConfirm
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isFormValid && !_isLoading
                        ? AppColors.buttonBackground
                        : AppColors.buttonBackground.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          'catalog.addToCart.confirm'.tr(),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Manrope',
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
