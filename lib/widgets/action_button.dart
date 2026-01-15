import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants.dart';

class ActionButton extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;
  final bool isPhoneIcon;
  final bool isWhatsApp;
  final VoidCallback? onPhoneTap;
  final VoidCallback? onWhatsAppTap;

  const ActionButton({
    super.key,
    required this.text,
    required this.color,
    required this.icon,
    this.isPhoneIcon = false,
    this.isWhatsApp = false,
    this.onPhoneTap,
    this.onWhatsAppTap,
  });

  @override
  Widget build(BuildContext context) {
    // Определяем цвет текста и иконки в зависимости от цвета кнопки
    final bool isYellowButton = color == AppColors.buttonBackground;
    final Color textAndIconColor = isYellowButton
        ? const Color(0xFF201001)
        : Colors.white;

    Widget? iconWidget;
    if (isWhatsApp) {
      iconWidget = SvgPicture.asset(
        'assets/icons/whatsapp.svg',
        width: 20,
        height: 20,
        colorFilter: ColorFilter.mode(textAndIconColor, BlendMode.srcIn),
        placeholderBuilder: (BuildContext context) => Container(
          width: 20,
          height: 20,
          color: Colors.transparent,
        ),
      );
    } else {
      iconWidget = Icon(icon, size: 20, color: textAndIconColor);
    }

    return ElevatedButton(
      onPressed: isWhatsApp
          ? onWhatsAppTap
          : isPhoneIcon
              ? onPhoneTap
              : () {
                  // TODO: Реализовать действие для других кнопок
                },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textAndIconColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconWidget,
          const SizedBox(width: AppSizes.paddingSmall),
          Text(
            text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
