import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants.dart';
import 'tooltip_tail_painter.dart';

class TooltipWidget extends StatelessWidget {
  final String? tooltipKey;
  final String? tooltipText;
  final String? openTooltipId;
  final bool showInfoText;
  final VoidCallback onTap;

  const TooltipWidget({
    super.key,
    this.tooltipKey,
    this.tooltipText,
    this.openTooltipId,
    this.showInfoText = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () {
            if (tooltipText != null) {
              onTap();
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
            left: showInfoText ? -120 : null,
            right: showInfoText ? -120 : 0,
            child: showInfoText
                ? Center(
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
                  )
                : Material(
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
        if (openTooltipId == tooltipKey && tooltipText != null)
          Positioned(
            bottom: 32,
            left: showInfoText ? 0 : null,
            right: showInfoText ? 0 : 20,
            child: showInfoText
                ? Center(
                    child: CustomPaint(
                      size: const Size(16, 8),
                      painter: TooltipTailPainter(isUpward: false),
                    ),
                  )
                : CustomPaint(
                    size: const Size(16, 8),
                    painter: TooltipTailPainter(isUpward: false),
                  ),
          ),
        if (showInfoText)
          Padding(
            padding: const EdgeInsets.only(left: AppSizes.paddingSmall),
            child: Text(
              'services.memorial.howItWorks'.tr(),
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
      ],
    );
  }
}
