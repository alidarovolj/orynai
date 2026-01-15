import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants.dart';
import 'tooltip_tail_painter.dart';

class InfoBlock extends StatelessWidget {
  final String backgroundImage;
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onButtonPressed;
  final String? tooltipKey;
  final String? tooltipText;
  final String? openTooltipId;
  final VoidCallback onInfoTap;

  const InfoBlock({
    super.key,
    required this.backgroundImage,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onButtonPressed,
    this.tooltipKey,
    this.tooltipText,
    this.openTooltipId,
    required this.onInfoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.buttonBorderRadius),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Фоновое изображение
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.buttonBorderRadius),
            child: Image.asset(
              backgroundImage,
              fit: BoxFit.cover,
              cacheHeight: 300, // Оптимизация памяти
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.iconAndText,
                );
              },
            ),
          ),
          // Градиент поверх изображения
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.buttonBorderRadius),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(233, 185, 73, 0),
                  AppColors.iconAndText,
                ],
              ),
            ),
          ),
          // Контент
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Заголовок и описание
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Text(
                          description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                // Кнопка и информационная иконка
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: onButtonPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.iconAndText,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: Text(
                            buttonText,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingSmall),
                    // Информационная иконка с подсказкой
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (tooltipText != null) {
                              onInfoTap();
                            }
                          },
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text(
                                'i',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.iconAndText,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (openTooltipId == tooltipKey && tooltipText != null)
                          Positioned(
                            bottom: 40,
                            left: -120,
                            right: -120,
                            child: Center(
                              child: Material(
                                color: Colors.transparent,
                                child: Container(
                                  constraints: const BoxConstraints(
                                    maxWidth: 280,
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    tooltipText!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.iconAndText,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (openTooltipId == tooltipKey && tooltipText != null)
                          Positioned(
                            bottom: 32,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: CustomPaint(
                                size: const Size(16, 8),
                                painter: TooltipTailPainter(isUpward: true),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: AppSizes.paddingSmall),
                    Text(
                      'infoBlocks.howItWorks'.tr(),
                      style: const TextStyle(fontSize: 12, color: Colors.white),
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
