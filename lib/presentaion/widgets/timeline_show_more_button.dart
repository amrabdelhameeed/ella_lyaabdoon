import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class TimelineShowMoreButton extends StatelessWidget {
  final bool isExpanded;
  final int remainingCount;
  final bool isLeftAligned;
  final bool isCurrent;
  final bool isLast;
  final Animation<double> pulseAnimation;
  final VoidCallback onToggle;

  const TimelineShowMoreButton({
    super.key,
    required this.isExpanded,
    required this.remainingCount,
    required this.isLeftAligned,
    required this.isCurrent,
    required this.isLast,
    required this.pulseAnimation,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final centerX = screenWidth / 2;
        final cardStart = isLeftAligned ? 16.0 : centerX + 16;
        final cardEnd = isLeftAligned ? centerX - 16 : screenWidth - 16;

        return SizedBox(
          height: 60,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: centerX - 1.5,
                top: 0,
                bottom: isLast ? null : 0,
                child: Container(
                  width: 3,
                  height: isLast ? 30 : null,
                  color: isCurrent ? Colors.greenAccent : Colors.grey[300],
                ),
              ),
              Positioned(
                left: cardStart,
                right: screenWidth - cardEnd,
                top: 8,
                bottom: 8,
                child: InkWell(
                  onTap: onToggle,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          size: 20,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isExpanded
                              ? 'show_less'.tr()
                              : '+$remainingCount' + "More".tr(),
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
