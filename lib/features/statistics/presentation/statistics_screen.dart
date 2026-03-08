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
      appBar: AppBar(
        title: Text('statistics_title'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Hero(
              tag: 'streak_icon',
              child: _buildCurrentStreakCard(context, _stats, color),
            ),
            const SizedBox(height: 20),
            const _ZikrLineChartCard(),
            const SizedBox(height: 16),
            // const _AppOpensLineChartCard(),
            // const SizedBox(height: 16),
            _buildZikrCard(context),
            const SizedBox(height: 16),
            _buildStatisticsGrid(context, _stats),
            const SizedBox(height: 16),
            _buildStreakSavesCard(context, _stats),
            const SizedBox(height: 16),
            _buildAchievementsSection(context, _stats),
            const SizedBox(height: 16),
            if (_stats['nextMilestone'] != null)
              _buildNextMilestoneCard(context, _stats, color),
            const SizedBox(height: 16),
            _buildActivityHeatmap(context, _stats),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // Current Streak Card
  // ──────────────────────────────────────────────────────────

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
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: color.withOpacity(0.1), width: 1),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.08), color.withOpacity(0.02)],
          ),
        ),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
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
                        fontWeight: FontWeight.w500,
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
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
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
                              padding: const EdgeInsets.only(
                                left: 4,
                                bottom: 8,
                              ),
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
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // Comparison Section
  // ──────────────────────────────────────────────────────────

  Widget _buildZikrCard(BuildContext context) {
    final todayStats = HistoryDBProvider.getTodayStats();
    final zikrsToday = todayStats['zikrsToday'] as int;
    final zikrsThisWeek = HistoryDBProvider.getZikrsThisWeek();
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'zikrs_completed'.tr(),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildZikrStat(
                    context,
                    icon: Icons.today_rounded,
                    label: 'today'.tr(),
                    value: zikrsToday,
                    color: colorScheme.primary,
                  ),
                ),
                Container(
                  width: 1,
                  height: 48,
                  color: colorScheme.outlineVariant,
                ),
                Expanded(
                  child: _buildZikrStat(
                    context,
                    icon: Icons.calendar_month_rounded,
                    label: 'this_week'.tr(),
                    value: zikrsThisWeek,
                    color: colorScheme.tertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZikrStat(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int value,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 28, color: color),
        const SizedBox(height: 6),
        Text(
          value.toString(),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonCard(
    BuildContext context, {
    required String title,
    required int thisWeek,
    required int lastWeek,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final diff = thisWeek - lastWeek;
    final percentChange = lastWeek > 0
        ? ((diff / lastWeek) * 100).round()
        : (thisWeek > 0 ? 100 : 0);
    final isImproved = diff > 0;
    final isSame = diff == 0;
    final changeColor = isSame
        ? Colors.grey
        : (isImproved ? Colors.green : Colors.red);
    final changeIcon = isSame
        ? Icons.remove
        : (isImproved ? Icons.trending_up : Icons.trending_down);

    return Card(
      elevation: 1,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClarityUnmask(
              child: Text(
                '$thisWeek',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            Text(
              'this_week'.tr(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(changeIcon, size: 16, color: changeColor),
                const SizedBox(width: 4),
                Text(
                  isSame
                      ? 'stats_same'.tr()
                      : '${isImproved ? '+' : ''}$percentChange%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: changeColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // Statistics Grid
  // ──────────────────────────────────────────────────────────

  Widget _buildStatisticsGrid(
    BuildContext context,
    Map<String, dynamic> stats,
  ) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1,
      children: [
        _buildStatCard(
          context,
          icon: Icons.emoji_events,
          title: 'longest_streak'.tr(),
          value: '${stats['longestStreak']}',
          color: Colors.amber,
        ),
        _buildStatCard(
          context,
          icon: Icons.calendar_today,
          title: 'total_active_days'.tr(),
          value: '${stats['totalActiveDays']}',
          color: Colors.green,
        ),
        // _buildStatCard(
        //   context,
        //   icon: Icons.broken_image,
        //   title: 'streak_breaks'.tr(),
        //   value: '${stats['streakBreaks']}',
        //   color: Colors.red,
        // ),
        // _buildStatCard(
        //   context,
        //   icon: Icons.analytics,
        //   title: 'average_streak'.tr(),
        //   value: (stats['averageStreak'] as double).toStringAsFixed(1),
        //   color: Colors.blue,
        // ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.1), color.withOpacity(0.03)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            ClarityUnmask(
              child: Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // Streak Saves Card
  // ──────────────────────────────────────────────────────────

  Widget _buildStreakSavesCard(
    BuildContext context,
    Map<String, dynamic> stats,
  ) {
    final availableSaves = stats['availableSaves'] as int;
    final maxSaves = stats['maxSaves'] as int;
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.shield, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'streak_saves'.tr(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'streak_saves_desc'.tr(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(maxSaves, (index) {
                final isAvailable = index < availableSaves;
                return Icon(
                  isAvailable ? Icons.shield : Icons.shield_outlined,
                  color: isAvailable
                      ? Colors.blue
                      : theme.colorScheme.onSurface.withOpacity(0.3),
                  size: 40,
                );
              }),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                '$availableSaves / $maxSaves ${'available_this_month'.tr()}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // Achievements
  // ──────────────────────────────────────────────────────────

  Widget _buildAchievementsSection(
    BuildContext context,
    Map<String, dynamic> stats,
  ) {
    final achievedMilestones = stats['achievedMilestones'] as List<int>;
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.military_tech, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'achievements'.tr(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: StreakService.milestones.map((milestone) {
                final isAchieved = achievedMilestones.contains(milestone);
                final color = StreakService.getStreakColor(milestone);
                final milestoneName =
                    StreakService.milestoneNames[milestone] ?? 'milestone';
                return _buildAchievementBadge(
                  context,
                  milestone: milestone,
                  name: milestoneName.tr(),
                  isAchieved: isAchieved,
                  color: color,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementBadge(
    BuildContext context, {
    required int milestone,
    required String name,
    required bool isAchieved,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Opacity(
      opacity: isAchieved ? 1.0 : 0.4,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isAchieved
              ? color.withOpacity(isDark ? 0.15 : 0.2)
              : theme.colorScheme.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isAchieved
                ? color
                : theme.colorScheme.onSurface.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isAchieved ? Icons.check_circle : Icons.lock,
              size: 16,
              color: isAchieved
                  ? color
                  : theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(width: 4),
            ClarityUnmask(
              child: Text(
                '$milestone ${'days'.tr()}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isAchieved
                      ? color
                      : theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // Next Milestone
  // ──────────────────────────────────────────────────────────

  Widget _buildNextMilestoneCard(
    BuildContext context,
    Map<String, dynamic> stats,
    Color color,
  ) {
    final nextMilestone = stats['nextMilestone'] as int;
    final daysToGo = stats['daysToNextMilestone'] as int;
    final currentStreak = stats['currentStreak'] as int;
    final progress = currentStreak / nextMilestone;
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'next_milestone'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ClarityUnmask(
                  child: Text(
                    '$nextMilestone ${'days'.tr()}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ClarityUnmask(
                  child: Text(
                    '$daysToGo ${'days_to_go'.tr()}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // Activity Heatmap
  // ──────────────────────────────────────────────────────────

  Widget _buildActivityHeatmap(
    BuildContext context,
    Map<String, dynamic> stats,
  ) {
    final last30Days = stats['last30Days'] as List<DateTime>;
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'activity_last_30_days'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildHeatmapGrid(context, last30Days),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClarityUnmask(
                  child: Text(
                    '${last30Days.length} / 30 ${'days'.tr()}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
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

  Widget _buildHeatmapGrid(BuildContext context, List<DateTime> activeDays) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    // final rtl = _isRtl();

    // In RTL: reverse index so today is on the right (index 0 visually = today)
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
        // LTR: index 0 = 29 days ago, index 29 = today
        // RTL: index 0 = today, index 29 = 29 days ago
        final adjustedIndex = index;
        final date = today.subtract(Duration(days: 29 - adjustedIndex));
        final isActive = activeDays.any(
          (d) =>
              d.year == date.year && d.month == date.month && d.day == date.day,
        );
        return Container(
          decoration: BoxDecoration(
            color: isActive
                ? theme.colorScheme.primary.withOpacity(isDark ? 0.6 : 0.7)
                : theme.colorScheme.onSurface.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────
// Shared chart helpers
// ──────────────────────────────────────────────────────────

/// Builds axis-label text for bottom titles, locale-aware.
/// [index] is the fl_chart x-value (always 0..days-1, LTR internal).
/// [days] total days in range.
/// [rtl] whether to mirror the date mapping.
String _chartDateLabel(int index, int days, bool rtl, DateTime today) {
  // In RTL mode the chart is still rendered LTR internally but we
  // mirror the date so index 0 maps to "today" and index days-1 to oldest.
  final dateIndex = rtl ? (days - 1 - index) : index;
  final date = today.subtract(Duration(days: days - 1 - dateIndex));
  final locale = AppServicesDBprovider.currentLocale();
  if (days <= 7) {
    return easy.DateFormat('EEE', locale).format(date);
  }
  return easy.DateFormat('d/M', locale).format(date);
}

/// Mirrors the data map for RTL so today is on the right side of the chart.
Map<int, int> _maybeReverseData(Map<int, int> data, int days, bool rtl) {
  if (!rtl) return data;
  final reversed = <int, int>{};
  for (int i = 0; i < days; i++) {
    reversed[i] = data[days - 1 - i] ?? 0;
  }
  return reversed;
}

// ──────────────────────────────────────────────────────────
// Zikr Line Chart Card
// ──────────────────────────────────────────────────────────

class _ZikrLineChartCard extends StatefulWidget {
  const _ZikrLineChartCard();

  @override
  State<_ZikrLineChartCard> createState() => _ZikrLineChartCardState();
}

class _ZikrLineChartCardState extends State<_ZikrLineChartCard> {
  int _selectedDays = 7;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rtl = _isRtl();
    final rawData = HistoryDBProvider.getDailyZikrCountsRange(_selectedDays);
    final data = _maybeReverseData(rawData, _selectedDays, rtl);

    return Card(
      elevation: 1,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_graph_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'weekly_zikr_chart'.tr(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                _RangeSelector(
                  selected: _selectedDays,
                  onChanged: (v) => setState(() => _selectedDays = v),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // ✅ Force LTR on fl_chart — RTL is handled via data mirroring above
            Directionality(
              textDirection: TextDirection.rtl,
              child: _buildZikrLineChart(context, data, _selectedDays, rtl),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZikrLineChart(
    BuildContext context,
    Map<int, int> data,
    int days,
    bool rtl,
  ) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final primaryColor = theme.colorScheme.primary;

    final spots = List.generate(days, (i) {
      return FlSpot(i.toDouble(), (data[i] ?? 0).toDouble());
    });

    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (days - 1).toDouble(),
          minY: 0,
          maxY: maxY < 1 ? 5 : maxY + 2,
          clipData: const FlClipData.all(),
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  // Reverse date mapping for tooltip too
                  final dateIndex = rtl
                      ? spot.x.toInt()
                      : (days - 1 - spot.x.toInt());
                  final date = today.subtract(Duration(days: dateIndex));
                  final label = easy.DateFormat(
                    'd MMM',
                    AppServicesDBprovider.currentLocale(),
                  ).format(date);
                  return LineTooltipItem(
                    '$label\n${spot.y.toInt()} ${'zikrs'.tr()}',
                    TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: days <= 7 ? 1 : (days <= 30 ? 5 : 10),
                getTitlesWidget: (value, meta) {
                  final label = _chartDateLabel(
                    value.toInt(),
                    days,
                    rtl,
                    today,
                  );
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 9,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox.shrink();
                  return Text(
                    '${value.toInt()}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 9,
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY < 1 ? 1 : (maxY / 4).ceilToDouble(),
            getDrawingHorizontalLine: (value) => FlLine(
              color: theme.colorScheme.onSurface.withOpacity(0.07),
              strokeWidth: 1,
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.35,
              color: primaryColor,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: days <= 14,
                getDotPainter: (spot, percent, bar, index) =>
                    FlDotCirclePainter(
                      radius: 4,
                      color: primaryColor,
                      strokeWidth: 2,
                      strokeColor: theme.colorScheme.surface,
                    ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    primaryColor.withOpacity(0.25),
                    primaryColor.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// App Opens Line Chart Card
// ──────────────────────────────────────────────────────────

class _AppOpensLineChartCard extends StatefulWidget {
  const _AppOpensLineChartCard();

  @override
  State<_AppOpensLineChartCard> createState() => _AppOpensLineChartCardState();
}

class _AppOpensLineChartCardState extends State<_AppOpensLineChartCard> {
  int _selectedDays = 7;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rtl = _isRtl();
    final rawData = HistoryDBProvider.getDailyAppOpensRange(_selectedDays);
    final data = _maybeReverseData(rawData, _selectedDays, rtl);

    return Card(
      elevation: 1,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.phone_android_rounded,
                  color: Colors.green,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'weekly_opens_chart'.tr(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                _RangeSelector(
                  selected: _selectedDays,
                  onChanged: (v) => setState(() => _selectedDays = v),
                  accentColor: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 20),
            // ✅ Force LTR on fl_chart — RTL handled via data mirroring
            Directionality(
              textDirection: TextDirection.ltr,
              child: _buildAppOpensLineChart(context, data, _selectedDays, rtl),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppOpensLineChart(
    BuildContext context,
    Map<int, int> data,
    int days,
    bool rtl,
  ) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    const lineColor = Colors.green;

    final spots = List.generate(days, (i) {
      final val = (data[i] ?? 0).toDouble().clamp(0.0, 1.0);
      return FlSpot(i.toDouble(), val);
    });

    return SizedBox(
      height: 160,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (days - 1).toDouble(),
          minY: -0.1,
          maxY: 1.4,
          clipData: const FlClipData.all(),
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final dateIndex = rtl
                      ? spot.x.toInt()
                      : (days - 1 - spot.x.toInt());
                  final date = today.subtract(Duration(days: dateIndex));
                  final label = easy.DateFormat(
                    'd MMM',
                    AppServicesDBprovider.currentLocale(),
                  ).format(date);
                  final opened = spot.y >= 1;
                  return LineTooltipItem(
                    '$label\n${opened ? 'stats_opened'.tr() : 'stats_not_opened'.tr()}',
                    TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: days <= 7 ? 1 : (days <= 30 ? 5 : 10),
                getTitlesWidget: (value, meta) {
                  final label = _chartDateLabel(
                    value.toInt(),
                    days,
                    rtl,
                    today,
                  );
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 9,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if (value == 1.0) {
                    return Text(
                      'stats_opened'.tr(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 8,
                        color: Colors.green.withOpacity(0.8),
                      ),
                    );
                  }
                  if (value == 0.0) {
                    return Text(
                      'stats_not_opened'.tr(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 8,
                        color: theme.colorScheme.onSurface.withOpacity(0.4),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) => FlLine(
              color: theme.colorScheme.onSurface.withOpacity(0.07),
              strokeWidth: 1,
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: false,
              color: lineColor,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) {
                  final isOpened = spot.y >= 1;
                  return FlDotCirclePainter(
                    radius: 5,
                    color: isOpened ? Colors.green : Colors.grey.shade400,
                    strokeWidth: 2,
                    strokeColor: theme.colorScheme.surface,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.green.withOpacity(0.2),
                    Colors.green.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// Reusable Range Selector Widget
// ──────────────────────────────────────────────────────────

class _RangeSelector extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;
  final Color? accentColor;

  const _RangeSelector({
    required this.selected,
    required this.onChanged,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = accentColor ?? theme.colorScheme.primary;
    const options = [7, 14, 30];
    const labels = ['7d', '14d', '30d'];

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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                labels[i],
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
