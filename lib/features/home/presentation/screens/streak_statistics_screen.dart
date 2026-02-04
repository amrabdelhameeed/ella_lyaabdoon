import 'package:easy_localization/easy_localization.dart';
import 'package:ella_lyaabdoon/core/services/app_services_database_provider.dart';
import 'package:ella_lyaabdoon/core/services/strike_service.dart';
import 'package:flutter/material.dart';

class StreakStatisticsScreen extends StatelessWidget {
  const StreakStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = StrikeService.getComprehensiveStats();
    final currentStreak = stats['currentStreak'] as int;
    final color = StrikeService.getStrikeColor(currentStreak);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('streak_statistics'.tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current Streak Card (Hero)
            Hero(
              tag: 'streak_icon',
              child: _buildCurrentStreakCard(context, stats, color),
            ),
            const SizedBox(height: 16),

            // Statistics Grid
            _buildStatisticsGrid(context, stats),
            const SizedBox(height: 16),

            // Achievements Section
            _buildAchievementsSection(context, stats),
            const SizedBox(height: 16),

            // Next Milestone
            if (stats['nextMilestone'] != null)
              _buildNextMilestoneCard(context, stats, color),
            const SizedBox(height: 16),

            // Activity Heatmap
            _buildActivityHeatmap(context, stats),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStreakCard(
    BuildContext context,
    Map<String, dynamic> stats,
    Color color,
  ) {
    final currentStreak = stats['currentStreak'] as int;
    final streakStartDate = stats['streakStartDate'] as DateTime?;
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
          ),
        ),
        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              Icon(Icons.local_fire_department, size: 80, color: color),
              const SizedBox(height: 16),
              Text(
                'current_streak'.tr(),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$currentStreak',
                style: theme.textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                'days'.tr(),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: color.withOpacity(0.7),
                ),
              ),
              if (streakStartDate != null) ...[
                const SizedBox(height: 16),
                Text(
                  '${'streak_started_on'.tr()}: ${DateFormat('d MMM yyyy', AppServicesDBprovider.currentLocale()).format(streakStartDate)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

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
        _buildStatCard(
          context,
          icon: Icons.broken_image,
          title: 'streak_breaks'.tr(),
          value: '${stats['streakBreaks']}',
          color: Colors.red,
        ),
        _buildStatCard(
          context,
          icon: Icons.analytics,
          title: 'average_streak'.tr(),
          value: (stats['averageStreak'] as double).toStringAsFixed(1),
          color: Colors.blue,
        ),
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
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
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
              children: StrikeService.milestones.map((milestone) {
                final isAchieved = achievedMilestones.contains(milestone);
                final color = StrikeService.getStrikeColor(milestone);
                final milestoneName =
                    StrikeService.milestoneNames[milestone] ?? 'milestone';

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
            Text(
              '$milestone ${'days'.tr()}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isAchieved
                    ? color
                    : theme.colorScheme.onSurface.withOpacity(0.5),
              ),
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
                Text(
                  '$nextMilestone ${'days'.tr()}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$daysToGo ${'days_to_go'.tr()}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
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
                Text(
                  '${last30Days.length} / 30 ${'days'.tr()}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
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
                ? theme.colorScheme.primary.withOpacity(isDark ? 0.6 : 0.7)
                : theme.colorScheme.onSurface.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
    );
  }
}
