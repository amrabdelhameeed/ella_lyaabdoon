import 'package:ella_lyaabdoon/core/models/timeline_reward.dart';
import 'package:ella_lyaabdoon/core/services/zikr_widget_service.dart';
import 'package:ella_lyaabdoon/features/home/presentation/widgets/reward_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ella_lyaabdoon/features/history/logic/history_cubit.dart';
import 'package:ella_lyaabdoon/features/history/data/history_db_provider.dart';

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
    return BlocBuilder<HistoryCubit, HistoryState>(
      builder: (context, state) {
        final isChecked = HistoryDBProvider.isCheckedToday(reward.id);

        return LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final centerX = screenWidth / 2;
            // final cardStart = isLeftAligned ? 16.0 : centerX + 16;
            final cardStart = isLeftAligned ? 16.0 : centerX + 14;
            // final cardEnd = isLeftAligned ? centerX - 16 : screenWidth - 16;
            final cardEnd = isLeftAligned ? centerX - 14 : screenWidth - 16;

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
                      color: isChecked
                          ? Colors.green
                          : (isCurrent ? Colors.green : Colors.grey[300]),
                    ),
                  ),

                  // Timeline dot
                  Positioned(
                    left: centerX - 6,
                    top: 34,
                    child: isCurrent || isChecked
                        ? FadeTransition(
                            opacity: pulseAnimation,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: isChecked
                                    ? Colors.green
                                    : Colors.greenAccent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (isChecked
                                                ? Colors.green
                                                : Colors.greenAccent)
                                            .withValues(alpha: 0.6),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: isChecked
                                  ? const Icon(
                                      Icons.check,
                                      size: 8,
                                      color: Colors.white,
                                    )
                                  : null,
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
                    // left: isLeftAligned ? lineEnd : lineStart,
                    left: isLeftAligned
                        ? null
                        : lineStart, // Start from center line
                    right: isLeftAligned ? (screenWidth - lineEnd) : null,
                    top: 39,
                    width: lineWidth,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 2,
                      color: isChecked || isCurrent
                          ? (isChecked ? Colors.green : Colors.greenAccent)
                                .withValues(alpha: 0.5)
                          : Colors.grey[300],
                    ),
                  ),

                  // Reward card
                  Positioned(
                    left: cardStart,
                    right: screenWidth - cardEnd, // Correct calculation?
                    // cardEnd IS the X coordinate for the end boundary? No, variable naming in Logic was confusing.
                    // Let's use simple width/left/right logic.
                    // If left aligned: left = 16. width = centerX - 14 - 16.
                    // If right aligned: left = centerX + 14. right = 16 (from screen edge).
                    top: 8,
                    bottom: 8,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _showRewardDetails(context),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isChecked
                              ? Colors.green.withValues(alpha: 0.05)
                              : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isChecked
                                ? Colors.green.withValues(alpha: 0.5)
                                : (isCurrent
                                      ? Colors.greenAccent.withValues(
                                          alpha: 0.3,
                                        )
                                      : Theme.of(
                                          context,
                                        ).dividerColor.withValues(alpha: 0.1)),
                            width: isChecked ? 2 : 1,
                          ),
                          boxShadow: (isChecked || isCurrent)
                              ? [
                                  BoxShadow(
                                    color:
                                        (isChecked
                                                ? Colors.green
                                                : Colors.greenAccent)
                                            .withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: Row(
                          children: [
                            // Checkbox/Action Button
                            GestureDetector(
                              onTap: () async {
                                context.read<HistoryCubit>().toggleCheck(
                                  reward.id,
                                );
                                await RewardWidgetService.updateWidget(); // Update widget too!
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 12),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isChecked
                                      ? Colors.green.withValues(alpha: 0.2)
                                      : (isCurrent
                                            ? Colors.greenAccent.withValues(
                                                alpha: 0.2,
                                              )
                                            : Colors.grey.withValues(
                                                alpha: 0.2,
                                              )),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  isChecked
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  size: 10,
                                  color: isChecked
                                      ? Colors.green[700]
                                      : (isCurrent
                                            ? Colors.green[700]
                                            : Colors.grey[700]),
                                ),
                              ),
                            ),

                            // Reward title
                            Expanded(
                              child: Text(
                                reward.title,
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isChecked || isCurrent
                                          ? Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.color
                                          : Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.color
                                                ?.withValues(alpha: 0.7),
                                      decoration: isChecked
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
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
      },
    );
  }
}
