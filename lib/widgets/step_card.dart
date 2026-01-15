import 'package:flutter/material.dart';
import '../constants.dart';
import 'action_button.dart';

class StepCard extends StatelessWidget {
  final String title;
  final List<String> paragraphs;
  final String buttonText;
  final Color buttonColor;
  final IconData buttonIcon;
  final bool isPhoneIcon;
  final bool isWhatsApp;
  final bool hasSecondButton;
  final String? secondButtonText;
  final Color? secondButtonColor;
  final IconData? secondButtonIcon;
  final bool isSecondButtonWhatsApp;
  final bool buttonsInRow;
  final VoidCallback? onPhoneTap;
  final VoidCallback? onWhatsAppTap;

  const StepCard({
    super.key,
    required this.title,
    required this.paragraphs,
    required this.buttonText,
    required this.buttonColor,
    required this.buttonIcon,
    this.isPhoneIcon = false,
    this.isWhatsApp = false,
    this.hasSecondButton = false,
    this.secondButtonText,
    this.secondButtonColor,
    this.secondButtonIcon,
    this.isSecondButtonWhatsApp = false,
    this.buttonsInRow = false,
    this.onPhoneTap,
    this.onWhatsAppTap,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMedium,
        vertical: AppSizes.paddingSmall,
      ),
      childrenPadding: const EdgeInsets.fromLTRB(
        AppSizes.paddingMedium,
        0,
        AppSizes.paddingMedium,
        AppSizes.paddingMedium,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.buttonBorderRadius),
        side: const BorderSide(color: AppColors.accordionBorder, width: 1),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.buttonBorderRadius),
        side: const BorderSide(color: AppColors.accordionBorder, width: 1),
      ),
      backgroundColor: Colors.white,
      collapsedBackgroundColor: Colors.white,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppColors.iconAndText,
        ),
      ),
      iconColor: AppColors.iconAndText,
      collapsedIconColor: AppColors.iconAndText,
      children: [
        // Текст параграфов
        ...paragraphs.map(
          (paragraph) => Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
            child: Text(
              paragraph,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.iconAndText,
                height: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.paddingMedium),
        // Кнопки
        if (hasSecondButton &&
            secondButtonText != null &&
            secondButtonColor != null &&
            secondButtonIcon != null)
          buttonsInRow
              ? Row(
                  children: [
                    ActionButton(
                      text: buttonText,
                      color: buttonColor,
                      icon: buttonIcon,
                      isPhoneIcon: isPhoneIcon,
                      isWhatsApp: false,
                      onPhoneTap: onPhoneTap,
                    ),
                    const SizedBox(width: AppSizes.paddingMedium),
                    ActionButton(
                      text: secondButtonText!,
                      color: secondButtonColor!,
                      icon: secondButtonIcon!,
                      isPhoneIcon: false,
                      isWhatsApp: isSecondButtonWhatsApp,
                      onWhatsAppTap: onWhatsAppTap,
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ActionButton(
                      text: buttonText,
                      color: buttonColor,
                      icon: buttonIcon,
                      isPhoneIcon: isPhoneIcon,
                      isWhatsApp: false,
                      onPhoneTap: onPhoneTap,
                    ),
                    const SizedBox(height: AppSizes.paddingMedium),
                    ActionButton(
                      text: secondButtonText!,
                      color: secondButtonColor!,
                      icon: secondButtonIcon!,
                      isPhoneIcon: false,
                      isWhatsApp: isSecondButtonWhatsApp,
                      onWhatsAppTap: onWhatsAppTap,
                    ),
                  ],
                )
        else
          Align(
            alignment: Alignment.centerLeft,
            child: ActionButton(
              text: buttonText,
              color: buttonColor,
              icon: buttonIcon,
              isPhoneIcon: isPhoneIcon,
              isWhatsApp: isWhatsApp,
              onPhoneTap: onPhoneTap,
              onWhatsAppTap: onWhatsAppTap,
            ),
          ),
      ],
    );
  }
}
