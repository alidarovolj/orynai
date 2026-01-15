import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  // Отправка OTP кода на WhatsApp
  Future<String> sendOtpWhatsApp(String phone) async {
    try {
      final result = await _apiService.post(
        '/api/v2/otp/whatsapp/send',
        body: {'phone': phone},
      );

      if (result is Map && result['data'] != null) {
        final responseBody = result['data'].toString();
        if (responseBody == 'OK' || responseBody.isEmpty) {
          return 'OK';
        }
        return responseBody;
      }
      
      final responseBody = result.toString();
      if (responseBody == 'OK' || responseBody.isEmpty) {
        return 'OK';
      }
      return responseBody;
    } catch (e) {
      if (e is ApiException) {
        throw Exception('Failed to send OTP: ${e.message}');
      }
      throw Exception('Error sending OTP: $e');
    }
  }

  // Верификация OTP кода
  Future<Map<String, dynamic>> verifyOtpWhatsApp(
    String phone,
    String code,
  ) async {
    try {
      final result = await _apiService.post(
        '/api/v2/otp/whatsapp/verify',
        body: {
          'phone': phone,
          'code': code,
        },
      );

      // Проверяем, является ли ошибка "Role not found"
      if (result is Map<String, dynamic> &&
          result['errorCode'] == 500 &&
          result['description']?.toString().contains('Role not found') == true) {
        return {
          'success': false,
          'needsRegistration': true,
          'error': result,
        };
      }

      // Токен может быть в корне ответа или в data
      if (result is Map<String, dynamic>) {
        return {
          'success': true,
          'data': result,
          'token': result['token'] ?? result['data']?['token'],
        };
      }
      
      return {
        'success': true,
        'data': result,
        'token': null,
      };
    } catch (e) {
      if (e is ApiException) {
        // Проверяем, является ли ошибка "Role not found"
        if (e.body?['errorCode'] == 500 &&
            e.body?['description']?.toString().contains('Role not found') ==
                true) {
          return {
            'success': false,
            'needsRegistration': true,
            'error': e.body,
          };
        }
        return {
          'success': false,
          'needsRegistration': false,
          'error': e.body ?? {'description': e.message},
        };
      }
      throw Exception('Error verifying OTP: $e');
    }
  }

  // Отправка запроса на получение данных по ИИН
  Future<Map<String, dynamic>> sendIinRequest(String iin) async {
    try {
      final result = await _apiService.get(
        '/rip-fcb/v1/individual/send/request',
        queryParameters: {'iin': iin},
      );
      if (result is Map<String, dynamic>) {
        return result;
      }
      return {'data': result};
    } catch (e) {
      if (e is ApiException) {
        throw Exception('Failed to send IIN request: ${e.message}');
      }
      throw Exception('Error sending IIN request: $e');
    }
  }

  // Регистрация пользователя через WhatsApp
  Future<Map<String, dynamic>> signupWhatsApp({
    required String phone,
    required String code,
    required String iin,
    required String name,
    required String surname,
    required String patronymic,
  }) async {
    try {
      final result = await _apiService.put(
        '/api/v2/user/signup/whatsapp',
        body: {
          'whatsappOTP': {
            'phone': phone,
            'code': code,
          },
          'iin': iin,
          'name': name,
          'surname': surname,
          'patronymic': patronymic,
        },
      );
      // PUT метод всегда возвращает Map<String, dynamic>
      return result as Map<String, dynamic>;
    } catch (e) {
      if (e is ApiException) {
        throw Exception('Failed to signup: ${e.message}');
      }
      throw Exception('Error during signup: $e');
    }
  }

  // Получение данных текущего пользователя
  Future<Map<String, dynamic>> getCurrentUser(String token) async {
    try {
      // Временно устанавливаем токен для этого запроса
      // (в будущем можно улучшить ApiService для поддержки передачи токена напрямую)
      final result = await _apiService.get(
        '/api/v2/user/current',
        requiresAuth: true,
      );
      // GET метод для /user/current всегда возвращает Map<String, dynamic>
      return result as Map<String, dynamic>;
    } catch (e) {
      if (e is ApiException) {
        throw Exception('Failed to get user: ${e.message}');
      }
      throw Exception('Error getting user: $e');
    }
  }
}
