import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants.dart';
import '../models/product.dart';
import '../services/auth_state_manager.dart';
import 'login_modal.dart';
import 'add_to_cart_modal.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onDetailsTap;
  final VoidCallback? onAddTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onDetailsTap,
    this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Изображение продукта (верхняя часть ~60%)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: product.imageUrls.isNotEmpty
                  ? Image.network(
                      product.imageUrls.first,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Если ошибка загрузки, показываем логотип
                        return Image.asset(
                          'assets/images/logos/main.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.accordionBorder.withOpacity(0.2),
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: AppColors.accordionBorder,
                                ),
                              ),
                            );
                          },
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: AppColors.accordionBorder.withOpacity(0.1),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                    )
                  : Image.asset(
                      'assets/images/logos/main.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.accordionBorder.withOpacity(0.2),
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: AppColors.accordionBorder,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
          // Информация о продукте (нижняя часть ~40%)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Название продукта
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.iconAndText,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Цена и доступность
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        '${product.price} 〒',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.iconAndText,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      product.availability ? 'catalog.productCard.inStock'.tr() : 'catalog.productCard.outOfStock'.tr(),
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.iconAndText.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Рейтинг (статичный)
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '4.9',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.iconAndText.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Локация
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: AppColors.iconAndText.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '${product.country}, ${product.city}',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.iconAndText.withOpacity(0.7),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Поставщик
                Row(
                  children: [
                    Icon(
                      Icons.store,
                      size: 14,
                      color: AppColors.iconAndText.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'catalog.productCard.supplier'.tr(),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.iconAndText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Кнопки действий
                Row(
                  children: [
                    // Кнопка "Подробнее"
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onDetailsTap,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            side: BorderSide(
                              color: AppColors.iconAndText.withOpacity(0.3),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'catalog.productCard.details'.tr(),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.iconAndText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Кнопка "Добавить"
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final authManager = AuthStateManager();
                            if (!authManager.isAuthenticated) {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                isScrollControlled: true,
                                builder: (context) => const LoginModal(),
                              );
                            } else {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                isScrollControlled: true,
                                builder: (context) => AddToCartModal(
                                  productName: product.name,
                                  productPrice: product.price,
                                  productId: product.id,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonBackground,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.shopping_cart_outlined,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'catalog.productCard.add'.tr(),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
