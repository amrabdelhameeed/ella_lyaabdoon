import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class TimelineHeader extends StatelessWidget {
  final String titleKey; // localization key instead of raw text
  final String time;
  final bool isCurrent;
  final bool isLeftAligned;
  final bool isFirst;
  final Animation<double> pulseAnimation;

  const TimelineHeader({
    super.key,
    required this.titleKey,
    required this.time,
    required this.isCurrent,
    required this.isLeftAligned,
    required this.isFirst,
    required this.pulseAnimation,
  });
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;

        return Container(
          color: scheme.background,
          height: 80,
          child: Stack(
            children: [
              if (!isFirst)
                Positioned(
                  left: screenWidth / 2 - 1.5,
                  top: 0,
                  height: 15,
                  child: Container(
                    width: 3,
                    color: isCurrent ? scheme.primary : scheme.outlineVariant,
                  ),
                ),
              Positioned(
                left: screenWidth / 2 - 1.5,
                bottom: 0,
                height: 15,
                child: Container(
                  width: 3,
                  color: isCurrent ? scheme.primary : scheme.outlineVariant,
                ),
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isLeftAligned)
                      Expanded(child: _buildTitleCard(context)),
                    if (isLeftAligned) const SizedBox(width: 8),
                    _buildTimeIndicator(context),
                    if (!isLeftAligned) const SizedBox(width: 8),
                    if (!isLeftAligned)
                      Expanded(child: _buildTitleCard(context)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeIndicator(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (isCurrent) {
      return AnimatedBuilder(
        animation: pulseAnimation,
        builder: (context, child) {
          return Container(
            width: 100,
            height: 55,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  scheme.primary.withValues(alpha: 0.6 * pulseAnimation.value),
                  scheme.secondary.withValues(
                    alpha: 0.6 * pulseAnimation.value,
                  ),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: scheme.primary.withValues(
                    alpha: 0.4 * pulseAnimation.value,
                  ),
                  blurRadius: 12 * pulseAnimation.value,
                  spreadRadius: 2 * pulseAnimation.value,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  time,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.onPrimary.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'now'.tr(),
                    style: TextStyle(
                      color: scheme.onPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    return Container(
      width: 100,
      height: 55,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outline),
      ),
      child: Center(
        child: Text(
          time,
          style: TextStyle(
            color: scheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildTitleCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: isCurrent
            ? LinearGradient(
                colors: [
                  scheme.primary.withValues(alpha: 0.15),
                  scheme.secondary.withValues(alpha: 0.08),
                ],
              )
            : null,
        color: isCurrent ? null : scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrent ? scheme.primary : scheme.outline,
          width: isCurrent ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isCurrent
                ? scheme.primary.withValues(alpha: 0.25)
                : Colors.black12,
            blurRadius: isCurrent ? 8 : 4,
          ),
        ],
      ),
      child: Text(
        titleKey.tr(),
        textAlign: isLeftAligned ? TextAlign.right : TextAlign.left,
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: isCurrent ? scheme.primary : null,
        ),
      ),
    );
  }
}
