import 'dart:io';
import 'package:easy_localization/easy_localization.dart' as ez;
import 'package:ella_lyaabdoon/core/shared_widgets/pulsing_wrapper.dart';
import 'package:ella_lyaabdoon/features/home/logic/translation_cubit.dart';
import 'package:ella_lyaabdoon/core/models/timeline_reward.dart';
import 'package:ella_lyaabdoon/core/services/app_services_database_provider.dart';
import 'package:ella_lyaabdoon/utils/notification_helper.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ella_lyaabdoon/core/services/zikr_widget_service.dart';
import 'package:ella_lyaabdoon/features/history/data/history_db_provider.dart';
import 'package:ella_lyaabdoon/features/history/logic/history_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Design tokens — single source of truth for the entire dialog.
// All cards, badges, and text styles derive from these.
// ─────────────────────────────────────────────────────────────────────────────

class _DialogTokens {
  _DialogTokens._();

  // ── Radii ────────────────────────────────────────────────────────────────
  static const double radiusCard = 12;
  static const double radiusDialog = 20;
  static const double radiusBadge = 6;

  // ── Border width ─────────────────────────────────────────────────────────
  static const double borderWidth = 1.5;

  // ── Spacing ──────────────────────────────────────────────────────────────
  static const double spaceXS = 6;
  static const double spaceSM = 10;
  static const double spaceMD = 14;
  static const double spaceLG = 20;

  // ── Card padding ─────────────────────────────────────────────────────────
  static const EdgeInsets paddingCard = EdgeInsets.all(14);

  // ── Icon sizes ───────────────────────────────────────────────────────────
  static const double iconCard = 18;
  static const double iconAction = 16;

  // ── Font sizes ───────────────────────────────────────────────────────────
  static const double fontCardTitle = 13;
  static const double fontBody = 15;
  static const double fontBodyArabic = 16;
  static const double fontSource = 14;
  static const double fontBadge = 10;

  // ── Arabic line height ───────────────────────────────────────────────────
  static const double heightArabic = 1.9;
  static const double heightBody = 1.6;

  // ── Semantic color roles ─────────────────────────────────────────────────
  // Each card type has ONE role. We derive fill/border/icon from colorScheme
  // or fixed Material palette roles — never raw hex.

  /// Hadith card — warm accent (uses colorScheme.tertiary on M3 themes,
  /// falls back to amber tone extracted from context).
  static Color hadithAccent(BuildContext context) =>
      Theme.of(context).colorScheme.tertiary;

  /// Tafsir card — secondary accent.
  static Color tafsirAccent(BuildContext context) =>
      Theme.of(context).colorScheme.secondary;

  /// Source card — primary.
  static Color sourceAccent(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  /// Translation card — primary (same role as source, different layout).
  static Color translationAccent(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  /// Error / warning — error role.
  static Color errorAccent(BuildContext context) =>
      Theme.of(context).colorScheme.error;

  // ── Fill helpers (consistent opacity contract) ───────────────────────────
  static Color fillCard(Color accent, bool isDark) =>
      accent.withOpacity(isDark ? 0.10 : 0.06);

  static Color borderCard(Color accent, bool isDark) =>
      accent.withOpacity(isDark ? 0.30 : 0.25);
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared card shell — use this for every info card in the dialog.
// ─────────────────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.accent,
    required this.isDark,
    required this.child,
  });

