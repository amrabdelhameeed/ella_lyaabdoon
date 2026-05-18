enum ZikrLevel { easy, hard }

enum AzkarCategory { morningAzkar, eveningAzkar, postPrayer, general }

class TimelineReward {
  final String id; // Unique ID for tracking history
  final String title; // الجايزة أو اسم الثواب، زي "حج وعمرة تامة تامة تامة"
  final String description; // الحديث أو الوصف الكامل للفضل
  final String source; // المصدر بتاع الحديث
  final bool isWithCounter; // هل الذكر ده له عداد؟
  final ZikrLevel zikrLevel; // مستوى الذكر (سهل - صعب)
  final String? tafsir; // تفسير الحديث أو الوصف الكامل للفضل
  final AzkarCategory? sharedCategory;

  const TimelineReward({
    required this.id,
    required this.title,
    required this.description,
    required this.source,
    this.isWithCounter = false,
    this.zikrLevel = ZikrLevel.easy,
    this.tafsir,
    this.sharedCategory,
  });

  TimelineReward copyWith({
    String? id,
    String? title,
    String? description,
    String? source,
    bool? isWithCounter,
    ZikrLevel? zikrLevel,
    String? tafsir,
    AzkarCategory? sharedCategory,
  }) {
    return TimelineReward(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      source: source ?? this.source,
      isWithCounter: isWithCounter ?? this.isWithCounter,
      zikrLevel: zikrLevel ?? this.zikrLevel,
      tafsir: tafsir ?? this.tafsir,
      sharedCategory: sharedCategory ?? this.sharedCategory,
    );
  }
}
