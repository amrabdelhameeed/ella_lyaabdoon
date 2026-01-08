import 'package:ella_lyaabdoon/models/azan_day_period.dart';

class TimelineReward {
  final String title; // الجايزة أو اسم الثواب، زي "حج وعمرة تامة تامة تامة"
  final String description; // الحديث أو الوصف الكامل للفضل
  final String source; // المصدر بتاع الحديث

  const TimelineReward({
    required this.title,
    required this.description,
    required this.source,
  });
}