  final Color accent;
  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: _DialogTokens.paddingCard,
      decoration: BoxDecoration(
        color: _DialogTokens.fillCard(accent, isDark),
        borderRadius: BorderRadius.circular(_DialogTokens.radiusCard),
        border: Border.all(
          color: _DialogTokens.borderCard(accent, isDark),
          width: _DialogTokens.borderWidth,
        ),
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card header row — icon + title + optional trailing action.
// ─────────────────────────────────────────────────────────────────────────────

class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.icon,
    required this.label,
    required this.accent,
    this.isDark = false,
    this.trailingTooltip,
    this.onTrailingTap,
  });

  final IconData icon;
  final String label;
  final Color accent;
  final bool isDark;
  final String? trailingTooltip;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    final labelColor = isDark ? accent.withOpacity(0.9) : accent;

    return Row(
      children: [
        Icon(icon, color: labelColor, size: _DialogTokens.iconCard),
        const SizedBox(width: _DialogTokens.spaceSM),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'kufi',
            fontSize: _DialogTokens.fontCardTitle,
            fontWeight: FontWeight.bold,
            color: labelColor,
          ),
        ),
        if (onTrailingTap != null) ...[
          const Spacer(),
          IconButton(
            onPressed: onTrailingTap,
            icon: Icon(Icons.copy, size: _DialogTokens.iconAction),
            tooltip: trailingTooltip,
            color: Theme.of(context).colorScheme.outline,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main widget entry point
// ─────────────────────────────────────────────────────────────────────────────

class RewardDetailDialog extends StatelessWidget {
  final TimelineReward reward;
  final VoidCallback? onChecked;

  const RewardDetailDialog({super.key, required this.reward, this.onChecked});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TranslationCubit>(create: (_) => TranslationCubit()),
      ],
      child: _RewardDetailDialogContent(reward: reward, onChecked: onChecked),
    );
  }
}

class _RewardDetailDialogContent extends StatefulWidget {
  final TimelineReward reward;
  final VoidCallback? onChecked;

  const _RewardDetailDialogContent({required this.reward, this.onChecked});

  @override
  State<_RewardDetailDialogContent> createState() =>
      _RewardDetailDialogContentState();
}

