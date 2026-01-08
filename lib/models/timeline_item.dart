import 'package:ella_lyaabdoon/models/azan_day_period.dart';
import 'package:ella_lyaabdoon/models/timeline_reward.dart';
import 'package:ella_lyaabdoon/utils/azan_helper.dart';

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
