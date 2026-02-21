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
import 'package:url_launcher/url_launcher.dart';

class RewardDetailDialog extends StatelessWidget {
  final TimelineReward reward;

  const RewardDetailDialog({super.key, required this.reward});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TranslationCubit>(
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

class _RewardDetailDialogContentState extends State<_RewardDetailDialogContent>
    with SingleTickerProviderStateMixin {
  // ── Simple local counter ────────────────────────────────────────────
  int _count = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool isEnabled = false;

  void _increment() {
    setState(() => _count++);
    _pulseController.forward(from: 0);
  }

  void _reset() {
    setState(() => _count = 0);
  }

  // ── Analytics ───────────────────────────────────────────────────────
  void _logEvent(String eventName, {Map<String, Object>? parameters}) {
    if (kReleaseMode) {
      FirebaseAnalytics.instance.logEvent(
        name: eventName,
        parameters: parameters,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // loadRemoteConfig();

    _logEvent(
      'reward_detail_opened',
      parameters: {
        'reward_id': widget.reward.id,
        'reward_title': widget.reward.title,
      },
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    )..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // ── Misc ─────────────────────────────────────────────────────────────
  bool _showTranslation = false;
  final ScreenshotController _screenshotController = ScreenshotController();

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('Copied'.tr()),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _launchUrl(String url) async {
    _logEvent('url_launched', parameters: {'url': url});
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _toggleTranslation(BuildContext context) {
    setState(() => _showTranslation = !_showTranslation);
    if (_showTranslation) {
      context.read<TranslationCubit>().translate(widget.reward.description);
    }
  }

  // ── Screenshot widget (no scroll) ───────────────────────────────────
  Widget _buildFullContentWidget(
    BuildContext context, {
    bool isSharing = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      decoration: BoxDecoration(
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _hadithCard(context, isDark, theme, isSharing: isSharing),
                const SizedBox(height: 20),
                _sourceCard(context, isDark, theme, isSharing: isSharing),
                const SizedBox(height: 20),
                _brandingFooter(context, isDark, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Share ────────────────────────────────────────────────────────────
  Future<void> _shareReward(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final Uint8List? image = await _screenshotController
          .captureFromLongWidget(
            InheritedTheme.captureAll(
              context,
              Material(
                child: MediaQuery(
                  data: MediaQuery.of(context),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: _buildFullContentWidget(context, isSharing: true),
                  ),
                ),
              ),
            ),
            delay: const Duration(milliseconds: 100),
            context: context,
            pixelRatio: 2.0,
            constraints: const BoxConstraints(maxWidth: 400),
          );

      if (image == null) {
        Navigator.pop(context);
        throw Exception('Failed to capture screenshot');
      }

      final directory = await getTemporaryDirectory();
      final imagePath =
          '${directory.path}/reward_${DateTime.now().millisecondsSinceEpoch}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(image);

      Navigator.pop(context);

      final translations = {
        "ar":
            "تم التقاطها بتطبيق إلا ليعبدون\n\nhttps://play.google.com/store/apps/details?id=com.amrabdelhameed.ella_lyaabdoon",
        "en":
            "Captured with Ella Lyaabdoon app\n\nhttps://play.google.com/store/apps/details?id=com.amrabdelhameed.ella_lyaabdoon",
      };

      final shareText = translations[AppServicesDBprovider.currentLocale()]!;

      await Share.shareXFiles(
        [XFile(imagePath)],
        text: shareText,
        subject: 'مشاركة من تطبيق إلا ليعبدون',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('جزاك الله خيراً'),
            backgroundColor: Colors.green,
          ),
        );
        Future.delayed(const Duration(seconds: 2), () {
          try {
            if (imageFile.existsSync()) imageFile.deleteSync();
          } catch (e) {
            debugPrint('Error deleting temp file: $e');
          }
        });
      }
    } catch (e) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      debugPrint('Share error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('failed_to_share'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ── Schedule reminder (extracted so it can be reused from the
  //    overflow popup menu on narrow screens) ───────────────────────────
  Future<void> _scheduleReminder(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null || !context.mounted) return;

    try {
      final notificationId = widget.reward.id.hashCode.abs() % 2147483647;
      final isScheduled = await NotificationHelper.isNotificationScheduled(
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
                onPressed: () => Navigator.pop(context, false),
                child: Text('cancel'.tr()),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
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
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        },
        title: widget.reward.title,
        body: widget.reward.description,
        time: time,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 3),
            content: Text(
              '${'Reminder scheduled for'.tr()} ${time.format(context)}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("Schedule Error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to schedule reminder'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ════════════════════════════════════════════════════════════════════
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
            // ── Header ──────────────────────────────────────────────
            _buildHeader(context, theme, isDark),

            // ── Body ─────────────────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.reward.isWithCounter) ...[
                      _buildCounter(context, isDark, theme),
                      const SizedBox(height: 20),
                    ],

                    _hadithCard(context, isDark, theme, isSharing: false),

                    if (isEnglish) ...[
                      const SizedBox(height: 16),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () => _toggleTranslation(context),
                          icon: Icon(
                            _showTranslation ? Icons.close : Icons.translate,
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
                                        const Icon(
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
                    _sourceCard(context, isDark, theme, isSharing: false),
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

  // ── Responsive header ────────────────────────────────────────────────
  //
  // Layout strategy:
  //   • Title + level badge take all available space (Expanded + Flexible).
  //   • Title is single-line with ellipsis – never wraps or clips.
  //   • On wide screens (≥ 340 dp) the Share and Reminder icons are shown
  //     individually.
  //   • On narrow screens (< 340 dp) those two actions collapse into a
  //     single three-dot overflow menu, keeping the header to one line.
  //   • The Close button is always visible.
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 4, 10),
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 340;

          return Row(
            children: [
              // ── Title + badge (takes remaining space) ─────────────
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        widget.reward.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'kufi',
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.green[900],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Badge is intrinsic-width; won't cause overflow.
                    _buildLevelBadge(context, widget.reward.zikrLevel),
                  ],
                ),
              ),

              // ── Action buttons ─────────────────────────────────────
              if (!isNarrow) ...[
                IconButton(
                  onPressed: () => _shareReward(context),
                  visualDensity: VisualDensity.compact,
                  icon: Badge(
                    alignment: Alignment.topRight,
                    label: Text("New".tr()),
                    textColor: Colors.white,
                    child: const Icon(Icons.share_outlined),
                  ),
                  color: Colors.green[700],
                  tooltip: "Share".tr(),
                ),
                IconButton(
                  onPressed: () => _scheduleReminder(context),
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.alarm_add),
                  color: Colors.green[700],
                  tooltip: "Schedule Reminder".tr(),
                ),
                IconButton(
                  onPressed: () {
                    _launchUrl('https://wa.me/201121009270');
                    _logEvent('zikr_complain');
                  },
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.report_gmailerrorred_outlined),
                  color: Colors.red[700],
                  tooltip: "report".tr(),
                ),
              ] else
                PopupMenuButton<_HeaderAction>(
                  icon: Icon(Icons.more_vert, color: Colors.green[700]),
                  onSelected: (action) {
                    if (action == _HeaderAction.share) {
                      _shareReward(context);
                    } else if (action == _HeaderAction.reminder) {
                      _scheduleReminder(context);
                    } else if (action == _HeaderAction.report) {
                      _launchUrl('https://wa.me/201121009270');
                      _logEvent('zikr_complain');
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: _HeaderAction.share,
                      child: Row(
                        children: [
                          Icon(
                            Icons.share_outlined,
                            color: Colors.green[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text("Share".tr()),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: _HeaderAction.reminder,
                      child: Row(
                        children: [
                          Icon(
                            Icons.alarm_add,
                            color: Colors.green[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text("Schedule Reminder".tr()),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: _HeaderAction.report,
                      child: Row(
                        children: [
                          Icon(
                            Icons.report_gmailerrorred_outlined,
                            color: Colors.red[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text("report".tr()),
                        ],
                      ),
                    ),
                  ],
                ),

              // Close is always visible
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close),
                color: Colors.grey[600],
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Counter Widget ───────────────────────────────────────────────────
  Widget _buildCounter(BuildContext context, bool isDark, ThemeData theme) {
    final primary = theme.colorScheme.primary;
    final screenWidth = MediaQuery.of(context).size.width;

    final buttonSize = (screenWidth * 0.14).clamp(44.0, 72.0);
    final iconSize = buttonSize * 0.5;
    final countFontSize = (screenWidth * 0.07).clamp(24.0, 40.0);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey[800]!.withValues(alpha: 0.6)
            : primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withValues(alpha: 0.25), width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'zikr_done_count'.tr(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white60 : Colors.grey[600],
                    fontWeight: FontWeight.w600,
                    fontSize: (screenWidth * 0.028).clamp(10.0, 13.0),
                  ),
                ),
                const SizedBox(height: 2),
                Transform.scale(
                  scale: _pulseAnimation.value,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '$_count',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: primary,
                      fontWeight: FontWeight.bold,
                      fontSize: countFontSize,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _count > 0
                ? IconButton(
                    key: const ValueKey('reset'),
                    onPressed: _reset,
                    icon: const Icon(Icons.refresh_rounded),
                    color: Colors.grey[500],
                    tooltip: 'reset'.tr(),
                    iconSize: (screenWidth * 0.055).clamp(18.0, 24.0),
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  )
                : SizedBox(
                    key: const ValueKey('empty'),
                    width: (screenWidth * 0.055).clamp(18.0, 24.0) + 12,
                  ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _increment,
            child: Container(
              width: buttonSize,
              height: buttonSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primary, primary.withValues(alpha: 0.75)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: iconSize,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Hadith card ───────────────────────────────────────────────────────
  Widget _hadithCard(
    BuildContext context,
    bool isDark,
    ThemeData theme, {
    required bool isSharing,
  }) {
    return Container(
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
              Icon(Icons.menu_book_rounded, color: Colors.amber[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Hadith'.tr(),
                style: theme.textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[800],
                ),
              ),
              if (!isSharing) ...[
                const Spacer(),
                IconButton(
                  onPressed: () =>
                      _copyToClipboard(context, widget.reward.description),
                  icon: const Icon(Icons.copy, size: 18),
                  tooltip: 'Copy Hadith'.tr(),
                  color: Colors.grey[600],
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.reward.description,
            style: theme.textTheme.bodyLarge!.copyWith(
              height: 2,
              fontFamily: 'kufi',
              fontSize: 16,
              color: isDark ? Colors.white : Colors.grey[800],
            ),
            textAlign: TextAlign.justify,
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  // ── Source card ──────────────────────────────────────────────────────
  Widget _sourceCard(
    BuildContext context,
    bool isDark,
    ThemeData theme, {
    required bool isSharing,
  }) {
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.source_rounded, color: Colors.green[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Source'.tr(),
                style: theme.textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              if (!isSharing) ...[
                const Spacer(),
                IconButton(
                  onPressed: () =>
                      _copyToClipboard(context, widget.reward.source),
                  icon: const Icon(Icons.copy, size: 18),
                  tooltip: 'Copy source'.tr(),
                  color: Colors.grey[600],
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.reward.source,
            textDirection: TextDirection.rtl,
            style: theme.textTheme.bodyMedium!.copyWith(
              height: 1.6,
              fontFamily: 'kufi',
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  // ── Branding footer (screenshot only) ───────────────────────────────
  Widget _brandingFooter(BuildContext context, bool isDark, ThemeData theme) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
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
            ),
            const SizedBox(width: 4),
            Image.asset('assets/playstore.png', height: 50, width: 50),
          ],
        ),
      ),
    );
  }

  // ── Level badge ──────────────────────────────────────────────────────
  Widget _buildLevelBadge(BuildContext context, ZikrLevel level) {
    final isEasy = level == ZikrLevel.easy;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: (isEasy ? Colors.blue : Colors.orange).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: (isEasy ? Colors.blue : Colors.orange).withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        isEasy ? "easy".tr() : "hard".tr(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isEasy ? Colors.blue : Colors.orange,
        ),
      ),
    );
  }
}

/// Small enum used by the overflow [PopupMenuButton] in the header.
enum _HeaderAction { share, reminder, report }
