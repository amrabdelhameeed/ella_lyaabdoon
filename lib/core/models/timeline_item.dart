import 'package:ella_lyaabdoon/core/models/azan_day_period.dart';
import 'package:ella_lyaabdoon/core/models/timeline_reward.dart';

class TimelineItem {
  final String title; // اسم الفترة زي الفجر، الظهر…
  final List<TimelineReward> rewards; // قائمة الجوايز لكل فترة
  final AzanDayPeriod period;

  const TimelineItem({
    required this.title,
    required this.rewards,
    required this.period,
  });
}
