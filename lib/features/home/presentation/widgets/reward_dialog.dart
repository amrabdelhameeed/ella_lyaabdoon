import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:ella_lyaabdoon/features/home/logic/translation_cubit.dart';
import 'package:ella_lyaabdoon/core/models/timeline_reward.dart';
import 'package:ella_lyaabdoon/core/services/app_services_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ella_lyaabdoon/utils/notification_helper.dart';
import 'package:ella_lyaabdoon/core/models/scheduled_notification_model.dart';

class RewardDetailDialog extends StatelessWidget {
  final TimelineReward reward;

  const RewardDetailDialog({super.key, required this.reward});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TranslationCubit(),
      child: _RewardDetailDialogContent(reward: reward),
    );
  }
}

class _RewardDetailDialogContent extends StatefulWidget {
  final TimelineReward reward;

  const _RewardDetailDialogContent({required this.reward});

  @override
  State<_RewardDetailDialogContent> createState() =>
      _RewardDetailDialogContentState();
}

class _RewardDetailDialogContentState
    extends State<_RewardDetailDialogContent> {
  bool _showTranslation = false;

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Copied'.tr()),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleTranslation(BuildContext context) {
    setState(() {
      _showTranslation = !_showTranslation;
    });

    if (_showTranslation) {
      context.read<TranslationCubit>().translate(widget.reward.description);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEnglish = AppServicesDBprovider.currentLocale() == "en";

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [Colors.grey[900]!, Colors.grey[850]!]
                : [Colors.white, Colors.green.withValues(alpha: 0.03)],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with gradient
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.greenAccent.withValues(alpha: 0.2),
                    Colors.green.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  // Container(
                  //   padding: const EdgeInsets.all(12),
                  //   decoration: BoxDecoration(
                  //     color: Colors.greenAccent.withValues(alpha: 0.3),
                  //     shape: BoxShape.circle,
                  //   ),
                  //   child: Icon(
                  //     Icons.auto_awesome,
                  //     color: Colors.green[700],
                  //     size: 12,
                  //   ),
                  // ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.reward.title,
                      maxLines: 4,
                      style: theme.textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,

                        color: isDark ? Colors.white : Colors.green[900],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );

                      if (time != null && context.mounted) {
                        try {
                          // Generate a stable, reasonable notification ID from reward ID
                          final notificationId =
                              widget.reward.id.hashCode.abs() % 2147483647;

                          // Check if already scheduled
                          final isScheduled =
                              await NotificationHelper.isNotificationScheduled(
                                notificationId,
                              );

                          if (isScheduled && context.mounted) {
                            final shouldReplace = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Already Scheduled'.tr()),
                                content: Text(
                                  'A reminder for this reward already exists. Do you want to replace it?'
                                      .tr(),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: Text('cancel'.tr()),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: Text('Replace'.tr()),
                                  ),
                                ],
                              ),
                            );

                            if (shouldReplace != true) return;
                          }

                          // Schedule the notification with full description
                          await NotificationHelper.scheduleDaily(
                            notificationId: notificationId,
                            payload: {
                              'reward_id': widget.reward.id.toString(),
                              'timestamp': DateTime.now().millisecondsSinceEpoch
                                  .toString(),
                            },
                            title: widget.reward.title,
                            body: widget.reward.description, // Full description
                            time: time,
                          );

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${'Reminder scheduled for'.tr()} ${time.format(context)}',
                                ),
                                backgroundColor: Colors.green,
                                action: SnackBarAction(
                                  label: 'Undo'.tr(),
                                  textColor: Colors.white,
                                  onPressed: () async {
                                    await NotificationHelper.cancel(
                                      notificationId,
                                    );
                                  },
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          debugPrint("Schedule Error: $e");

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Failed to schedule reminder'.tr(),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
                    icon: const Icon(Icons.alarm_add),
                    color: Colors.green[700],
                    tooltip: "Schedule Reminder".tr(),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hadith section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey[800]!.withValues(alpha: 0.5)
                            : Colors.amber.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? Colors.amber.withValues(alpha: 0.2)
                              : Colors.amber.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.menu_book_rounded,
                                color: Colors.amber[700],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Hadith'.tr(),
                                style: theme.textTheme.titleMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber[800],
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () => _copyToClipboard(
                                  context,
                                  widget.reward.description,
                                ),
                                icon: const Icon(Icons.copy, size: 18),
                                tooltip: 'Copy Hadith'.tr(),
                                color: Colors.grey[600],
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.reward.description,
                            style: theme.textTheme.bodyLarge!.copyWith(
                              height: 2,
                              fontSize: 16,
                              color: isDark ? Colors.white : Colors.grey[800],
                            ),
                            textAlign: TextAlign.justify,
                          ),

                          // Translation button (only for English locale)
                          if (isEnglish) ...[
                            const SizedBox(height: 16),
                            Center(
                              child: ElevatedButton.icon(
                                onPressed: () => _toggleTranslation(context),
                                icon: Icon(
                                  _showTranslation
                                      ? Icons.close
                                      : Icons.translate,
                                  size: 18,
                                ),
                                label: Text(
                                  _showTranslation
                                      ? 'Hide Translation'
                                      : 'Translate to English',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Translation section (only shown when toggled)
                    if (isEnglish && _showTranslation) ...[
                      const SizedBox(height: 16),
                      BlocBuilder<TranslationCubit, TranslationState>(
                        builder: (context, state) {
                          if (state is TranslationLoading) {
                            return Container(
                              padding: const EdgeInsets.all(32),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.grey[800]!.withValues(alpha: 0.5)
                                    : Colors.green.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.green.withValues(alpha: 0.3),
                                  width: 2,
                                ),
                              ),
                              child: const Column(
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 16),
                                  Text('Translating...'),
                                ],
                              ),
                            );
                          }

                          if (state is TranslationError) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.red[200]!,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: Colors.red[600],
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Error',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    state.message,
                                    style: TextStyle(color: Colors.red[800]),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (state is TranslationLoaded) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.grey[800]!.withValues(alpha: 0.5)
                                    : Colors.green.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.green.withValues(alpha: 0.2)
                                      : Colors.green.withValues(alpha: 0.3),
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Disclaimer
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.red),
                                      color: Colors.red.withValues(alpha: 0.1),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.warning_amber_rounded,
                                          color: Colors.red,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Disclaimer: The translation is not 100% accurate',
                                            maxLines: 3,
                                            style: TextStyle(
                                              fontSize: 12,
                                              overflow: TextOverflow.ellipsis,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red[700],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Row(
                                    children: [
                                      Icon(
                                        Icons.translate,
                                        color: Colors.blue[700],
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'English Translation',
                                        style: theme.textTheme.titleMedium!
                                            .copyWith(
                                              fontSize: 12,
                                              overflow: TextOverflow.ellipsis,

                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue[800],
                                            ),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        onPressed: () => _copyToClipboard(
                                          context,
                                          state.translatedText,
                                        ),
                                        icon: const Icon(Icons.copy, size: 18),
                                        tooltip: 'Copy translation',
                                        color: Colors.grey[600],
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    state.translatedText,
                                    style: theme.textTheme.bodyLarge!.copyWith(
                                      height: 1.8,
                                      fontSize: 16,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.grey[800],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return const SizedBox();
                        },
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Source section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey[800]!.withValues(alpha: 0.5)
                            : Colors.green.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? Colors.green.withValues(alpha: 0.2)
                              : Colors.green.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.source_rounded,
                                color: Colors.green[700],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Source'.tr(),
                                style: theme.textTheme.titleMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[800],
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () => _copyToClipboard(
                                  context,
                                  widget.reward.source,
                                ),
                                icon: const Icon(Icons.copy, size: 18),
                                tooltip: 'Copy source'.tr(),
                                color: Colors.grey[600],
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.reward.source,
                            style: theme.textTheme.bodyMedium!.copyWith(
                              height: 1.6,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Decorative footer
                    // Center(
                    //   child: Container(
                    //     padding: const EdgeInsets.symmetric(
                    //       horizontal: 16,
                    //       vertical: 8,
                    //     ),
                    //     decoration: BoxDecoration(
                    //       color: Colors.greenAccent.withValues(alpha:0.1),
                    //       borderRadius: BorderRadius.circular(20),
                    //     ),
                    //     child: Row(
                    //       mainAxisSize: MainAxisSize.min,
                    //       children: [
                    //         Icon(
                    //           Icons.verified,
                    //           color: Colors.green[600],
                    //           size: 16,
                    //         ),
                    //         const SizedBox(width: 8),
                    //         Text(
                    //           'بارك الله فيك',
                    //           style: theme.textTheme.bodySmall!.copyWith(
                    //             color: Colors.green[700],
                    //             fontWeight: FontWeight.w600,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
