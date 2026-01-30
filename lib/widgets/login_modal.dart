import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:async';
import '../constants.dart';
import '../services/auth_service.dart';
import '../services/auth_state_manager.dart';
import '../models/user.dart';

enum LoginStep {
  phone, // Шаг 1: Ввод номера телефона
  code, // Шаг 2: Ввод кода
  registration, // Шаг 3: Регистрация
}

class LoginModal extends StatefulWidget {
  const LoginModal({super.key});

  @override
  State<LoginModal> createState() => _LoginModalState();
}

class _LoginModalState extends State<LoginModal> {
  final AuthService _authService = AuthService();
  LoginStep _currentStep = LoginStep.phone;

  // Шаг 1: Ввод телефона
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoadingPhone = false;

  // Шаг 2: Ввод кода
  final List<TextEditingController> _codeControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _codeFocusNodes = List.generate(4, (_) => FocusNode());
  bool _isLoadingCode = false;
  int _resendTimer = 0;
  Timer? _timer;

  // Шаг 3: Регистрация
  final TextEditingController _iinController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _patronymicController = TextEditingController();
  bool _isLoadingRegistration = false;
  bool _isLoadingIin = false;
  bool _agreedToTerms = false;

  String _phone = '';

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_formatPhoneNumber);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var focusNode in _codeFocusNodes) {
      focusNode.dispose();
    }
    _iinController.dispose();
    _surnameController.dispose();
    _nameController.dispose();
    _patronymicController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _formatPhoneNumber() {
    final text = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
    if (text.length > 11) {
      _phoneController.text = text.substring(0, 11);
      _phoneController.selection = TextSelection.collapsed(
        offset: _phoneController.text.length,
      );
      return;
    }

    String formatted = '';
    if (text.isNotEmpty) {
      if (text.startsWith('7')) {
        formatted =
            '+7 (${text.substring(1, text.length > 4 ? 4 : text.length)}';
        if (text.length > 4) {
          formatted +=
              ') ${text.substring(4, text.length > 7 ? 7 : text.length)}';
        }
        if (text.length > 7) {
          formatted +=
              '-${text.substring(7, text.length > 9 ? 9 : text.length)}';
        }
        if (text.length > 9) {
          formatted += '-${text.substring(9)}';
        }
      } else {
        formatted = text;
      }
    }

    if (formatted != _phoneController.text) {
      _phoneController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  String _getCleanPhone() {
    return _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
  }

  String _formatPhoneForDisplay(String phone) {
    if (phone.length == 11 && phone.startsWith('7')) {
      return '+7 (${phone.substring(1, 4)}) ${phone.substring(4, 7)}-${phone.substring(7, 9)}-${phone.substring(9)}';
    }
    return phone;
  }

  Future<void> _sendOtp() async {
    final phone = _getCleanPhone();
    if (phone.length < 11 || !phone.startsWith('7')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('login.errors.invalidPhone'.tr()),
        ),
      );
      return;
    }

    setState(() {
      _isLoadingPhone = true;
    });

    try {
      final result = await _authService.sendOtpWhatsApp(phone);
      if (result == 'OK') {
        setState(() {
          _phone = phone;
          _currentStep = LoginStep.code;
          _resendTimer = 60;
        });
        _startResendTimer();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('login.errors.errorGeneric'.tr(namedArgs: {'message': result}))));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('login.errors.errorSendCode'.tr(namedArgs: {'error': e.toString()}))));
    } finally {
      setState(() {
        _isLoadingPhone = false;
      });
    }
  }

  void _startResendTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_resendTimer > 0) {
            _resendTimer--;
          } else {
            timer.cancel();
          }
        });
      }
    });
  }

  String _getCodeFromFields() {
    return _codeControllers.map((controller) => controller.text).join();
  }

  void _handleCodeInput(int index, String value) {
    if (value.isNotEmpty) {
      // Перемещаем фокус на следующее поле
      if (index < 3) {
        _codeFocusNodes[index + 1].requestFocus();
      } else {
        // Если последнее поле заполнено, автоматически проверяем код
        _codeFocusNodes[index].unfocus();
        _verifyCode();
      }
    } else if (value.isEmpty && index > 0) {
      // При удалении возвращаемся к предыдущему полю
      _codeFocusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verifyCode() async {
    final code = _getCodeFromFields();
    if (code.length != 4) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('login.errors.enterFourDigitCode'.tr())));
      return;
    }

    setState(() {
      _isLoadingCode = true;
    });

    try {
      final result = await _authService.verifyOtpWhatsApp(_phone, code);

      if (result['success'] == true) {
        // Успешный вход
        final token = result['token'] ?? result['data']?['token'] ?? '';
        if (token.isNotEmpty) {
        // Сохраняем токен временно для запроса
        final tempUser = User(phone: _phone, token: token);
        await AuthStateManager().setUser(tempUser);
        
        // Получаем данные пользователя
        try {
          final userData = await _authService.getCurrentUser(token);
          // API возвращает: id, name, surname, patronymic, iin, phone
          final user = User(
            phone: userData['phone']?.toString() ?? _phone,
            token: token,
            name: userData['name']?.toString(),
            surname: userData['surname']?.toString(),
            patronymic: userData['patronymic']?.toString(),
            iin: userData['iin']?.toString(),
          );
          await AuthStateManager().setUser(user);
        } catch (e) {
          debugPrint('Error getting user data: $e');
          // Сохраняем хотя бы токен и телефон
          final user = User(
            phone: _phone,
            token: token,
          );
          await AuthStateManager().setUser(user);
        }
        // Сохраняем токен и закрываем модалку
        Navigator.pop(context, {'token': token, 'phone': _phone});
        }
      } else if (result['needsRegistration'] == true) {
        // Нужна регистрация
        setState(() {
          _currentStep = LoginStep.registration;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error']?['description'] ?? 'login.errors.invalidCode'.tr()),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('login.errors.errorVerify'.tr(namedArgs: {'error': e.toString()}))));
    } finally {
      setState(() {
        _isLoadingCode = false;
      });
    }
  }

  Future<void> _sendIinRequest() async {
    final iin = _iinController.text.trim();
    if (iin.length != 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('login.errors.iinMustBe12'.tr())),
      );
      return;
    }

    setState(() {
      _isLoadingIin = true;
    });

    try {
      await _authService.sendIinRequest(iin);
      // Данные должны автоматически заполниться, но так как API не возвращает их,
      // оставляем поля пустыми для ручного ввода
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('login.errors.errorIinRequest'.tr(namedArgs: {'error': e.toString()}))));
    } finally {
      setState(() {
        _isLoadingIin = false;
      });
    }
  }

  Future<void> _register() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('login.errors.agreeToTerms'.tr()),
        ),
      );
      return;
    }

    final iin = _iinController.text.trim();
    final surname = _surnameController.text.trim();
    final name = _nameController.text.trim();
    final patronymic = _patronymicController.text.trim();
    final code = _getCodeFromFields();

    if (iin.isEmpty || surname.isEmpty || name.isEmpty || patronymic.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('login.errors.fillAllFields'.tr())));
      return;
    }

    setState(() {
      _isLoadingRegistration = true;
    });

    try {
      final result = await _authService.signupWhatsApp(
        phone: _phone,
        code: code,
        iin: iin,
        name: name,
        surname: surname,
        patronymic: patronymic,
      );

      final token = result['token'] ?? '';
      if (token.isNotEmpty) {
        // Сохраняем токен временно для запроса
        final tempUser = User(
          phone: _phone,
          token: token,
          iin: iin,
          name: name,
          surname: surname,
          patronymic: patronymic,
        );
        await AuthStateManager().setUser(tempUser);
        
        // Получаем данные пользователя с сервера после регистрации
        try {
          final userData = await _authService.getCurrentUser(token);
          // API возвращает: id, name, surname, patronymic, iin, phone
          final user = User(
            phone: userData['phone']?.toString() ?? _phone,
            token: token,
            name: userData['name']?.toString() ?? name,
            surname: userData['surname']?.toString() ?? surname,
            patronymic: userData['patronymic']?.toString() ?? patronymic,
            iin: userData['iin']?.toString() ?? iin,
          );
          await AuthStateManager().setUser(user);
        } catch (e) {
          debugPrint('Error getting user data: $e');
          // Сохраняем данные из формы регистрации
          final user = User(
            phone: _phone,
            token: token,
            iin: iin,
            name: name,
            surname: surname,
            patronymic: patronymic,
          );
          await AuthStateManager().setUser(user);
        }

        Navigator.pop(context, {
          'token': token,
          'phone': _phone,
          'iin': iin,
          'name': name,
          'surname': surname,
          'patronymic': patronymic,
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('login.errors.registrationError'.tr())));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('login.errors.registrationErrorDetail'.tr(namedArgs: {'error': e.toString()}))));
    } finally {
      setState(() {
        _isLoadingRegistration = false;
      });
    }
  }

  void _resendCode() {
    if (_resendTimer > 0) return;

    _sendOtp();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: 24 + keyboardHeight,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок и кнопка закрытия
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getTitle(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.iconAndText,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Контент в зависимости от шага
            if (_currentStep == LoginStep.phone) _buildPhoneStep(),
            if (_currentStep == LoginStep.code) _buildCodeStep(),
            if (_currentStep == LoginStep.registration) _buildRegistrationStep(),
          ],
        ),
      ),
    );
  }

  String _getTitle() {
    switch (_currentStep) {
      case LoginStep.phone:
        return 'login.titlePhone'.tr();
      case LoginStep.code:
        return 'login.titleCode'.tr();
      case LoginStep.registration:
        return 'login.titleRegistration'.tr();
    }
  }

  Widget _buildPhoneStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'login.enterPhoneLabel'.tr(),
          style: const TextStyle(fontSize: 14, color: AppColors.iconAndText),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: 'login.enterPhoneHint'.tr(),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _isLoadingPhone ? null : _sendOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoadingPhone
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'login.getCodeWhatsApp'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildCodeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'login.codeSentTo'.tr(),
          style: const TextStyle(fontSize: 14, color: AppColors.iconAndText),
        ),
        const SizedBox(height: 8),
        Text(
          _formatPhoneForDisplay(_phone),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.iconAndText,
          ),
        ),
        const SizedBox(height: 24),
        // 4 квадратных поля для ввода кода
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(4, (index) {
            return SizedBox(
              width: 60,
              height: 60,
              child: TextField(
                controller: _codeControllers[index],
                focusNode: _codeFocusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: const Color(0xFFF5F6FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) => _handleCodeInput(index, value),
              ),
            );
          }),
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: _resendTimer == 0 ? _resendCode : null,
          child: Text(
            _resendTimer > 0
                ? 'login.resendCodeIn'.tr(namedArgs: {'seconds': _resendTimer.toString()})
                : 'login.resendCode'.tr(),
            style: TextStyle(
              fontSize: 14,
              color: _resendTimer > 0
                  ? AppColors.accordionBorder
                  : AppColors.buttonBackground,
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _isLoadingCode ? null : _verifyCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoadingCode
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'login.confirm'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          Text(
            'login.enterPhoneLabel'.tr(),
            style: const TextStyle(fontSize: 14, color: AppColors.iconAndText),
          ),
          const SizedBox(height: 8),
          Text(
            _formatPhoneForDisplay(_phone),
            style: const TextStyle(fontSize: 14, color: AppColors.iconAndText),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _iinController,
            keyboardType: TextInputType.number,
            maxLength: 12,
            enabled: !_isLoadingIin,
            decoration: InputDecoration(
              hintText: 'login.enterIinHint'.tr(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              suffixIcon: _isLoadingIin
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) {
              if (value.length == 12) {
                _sendIinRequest();
              }
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _surnameController,
            decoration: InputDecoration(
              hintText: 'login.enterSurnameHint'.tr(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'login.enterNameHint'.tr(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _patronymicController,
            decoration: InputDecoration(
              hintText: 'login.enterPatronymicHint'.tr(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: _agreedToTerms,
                onChanged: (value) {
                  setState(() {
                    _agreedToTerms = value ?? false;
                  });
                },
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _agreedToTerms = !_agreedToTerms;
                    });
                  },
                  child: Text(
                    'login.agreeTerms'.tr(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.iconAndText,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoadingRegistration ? null : _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoadingRegistration
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'login.register'.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
      ],
    );
  }
}
