import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:ella_lyaabdoon/core/services/app_services_database_provider.dart';
import 'package:ella_lyaabdoon/core/services/streak_service.dart';
import 'package:ella_lyaabdoon/features/history/data/history_db_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// ──────────────────────────────────────────────────────────
// Helper: is the current locale RTL (Arabic)?
// ──────────────────────────────────────────────────────────
bool _isRtl() => AppServicesDBprovider.currentLocale().startsWith('ar');

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with WidgetsBindingObserver {
  late Map<String, dynamic> _stats;
  late int _zikrsToday;
  late bool _openedToday;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _loadData();
  }

  void _loadData() {
    final todayStats = HistoryDBProvider.getTodayStats();
    setState(() {
      _stats = StreakService.getComprehensiveStats();
      _zikrsToday = todayStats['zikrsToday'] as int;
      _openedToday = todayStats['openedToday'] as bool;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentStreak = _stats['currentStreak'] as int;
    final color = StreakService.getStreakColor(currentStreak);

    return Scaffold(
      appBar: AppBar(title: Text('statistics_title'.tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ════════════════════════════════════════════════════
            // SECTION 1 — STREAK
            // Everything streak-related together: current, longest,
            // active days, saves, next milestone.
            // ════════════════════════════════════════════════════
            Hero(
              tag: 'streak_icon',
              child: _buildCurrentStreakCard(context, _stats, color),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildSimpleStatCard(
                    context,
                    icon: Icons.emoji_events_rounded,
                    title: 'longest_streak'.tr(),
                    value: '${_stats['longestStreak']}',
                    unit: 'days'.tr().toLowerCase(),
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSimpleStatCard(
                    context,
                    icon: Icons.calendar_today_rounded,
                    title: 'total_active_days'.tr(),
                    value: '${_stats['totalActiveDays']}',
                    unit: 'days'.tr().toLowerCase(),
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildStreakSavesCard(context, _stats),
            if (_stats['nextMilestone'] != null) ...[
              const SizedBox(height: 8),
              _buildNextMilestoneCard(context, _stats, color),
            ],

            const SizedBox(height: 24),
            _sectionLabel(context, 'stats_section_azkar'.tr()),
            const SizedBox(height: 8),

            // ════════════════════════════════════════════════════
            // SECTION 2 — AZKAR COUNTS (numbers only, no graphs)
            // Today, week, month comparison, 3m/6m/all-time.
            // ════════════════════════════════════════════════════
            _buildAzkarCountsSection(context),

            const SizedBox(height: 24),
            _sectionLabel(context, 'stats_section_trends'.tr()),
            const SizedBox(height: 8),

            // ════════════════════════════════════════════════════
            // SECTION 3 — TRENDS (graphs only)
            // Insight pills, single toggleable chart, heatmap.
            // ════════════════════════════════════════════════════
            _buildInsightRow(context),
            const SizedBox(height: 8),
            const _ZikrChartCard(),
            const SizedBox(height: 8),
            _buildSmartActivityHeatmap(context, _stats),

            const SizedBox(height: 24),
            _sectionLabel(context, 'stats_section_achievements'.tr()),
            const SizedBox(height: 8),

            // ════════════════════════════════════════════════════
            // SECTION 4 — ACHIEVEMENTS
            // ════════════════════════════════════════════════════
            _buildAchievementsSection(context, _stats),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // Helpers shared across sections
  // ─────────────────────────────────────────

  Widget _sectionLabel(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.only(left: 2),
    child: Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
        letterSpacing: 1.2,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  // ─────────────────────────────────────────
  // SECTION 1 — Streak widgets
  // ─────────────────────────────────────────

  Widget _buildCurrentStreakCard(
    BuildContext context,
    Map<String, dynamic> stats,
    Color color,
  ) {
    final currentStreak = stats['currentStreak'] as int;
    final streakStartDate = stats['streakStartDate'] as DateTime?;
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: color.withOpacity(0.15), width: 1),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.08), color.withOpacity(0.02)],
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_fire_department_rounded,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'current_streak'.tr(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (streakStartDate != null)
                    ClarityUnmask(
                      child: Text(
                        easy.DateFormat(
                          'd MMM yyyy',
                          AppServicesDBprovider.currentLocale(),
                        ).format(streakStartDate),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            ClarityUnmask(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$currentStreak',
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w300,
                        letterSpacing: -1,
                      ),
                    ),
                    WidgetSpan(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(
                          'days'.tr().toLowerCase(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: color.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
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
    );
  }

  Widget _buildSimpleStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String unit,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: color.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.55),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  ClarityUnmask(
                    child: Text(
                      '$value $unit',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakSavesCard(
    BuildContext context,
    Map<String, dynamic> stats,
  ) {
    final availableSaves = stats['availableSaves'] as int;
    final maxSaves = stats['maxSaves'] as int;
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            const Icon(Icons.shield_rounded, color: Colors.blue, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'streak_saves'.tr(),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'streak_saves_desc'.tr(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.55),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(maxSaves, (i) {
                final active = i < availableSaves;
                return Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(
                    active ? Icons.shield_rounded : Icons.shield_outlined,
                    color: active
                        ? Colors.blue
                        : theme.colorScheme.onSurface.withOpacity(0.25),
                    size: 28,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextMilestoneCard(
    BuildContext context,
    Map<String, dynamic> stats,
    Color color,
  ) {
    final nextMilestone = stats['nextMilestone'] as int;
    final daysToGo = stats['daysToNextMilestone'] as int;
    final currentStreak = stats['currentStreak'] as int;
    final progress = (currentStreak / nextMilestone).clamp(0.0, 1.0);
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flag_rounded, color: color, size: 18),
                const SizedBox(width: 6),
                Text(
                  'next_milestone'.tr(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                ClarityUnmask(
                  child: Text(
                    '$daysToGo ${'days_to_go'.tr()}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.55),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: color.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ClarityUnmask(
                  child: Text(
                    '$currentStreak ${'days'.tr().toLowerCase()}',
                    style: theme.textTheme.labelSmall?.copyWith(color: color),
                  ),
                ),
                ClarityUnmask(
                  child: Text(
                    '$nextMilestone ${'days'.tr().toLowerCase()}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.45),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // SECTION 2 — Azkar counts (numeric only)
  // ─────────────────────────────────────────

  Widget _buildAzkarCountsSection(BuildContext context) {
    final todayStats = HistoryDBProvider.getTodayStats();
    final zikrsToday = todayStats['zikrsToday'] as int;
    final zikrsThisWeek = HistoryDBProvider.getZikrsThisWeek();
    final zikrsThisMonth = HistoryDBProvider.getZikrsThisMonth();
    final zikrsLastMonth = HistoryDBProvider.getZikrsLastMonth();
    final zikrs3Months = HistoryDBProvider.getZikrsLast3Months();
    final zikrs6Months = HistoryDBProvider.getZikrsLast6Months();
    final zikrsAllTime = HistoryDBProvider.getZikrsAllTime();

    final monthDiff = zikrsThisMonth - zikrsLastMonth;
    final monthPercent = zikrsLastMonth > 0
        ? ((monthDiff / zikrsLastMonth) * 100).round()
        : (zikrsThisMonth > 0 ? 100 : 0);
    final isImproved = monthDiff > 0;
    final isSame = monthDiff == 0;

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      children: [
        // Row 1: today + this week
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildCountTile(
                  context,
                  label: 'today'.tr(),
                  value: zikrsToday,
                  icon: Icons.today_rounded,
                  color: cs.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCountTile(
                  context,
                  label: 'this_week'.tr(),
                  value: zikrsThisWeek,
                  icon: Icons.view_week_rounded,
                  color: cs.tertiary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Row 2: this month ↔ last month with delta
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'this_month'.tr(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.onSurface.withOpacity(0.55),
                        ),
                      ),
                      const SizedBox(height: 2),
                      ClarityUnmask(
                        child: Text(
                          '$zikrsThisMonth',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSame
                        ? cs.onSurface.withOpacity(0.07)
                        : (isImproved
                              ? Colors.green.withOpacity(0.12)
                              : Colors.red.withOpacity(0.12)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSame
                            ? Icons.remove_rounded
                            : (isImproved
                                  ? Icons.trending_up_rounded
                                  : Icons.trending_down_rounded),
                        size: 14,
                        color: isSame
                            ? cs.onSurface.withOpacity(0.4)
                            : (isImproved ? Colors.green : Colors.red),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        isSame
                            ? 'stats_same'.tr()
                            : '${isImproved ? '+' : ''}$monthPercent%',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSame
                              ? cs.onSurface.withOpacity(0.4)
                              : (isImproved ? Colors.green : Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'last_month'.tr(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.onSurface.withOpacity(0.55),
                        ),
                      ),
                      const SizedBox(height: 2),
                      ClarityUnmask(
                        child: Text(
                          '$zikrsLastMonth',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Row 3: 3m / 6m / all-time
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildCountTile(
                  context,
                  label: 'stats_3_months'.tr(),
                  value: zikrs3Months,
                  icon: Icons.date_range_rounded,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCountTile(
                  context,
                  label: 'stats_6_months'.tr(),
                  value: zikrs6Months,
                  icon: Icons.date_range_rounded,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCountTile(
                  context,
                  label: 'stats_all_time'.tr(),
                  value: zikrsAllTime,
                  icon: Icons.all_inclusive_rounded,
                  color: Colors.amber.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCountTile(
    BuildContext context, {
    required String label,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: color.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            ClarityUnmask(
              child: Text(
                '$value',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.55),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // SECTION 3 — Trends
  // ─────────────────────────────────────────

  Widget _buildInsightRow(BuildContext context) {
    final weeklyAvg = HistoryDBProvider.getWeeklyAverageZikrs();
    final completionRate30 = HistoryDBProvider.getCompletionRate(30);
    final bestDayIndex = HistoryDBProvider.getBestDayOfWeek();
    final locale = AppServicesDBprovider.currentLocale();
    final now = DateTime.now();
    final bestDayName = bestDayIndex >= 0
        ? easy.DateFormat('EEE', locale).format(
            DateTime(
              now.year,
              now.month,
              now.day,
            ).subtract(Duration(days: now.weekday - 1 - bestDayIndex)),
          )
        : '–';

    // Use IntrinsicHeight so all three pills have equal height
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _buildInsightPill(
              context,
              icon: Icons.show_chart_rounded,
              label: 'stats_weekly_avg'.tr(),
              value: weeklyAvg.toStringAsFixed(1),
              color: Colors.teal,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildInsightPill(
              context,
              icon: Icons.percent_rounded,
              label: 'stats_completion_30d'.tr(),
              value: '$completionRate30%',
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildInsightPill(
              context,
              icon: Icons.star_rounded,
              label: 'stats_best_day'.tr(),
              value: bestDayName,
              color: Colors.pink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightPill(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: color.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 5),
            ClarityUnmask(
              child: Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartActivityHeatmap(
    BuildContext context,
    Map<String, dynamic> stats,
  ) {
    final totalActiveDays = stats['totalActiveDays'] as int;
    final theme = Theme.of(context);
    final use90Day = totalActiveDays > 30;
    final title = use90Day
        ? 'activity_last_90_days'.tr()
        : 'activity_last_30_days'.tr();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            if (use90Day)
              _build90DayHeatmap(context)
            else
              _build30DayHeatmap(
                context,
                stats['last30Days'] as List<DateTime>,
              ),
            if (!use90Day) ...[
              const SizedBox(height: 10),
              Center(
                child: ClarityUnmask(
                  child: Text(
                    '${(stats['last30Days'] as List<DateTime>).length} / 30 ${'days'.tr().toLowerCase()}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.55),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _build30DayHeatmap(BuildContext context, List<DateTime> activeDays) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: 30,
      itemBuilder: (context, index) {
        final date = today.subtract(Duration(days: 29 - index));
        final isActive = activeDays.any(
          (d) =>
              d.year == date.year && d.month == date.month && d.day == date.day,
        );
        return Container(
          decoration: BoxDecoration(
            color: isActive
                ? theme.colorScheme.primary.withOpacity(isDark ? 0.65 : 0.75)
                : theme.colorScheme.onSurface.withOpacity(0.08),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
    );
  }

  Widget _build90DayHeatmap(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final rawCounts = HistoryDBProvider.getDailyZikrCountsRange(90);
    final maxCount = rawCounts.values.fold(0, (m, v) => v > m ? v : m);

    Color cellColor(int count) {
      if (count == 0) {
        return isDark
            ? Colors.white.withOpacity(0.07)
            : Colors.black.withOpacity(0.07);
      }
      final t = maxCount > 0 ? count / maxCount : 0.0;
      final p = theme.colorScheme.primary;
      if (t <= 0.25) return p.withOpacity(0.25);
      if (t <= 0.50) return p.withOpacity(0.45);
      if (t <= 0.75) return p.withOpacity(0.65);
      return p.withOpacity(0.90);
    }

    final startDate = today.subtract(const Duration(days: 89));
    final paddedStart = startDate.subtract(
      Duration(days: startDate.weekday - 1),
    );
    final weeks = <List<Map<String, dynamic?>>>[];
    var cursor = paddedStart;
    while (!cursor.isAfter(today)) {
      final week = <Map<String, dynamic?>>[];
      for (int d = 0; d < 7; d++) {
        final cellDate = cursor.add(Duration(days: d));
        if (cellDate.isBefore(startDate) || cellDate.isAfter(today)) {
          week.add({'date': null, 'count': 0});
        } else {
          final daysAgo = today.difference(cellDate).inDays;
          final idx = 89 - daysAgo;
          week.add({
            'date': cellDate,
            'count': idx >= 0 && idx < 90 ? (rawCounts[idx] ?? 0) : 0,
          });
        }
      }
      weeks.add(week);
      cursor = cursor.add(const Duration(days: 7));
    }

    final locale = AppServicesDBprovider.currentLocale();
    final dayLabels = List.generate(7, (i) {
      final ref = today.subtract(Duration(days: today.weekday - 1 - i));
      return easy.DateFormat('EEEEE', locale).format(ref);
    });
    final monthLabels = <int, String>{};
    for (int w = 0; w < weeks.length; w++) {
      final firstReal = weeks[w].firstWhere(
        (c) => c['date'] != null,
        orElse: () => {'date': null, 'count': 0},
      );
      if (firstReal['date'] == null) continue;
      final d = firstReal['date'] as DateTime;
      if (d.day <= 7) {
        monthLabels[w] = easy.DateFormat('MMM', locale).format(d);
      }
    }

    const cellSize = 13.0;
    const cellGap = 3.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 22),
            ...List.generate(
              weeks.length,
              (w) => SizedBox(
                width: cellSize + cellGap,
                child: monthLabels.containsKey(w)
                    ? Text(
                        monthLabels[w]!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 9,
                          color: theme.colorScheme.onSurface.withOpacity(0.45),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ...List.generate(7, (dayIndex) {
          return Padding(
            padding: const EdgeInsets.only(bottom: cellGap),
            child: Row(
              children: [
                SizedBox(
                  width: 22,
                  child: Text(
                    dayIndex % 2 == 1 ? dayLabels[dayIndex] : '',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 9,
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 3),
                ...List.generate(weeks.length, (w) {
                  final cell = weeks[w][dayIndex];
                  final date = cell['date'] as DateTime?;
                  final count = cell['count'] as int;
                  return Padding(
                    padding: const EdgeInsets.only(right: cellGap),
                    child: Tooltip(
                      message: date != null
                          ? '${easy.DateFormat('d MMM', locale).format(date)}: $count ${'zikrs'.tr()}'
                          : '',
                      child: Container(
                        width: cellSize,
                        height: cellSize,
                        decoration: BoxDecoration(
                          color: date != null
                              ? cellColor(count)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'stats_legend_none'.tr(),
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 9,
                color: theme.colorScheme.onSurface.withOpacity(0.45),
              ),
            ),
            const SizedBox(width: 4),
            ...[0.07, 0.25, 0.45, 0.65, 0.90].map(
              (o) => Padding(
                padding: const EdgeInsets.only(right: 3),
                child: Container(
                  width: cellSize,
                  height: cellSize,
                  decoration: BoxDecoration(
                    color: o == 0.07
                        ? (isDark
                              ? Colors.white.withOpacity(0.07)
                              : Colors.black.withOpacity(0.07))
                        : theme.colorScheme.primary.withOpacity(o),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            Text(
              'stats_legend_high'.tr(),
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 9,
                color: theme.colorScheme.onSurface.withOpacity(0.45),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  // SECTION 4 — Achievements
  // ─────────────────────────────────────────

  Widget _buildAchievementsSection(
    BuildContext context,
    Map<String, dynamic> stats,
  ) {
    final achievedMilestones = stats['achievedMilestones'] as List<int>;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: StreakService.milestones.map((milestone) {
            final isAchieved = achievedMilestones.contains(milestone);
            final color = StreakService.getStreakColor(milestone);
            return Opacity(
              opacity: isAchieved ? 1.0 : 0.35,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isAchieved
                      ? color.withOpacity(isDark ? 0.15 : 0.12)
                      : theme.colorScheme.onSurface.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isAchieved
                        ? color
                        : theme.colorScheme.onSurface.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAchieved
                          ? Icons.check_circle_rounded
                          : Icons.lock_rounded,
                      size: 14,
                      color: isAchieved
                          ? color
                          : theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                    const SizedBox(width: 5),
                    ClarityUnmask(
                      child: Text(
                        '$milestone ${'days'.tr().toLowerCase()}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isAchieved
                              ? color
                              : theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// Shared helpers (top-level, used by _ZikrChartCard)
// ══════════════════════════════════════════════════════════════════

String _chartDateLabel(int index, int days, bool rtl, DateTime today) {
  final dateIndex = rtl ? (days - 1 - index) : index;
  final date = today.subtract(Duration(days: days - 1 - dateIndex));
  final locale = AppServicesDBprovider.currentLocale();
  if (days <= 7) return easy.DateFormat('EEE', locale).format(date);
  if (days <= 30) return easy.DateFormat('d/M', locale).format(date);
  if (date.day == 1 || index == 0) {
    return easy.DateFormat('MMM', locale).format(date);
  }
  return '';
}

Map<int, int> _maybeReverseData(Map<int, int> data, int days, bool rtl) {
  if (!rtl) return data;
  return {for (int i = 0; i < days; i++) i: data[days - 1 - i] ?? 0};
}

// ══════════════════════════════════════════════════════════════════
// Zikr Chart Card — single card, 7/14/30 = line chart, 90 = bar chart
// ══════════════════════════════════════════════════════════════════

class _ZikrChartCard extends StatefulWidget {
  const _ZikrChartCard();
  @override
  State<_ZikrChartCard> createState() => _ZikrChartCardState();
}

class _ZikrChartCardState extends State<_ZikrChartCard> {
  int _selectedDays = 7;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rtl = _isRtl();
    final rawData = HistoryDBProvider.getDailyZikrCountsRange(_selectedDays);
    final data = _maybeReverseData(rawData, _selectedDays, rtl);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final maxY = data.values.fold(
      0.0,
      (a, b) => b.toDouble() > a ? b.toDouble() : a,
    );
    final primary = theme.colorScheme.primary;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_graph_rounded, color: primary, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'stats_zikr_over_time'.tr(),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _RangeSelector(
                  selected: _selectedDays,
                  options: const [7, 14, 30, 90],
                  labelKeys: const [
                    'zikr_chart_7_days_label',
                    'zikr_chart_14_days_label',
                    'zikr_chart_30_days_label',
                    'zikr_chart_90_days_label',
                  ],
                  onChanged: (v) => setState(() => _selectedDays = v),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Force LTR for fl_chart — RTL handled via data mirroring
            Directionality(
              textDirection: TextDirection.ltr,
              child: SizedBox(
                height: 200,
                child: _selectedDays == 90
                    ? _buildBarChart(
                        context,
                        data,
                        _selectedDays,
                        rtl,
                        today,
                        maxY: maxY,
                      )
                    : _buildLineChart(
                        context,
                        data,
                        _selectedDays,
                        rtl,
                        today,
                        maxY: maxY,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(
    BuildContext context,
    Map<int, int> data,
    int days,
    bool rtl,
    DateTime today, {
    required double maxY,
  }) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final locale = AppServicesDBprovider.currentLocale();
    final spots = List.generate(
      days,
      (i) => FlSpot(i.toDouble(), (data[i] ?? 0).toDouble()),
    );

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (days - 1).toDouble(),
        minY: 0,
        maxY: maxY < 1 ? 5 : maxY + 2,
        clipData: const FlClipData.all(),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots.map((spot) {
              final dIdx = rtl ? spot.x.toInt() : (days - 1 - spot.x.toInt());
              final date = today.subtract(Duration(days: dIdx));
              return LineTooltipItem(
                '${easy.DateFormat('d MMM', locale).format(date)}\n${spot.y.toInt()} ${'zikrs'.tr()}',
                TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            }).toList(),
          ),
        ),
        titlesData: _titlesData(
          context,
          days,
          rtl,
          today,
          interval: days <= 7 ? 1.0 : 5.0,
        ),
        borderData: FlBorderData(show: false),
        gridData: _gridData(context, maxY),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: primary,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: days <= 14,
              getDotPainter: (s, p, b, i) => FlDotCirclePainter(
                radius: 4,
                color: primary,
                strokeWidth: 2,
                strokeColor: theme.colorScheme.surface,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [primary.withOpacity(0.22), primary.withOpacity(0.0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(
    BuildContext context,
    Map<int, int> data,
    int days,
    bool rtl,
    DateTime today, {
    required double maxY,
  }) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final locale = AppServicesDBprovider.currentLocale();

    return BarChart(
      BarChartData(
        minY: 0,
        maxY: maxY < 1 ? 5 : maxY + 1,
        barGroups: List.generate(
          days,
          (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: (data[i] ?? 0).toDouble(),
                color: primary.withOpacity(0.7),
                width: 3,
                borderRadius: BorderRadius.circular(2),
              ),
            ],
          ),
        ),
        titlesData: _titlesData(context, days, rtl, today, interval: 1),
        borderData: FlBorderData(show: false),
        gridData: _gridData(context, maxY),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, _, rod, __) {
              final dIdx = rtl ? group.x : (days - 1 - group.x);
              final date = today.subtract(Duration(days: dIdx));
              return BarTooltipItem(
                '${easy.DateFormat('d MMM', locale).format(date)}\n${rod.toY.toInt()} ${'zikrs'.tr()}',
                TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  FlTitlesData _titlesData(
    BuildContext context,
    int days,
    bool rtl,
    DateTime today, {
    required double interval,
  }) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall?.copyWith(
      fontSize: 9,
      color: theme.colorScheme.onSurface.withOpacity(0.5),
    );
    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 28,
          interval: interval,
          getTitlesWidget: (v, _) {
            final label = _chartDateLabel(v.toInt(), days, rtl, today);
            if (label.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(label, style: style),
            );
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 28,
          getTitlesWidget: (v, _) {
            if (v == 0) return const SizedBox.shrink();
            return Text('${v.toInt()}', style: style);
          },
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  FlGridData _gridData(BuildContext context, double maxY) {
    final theme = Theme.of(context);
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: maxY < 1 ? 1 : (maxY / 4).ceilToDouble(),
      getDrawingHorizontalLine: (_) => FlLine(
        color: theme.colorScheme.onSurface.withOpacity(0.07),
        strokeWidth: 1,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// Range Selector
// ══════════════════════════════════════════════════════════════════

class _RangeSelector extends StatelessWidget {
  final int selected;
  final List<int> options;
  final List<String> labelKeys;
  final ValueChanged<int> onChanged;
  final Color? accentColor;

  const _RangeSelector({
    required this.selected,
    required this.options,
    required this.labelKeys,
    required this.onChanged,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = accentColor ?? theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(options.length, (i) {
          final isSelected = selected == options[i];
          return GestureDetector(
            onTap: () => onChanged(options[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                labelKeys[i].tr(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isSelected
                      ? Colors.white
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
