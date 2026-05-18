import re

with open('lib/core/constants/app_lists.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# We need to replace the rewards list for each period.
# Instead of complex regex, let's just find the blocks and replace them.

def replace_block(text, start_marker, end_marker, replacement):
    s = text.find(start_marker)
    if s == -1: return text
    # find the end of the rewards array
    rewards_start = text.find("rewards: const [", s)
    if rewards_start == -1:
        rewards_start = text.find("rewards: [", s)
    
    if rewards_start == -1: return text
    
    array_start = text.find("[", rewards_start)
    
    # find matching bracket
    count = 1
    idx = array_start + 1
    while count > 0 and idx < len(text):
        if text[idx] == '[': count += 1
        elif text[idx] == ']': count -= 1
        idx += 1
        
    e = idx
    return text[:rewards_start] + replacement + text[e:]

# Shorouq
content = replace_block(content, "period: AzanDayPeriod.shorouq,", "period: AzanDayPeriod.duhr,", """rewards: [
        ...SharedAzkar.morningAzkar,
        const TimelineReward(
          id: 'kifayat_allah_4_rakat',
          title: 'كفاية الله في آخر النهار',
          description:
              'عن نعيم بن همار الغطفاني رضي الله عنه أن رسول الله ﷺ قال: «قَالَ اللَّهُ عَزَّ وَجَلَّ: يَا ابْنَ آدَمَ، لَا تَعْجِزْ عَنْ أَرْبَعِ رَكَعَاتٍ مِنْ أَوَّلِ النَّهَارِ أَكْفِكَ آخِرَهُ».',
          source: 'رواه أبو داود (1289) والترمذي (475).',
          zikrLevel: ZikrLevel.easy,
          isWithCounter: false,
        ),
        const TimelineReward(
          id: 'duha_360_charity',
          title: 'صدقة عن كل مفصل',
          description:
              'عن أبي ذر رضي الله عنه أن رسول الله ﷺ قال: «يُصْبِحُ عَلَى كُلِّ سُلَامَى مِنْ أَحَدِكُمْ صَدَقَةٌ... وَيُجْزِئُ مِنْ ذَلِكَ رَكْعَتَانِ يَرْكَعُهُمَا مِنَ الضُّحَى».',
          source: 'رواه مسلم (720).',
          isWithCounter: false,
          zikrLevel: ZikrLevel.easy,
        ),
      ]""")

# Duhr
content = replace_block(content, "period: AzanDayPeriod.duhr,", "period: AzanDayPeriod.asr,", """rewards: [
        ...SharedAzkar.postPrayerAzkar,
        ...SharedAzkar.morningAzkar,
        const TimelineReward(
          id: 'duhr_12_rakat_house',
          title: 'بيت في الجنة',
          description:
              'عن أم حبيبة رضي الله عنها زوج النبي ﷺ قالت: سمعت رسول الله ﷺ يقول: «مَنْ صَلَّى ثِنْتَيْ عَشْرَةَ رَكْعَةً فِي يَوْمٍ وَلَيْلَةٍ، بُنِيَ لَهُ بِهِنَّ بَيْتٌ فِي الْجَنَّةِ».',
          source: 'رواه مسلم (728).',
          isWithCounter: false,
          zikrLevel: ZikrLevel.hard,
        ),
        const TimelineReward(
          id: 'duhr_4_before_4_after',
          title: 'تحريم على النار',
          description:
              'عن أم حبيبة رضي الله عنها قالت: سمعت رسول الله ﷺ يقول: «مَنْ حَافَظَ عَلَى أَرْبَعِ رَكَعَاتٍ قَبْلَ الظُّهْرِ وَأَرْبَعٍ بَعْدَهَا حَرَّمَهُ اللَّهُ عَلَى النَّارِ».',
          source: 'رواه أبو داود (1269) والترمذي (427).',
          zikrLevel: ZikrLevel.hard,
          isWithCounter: false,
        ),
        const TimelineReward(
          id: 'duhr_sky_gates_open',
          title: 'تفتح لها أبواب السماء',
          description:
              'عن عبد الله بن السائب رضي الله عنه أن رسول الله ﷺ كان يصلي أربعاً بعد أن تزول الشمس قبل الظهر وقال: «إِنَّهَا سَاعَةٌ تُفْتَحُ فِيهَا أَبْوَابُ السَّمَاءِ، وَأُحِبُّ أَنْ يَصْعَدَ لِي فِيهَا عَمَلٌ صَالِحٌ».',
          source: 'رواه الترمذي (478).',
          zikrLevel: ZikrLevel.easy,
          isWithCounter: false,
        ),
        const TimelineReward(
          id: 'duhr_waiting_salah',
          title: 'ما زال في صلاة',
          description:
              'قال رسول الله ﷺ: «لَا يَزَالُ أَحَدُكُمْ فِي صَلَاةٍ مَا دَامَتِ الصَّلَاةُ تَحْبِسُهُ، لَا يَمْنَعُهُ أَنْ يَنْقَلِبَ إِلَى أَهْلِهِ إِلَّا الصَّلَاةُ».',
          source: 'رواه البخاري (659).',
          zikrLevel: ZikrLevel.easy,
          isWithCounter: false,
        ),
        const TimelineReward(
          id: 'duhr_dua_between_azan',
          title: 'الدعاء لا يرد',
          description:
              'قال رسول الله ﷺ: «الدُّعَاءُ لَا يُرَدُّ بَيْنَ الْأَذَانِ وَالْإِقَامَةِ».',
          source: 'رواه الترمذي (212) وأبو داود (521).',
          zikrLevel: ZikrLevel.easy,
          isWithCounter: false,
        ),
        const TimelineReward(
          id: 'duhr_qailulah_sunnah',
          title: 'الاستعانة على قيام الليل',
          description:
              'عن ابن عباس رضي الله عنهما أن النبي ﷺ قال: «اسْتَعِينُوا بِطَعَامِ السَّحَرِ عَلَى صِيَامِ النَّهَارِ، وَبِالْقَيْلُولَةِ عَلَى قِيَامِ اللَّيْلِ».',
          source: 'رواه ابن ماجه (1693) وحسنه الألباني.',
          zikrLevel: ZikrLevel.hard,
          isWithCounter: false,
        ),
        const TimelineReward(
          id: 'duhr_jamaah_27',
          title: 'صلاة الجماعة أفضل',
          description:
              'قال رسول الله ﷺ: «صَلَاةُ الْجَمَاعَةِ تَفْضُلُ صَلَاةَ الْفَذِّ بِسَبْعٍ وَعِشْرِينَ دَرَجَةً».',
          source: 'رواه البخاري (645) ومسلم (650).',
          zikrLevel: ZikrLevel.easy,
          isWithCounter: false,
        ),
        const TimelineReward(
          id: 'duhr_early_to_masjid',
          title: 'استغفار الملائكة',
          description:
              'قال رسول الله ﷺ: «الْمَلَائِكَةُ تُصَلِّي عَلَى أَحَدِكُمْ مَا دَامَ فِي مَجْلِسِهِ الَّذِي صَلَّى فِيهِ: اللَّهُمَّ ارْحَمْهُ، اللَّهُمَّ اغْفِرْ لَهُ، اللَّهُمَّ تُبْ عَلَيْهِ».',
          source: 'رواه مسلم (649).',
          zikrLevel: ZikrLevel.hard,
          isWithCounter: false,
        ),
        const TimelineReward(
          id: 'duhr_first_row',
          title: 'خير الصفوف',
          description:
              'قال رسول الله ﷺ: «خَيْرُ صُفُوفِ الرِّجَالِ أَوَّلُهَا، وَشَرُّهَا آخِرُهَا».',
          source: 'رواه مسلم (440).',
          zikrLevel: ZikrLevel.easy,
          isWithCounter: false,
        ),
        const TimelineReward(
          id: 'duhr_walk_to_masjid',
          title: 'رفع الدرجات وحط الخطايا',
          description:
              'قال رسول الله ﷺ: «مَنْ تَطَهَّرَ فِي بَيْتِهِ، ثُمَّ مَشَى إِلَى بَيْتٍ مِنْ بُيُوتِ اللهِ... كَانَتْ خَطْوَتَاهُ إِحْدَاهُمَا تَحُطُّ خَطِيئَةً، وَالْأُخْرَى تَرْفَعُ دَرَجَةً».',
          source: 'رواه مسلم (666).',
          zikrLevel: ZikrLevel.hard,
          isWithCounter: false,
        ),
        const TimelineReward(
          id: 'duhr_sit_after_salah',
          title: 'نزول السكينة وغشيان الرحمة',
          description:
              'قال رسول الله ﷺ: «وَمَا اجْتَمَعَ قَوْمٌ فِي بَيْتٍ مِنْ بُيُوتِ اللهِ... إِلَّا نَزَلَتْ عَلَيْهِمِ السَّكِينَةُ، وَغَشِيَتْهُمُ الرَّحْمَةُ».',
          source: 'رواه مسلم (2699).',
          zikrLevel: ZikrLevel.easy,
          isWithCounter: false,
        ),
        const TimelineReward(
          id: 'duhr_salat_nabi',
          title: 'يصلي الله عليك عشراً',
          description:
              'قال رسول الله ﷺ: «مَنْ صَلَّى عَلَيَّ صَلَاةً صَلَّى اللَّهُ عَلَيْهِ بِهَا عَشْرًا».',
          source: 'رواه مسلم (384).',
          isWithCounter: true,
          zikrLevel: ZikrLevel.hard,
        ),
        const TimelineReward(
          id: 'duhr_dua_after_salah',
          title: 'أسمع الدعاء',
          description:
              'قيل: يا رسول الله، أيُّ الدُّعَاءِ أَسْمَعُ؟ قال: «جَوْفُ اللَّيْلِ الآخِرُ، وَدُبُرُ الصَّلَوَاتِ الْمَكْتُوبَاتِ».',
          source: 'رواه الترمذي (3499).',
          zikrLevel: ZikrLevel.easy,
          isWithCounter: false,
        ),
        const TimelineReward(
          id: 'duhr_ikhlas_10',
          title: 'قصر في الجنة',
          description:
              'قال رسول الله ﷺ: «مَنْ قَرَأَ قُلْ هُوَ اللَّهُ أَحَدٌ حَتَّى يَخْتِمَهَا عَشْرَ مَرَّاتٍ، بَنَى اللَّهُ لَهُ قَصْرًا فِي الْجَنَّةِ».',
          source: 'رواه أحمد (15610) وصححه الألباني.',
          isWithCounter: true,
          zikrLevel: ZikrLevel.hard,
        ),
        const TimelineReward(
          id: 'duhr_subhan_once',
          title: 'غرس نخلة في الجنة',
          description:
              'قال رسول الله ﷺ: «مَنْ قَالَ: سُبْحَانَ اللَّهِ الْعَظِيمِ وَبِحَمْدِهِ، غُرِسَتْ لَهُ نَخْلَةٌ فِي الْجَنَّةِ».',
          source: 'رواه الترمذي (3464).',
          isWithCounter: false,
          zikrLevel: ZikrLevel.easy,
        ),
        const TimelineReward(
          id: 'duhr_hawqala',
          title: 'كنز من كنوز الجنة',
          description:
              'قال رسول الله ﷺ: «يَا عَبْدَ اللَّهِ بْنَ قَيْسٍ، أَلَا أَدُلُّكَ عَلَى كَنْزٍ مِنْ كُنُوزِ الْجَنَّةِ؟ فَقُلْتُ: بَلَى يَا رَسُولَ اللَّهِ، قَالَ: قُلْ لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ».',
          source: 'رواه البخاري (6384) ومسلم (2704).',
          isWithCounter: false,
          zikrLevel: ZikrLevel.easy,
        ),
      ]""")

# Asr
content = replace_block(content, "period: AzanDayPeriod.asr,", "period: AzanDayPeriod.maghrib,", """rewards: [
        ...SharedAzkar.postPrayerAzkar,
        ...SharedAzkar.eveningAzkar,
        const TimelineReward(
          id: 'asr_4_rakat_before',
          title: 'رحمة الله للمصلي',
          description:
              'قال رسول الله ﷺ: «رَحِمَ اللَّهُ امْرَأً صَلَّى قَبْلَ الْعَصْرِ أَرْبَعًا».',
          source: 'رواه أبو داود (1271) والترمذي (430).',
          isWithCounter: false,
          zikrLevel: ZikrLevel.hard,
        ),
        const TimelineReward(
          id: 'asr_angels_witness',
          title: 'تشهدك ملائكة الليل والنهار',
          description:
              'قال رسول الله ﷺ: «يَتَعَاقَبُونَ فِيكُمْ مَلَائِكَةٌ بِاللَّيْلِ وَمَلَائِكَةٌ بِالنَّهَارِ، وَيَجْتَمِعُونَ فِي صَلَاةِ الْفَجْرِ وَصَلَاةِ الْعَصْرِ...».',
          source: 'رواه البخاري (555) ومسلم (632).',
          zikrLevel: ZikrLevel.easy,
          isWithCounter: false,
        ),
        const TimelineReward(
          id: 'asr_paradise_entry',
          title: 'وجبت له الجنة',
          description:
              'عن أبي سعيد الخدري رضي الله عنه قال: قال رسول الله ﷺ: «مَنْ رَضِيَ بِاللَّهِ رَبًّا، وَبِالْإِسْلَامِ دِينًا، وَبِمُحَمَّدٍ نَبِيًّا، وَجَبَتْ لَهُ الْجَنَّةُ».',
          source: 'رواه مسلم (1884).',
          zikrLevel: ZikrLevel.easy,
          isWithCounter: false,
        ),
        const TimelineReward(
          id: 'asr_tasbih_100',
          title: 'ألف حسنة أو حط ألف خطيئة',
          description:
              'عن مصعب بن سعد قال: حدثني أبي قال: كُنَّا عِنْدَ رَسُولِ اللهِ ﷺ، فَقَالَ: «أَيَعْجِزُ أَحَدُكُمْ أَنْ يَكْسِبَ كُلَّ يَوْمٍ أَلْفَ حَسَنَةٍ؟ يُسَبِّحُ مِائَةَ تَسْبِيحَةٍ، فَيُكْتَبُ لَهُ أَلْفُ حَسَنَةٍ، أَوْ يُحَطُّ عَنْهُ أَلْفُ خَطِيئَةٍ».',
          source: 'رواه مسلم (2698).',
          isWithCounter: true,
          zikrLevel: ZikrLevel.hard,
        ),
        const TimelineReward(
          id: 'asr_sitting_dhikr',
          title: 'أحب إلي من عتق أربعة',
          description:
              'عن أنس بن مالك رضي الله عنه قال: قال رسول الله ﷺ: «لَأَنْ أَقْعُدَ مَعَ قَوْمٍ يَذْكُرُونَ اللَّهَ تَعَالَى مِنْ صَلَاةِ الْعَصْرِ إِلَى أَنْ تَغْرُبَ الشَّمْسُ، أَحَبُّ إِلَيَّ مِنْ أَنْ أَعْتِقَ أَرْبَعَةً مِنْ وَلَدِ إِسْمَاعِيلَ».',
          source: 'رواه أبو داود (3667) وحسنه الألباني.',
          zikrLevel: ZikrLevel.hard,
          isWithCounter: false,
        ),
        const TimelineReward(
          id: 'asr_middle_prayer',
          title: 'الحفاظ على الصلاة الوسطى',
          description:
              'قال تعالى: {حَافِظُوا عَلَى الصَّلَوَاتِ وَالصَّلَاةِ الْوُسْطَىٰ}. وعن علي رضي الله عنه أن النبي ﷺ قال يوم الأحزاب: «شَغَلُونَا عَنِ الصَّلاةِ الوُسْطَى، صَلاةِ العَصْرِ، مَلأَ اللَّهُ بُيُوتَهُمْ وَقُبُورَهُمْ نَارًا».',
          source: 'سورة البقرة (238) ومسلم (627).',
          zikrLevel: ZikrLevel.hard,
          isWithCounter: false,
        ),
        const TimelineReward(
          id: 'asr_bardaun_paradise',
          title: 'دخول الجنة بالبردين',
          description:
              'عن أبي موسى الأشعري رضي الله عنه أن رسول الله ﷺ قال: «مَنْ صَلَّى الْبَرْدَيْنِ دَخَلَ الْجَنَّةَ». (والبردان هما الصبح والعصر).',
          source: 'رواه البخاري (574) ومسلم (635).',
          zikrLevel: ZikrLevel.easy,
          isWithCounter: false,
        ),
        const TimelineReward(
          id: 'asr_tawheed_10_times',
          title: 'كعتق أربعة أنفس',
          description:
              'قال رسول الله ﷺ: «مَنْ قَالَ: لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، عَشْرَ مَرَّاتٍ، كَانَ كَمَنْ أَعْتَقَ أَرْبَعَةَ أَنْفُسٍ مِنْ وَلَدِ إِسْمَاعِيلَ».',
          source: 'رواه البخاري (6404) ومسلم (2693).',
          zikrLevel: ZikrLevel.hard,
          isWithCounter: true,
        ),
        const TimelineReward(
          id: 'asr_istighfar_after',
          title: 'غفران الذنوب',
          description:
              'عن ثوبان رضي الله عنه قال: كَانَ رَسُولُ اللهِ ﷺ إِذَا انْصَرَفَ مِنْ صَلَاتِهِ اسْتَغْفَرَ ثَلَاثًا، وَقَالَ: «اللهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ، تَبَارَكْتَ ذَا الْجَلَالِ وَالْإِكْرَامِ».',
          source: 'رواه مسلم (591).',
          zikrLevel: ZikrLevel.easy,
          isWithCounter: true,
        ),
        const TimelineReward(
          id: 'asr_safety_from_fire',
          title: 'عدم دخول النار',
          description:
              'عن عمارة بن رويبة رضي الله عنه قال: سمعت رسول الله ﷺ يقول: «لَنْ يَلِجَ النَّارَ أَحَدٌ صَلَّى قَبْلَ طُلُوعِ الشَّمْسِ، وَقَبْلَ غُرُوبِهَا».',
          source: 'رواه مسلم (634).',
          zikrLevel: ZikrLevel.easy,
          isWithCounter: false,
        ),
        const TimelineReward(
          id: 'asr_dua_between_azan_iqama',
          title: 'دعاء لا يرد',
          description:
              'قال رسول الله ﷺ: «الدُّعَاءُ لَا يُرَدُّ بَيْنَ الْأَذَانِ وَالْإِقَامَةِ».',
          source: 'رواه الترمذي (212) وأبو داود (521).',
          zikrLevel: ZikrLevel.easy,
          isWithCounter: false,
        ),
        const TimelineReward(
          id: 'asr_jamaah_merit',
          title: 'تفضيل صلاة الجماعة',
          description:
              'قال رسول الله ﷺ: «صَلَاةُ الْجَمَاعَةِ تَفْضُلُ صَلَاةَ الْفَذِّ بِسَبْعٍ وَعِشْرِينَ دَرَجَةً»..',
          source: 'رواه البخاري (645) ومسلم (650).',
          zikrLevel: ZikrLevel.hard,
          isWithCounter: false,
        ),
      ]""")

# Maghrib
content = replace_block(content, "period: AzanDayPeriod.maghrib,", "period: AzanDayPeriod.isha,", """rewards: [
        ...SharedAzkar.postPrayerAzkar,
        ...SharedAzkar.eveningAzkar,
        const TimelineReward(
          id: 'maghrib_sunnah_house',
          title: 'بيت في الجنة',
          description:
              'عن أم حبيبة رضي الله عنها قالت: قال رسول الله ﷺ: «مَنْ صَلَّى فِي يَوْمٍ وَلَيْلَةٍ ثِنْتَيْ عَشْرَةَ رَكْعَةً بُنِيَ لَهُ بَيْتٌ فِي الْجَنَّةِ... وَرَكْعَتَيْنِ بَعْدَ الْمَغْرِبِ».',
          source: 'رواه الترمذي (415).',
          isWithCounter: true,
          zikrLevel: ZikrLevel.hard,
        ),
      ]""")

# Isha
content = replace_block(content, "period: AzanDayPeriod.isha,", "period: AzanDayPeriod.night,", """rewards: [
        ...SharedAzkar.postPrayerAzkar,
        ...SharedAzkar.eveningAzkar,
        const TimelineReward(
          id: 'isha_half_night_prayer',
          title: 'كأنما قام نصف الليل',
          description:
              'عن عثمان بن عفان رضي الله عنه قال: سمعت رسول الله ﷺ يقول: «مَنْ صَلَّى الْعِشَاءَ فِي جَمَاعَةٍ فَكَأَنَّمَا قَامَ نِصْفَ اللَّيْلِ».',
          source: 'رواه مسلم (656).',
          zikrLevel: ZikrLevel.hard,
          isWithCounter: false,
        ),
        const TimelineReward(
          id: 'isha_sunnah_house',
          title: 'بيت في الجنة',
          description:
              'عن أم حبيبة رضي الله عنها قالت: قال رسول الله ﷺ: «مَنْ صَلَّى فِي يَوْمٍ وَلَيْلَةٍ ثِنْتَيْ عَشْرَةَ رَكْعَةً بُنِيَ لَهُ بَيْتٌ فِي الْجَنَّةِ: مِنْهَا رَكْعَتَانِ بَعْدَ الْعِشَاءِ».',
          source: 'رواه الترمذي (415).',
          isWithCounter: false,
          zikrLevel: ZikrLevel.hard,
        ),
        const TimelineReward(
          id: 'isha_witr_love',
          title: 'إن الله يحب الوتر',
          description:
              'عن علي رضي الله عنه قال: قال رسول الله ﷺ: «يَا أَهْلَ الْقُرْآنِ، أَوْتِرُوا، فَإِنَّ اللَّهَ وِتْرٌ يُحِبُّ الْوِتْرَ».',
          source: 'رواه أبو داود (1416).',
          zikrLevel: ZikrLevel.easy,
          isWithCounter: false,
        ),
        const TimelineReward(
          id: 'isha_timing_bless',
          title: 'حفظ وقت العشاء',
          description:
              'عن أبي برزة الأسلمي رضي الله عنه قال: «أَنَّ رَسُولَ اللَّهِ ﷺ كَانَ يَكْرَهُ النَّوْمَ قَبْلَ العِشَاءِ وَالحَدِيثَ بَعْدَهَا».',
          source: 'رواه البخاري (568).',
          zikrLevel: ZikrLevel.hard,
          isWithCounter: false,
        ),
        const TimelineReward(
          id: 'isha_waiting_merit',
          title: 'ما زال في صلاة',
          description:
              'قال رسول الله ﷺ: «لاَ يَزَالُ أَحَدُكُمْ فِي صَلاَةٍ مَا دَامَتِ الصَّلاَةُ تَحْبِسُهُ، لاَ يَمْنَعُهُ أَنْ يَنْقَلِبَ إِلَى أَهْلِهِ إِلَّا الصَّلاَةُ».',
          source: 'رواه البخاري (659).',
          zikrLevel: ZikrLevel.easy,
          isWithCounter: false,
        ),
        const TimelineReward(
          id: 'isha_dua_mustajab',
          title: 'دعاء لا يرد',
          description:
              'قال رسول الله ﷺ: «الدُّعَاءُ لَا يُرَدُّ بَيْنَ الْأَذَانِ وَالْإِقَامَةِ، قَالُوا: فَمَاذَا نَقُولُ يَا رَسُولَ اللَّهِ؟ قَالَ: سَلُوا اللَّهَ الْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ».',
          source: 'رواه الترمذي (212).',
          zikrLevel: ZikrLevel.easy,
          isWithCounter: false,
        ),
        const TimelineReward(
          id: 'isha_munafiqin_safety',
          title: 'البراءة من أثقل الصلاة',
          description:
              'قال رسول الله ﷺ: «إِنَّ أَثْقَلَ صَلَاةٍ عَلَى الْمُنَافِقِينَ صَلَاةُ الْعِشَاءِ وَصَلَاةُ الْفَجْرِ، وَلَوْ يَعْلَمُونَ مَا فِيهِمَا لَأَتَوْهُمَا وَلَوْ حَبْوًا».',
          source: 'رواه مسلم (651).',
          zikrLevel: ZikrLevel.hard,
          isWithCounter: false,
        ),
      ]""")

# Fajr
content = replace_block(content, "period: AzanDayPeriod.fajr,", "period: AzanDayPeriod.shorouq,", """rewards: [
        ...SharedAzkar.postPrayerAzkar,
        const TimelineReward(
          id: 'fajr_sunnah',
          title: 'خير من الدنيا وما فيها',
          description:
              'قال رسول الله ﷺ: «رَكْعَتَا الْفَجْرِ خَيْرٌ مِنَ الدُّنْيَا وَمَا فِيهَا».',
          source: 'رواه مسلم (725).',
          isWithCounter: false,
          zikrLevel: ZikrLevel.hard,
        ),
        const TimelineReward(
          id: 'fajr_protection',
          title: 'في ذمة الله (حفظ الله وضمانه)',
          description:
              'قال رسول الله ﷺ: «مَنْ صَلَّى صَلَاةَ الصُّبْحِ فَهُوَ فِي ذِمَّةِ اللَّهِ، فَلَا يَطْلُبَنَّكُمُ اللَّهُ مِنْ ذِمَّتِهِ بِشَيْءٍ، فَإِنَّهُ مَنْ يَطْلُبْهُ مِنْ ذِمَّتِهِ بِشَيْءٍ يُدْرِكْهُ، ثُمَّ يَكُبَّهُ عَلَى وَجْهِهِ فِي نَارِ جَهَنَّمَ».',
          source: 'رواه مسلم (657).',
          zikrLevel: ZikrLevel.hard,
          isWithCounter: false,
        ),
        const TimelineReward(
          id: 'fajr_congregation',
          title: 'كأنما قام الليل كله',
          description:
              'قال رسول الله ﷺ: «مَنْ صَلَّى الْعِشَاءَ فِي جَمَاعَةٍ فَكَأَنَّمَا قَامَ نِصْفَ اللَّيْلِ، وَمَنْ صَلَّى الصُّبْحَ فِي جَمَاعَةٍ فَكَأَنَّمَا صَلَّى اللَّيْلَ كُلَّهُ».',
          source: 'رواه مسلم (656).',
          isWithCounter: false,
          zikrLevel: ZikrLevel.easy,
        ),
        const TimelineReward(
          id: 'fajr_angels_witness',
          title: 'تشهده الملائكة',
          description:
              'قال تعالى: ﴿وَقُرْآنَ الْفَجْرِ إِنَّ قُرْآنَ الْفَجْرِ كَانَ مَشْهُودًا﴾. وقال ﷺ: «تَجْتَمِعُ مَلَائِكَةُ اللَّيْلِ وَمَلَائِكَةُ النَّهَارِ فِي صَلَاةِ الْفَجْرِ».',
          source: 'سورة الإسراء (78) والبخاري (4717).',
          zikrLevel: ZikrLevel.easy,
          isWithCounter: false,
        ),
        const TimelineReward(
          id: 'fajr_light',
          title: 'النور التام يوم القيامة',
          description:
              'قال رسول الله ﷺ: «بَشِّرِ الْمَشَّائِينَ فِي الظُّلَمِ إِلَى الْمَسَاجِدِ بِالنُّورِ التَّامِّ يَوْمَ الْقِيَامَةِ».',
          source: 'رواه أبو داود (561) والترمذي (223).',
          isWithCounter: false,
          zikrLevel: ZikrLevel.easy,
        ),
        const TimelineReward(
          id: 'fajr_safety_from_hypocrisy',
          title: 'براءة من النفاق',
          description:
              'قال رسول الله ﷺ: «لَيْسَ صَلَاةٌ أَثْقَلَ عَلَى الْمُنَافِقِينَ مِنْ صَلَاةِ الْفَجْرِ وَالْعِشَاءِ، وَلَوْ يَعْلَمُونَ مَا فِيهِمَا لَأَتَوْهُمَا وَلَوْ حَبْوًا».',
          source: 'رواه البخاري (657) ومسلم (651).',
          zikrLevel: ZikrLevel.hard,
          isWithCounter: false,
        ),
        const TimelineReward(
          id: 'fajr_paradise_guarantee',
          title: 'دخول الجنة والنجاة من النار',
          description:
              'قال رسول الله ﷺ: «لَنْ يَلِجَ النَّارَ أَحَدٌ صَلَّى قَبْلَ طُلُوعِ الشَّمْسِ، وَقَبْلَ غُرُوبِهَا» (يعني الفجر والعصر). وقال: «مَنْ صَلَّى الْبَرْدَيْنِ دَخَلَ الْجَنَّةَ».',
          source: 'رواه مسلم (634) والبخاري (574).',
          zikrLevel: ZikrLevel.easy,
          isWithCounter: false,
        ),
      ]""")

# Night
content = replace_block(content, "period: AzanDayPeriod.night,", "static const List<Map<String, String>> reciters", """rewards: [
        ...SharedAzkar.eveningAzkar,
        const TimelineReward(
          id: 'night_bed_tasbih',
          title: 'ألف في الميزان',
          description:
              'قال رسول الله ﷺ: «إِذَا أَوَى أَحَدُكُمْ إِلَى فِرَاشِهِ سَبَّحَ ثَلَاثًا وَثَلَاثِينَ، وَحَمِدَ ثَلَاثًا وَثَلَاثِينَ، وَكَبَّرَ أَرْبَعًا وَثَلَاثِينَ، فَهِيَ مِائَةٌ عَلَى اللِّسَانِ، وَأَلْفٌ فِي الْمِيزَانِ».',
          source: 'رواه أبو داود (5065).',
          isWithCounter: true,
          zikrLevel: ZikrLevel.hard,
        ),
        const TimelineReward(
          id: 'night_ikhlas',
          title: 'قراءة ثلث القرآن',
          description:
              'عن أبي سعيد الخدري رضي الله عنه أن النبي ﷺ قال: «وَالَّذِي نَفْسِي بِيَدِهِ، إِنَّهَا لَتَعْدِلُ ثُلُثَ القُرْآنِ». (في {قُلْ هُوَ اللهُ أَحَدٌ}).',
          source: 'رواه البخاري (6643).',
          isWithCounter: true,
          zikrLevel: ZikrLevel.easy,
        ),
        const TimelineReward(
          id: 'night_sayyid_istighfar',
          title: 'من أهل الجنة إن مات',
          description:
              'قال رسول الله ﷺ: «سَيِّدُ الِاسْتِغْفَارِ أَنْ تَقُولَ: اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ لَكَ بِذَنْبِي فَاغْفِرْ لِي، فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ. وَمَنْ قَالَهَا مِنَ اللَّيْلِ وَهُوَ مُوقِنٌ بِهَا، فَمَاتَ قَبْلَ أَنْ يُصْبِحَ، فَهُوَ مِنْ أَهْلِ الْجَنَّةِ».',
          source: 'رواه البخاري (6306).',
          zikrLevel: ZikrLevel.easy,
          isWithCounter: false,
        ),
        const TimelineReward(
          id: 'night_wake_up',
          title: 'استجابة الدعاء وقبول الصلاة',
          description:
              'قال رسول الله ﷺ: «مَنْ تَعَارَّ مِنَ اللَّيْلِ، فَقَالَ: لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، الْحَمْدُ لِلَّهِ، وَسُبْحَانَ اللَّهِ، وَلَا إِلَهَ إِلَّا اللَّهُ، وَاللَّهُ أَكْبَرُ، وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ، ثُمَّ قَالَ: اللَّهُمَّ اغْفِرْ لِي، أَوْ دَعَا، اسْتُجِيبَ لَهُ، فَإِنْ تَوَضَّأَ وَصَلَّى قُبِلَتْ صَلَاتُهُ».',
          source: 'رواه البخاري (1154).',
          zikrLevel: ZikrLevel.easy,
          isWithCounter: false,
        ),
        const TimelineReward(
          id: 'night_bed_dhikr',
          title: 'غفران الذنوب مثل زبد البحر',
          description:
              'قال رسول الله ﷺ: «مَنْ قَالَ حِينَ يَأْوِي إِلَى فِرَاشِهِ: لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ، غُفِرَتْ لَهُ ذُنُوبُهُ وَإِنْ كَانَتْ مِثْلَ زَبَدِ الْبَحْرِ».',
          source: 'رواه النسائي في عمل اليوم والليلة (471) وابن حبان.',
          zikrLevel: ZikrLevel.easy,
          isWithCounter: false,
        ),
        const TimelineReward(
          id: 'night_bed_tawheed',
          title: 'حمد بجميع محامد الخلق',
          description:
              'عن أنس رضي الله عنه أن رسول الله ﷺ قال: «مَنْ قَالَ إِذَا أَوَى إِلَى فِرَاشِهِ: الْحَمْدُ لِلَّهِ الَّذِي كَفَانِي وَآوَانِي، الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنِي وَسَقَانِي، الْحَمْدُ لِلَّهِ الَّذِي مَنَّ عَلَيَّ فَأَفْضَلَ، اللَّهُمَّ إِنِّي أَسْأَلُكَ بِعِزَّتِكَ أَنْ تُنَجِّيَنِي مِنَ النَّارِ، فَقَدْ حَمِدَ اللَّهَ بِجَمِيعِ مَحَامِدِ الْخَلْقِ».',
          source: 'رواه الحاكم في المستدرك (1/730).',
          zikrLevel: ZikrLevel.easy,
          isWithCounter: false,
        ),
        const TimelineReward(
          id: 'night_aslamtu',
          title: 'على الفطرة إن مات',
          description:
              'قال رسول الله ﷺ: «إِذَا أَوَيْتَ إِلَى فِرَاشِكَ فَقُلْ: اللَّهُمَّ أَسْلَمْتُ نَفْسِي إِلَيْكَ، وَفَوَّضْتُ أَمْرِي إِلَيْكَ، وَوَجَّهْتُ وَجْهِي إِلَيْكَ، وَأَلْجَأْتُ ظَهْرِي إِلَيْكَ، رَغْبَةً وَرَهْبَةً إِلَيْكَ، لَا مَلْجَأَ وَلَا مَنْجَا مِنْكَ إِلَّا إِلَيْكَ، آمَنْتُ بِكِتَابِكَ الَّذِي أَنْزَلْتَ، وَبِنَبِيِّكَ الَّذِي أَرْسَلْتَ، فَإِنْ مُتَّ مُتَّ عَلَى الفِطْرَةِ، وَاجْعَلْهُنَّ آخِرَ مَا تَقُولُ».',
          source: 'رواه البخاري (247).',
          zikrLevel: ZikrLevel.hard,
          isWithCounter: false,
        ),
        const TimelineReward(
          id: 'night_bismik_rabbi',
          title: 'توكل كامل عند النوم',
          description:
              'قال رسول الله ﷺ: «إِذَا أَخَذْتَ مَضْجَعَكَ فَقُلْ: بِاسْمِكَ رَبِّي وَضَعْتُ جَنْبِي، وَبِكَ أَرْفَعُهُ، فَإِنْ أَمْسَكْتَ نَفْسِي فَارْحَمْهَا، وَإِنْ أَرْسَلْتَهَا فَاحْفَظْهَا بِمَا تَحْفَظُ بِهِ عِبَادَكَ الصَّالِحِينَ».',
          source: 'رواه البخاري (6320) ومسلم (2714).',
          zikrLevel: ZikrLevel.easy,
          isWithCounter: false,
        ),
        const TimelineReward(
          id: 'night_allahumma_khalaqta',
          title: 'سؤال الحفظ والمغفرة',
          description:
              'قال رسول الله ﷺ: «اللَّهُمَّ إِنَّكَ خَلَقْتَ نَفْسِي وَأَنْتَ تَوَفَّاهَا لَكَ مَمَاتُهَا وَمَحْيَاهَا، إِنْ أَحْيَيْتَهَا فَاحْفَظْهَا، وَإِنْ أَمَتَّهَا فَاغْفِرْ لَهَا. اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَافِيَةَ».',
          source: 'رواه مسلم (2712).',
          zikrLevel: ZikrLevel.easy,
          isWithCounter: false,
        ),
        const TimelineReward(
          id: 'night_prayer_sharaf',
          title: 'شرف المؤمن',
          description:
              'عن سهل بن سعد الساعدي رضي الله عنه: أتاني جبريل عليه السَّلامُ فقال: "يا محمَّدُ! عِشْ ما شئتَ فإنَّك ميِّتٌ، وأحبِبْ من شئتَ فإنَّك مفارقُه، واعمَلْ ما شئتَ فإنَّك مجزِيٌّ به. ثم قال: يا محمَّدُ! شرفُ المؤمنِ قيامُه باللَّيلِ، وعِزُّه استغناؤُه عن النَّاسِ".',
          source:
              'الطبراني (4278)، الحاكم (7921)، أبو نعيم، حلية الأولياء 3/290',
          zikrLevel: ZikrLevel.hard,
          isWithCounter: false,
        ),
        const TimelineReward(
          id: 'night_divine_descent',
          title: 'يستجيب الله دعاءك',
          description:
              'قال رسول الله ﷺ: «يَنْزِلُ رَبُّنَا تَبَارَكَ وَتَعَالَى كُلَّ لَيْلَةٍ إِلَى السَّمَاءِ الدُّنْيَا حِينَ يَبْقَى ثُلُثُ اللَّيْلِ الآخِرُ يَقُولُ: مَنْ يَدْعُونِي فَأَسْتجِيبَ لَهُ، مَنْ يَسْأَلُنِي فَأُعْطِيَهُ، مَنْ يَسْتَغْفِرُنِي فَأَغْفِرَ لَهُ».',
          source: 'رواه البخاري (1145) ومسلم (758).',
          zikrLevel: ZikrLevel.easy,
          isWithCounter: false,
        ),
        const TimelineReward(
          id: 'night_100_ayat',
          title: 'كُتب من القانتين',
          description:
              'قال رسول الله ﷺ: «مَنْ قَامَ بِعَشْرِ آياتٍ لَمْ يُكْتَبْ مِنَ الغَافِلِينَ، وَمَنْ قَامَ بِمِائَةِ آيَةٍ كُتِبَ مِنَ القَانِتِينَ، وَمَنْ قَامَ بِأَلْفِ آيَةٍ كُتِبَ مِنَ المُقَنْطِرِينَ».',
          source: 'رواه أبو داود (1398).',
          isWithCounter: false,
          zikrLevel: ZikrLevel.hard,
        ),
        const TimelineReward(
          id: 'night_baqarah_last_two',
          title: 'كفتاه من كل سوء',
          description:
              'عن أبي مسعود البدري رضي الله عنه قال: قال رسول الله ﷺ: «الآيَتَانِ مِنْ آخرِ سُورَةِ البَقَرَةِ، مَنْ قَرَأَهُمَا فِي لَيْلَةٍ كَفَتَاهُ».',
          source: 'رواه البخاري (5009) ومسلم (808).',
          isWithCounter: false,
          zikrLevel: ZikrLevel.hard,
        ),
        const TimelineReward(
          id: 'night_surah_mulk',
          title: 'المانعة من عذاب القبر',
          description:
              'قال رسول الله ﷺ: «إِنَّ سُورَةً مِنَ القُرْآنِ ثَلَاثُونَ آيَةً شَفَعَتْ لِرَجُلٍ حَتَّى غُفِرَ لَهُ، وَهِيَ سُورَةُ تَبَارَكَ الَّذِي بِيَدِهِ الْمُلْكُ».',
          source: 'رواه الترمذي (2891) وأبو داود (1400).',
          isWithCounter: false,
          zikrLevel: ZikrLevel.hard,
        ),
        const TimelineReward(
          id: 'night_sleep_wudu',
          title: 'ملك يستغفر لك حتى تستيقظ',
          description:
              'قال رسول الله ﷺ: «مَنْ بَاتَ طَاهِرًا بَاتَ فِي شِعَارِهِ مَلَكٌ، فَلَا يَسْتَيْقِظُ سَاعَةً مِنَ اللَّيْلِ إِلَّا قَالَ الْمَلَكُ: اللَّهُمَّ اغْفِرْ لِعَبْدِكَ فُلَانٍ، فَإِنَّهُ بَاتَ طَاهِرًا».',
          source: 'رواه ابن حبان (3/328) وصححه الألباني.',
          zikrLevel: ZikrLevel.hard,
          isWithCounter: false,
        ),
        const TimelineReward(
          id: 'night_surah_kafirun',
          title: 'براءة من الشرك',
          description:
              'عن فروة بن نوفل، عن أبيه، أن النبي ﷺ قال لنوفل: «اقْرَأْ: قُلْ يَا أَيُّهَا الْكَافِرُونَ، ثُمَّ نَمْ عَلَى خَاتِمَتِهَا، فَإِنَّهَا بَرَاءَةٌ مِنَ الشِّرْكِ».',
          source: 'رواه أبو داود (5055) والترمذي (3403).',
          zikrLevel: ZikrLevel.easy,
          isWithCounter: false,
        ),
        const TimelineReward(
          id: 'night_any_moment_dua',
          title: 'ساعة لا يرد فيها سائل',
          description:
              'قال رسول الله ﷺ: «إِنَّ فِي اللَّيْلِ لَسَاعَةً، لَا يُوَافِقُهَا رَجُلٌ مُسْلِمٌ، يَسْأَلُ اللهَ خَيْرًا مِنْ أَمْرِ الدُّنْيَا وَالْآخِرَةِ، إِلَّا أَعْطَاهُ إِيَّاهُ، وَذَلِكَ كُلَّ لَيْلَةٍ».',
          source: 'رواه مسلم (757).',
          zikrLevel: ZikrLevel.easy,
          isWithCounter: false,
        ),
        const TimelineReward(
          id: 'night_intention_reward',
          title: 'أجر قيام الليل وإن نمت',
          description:
              'قال رسول الله ﷺ: «مَا مِنِ امْرِئٍ تَكُونُ لَهُ صَلَاةٌ بِلَيْلٍ، فَيَغْلِبُهُ عَلَيْهَا نَوْمٌ، إِلَّا كُتِبَ لَهُ أَجْرُ صَلَاتِهِ، وَكَانَ نَوْمُهُ صَدَقَةً عَلَيْهِ مِنْ رَبِّهِ».',
          source: 'رواه النسائي (1784) وأبو داود (1314).',
          zikrLevel: ZikrLevel.easy,
          isWithCounter: false,
        ),
        const TimelineReward(
          id: 'night_two_rakats',
          title: 'خير من الدنيا وما فيها',
          description:
              'قال رسول الله ﷺ: «رَكْعَتَانِ يَرْكَعُهُمَا ابْنُ آدَمَ فِي جَوْفِ اللَّيْلِ الآخِرِ خَيْرٌ لَهُ مِنَ الدُّنْيَا وَمَا فِيهَا».',
          source:
              'رواه ابن المبارك في الزهد وصححه الألباني في صحيح الجامع (3505).',
          isWithCounter: false,
          zikrLevel: ZikrLevel.hard,
        ),
        const TimelineReward(
          id: 'night_istighfar_dawn',
          title: 'وعد الله للمستغفرين',
          description:
              'قال تعالى: {وَالْمُسْتَغْفِرِينَ بِالْأَسْحَارِ}. وقال ﷺ: «يَنْزِلُ اللَّهُ كُلَّ لَيْلَةٍ إِلَى السَّمَاءِ الدُّنْيَا حِينَ يَبْقَى ثُلُثُ اللَّيْلِ الْآخِرُ، فَيَقُولُ: هَلْ مِنْ مُسْتَغْفِرٍ فَأَغْفِرَ لَهُ؟ هَلْ مِنْ طَائِعٍ فَأَرْفَعَ لَهُ؟ هَلْ مِنْ دَاعٍ فَأُسْتَجَابَ لَهُ؟».',
          source: 'سورة آل عمران (17)، البخاري (1145)',
          isWithCounter: true,
          zikrLevel: ZikrLevel.easy,
        ),
        const TimelineReward(
          id: 'night_siwak_sunnah',
          title: 'سنة النبي ﷺ عند القيام',
          description:
              'عن حذيفة بن اليمان رضي الله عنهما قال: «كَانَ النَّبِيُّ ﷺ إِذَا قَامَ مِنَ اللَّيْلِ يَشُوصُ فَاهُ بِالسِّوَاكِ».',
          source: 'رواه البخاري (245) ومسلم (255).',
          zikrLevel: ZikrLevel.easy,
          isWithCounter: false,
        ),
      ]""")

content = content.replace("import 'package:ella_lyaabdoon/core/models/timeline_item.dart';", 
"""import 'package:ella_lyaabdoon/core/models/timeline_item.dart';
import 'package:ella_lyaabdoon/core/constants/shared_azkar.dart';""")

with open('lib/core/constants/app_lists.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated app_lists.dart")
