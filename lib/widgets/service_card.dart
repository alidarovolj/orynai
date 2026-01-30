import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants.dart';
import 'app_button.dart';
import 'tooltip_widget.dart';

// Компактная версия кнопки без растягивания на всю ширину
class _CompactAppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const _CompactAppButton({
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.buttonBackground,
          foregroundColor: foregroundColor ?? Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final String iconPath;
  final String title;
  final String description;
  final String buttonText;
  final bool showInfoText;
  final String? tooltipKey;
  final String? tooltipText;
  final String? openTooltipId;
  final VoidCallback onInfoTap;
  final VoidCallback? onButtonPressed;

  const ServiceCard({
    super.key,
    required this.iconPath,
    required this.title,
    required this.description,
    required this.buttonText,
    this.showInfoText = false,
    this.tooltipKey,
    this.tooltipText,
    this.openTooltipId,
    required this.onInfoTap,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.iconAndText,
        borderRadius: BorderRadius.circular(AppSizes.buttonBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Иконка
          SvgPicture.asset(
            iconPath,
            width: 50,
            height: 50,
            placeholderBuilder: (BuildContext context) => Container(
              width: 50,
              height: 50,
              color: Colors.transparent,
            ),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          // Заголовок
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          // Описание
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          // Кнопка и (при наличии тултипа) информационная иконка; текст "Как это работает" только при showInfoText
          tooltipKey != null
              ? Row(
                  children: [
                    Expanded(
                      child: _CompactAppButton(
                        text: buttonText,
                        onPressed: onButtonPressed ?? () {},
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.iconAndText,
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingSmall),
                    TooltipWidget(
                      tooltipKey: tooltipKey,
                      tooltipText: tooltipText,
                      openTooltipId: openTooltipId,
                      showInfoText: showInfoText,
                      onTap: onInfoTap,
                    ),
                  ],
                )
              : AppButton(
                  text: buttonText,
                  onPressed: onButtonPressed ?? () {},
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.iconAndText,
                ),
        ],
      ),
    );
  }
}
