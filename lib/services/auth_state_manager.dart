import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthStateManager {
  static final AuthStateManager _instance = AuthStateManager._internal();
  factory AuthStateManager() => _instance;
  AuthStateManager._internal();

  User? _currentUser;
  final ApiService _apiService = ApiService();
  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  // Сохранение токена и данных пользователя
  Future<void> setUser(User user) async {
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, user.token);
    await prefs.setString(_userDataKey, json.encode(user.toJson()));
  }

  // Очистка данных пользователя
  Future<void> clearUser() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userDataKey);
  }

  /// Выход из аккаунта: очистка пользователя и всего локального хранилища.
  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Загрузка токена из хранилища
  Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Инициализация при запуске приложения
  Future<bool> initialize() async {
    try {
      final token = await getStoredToken();
      if (token == null || token.isEmpty) {
        return false;
      }

      // Проверяем токен через API
      try {
        // Временно устанавливаем пользователя для получения токена
        _currentUser = User(phone: '', token: token);

        final userData = await _apiService.get(
          '/api/v2/user/current',
          requiresAuth: true,
        );

        // API возвращает: id, name, surname, patronymic, iin, phone
        final user = User(
          phone: userData['phone']?.toString() ?? '',
          token: token,
          name: userData['name']?.toString(),
          surname: userData['surname']?.toString(),
          patronymic: userData['patronymic']?.toString(),
          iin: userData['iin']?.toString(),
        );
        _currentUser = user;
        // Обновляем сохраненные данные
        await setUser(user);
        return true;
      } catch (e) {
        // Токен невалидный, очищаем хранилище
        debugPrint('Token validation failed: $e');
        _currentUser = null;
        await clearUser();
        return false;
      }
    } catch (e) {
      debugPrint('Error initializing auth: $e');
      return false;
    }
  }

  String getDisplayName() {
    if (_currentUser == null) return '';

    final surname = _currentUser!.surname ?? '';
    final name = _currentUser!.name ?? '';

    if (surname.isEmpty && name.isEmpty) {
      return _currentUser!.phone;
    }

    // Формат: А. Олжас (первая буква фамилии + точка + пробел + имя)
    if (surname.isNotEmpty && name.isNotEmpty) {
      final surnameInitial = surname[0].toUpperCase();
      return '$surnameInitial. $name';
    }

    // Если нет фамилии, показываем только имя
    if (name.isNotEmpty) {
      return name;
    }

    // Если нет имени, показываем только фамилию
    if (surname.isNotEmpty) {
      return surname;
    }

    return _currentUser!.phone;
  }
}
