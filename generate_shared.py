import re

with open('lib/core/constants/app_lists.dart', 'r', encoding='utf-8') as f:
    content = f.read()

def get_rewards(start_str, end_str):
    s = content.find(start_str)
    e = content.find(end_str, s)
    text = content[s:e]
    # match each TimelineReward up to its closing parenthesis and comma
    return re.findall(r'(TimelineReward\([^;]*?\),)', text, re.DOTALL)

shorouq_all = get_rewards("SHOROUQ", "DUHR")
morning_rewards = shorouq_all[:19] # exclude the last 2

maghrib_all = get_rewards("MAGHRIB", "ISHA")
evening_rewards = maghrib_all

def add_category(rewards, cat):
    out = []
    for r in rewards:
        if 'sharedCategory:' not in r:
            r = r.replace('),', f'  sharedCategory: {cat},\n        ),')
        out.append(r)
    return out

morning_azkar = add_category(morning_rewards, "AzkarCategory.morningAzkar")
evening_azkar = add_category(evening_rewards, "AzkarCategory.eveningAzkar")

post_prayer_azkar = [
    """        TimelineReward(
          id: 'post_prayer_ayat_kursi',
          title: 'دخول الجنة مباشرة',
          description: 'قال رسول الله ﷺ: «مَنْ قَرَأَ آيَةَ الْكُرْسِيِّ فِي دُبُرِ كُلِّ صَلَاةٍ مَكْتُوبَةٍ لَمْ يَمْنَعْهُ مِنْ دُخُولِ الْجَنَّةِ إِلَّا أَنْ يَمُوتَ».',
          source: 'رواه النسائي في الكبرى (9848).',
          zikrLevel: ZikrLevel.easy,
          isWithCounter: false,
          sharedCategory: AzkarCategory.postPrayer,
        ),""",
    """        TimelineReward(
          id: 'post_prayer_tasbih_33',
          title: 'غفران الخطايا مثل زبد البحر',
          description: 'قال رسول الله ﷺ: «مَنْ سَبَّحَ اللَّهَ فِي دُبُرِ كُلِّ صَلَاةٍ ثَلَاثًا وَثَلَاثِينَ، وَحَمِدَ اللَّهَ ثَلَاثًا وَثَلَاثِينَ، وَكَبَّرَ اللَّهَ ثَلَاثًا وَثَلَاثِينَ... غُفِرَتْ خَطَايَاهُ».',
          source: 'رواه مسلم (597).',
          isWithCounter: true,
          zikrLevel: ZikrLevel.hard,
          sharedCategory: AzkarCategory.postPrayer,
        ),"""
]

# We need to rewrite app_lists.dart
# The simplest approach is to define these as static const lists at the top of AppLists class,
# and then replace the rewards arrays for each period with `[...morningAzkar, ...postPrayerAzkar, ...]` 

# But since we can't easily parse Dart with Python to that depth without breaking things,
# let's just create a shared_azkar.dart file
with open('lib/core/constants/shared_azkar.dart', 'w', encoding='utf-8') as f:
    f.write("import 'package:ella_lyaabdoon/core/models/timeline_reward.dart';\n\n")
    f.write("class SharedAzkar {\n")
    f.write("  static const List<TimelineReward> morningAzkar = [\n")
    f.write("\n".join(morning_azkar))
    f.write("\n  ];\n\n")
    f.write("  static const List<TimelineReward> eveningAzkar = [\n")
    f.write("\n".join(evening_azkar))
    f.write("\n  ];\n\n")
    f.write("  static const List<TimelineReward> postPrayerAzkar = [\n")
    f.write("\n".join(post_prayer_azkar))
    f.write("\n  ];\n")
    f.write("}\n")

print("Created shared_azkar.dart")
