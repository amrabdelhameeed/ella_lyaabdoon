import 'package:ella_lyaabdoon/models/timeline_reward.dart';
import 'package:ella_lyaabdoon/presentaion/widgets/reward_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ella_lyaabdoon/models/timeline_reward.dart';
import 'package:flutter/material.dart';

class TimelineRewardItem extends StatelessWidget {
  final TimelineReward reward;
  final bool isCurrent;
  final bool isLeftAligned;
  final bool isLast;
  final Animation<double> pulseAnimation;

  const TimelineRewardItem({
    super.key,
    required this.reward,
    required this.isCurrent,
    required this.isLeftAligned,
    required this.isLast,
    required this.pulseAnimation,
  });

  void _showRewardDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => RewardDetailDialog(reward: reward),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final centerX = screenWidth / 2;
        final cardStart = isLeftAligned ? 16.0 : centerX + 16;
        final cardEnd = isLeftAligned ? centerX - 16 : screenWidth - 16;
        final lineStart = centerX + 6;
        final lineEnd = isLeftAligned ? cardEnd : cardStart;
        final lineWidth = (lineEnd - lineStart).abs();

        return SizedBox(
          height: 100,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Vertical timeline line
              Positioned(
                left: centerX - 1.5,
                top: 0,
                bottom: isLast ? null : 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 3,
                  height: isLast ? 35 : null,
                  color: isCurrent ? Colors.greenAccent : Colors.grey[300],
                ),
              ),

              // Timeline dot
              Positioned(
                left: centerX - 6,
                top: 34,
                child: isCurrent
                    ? FadeTransition(
                        opacity: pulseAnimation,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.greenAccent.withOpacity(0.6),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
              ),

              // Horizontal line to card
              Positioned(
                left: isLeftAligned ? lineEnd : lineStart,
                top: 39,
                width: lineWidth,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 2,
                  color: isCurrent
                      ? Colors.greenAccent.withOpacity(0.5)
                      : Colors.grey[300],
                ),
              ),

              // Reward card
              Positioned(
                left: cardStart,
                right: screenWidth - cardEnd,
                top: 8,
                bottom: 8,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _showRewardDetails(context),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCurrent
                            ? Colors.greenAccent.withOpacity(0.3)
                            : Colors.grey[200]!,
                        width: 1,
                      ),
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: Colors.greenAccent.withOpacity(0.1),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        // Reward icon
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? Colors.greenAccent.withOpacity(0.2)
                                : Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.star_rounded,
                            size: 15,
                            color: isCurrent
                                ? Colors.green[700]
                                : Colors.amber[700],
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Reward title
                        Expanded(
                          child: Text(
                            reward.title,
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isCurrent
                                      ? Colors.black87
                                      : Colors.grey[700],
                                ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // const SizedBox(width: 8),

                        // Info icon
                        // Icon(
                        //   Icons.info_outline,
                        //   size: 18,
                        //   color: isCurrent
                        //       ? Colors.green[600]
                        //       : Colors.grey[500],
                        // ),
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
