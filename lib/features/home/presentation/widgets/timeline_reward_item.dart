import 'dart:ui' as ui;
import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:ella_lyaabdoon/core/models/timeline_reward.dart';
import 'package:ella_lyaabdoon/core/services/app_services_database_provider.dart';
import 'package:ella_lyaabdoon/core/services/zikr_widget_service.dart';
import 'package:ella_lyaabdoon/features/home/presentation/widgets/reward_dialog.dart';
import 'package:ella_lyaabdoon/utils/constants/app_colors.dart';
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
    Clarity.setCurrentScreenName('reward_dialog');
    showDialog(
      context: context,
      builder: (context) {
        return RewardDetailDialog(reward: reward);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isArabic = AppServicesDBprovider.currentLocale() == "ar";

    return BlocBuilder<HistoryCubit, HistoryState>(
      builder: (context, state) {
        final isChecked = HistoryDBProvider.isCheckedToday(reward.id);

        return LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final centerX = screenWidth / 2;
            final cardStart = isLeftAligned ? 16.0 : centerX + 14;
            final cardEnd = isLeftAligned ? centerX - 14 : screenWidth - 16;

            final lineStart = centerX + 6;
            final lineEnd = isLeftAligned ? cardEnd : cardStart;
            final lineWidth = (lineEnd - lineStart).abs();

            return SizedBox(
              height: 110,
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
                    top: 44, // 50 (center) - 6 (half of 12 height) = 44
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
                                  color: Colors.white54,
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
                                      color: Colors.white54,
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
                              border: Border.all(
                                color: Colors.white54,
                                width: 2,
                              ),
                            ),
                          ),
                  ),

                  // Horizontal line to card
                  Positioned(
                    left: isLeftAligned ? null : lineStart,
                    right: isLeftAligned ? (screenWidth / 2) : null,

                    top: 49,
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
                    right: screenWidth - cardEnd,
                    top: 8,
                    bottom: 8,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _showRewardDetails(context),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
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
                        child: Directionality(
                          textDirection: isArabic
                              ? ui.TextDirection.rtl
                              : ui.TextDirection.ltr,
                          child: Row(
                            children: [
                              // Square Checkbox Button with enhanced colors
                              GestureDetector(
                                onTap: () async {
                                  context.read<HistoryCubit>().toggleCheck(
                                    reward.id,
                                  );
                                  await RewardWidgetService.updateWidget();
                                },
                                child: Container(
                                  width: 28,
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                    color: isChecked
                                        ? (isDarkMode
                                              ? Colors.green.withValues(
                                                  alpha: 0.25,
                                                )
                                              : Colors.green.withValues(
                                                  alpha: 0.15,
                                                ))
                                        : (isCurrent
                                              ? (isDarkMode
                                                    ? Colors.greenAccent
                                                          .withValues(
                                                            alpha: 0.25,
                                                          )
                                                    : Colors.greenAccent
                                                          .withValues(
                                                            alpha: 0.15,
                                                          ))
                                              : (isDarkMode
                                                    // 🎨 Enhanced dark mode unchecked
                                                    ? Colors.grey[800]!
                                                          .withValues(
                                                            alpha: 0.4,
                                                          )
                                                    // 🎨 Enhanced light mode unchecked
                                                    : Colors.grey[200]!
                                                          .withValues(
                                                            alpha: 0.6,
                                                          ))),
                                    borderRadius:
                                        const BorderRadiusDirectional.only(
                                          topStart: Radius.circular(12),
                                          bottomStart: Radius.circular(12),
                                        ),
                                  ),
                                  child: // Square Checkbox Button
                                  SizedBox(
                                    width: 28,
                                    height: double.infinity,
                                    child: Transform.scale(
                                      scale:
                                          0.9, // Adjust scale to match your 28px width preference
                                      child: Checkbox(
                                        value: isChecked,
                                        // Maintains your Cubit logic
                                        onChanged: (bool? value) async {
                                          context
                                              .read<HistoryCubit>()
                                              .toggleCheck(reward.id);
                                          await RewardWidgetService.updateWidget();
                                        },
                                        // Ensures the shape is slightly rounded like your original BoxDecoration
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Reward title (with proper spacing)
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Stack(
                                    children: [
                                      // Content
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 12,
                                        ),
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          reward.title,
                                          textDirection: ui.TextDirection.rtl,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                fontFamily: 'kufi',
                                                fontWeight: FontWeight.w600,
                                                color: isChecked || isCurrent
                                                    ? Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.color
                                                    : Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.color
                                                          ?.withValues(
                                                            alpha: 0.7,
                                                          ),
                                                decoration: isChecked
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                              ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),

                                      // Smaller / Closer Banner
                                      Positioned(
                                        top: -2,
                                        right: isArabic ? null : -2,
                                        left: isArabic ? -2 : null,
                                        child: Transform.scale(
                                          scale: 0.8, // reduce visual size
                                          child: Banner(
                                            location: isArabic
                                                ? BannerLocation.topEnd
                                                : BannerLocation.topEnd,
                                            message:
                                                reward.zikrLevel ==
                                                    ZikrLevel.easy
                                                ? "easy".tr()
                                                : "hard".tr(),
                                            color:
                                                reward.zikrLevel ==
                                                    ZikrLevel.easy
                                                ? Colors.blue
                                                : Colors.orange.withValues(
                                                    alpha: 0.8,
                                                  ),
                                            textStyle: const TextStyle(
                                              fontSize: 11,
                                              fontFamily: 'kufi',
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
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

  Widget _buildLevelBadge(BuildContext context, ZikrLevel level) {
    final isEasy = level == ZikrLevel.easy;
    return Banner(
      location: BannerLocation.topStart,
      message: isEasy ? "easy".tr() : "hard".tr(),
      // child: Text(
      //   // style: TextStyle(
      //   //   fontSize: 10,
      //   //   fontWeight: FontWeight.bold,
      //   //   color: isEasy ? Colors.blue : Colors.orange,
      //   // ),
      // ),
    );
  }
}
