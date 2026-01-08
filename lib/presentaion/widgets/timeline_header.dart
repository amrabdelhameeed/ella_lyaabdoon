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
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;

        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
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
                    color: isCurrent
                        ? Colors.greenAccent
                        : Colors.blueGrey[300],
                  ),
                ),
              Positioned(
                left: screenWidth / 2 - 1.5,
                bottom: 0,
                height: 15,
                child: Container(
                  width: 3,
                  color: isCurrent ? Colors.greenAccent : Colors.blueGrey[300],
                ),
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isLeftAligned)
                      Expanded(child: _buildTitleCard(context)),
                    if (isLeftAligned) const SizedBox(width: 8),
                    _buildTimeIndicator(),
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

  Widget _buildTimeIndicator() {
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
                  Colors.greenAccent.withOpacity(pulseAnimation.value),
                  Colors.green.withOpacity(pulseAnimation.value),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.greenAccent.withOpacity(
                    0.5 * pulseAnimation.value,
                  ),
                  blurRadius: 12 * pulseAnimation.value,
                  spreadRadius: 2 * pulseAnimation.value,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 3),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'now'.tr(),
                    style: const TextStyle(
                      color: Colors.white,
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
        color: Colors.blueGrey[300],
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Text(
          time,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildTitleCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: isCurrent
            ? LinearGradient(
                colors: [
                  Colors.greenAccent.withOpacity(0.15),
                  Colors.green.withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isCurrent ? null : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrent ? Colors.greenAccent : Colors.blueGrey[300]!,
          width: isCurrent ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isCurrent
                ? Colors.greenAccent.withOpacity(0.2)
                : Colors.black12,
            blurRadius: isCurrent ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        titleKey.tr(), // localized here
        textAlign: isLeftAligned ? TextAlign.right : TextAlign.left,
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
          fontWeight: FontWeight.bold,
          color: isCurrent ? Colors.greenAccent : null,
          fontSize: 18,
        ),
      ),
    );
  }
}
