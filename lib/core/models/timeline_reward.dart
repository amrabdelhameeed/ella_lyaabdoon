enum ZikrLevel { easy, hard }

class TimelineReward {
  final String id; // Unique ID for tracking history
  final String title; // الجايزة أو اسم الثواب، زي "حج وعمرة تامة تامة تامة"
  final String description; // الحديث أو الوصف الكامل للفضل
  final String source; // المصدر بتاع الحديث
  final bool isWithCounter; // هل الذكر ده له عداد؟
  final ZikrLevel zikrLevel; // مستوى الذكر (سهل - صعب)

  const TimelineReward({
    required this.id,
    required this.title,
    required this.description,
    required this.source,
    this.isWithCounter = false,
    this.zikrLevel = ZikrLevel.easy,
  });
}
