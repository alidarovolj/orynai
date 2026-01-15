import 'package:flutter/material.dart';
import '../constants.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final Widget? icon;
  final bool isOutlined;
  final double? fontSize;
  final EdgeInsets? padding;
  final double? height;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth,
    this.icon,
    this.isOutlined = false,
    this.fontSize,
    this.padding,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final buttonPadding = padding ?? const EdgeInsets.symmetric(vertical: 14);
    final buttonFontSize = fontSize ?? 14.0;
    final buttonHeight = height ?? AppSizes.buttonHeight;

    if (isOutlined) {
      return SizedBox(
        width: double.infinity,
        height: buttonHeight,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: foregroundColor ?? AppColors.iconAndText,
            padding: buttonPadding,
            side: BorderSide(
              color: borderColor ?? AppColors.accordionBorder.withOpacity(0.3),
              width: borderWidth ?? 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: AppSizes.paddingSmall),
              ],
              Text(
                text,
                style: TextStyle(
                  fontSize: buttonFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return SizedBox(
        width: double.infinity,
        height: buttonHeight,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppColors.buttonBackground,
            foregroundColor: foregroundColor ?? Colors.white,
            padding: buttonPadding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: AppSizes.paddingSmall),
              ],
              Text(
                text,
                style: TextStyle(
                  fontSize: buttonFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
