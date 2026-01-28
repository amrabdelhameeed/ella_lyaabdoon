import 'dart:io';
import 'package:easy_localization/easy_localization.dart' as ez;
import 'package:ella_lyaabdoon/features/home/logic/translation_cubit.dart';
import 'package:ella_lyaabdoon/core/models/timeline_reward.dart';
import 'package:ella_lyaabdoon/core/services/app_services_database_provider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ella_lyaabdoon/utils/notification_helper.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

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
  void _logEvent(String eventName, {Map<String, Object>? parameters}) {
    kReleaseMode
        ? FirebaseAnalytics.instance.logEvent(
            name: eventName,
            parameters: parameters,
          )
        : null;
  }

  @override
  initState() {
    _logEvent(
      'reward_detail_opened',
      parameters: {
        'reward_id': widget.reward.id,
        'reward_title': widget.reward.title,
      },
    );
    super.initState();
  }

  bool _showTranslation = false;
  final ScreenshotController _screenshotController = ScreenshotController();

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

  // Build the full content widget for screenshot (without ScrollView)
  Widget _buildFullContentWidget(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      decoration: BoxDecoration(
        // borderRadius: BorderRadius.circular(20),
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
                // topLeft: Radius.circular(20),
                // topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.reward.title,
                    style: theme.textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isDark ? Colors.white : Colors.green[900],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content (NO ScrollView for screenshot)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
                    mainAxisSize: MainAxisSize.min,
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
                    ],
                  ),
                ),

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
                    mainAxisSize: MainAxisSize.min,
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

                // App branding footer
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'shared_with'.tr(),
                          style: theme.textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.grey[800],
                          ),
                          // textAlign: TextAlign.center,
                        ),
                        const SizedBox(width: 4),
                        Image.asset(
                          'assets/playstore.png',
                          height: 50,
                          width: 50,
                        ),
                        // const SizedBox(height: 4),
                        // Text(
                        //   'تطبيق فضائل الصلوات',
                        //   style: theme.textTheme.bodySmall!.copyWith(
                        //     color: Colors.green[600],
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareReward(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: CircularProgressIndicator(),
          ),
        ),
      );

      // Capture FULL widget including scrolled content
      final Uint8List? image = await _screenshotController
          .captureFromLongWidget(
            InheritedTheme.captureAll(
              context,
              Material(
                child: MediaQuery(
                  data: MediaQuery.of(context),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: _buildFullContentWidget(context),
                  ),
                ),
              ),
            ),
            delay: Duration(milliseconds: 100),
            context: context,
            pixelRatio: 2.0,
            constraints: BoxConstraints(maxWidth: 400),
          );

      if (image == null) {
        Navigator.pop(context); // Close loading dialog
        throw Exception('Failed to capture screenshot');
      }

      // Save image to temporary directory
      final directory = await getTemporaryDirectory();
      final imagePath =
          '${directory.path}/reward_${DateTime.now().millisecondsSinceEpoch}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(image);

      Navigator.pop(context); // Close loading dialog
      final translations = {
        "ar":
            "تم التقاطها بتطبيق إلا ليعبدون\n\nhttps://play.google.com/store/apps/details?id=com.amrabdelhameed.ella_lyaabdoon",
        "en":
            "Captured with Ella Lyaabdoon app\n\nhttps://play.google.com/store/apps/details?id=com.amrabdelhameed.ella_lyaabdoon",
      };
      // Share with text
      final shareText = translations[AppServicesDBprovider.currentLocale()]!;

      final result = await SharePlus.instance.share(
        ShareParams(
          title: 'الا ليعبدون',
          subject: 'مشاركة من تطبيق إلا ليعبدون',
          text: shareText,
          files: [XFile(imagePath)],
        ),
      );

      // Clean up the temporary file after sharing
      if (result.status == ShareResultStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('جزاك الله خيراً'),
            backgroundColor: Colors.green,
          ),
        );
        Future.delayed(Duration(seconds: 2), () {
          try {
            if (imageFile.existsSync()) {
              imageFile.deleteSync();
            }
          } catch (e) {
            debugPrint('Error deleting temp file: $e');
          }
        });
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      debugPrint('Share error: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
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
                  // Share button
                  IconButton(
                    onPressed: () => _shareReward(context),
                    icon: Badge(
                      alignment: Alignment.topRight,
                      // largeSize: 2,
                      label: Text("New".tr()),
                      textColor: Colors.white,
                      child: Icon(Icons.share_outlined),
                    ),
                    color: Colors.green[700],
                    tooltip: "Share".tr(),
                  ),
                  // Alarm button
                  IconButton(
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );

                      if (time != null && context.mounted) {
                        try {
                          final notificationId =
                              widget.reward.id.hashCode.abs() % 2147483647;

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

                          await NotificationHelper.scheduleDaily(
                            notificationId: notificationId,
                            payload: {
                              'reward_id': widget.reward.id.toString(),
                              'timestamp': DateTime.now().millisecondsSinceEpoch
                                  .toString(),
                            },
                            title: widget.reward.title,
                            body: widget.reward.description,
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
                  // Close button
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),

            // Content (WITH ScrollView for viewing)
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