class _RewardDetailDialogContentState extends State<_RewardDetailDialogContent>
    with SingleTickerProviderStateMixin {
  int _count = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool _showTranslation = false;
  bool _showTafsir = false;

  final ScreenshotController _screenshotController = ScreenshotController();

  // ── Helpers ──────────────────────────────────────────────────────────────

  void _increment() {
    setState(() => _count++);
    _pulseController.forward(from: 0);
  }

  void _reset() => setState(() => _count = 0);

  void _logEvent(String name, {Map<String, Object>? parameters}) {
    if (kReleaseMode) {
      FirebaseAnalytics.instance.logEvent(name: name, parameters: parameters);
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text('Copied'.tr()),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _launchUrl(String url) async {
    _logEvent('url_launched', parameters: {'url': url});
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  void _toggleTranslation() {
    setState(() => _showTranslation = !_showTranslation);
    if (_showTranslation) {
      context.read<TranslationCubit>().translate(widget.reward.description);
    }
  }

  void _toggleTafsir() => setState(() => _showTafsir = !_showTafsir);

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
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

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEnglish = AppServicesDBprovider.currentLocale() == 'en';
    final hasTafsir =
        widget.reward.tafsir != null && widget.reward.tafsir!.isNotEmpty;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_DialogTokens.radiusDialog),
      ),
      elevation: 8,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_DialogTokens.radiusDialog),
          color: theme.colorScheme.surface,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, theme, isDark),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: _DialogTokens.spaceLG,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: _DialogTokens.spaceMD),

                    // Done-today checkbox
                    BlocBuilder<HistoryCubit, HistoryState>(
                      builder: (context, _) {
                        final isChecked = HistoryDBProvider.isCheckedToday(
                          widget.reward.id,
                        );
                        return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          checkboxShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          activeColor: theme.colorScheme.primary,
                          value: isChecked,
                          onChanged: (_) async {
                            context.read<HistoryCubit>().toggleCheck(
                              widget.reward.id,
                            );
                            await RewardWidgetService.updateWidget();
                            widget.onChecked?.call();
                          },
                          title: Text(
                            isChecked
                                ? 'zikr_done_today'.tr()
                                : 'mark_as_done'.tr(),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isChecked
                                  ? theme.colorScheme.primary
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),

                    if (widget.reward.isWithCounter) ...[
                      const SizedBox(height: _DialogTokens.spaceSM),
                      _buildCounter(context, isDark, theme),
                    ],

                    const SizedBox(height: _DialogTokens.spaceMD),
                    _hadithCard(context, isDark, theme, isSharing: false),

                    // Translate button (English only)
                    if (isEnglish) ...[
                      const SizedBox(height: _DialogTokens.spaceMD),
                      Center(
                        child: OutlinedButton.icon(
                          onPressed: _toggleTranslation,
                          icon: Icon(
                            _showTranslation ? Icons.close : Icons.translate,
                            size: 16,
                          ),
                          label: Text(
                            _showTranslation
                                ? 'Hide Translation'
                                : 'Translate to English',
                            style: const TextStyle(fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.colorScheme.primary,
                            side: BorderSide(
                              color: theme.colorScheme.primary,
                              width: _DialogTokens.borderWidth,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                      if (_showTranslation) ...[
                        const SizedBox(height: _DialogTokens.spaceMD),
                        _translationCard(context, isDark, theme),
                      ],
                    ],

                    // Tafsir
                    if (hasTafsir) ...[
                      const SizedBox(height: _DialogTokens.spaceMD),
                      _tafsirToggleRow(context, isDark, theme),
                      if (_showTafsir) ...[
                        const SizedBox(height: _DialogTokens.spaceXS),
                        _tafsirCard(context, isDark, theme, isSharing: false),
                      ],
                    ],

                    const SizedBox(height: _DialogTokens.spaceLG),
                    _sourceCard(context, isDark, theme, isSharing: false),
                    const SizedBox(height: _DialogTokens.spaceLG),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Header
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, ThemeData theme, bool isDark) {
    final primary = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 4, 10),
      decoration: BoxDecoration(
        color: _DialogTokens.fillCard(primary, isDark),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(_DialogTokens.radiusDialog),
          topRight: Radius.circular(_DialogTokens.radiusDialog),
        ),
        border: Border(
          bottom: BorderSide(
            color: _DialogTokens.borderCard(primary, isDark),
            width: _DialogTokens.borderWidth,
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 340;

          return Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        widget.reward.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'kufi',
                          fontSize: 14,
                          color: primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: _DialogTokens.spaceXS),
                    _levelBadge(context, widget.reward.zikrLevel, theme),
                  ],
                ),
              ),
              if (!isNarrow) ...[
                _headerIconBtn(
                  context,
                  Icons.share_outlined,
                  tooltip: 'Share'.tr(),
                  onTap: () => _shareReward(context),
                ),
                PulsingWrapper(
                  child: _headerIconBtn(
                    context,
                    Icons.alarm_add,
                    tooltip: 'Schedule Reminder'.tr(),
                    onTap: () => _scheduleReminder(context),
                  ),
                ),
                _headerIconBtn(
                  context,
                  Icons.report_gmailerrorred_outlined,
                  tooltip: 'report'.tr(),
                  color: theme.colorScheme.error,
                  onTap: _reportZikr,
                ),
              ] else
                PulsingWrapper(
                  child: PopupMenuButton<_HeaderAction>(
                    icon: Icon(Icons.more_vert, color: primary),
                    onSelected: (action) {
                      switch (action) {
                        case _HeaderAction.share:
                          _shareReward(context);
                        case _HeaderAction.reminder:
                          _scheduleReminder(context);
                        case _HeaderAction.report:
                          _reportZikr();
                      }
                    },
                    itemBuilder: (_) => [
                      _popupItem(
                        context,
                        _HeaderAction.share,
                        Icons.share_outlined,
                        'Share'.tr(),
                        primary,
                      ),
                      _popupItem(
                        context,
                        _HeaderAction.reminder,
                        Icons.alarm_add,
                        'Schedule Reminder'.tr(),
                        primary,
                      ),
                      _popupItem(
                        context,
                        _HeaderAction.report,
                        Icons.report_gmailerrorred_outlined,
                        'report'.tr(),
                        theme.colorScheme.error,
                      ),
                    ],
                  ),
                ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close),
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          );
        },
      ),
    );
  }

  void _reportZikr() {
    _launchUrl(
      'https://wa.me/201121009270?text=${Uri.encodeComponent('يوجد مشكلة في هذا الذكر : ${widget.reward.title} و المعرف الخاص به ${widget.reward.id}')}',
    );
    _logEvent('zikr_complain');
  }

  Widget _headerIconBtn(
    BuildContext context,
    IconData icon, {
    required String tooltip,
    required VoidCallback onTap,
    Color? color,
  }) {
    return IconButton(
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
      icon: Icon(icon),
      color: color ?? Theme.of(context).colorScheme.primary,
      tooltip: tooltip,
    );
  }

  PopupMenuItem<_HeaderAction> _popupItem(
    BuildContext context,
    _HeaderAction value,
    IconData icon,
    String label,
    Color color,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Counter
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildCounter(BuildContext context, bool isDark, ThemeData theme) {
    final primary = theme.colorScheme.primary;
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonSize = (screenWidth * 0.14).clamp(44.0, 72.0);

    return Material(
      color: Colors.transparent,
      child: PulsingWrapper(
        child: InkWell(
          borderRadius: BorderRadius.circular(_DialogTokens.radiusCard),
          onTap: _increment,
          child: _InfoCard(
            accent: primary,
            isDark: isDark,
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
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
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
                          color: theme.colorScheme.onSurfaceVariant,
                          tooltip: 'reset'.tr(),
                          iconSize: 20,
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        )
                      : SizedBox(key: const ValueKey('empty'), width: 32),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _increment,
                  child: Container(
                    width: buttonSize,
                    height: buttonSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primary,
                      boxShadow: [
                        BoxShadow(
                          color: primary.withOpacity(0.30),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      color: theme.colorScheme.onPrimary,
                      size: buttonSize * 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Hadith card
  // ─────────────────────────────────────────────────────────────────────────

  Widget _hadithCard(
    BuildContext context,
    bool isDark,
    ThemeData theme, {
    required bool isSharing,
  }) {
    final accent = _DialogTokens.hadithAccent(context);

    return _InfoCard(
      accent: accent,
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _CardHeader(
            icon: Icons.menu_book_rounded,
            label: 'Hadith'.tr(),
            accent: accent,
            isDark: isDark,
            trailingTooltip: isSharing ? null : 'Copy Hadith'.tr(),
            onTrailingTap: isSharing
                ? null
                : () => _copyToClipboard(widget.reward.description),
          ),
          const SizedBox(height: _DialogTokens.spaceSM),
          Text(
            widget.reward.description,
            style: theme.textTheme.bodyLarge!.copyWith(
              height: _DialogTokens.heightArabic,
              fontFamily: 'kufi',
              fontSize: _DialogTokens.fontBodyArabic,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.justify,
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Tafsir toggle row
  // ─────────────────────────────────────────────────────────────────────────

  Widget _tafsirToggleRow(BuildContext context, bool isDark, ThemeData theme) {
    final accent = _DialogTokens.tafsirAccent(context);

    return GestureDetector(
      onTap: _toggleTafsir,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _DialogTokens.fillCard(
            accent,
            isDark,
          ).withOpacity(_showTafsir ? 0.14 : 0.06),
          borderRadius: BorderRadius.circular(_DialogTokens.radiusCard),
          border: Border.all(
            color: _DialogTokens.borderCard(accent, isDark),
            width: _DialogTokens.borderWidth,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.lightbulb_outline_rounded, color: accent, size: 18),
            const SizedBox(width: 8),
            Text(
              AppServicesDBprovider.currentLocale() == 'ar'
                  ? 'تفسير'
                  : 'Explanation',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: _DialogTokens.fontCardTitle,
                color: accent,
              ),
            ),
            const Spacer(),
            AnimatedRotation(
              turns: _showTafsir ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: accent,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Tafsir card
  // ─────────────────────────────────────────────────────────────────────────

  Widget _tafsirCard(
    BuildContext context,
    bool isDark,
    ThemeData theme, {
    required bool isSharing,
  }) {
    final accent = _DialogTokens.tafsirAccent(context);
    final isArabic = AppServicesDBprovider.currentLocale() == 'ar';

    return _InfoCard(
      accent: accent,
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: Icons.lightbulb_outline_rounded,
            label: isArabic ? 'تفسير' : 'Explanation',
            accent: accent,
            isDark: isDark,
            trailingTooltip: isSharing ? null : 'Copy'.tr(),
            onTrailingTap: isSharing
                ? null
                : () => _copyToClipboard(widget.reward.tafsir!),
          ),
          const SizedBox(height: _DialogTokens.spaceSM),
          Text(
            widget.reward.tafsir!,
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: _DialogTokens.fontBody,
              height: _DialogTokens.heightArabic,
              color: theme.colorScheme.onSurface,
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Translation card
  // ─────────────────────────────────────────────────────────────────────────

  Widget _translationCard(BuildContext context, bool isDark, ThemeData theme) {
    final accent = _DialogTokens.translationAccent(context);
    final errorAccent = _DialogTokens.errorAccent(context);

    return BlocBuilder<TranslationCubit, TranslationState>(
      builder: (context, state) {
        if (state is TranslationLoading) {
          return _InfoCard(
            accent: accent,
            isDark: isDark,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Translating...'),
                  ],
                ),
              ),
            ),
          );
        }

        if (state is TranslationError) {
          return _InfoCard(
            accent: errorAccent,
            isDark: isDark,
            child: Row(
              children: [
                Icon(Icons.error_outline, color: errorAccent, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    state.message,
                    style: TextStyle(color: errorAccent, fontSize: 13),
                  ),
                ),
              ],
            ),
          );
        }

        if (state is TranslationLoaded) {
          return _InfoCard(
            accent: accent,
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Disclaimer banner
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  margin: const EdgeInsets.only(bottom: _DialogTokens.spaceSM),
                  decoration: BoxDecoration(
                    color: errorAccent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(
                      _DialogTokens.radiusCard - 4,
                    ),
                    border: Border.all(
                      color: errorAccent.withOpacity(0.3),
                      width: _DialogTokens.borderWidth,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: errorAccent,
                        size: 15,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Disclaimer: Translation is not 100% accurate',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: errorAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                _CardHeader(
                  icon: Icons.translate,
                  label: 'English Translation',
                  accent: accent,
                  isDark: isDark,
                  trailingTooltip: 'Copy translation',
                  onTrailingTap: () => _copyToClipboard(state.translatedText),
                ),

                const SizedBox(height: _DialogTokens.spaceSM),

                Text(
                  state.translatedText,
                  style: theme.textTheme.bodyMedium!.copyWith(
                    height: _DialogTokens.heightBody,
                    fontSize: _DialogTokens.fontBody,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          );
        }

        return const SizedBox();
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Source card
  // ─────────────────────────────────────────────────────────────────────────

  Widget _sourceCard(
    BuildContext context,
    bool isDark,
    ThemeData theme, {
    required bool isSharing,
  }) {
    final accent = _DialogTokens.sourceAccent(context);

    return _InfoCard(
      accent: accent,
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _CardHeader(
            icon: Icons.source_rounded,
            label: 'Source'.tr(),
            accent: accent,
            isDark: isDark,
            trailingTooltip: isSharing ? null : 'Copy source'.tr(),
            onTrailingTap: isSharing
                ? null
                : () => _copyToClipboard(widget.reward.source),
          ),
          const SizedBox(height: _DialogTokens.spaceSM),
          Text(
            widget.reward.source,
            textDirection: TextDirection.rtl,
            style: theme.textTheme.bodyMedium!.copyWith(
              height: _DialogTokens.heightBody,
              fontFamily: 'kufi',
              fontWeight: FontWeight.w600,
              fontSize: _DialogTokens.fontSource,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Share capture widget
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildShareCaptureWidget(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      color: theme.colorScheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Share header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(_DialogTokens.spaceLG),
            color: _DialogTokens.fillCard(theme.colorScheme.primary, isDark),
            child: Text(
              widget.reward.title,
              style: theme.textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'kufi',
                fontSize: 16,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(_DialogTokens.spaceLG),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _hadithCard(context, isDark, theme, isSharing: true),
                if (widget.reward.tafsir != null &&
                    widget.reward.tafsir!.trim().isNotEmpty) ...[
                  const SizedBox(height: _DialogTokens.spaceMD),
                  _tafsirCard(context, isDark, theme, isSharing: true),
                ],
                const SizedBox(height: _DialogTokens.spaceMD),
                _sourceCard(context, isDark, theme, isSharing: true),
                const SizedBox(height: _DialogTokens.spaceMD),
                _brandingFooter(context, isDark, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Share action
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _shareReward(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final image = await _screenshotController.captureFromLongWidget(
        InheritedTheme.captureAll(
          context,
          Material(
            child: MediaQuery(
              data: MediaQuery.of(context),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: _buildShareCaptureWidget(context),
              ),
            ),
          ),
        ),
        delay: const Duration(milliseconds: 100),
        context: context,
        pixelRatio: 2.0,
        constraints: const BoxConstraints(maxWidth: 520),
      );

      if (image == null) {
        if (context.mounted) Navigator.pop(context);
        throw Exception('Failed to capture screenshot');
      }

      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/reward_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(path);
      await file.writeAsBytes(image);

      if (context.mounted) Navigator.pop(context);

      final isArabic = AppServicesDBprovider.currentLocale() == 'ar';
      await Share.shareXFiles(
        [XFile(path)],
        text: isArabic
            ? 'تم التقاطها بتطبيق إلا ليعبدون\n\nhttps://play.google.com/store/apps/details?id=com.amrabdelhameed.ella_lyaabdoon'
            : 'Captured with Ella Lyaabdoon app\n\nhttps://play.google.com/store/apps/details?id=com.amrabdelhameed.ella_lyaabdoon',
        subject: 'مشاركة من تطبيق إلا ليعبدون',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('جزاك الله خيراً'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        Future.delayed(const Duration(seconds: 2), () {
          try {
            if (file.existsSync()) file.deleteSync();
          } catch (_) {}
        });
      }
    } catch (e) {
      if (context.mounted && Navigator.canPop(context)) Navigator.pop(context);
      debugPrint('Share error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('failed_to_share'.tr()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Schedule reminder
  // ─────────────────────────────────────────────────────────────────────────

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
          builder: (ctx) => AlertDialog(
            title: Text('Already Scheduled'.tr()),
            content: Text(
              'A reminder for this reward already exists. Do you want to replace it?'
                  .tr(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('cancel'.tr()),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
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
          'type': 'zikr_reminder',
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
            content: Text(
              '${'Reminder scheduled for'.tr()} ${time.format(context)}',
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      debugPrint('Schedule Error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to schedule reminder'.tr()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Branding footer
  // ─────────────────────────────────────────────────────────────────────────

  Widget _brandingFooter(BuildContext context, bool isDark, ThemeData theme) {
    final accent = theme.colorScheme.primary;
    return _InfoCard(
      accent: accent,
      isDark: isDark,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'shared_with'.tr(),
            style: theme.textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Image.asset('assets/playstore.png', height: 40, width: 40),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Level badge
  // ─────────────────────────────────────────────────────────────────────────

  Widget _levelBadge(BuildContext context, ZikrLevel level, ThemeData theme) {
    final isEasy = level == ZikrLevel.easy;
    // Use colorScheme roles: easy → secondary, hard → tertiary
    final color = isEasy ? Colors.blue : Colors.orange.withValues(alpha: 0.8);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(_DialogTokens.radiusBadge),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        isEasy ? 'easy'.tr() : 'hard'.tr(),
        style: TextStyle(
          fontSize: _DialogTokens.fontBadge,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

enum _HeaderAction { share, reminder, report }
