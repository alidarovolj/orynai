import 'package:flutter/material.dart';

/// Константы цветов приложения Orynai
class AppColors {
  // Фон страницы
  static const Color background = Color.fromRGBO(250, 247, 238, 1);
  
  // Цвет кнопок
  static const Color buttonBackground = Color.fromRGBO(233, 185, 73, 1);
  
  // Цвет зеленых кнопок (WhatsApp)
  static const Color buttonGreen = Color(0xFF25D366);
  
  // Цвет границ
  static const Color border = Color.fromRGBO(32, 16, 1, 1);
  
  // Цвет границ аккордеонов
  static const Color accordionBorder = Color(0xFFAFB5C1);
  
  // Цвет иконок и некоторых текстов
  static const Color iconAndText = Color.fromRGBO(67, 58, 63, 1);
  
  // Цвет хэдера при скролле
  static const Color headerScrolled = Color(0xFF1F1004);
  
  // Приватный конструктор, чтобы предотвратить создание экземпляров
  AppColors._();
}

/// Константы размеров и отступов
class AppSizes {
  // Отступы
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  // Размеры кнопок
  static const double buttonHeight = 56.0;
  static const double buttonBorderRadius = 12.0;
  
  // Размеры логотипов
  static const double headerLogoSize = 40.0;
  static const double mainLogoHeight = 120.0;
  
  // Приватный конструктор
  AppSizes._();
}
