import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants.dart';
import '../services/auth_state_manager.dart';
import 'login_modal.dart';
import 'app_button.dart';
import '../pages/catalog_page.dart';
import '../pages/cart_page.dart';
import '../pages/cemeteries_page.dart';
import '../pages/profile_page.dart';
import '../pages/about_page.dart';

class MenuModal extends StatelessWidget {
  const MenuModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const MenuModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Переключатель языка
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.accordionBorder.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final isSelected =
                            context.locale.languageCode == 'ru';
                        return GestureDetector(
                          onTap: () {
                            context.setLocale(const Locale('ru'));
                            Navigator.pop(context);
                            MenuModal.show(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSizes.paddingSmall,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'РУ',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: isSelected
                                    ? AppColors.iconAndText
                                    : AppColors.accordionBorder,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final isSelected =
                            context.locale.languageCode == 'kk';
                        return GestureDetector(
                          onTap: () {
                            context.setLocale(const Locale('kk'));
                            Navigator.pop(context);
                            MenuModal.show(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSizes.paddingSmall,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'ҚАЗ',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: isSelected
                                    ? AppColors.iconAndText
                                    : AppColors.accordionBorder,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Кнопка "Корзина" для авторизованных пользователей (под выбором языка)
            Builder(
              builder: (context) {
                final authManager = AuthStateManager();
                if (authManager.isAuthenticated) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      top: AppSizes.paddingLarge,
                    ),
                    child: AppButton(
                      text: 'menu.cart'.tr(),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CartPage(),
                          ),
                        );
                      },
                      backgroundColor: AppColors.buttonBackground,
                      icon: const Icon(
                        Icons.shopping_cart,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: AppSizes.paddingXLarge),
            // Проверяем, авторизован ли пользователь
            Builder(
              builder: (context) {
                final authManager = AuthStateManager();
                final isAuthenticated = authManager.isAuthenticated;

                if (!isAuthenticated) {
                  // Для неавторизованных пользователей
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Секция "КЛИЕНТТЕРГЕ"
                      Text(
                        'menu.forClients'.tr(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.accordionBorder,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingSmall),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.person_outline,
                          color: AppColors.iconAndText,
                        ),
                        title: Text(
                          'menu.loginRegister'.tr(),
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.iconAndText,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (context) => const LoginModal(),
                          );
                        },
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      // Разделитель
                      Divider(
                        color: AppColors.accordionBorder,
                        thickness: 1,
                        height: 1,
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      // Секция "СЕРІКТЕСТЕРГЕ"
                      Text(
                        'menu.forPartners'.tr(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.accordionBorder,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingSmall),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.business_outlined,
                          color: AppColors.iconAndText,
                        ),
                        title: Text(
                          'menu.loginAsProvider'.tr(),
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.iconAndText,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          // TODO: Реализовать вход для партнеров
                        },
                      ),
                      const SizedBox(height: AppSizes.paddingLarge),
                      // Разделитель
                      Divider(
                        color: AppColors.accordionBorder,
                        thickness: 1,
                        height: 1,
                      ),
                      const SizedBox(height: AppSizes.paddingLarge),
                    ],
                  );
                } else {
                  // Для авторизованных пользователей
                  return const SizedBox.shrink();
                }
              },
            ),
            // Навигационные ссылки
            // Кнопка "Профиль" для авторизованных пользователей
            Builder(
              builder: (context) {
                final authManager = AuthStateManager();
                if (authManager.isAuthenticated) {
                  return Column(
                    children: [
                      _buildDrawerMenuItem(
                        text: 'menu.profile'.tr(),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfilePage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AppSizes.paddingSmall),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            _buildDrawerMenuItem(
              text: 'menu.home'.tr(),
              onTap: () {
                Navigator.pop(context);
                // Если мы не на главной странице, возвращаемся на нее
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            _buildDrawerMenuItem(
              text: 'menu.catalog'.tr(),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CatalogPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            _buildDrawerMenuItem(
              text: 'menu.bookPlace'.tr(),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CemeteriesPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            _buildDrawerMenuItem(
              text: 'footer.aboutUs'.tr(),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSizes.paddingMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerMenuItem({
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingSmall),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.iconAndText,
          ),
        ),
      ),
    );
  }
}
