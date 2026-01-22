import 'package:flutter/material.dart';
import '../models/order.dart';
import '../widgets/payment_modal.dart';
import '../widgets/app_button.dart';

/// Переиспользуемый виджет кнопки оплаты заказа
/// 
/// Автоматически показывает кнопку "Оплатить" только для заказов
/// со статусом 'pending_payment' и обрабатывает процесс оплаты
class OrderPaymentButton extends StatelessWidget {
  final Order order;
  final VoidCallback? onPaymentSuccess;
  final Color? buttonColor;
  final String? buttonText;

  const OrderPaymentButton({
    super.key,
    required this.order,
    this.onPaymentSuccess,
    this.buttonColor,
    this.buttonText,
  });

  /// Проверяет, нужна ли оплата для этого заказа
  bool get needsPayment => order.status == 'pending_payment';

  void _handlePayment(BuildContext context) {
    OrderPaymentHelper.openPayment(
      context,
      order,
      onSuccess: onPaymentSuccess,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Показываем кнопку только если заказ требует оплаты
    if (!needsPayment) {
      return const SizedBox.shrink();
    }

    return AppButton(
      text: buttonText ?? 'Оплатить',
      onPressed: () => _handlePayment(context),
      backgroundColor: buttonColor ?? const Color(0xFF4CAF50),
    );
  }
}

/// Вспомогательный класс для работы с оплатой заказов
/// 
/// Предоставляет переиспользуемые методы для открытия модалки оплаты
class OrderPaymentHelper {
  /// Открывает модалку оплаты для указанного заказа
  /// 
  /// [context] - контекст для навигации
  /// [order] - заказ для оплаты
  /// [onSuccess] - колбэк, вызываемый после успешной оплаты
  static void openPayment(
    BuildContext context,
    Order order, {
    VoidCallback? onSuccess,
  }) {
    PaymentModal.show(
      context,
      order,
      onSuccess: () {
        // Вызываем пользовательский колбэк, если он предоставлен
        onSuccess?.call();
      },
    );
  }
}
