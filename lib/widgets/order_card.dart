import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../models/order.dart';
import 'app_button.dart';

/// Переиспользуемый виджет карточки заказа
class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onPayPressed;

  const OrderCard({
    super.key,
    required this.order,
    this.onPayPressed,
  });

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('d MMMM yyyy, HH:mm', 'ru').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showPayButton = order.status == 'pending_payment';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accordionBorder.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок заказа
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Заказ #${order.id}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1d1c1a),
                  fontFamily: 'Manrope',
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.statusText,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1d1c1a),
                    fontFamily: 'Manrope',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          // Дата создания
          Text(
            _formatDate(order.createdAt),
            style: TextStyle(
              fontSize: 14,
              color: AppColors.accordionBorder,
              fontFamily: 'Manrope',
            ),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          // Список товаров
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Изображение товара
                  if (item.product.imageUrls.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.product.imageUrls.first,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 60,
                            color: AppColors.background,
                            child: const Icon(Icons.image),
                          );
                        },
                      ),
                    )
                  else
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.image),
                    ),
                  const SizedBox(width: AppSizes.paddingSmall),
                  // Информация о товаре
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1d1c1a),
                            fontFamily: 'Manrope',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Количество: ${item.quantity}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.accordionBorder,
                            fontFamily: 'Manrope',
                          ),
                        ),
                        Text(
                          '${item.totalPrice} 〒',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1d1c1a),
                            fontFamily: 'Manrope',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          // Итого
          Divider(
            color: AppColors.accordionBorder.withOpacity(0.3),
            thickness: 1,
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Итого:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1d1c1a),
                  fontFamily: 'Manrope',
                ),
              ),
              Text(
                '${order.totalPrice} 〒',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1d1c1a),
                  fontFamily: 'Manrope',
                ),
              ),
            ],
          ),
          // Кнопка "Оплатить" для заказов со статусом "Ожидает оплаты"
          if (showPayButton) ...[
            const SizedBox(height: AppSizes.paddingMedium),
            AppButton(
              text: 'Оплатить',
              onPressed: onPayPressed ?? () {
                // Пока ничего не делаем, как просил пользователь
              },
              backgroundColor: AppColors.buttonGreen,
            ),
          ],
        ],
      ),
    );
  }
}
