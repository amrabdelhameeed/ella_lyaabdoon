import 'package:easy_localization/easy_localization.dart';
import 'package:ella_lyaabdoon/models/azan_day_period.dart';
import 'package:ella_lyaabdoon/models/timeline_item.dart';
import 'package:ella_lyaabdoon/models/timeline_reward.dart';

class AppLists {
  AppLists._();

  static List<TimelineItem> get timelineItems => [
    // Fajr Period
    TimelineItem(
      title: 'fajr',
      period: AzanDayPeriod.fajr,
      rewards: const [
        TimelineReward(
          title: 'حج وعمرة تامة تامة تامة',
          description:
              'من صلى الفجر في جماعة، ثم قعد يذكر الله حتى تطلع الشمس، ثم صلى ركعتين، كانت له كأجر حجة وعمرة تامة تامة تامة',
          source: 'رواه الترمذي (586)',
        ),
        TimelineReward(
          title: 'في ذمة الله',
          description: 'من صلى الصبح فهو في ذمة الله',
          source: 'رواه مسلم (657)',
        ),
        TimelineReward(
          title: 'نور تام يوم القيامة',
          description:
              'بشر المشائين في الظلم إلى المساجد بالنور التام يوم القيامة',
          source: 'رواه الترمذي (223)',
        ),
        TimelineReward(
          title: 'رؤية الله عز وجل',
          description:
              'إنكم سترون ربكم كما ترون القمر، لا تضامون في رؤيته، فإن استطعتم أن لا تغلبوا على صلاة قبل طلوع الشمس وصلاة قبل غروبها فافعلوا',
          source: 'رواه البخاري (554)',
        ),
        TimelineReward(
          title: 'خير من الدنيا وما فيها',
          description: 'ركعتا الفجر خير من الدنيا وما فيها',
          source: 'رواه مسلم (725)',
        ),
      ],
    ),

    // Shorouq (Sunrise) Period
    TimelineItem(
      title: 'shorouq',
      period: AzanDayPeriod.shorouq,
      rewards: const [
        TimelineReward(
          title: 'أجر حجة وعمرة',
          description:
              'من صلى الفجر في جماعة، ثم قعد يذكر الله حتى تطلع الشمس، ثم صلى ركعتين، كانت له كأجر حجة وعمرة',
          source: 'رواه الترمذي (586)',
        ),
        TimelineReward(
          title: 'صلاة الضحى',
          description: 'من صلى الضحى ثنتي عشرة ركعة بنى الله له قصرًا في الجنة',
          source: 'رواه الترمذي (473)',
        ),
        TimelineReward(
          title: 'صدقة عن كل مفصل',
          description:
              'يصبح على كل سلامى من أحدكم صدقة، فكل تسبيحة صدقة، وكل تحميدة صدقة، وكل تهليلة صدقة، وكل تكبيرة صدقة، وأمر بالمعروف صدقة، ونهي عن المنكر صدقة، ويجزئ من ذلك ركعتان يركعهما من الضحى',
          source: 'رواه مسلم (720)',
        ),
        TimelineReward(
          title: 'الذكر بعد صلاة الفجر',
          description:
              'من قال حين يصبح: لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير، كان له عدل رقبة من ولد إسماعيل',
          source: 'رواه البخاري (6403)',
        ),
      ],
    ),

    // Duhr (Noon) Period
    TimelineItem(
      title: 'duhr',
      period: AzanDayPeriod.duhr,
      rewards: const [
        TimelineReward(
          title: 'بيت في الجنة',
          description:
              'من صلى اثنتي عشرة ركعة في يوم وليلة، بُني له بهن بيت في الجنة',
          source: 'رواه مسلم (728)',
        ),
        TimelineReward(
          title: 'حرمه الله على النار',
          description:
              'من حافظ على أربع ركعات قبل الظهر وأربع بعدها، حرمه الله على النار',
          source: 'رواه الترمذي (428)',
        ),
        TimelineReward(
          title: 'خير من الدنيا وما فيها',
          description: 'ركعتان قبل الظهر خير من الدنيا وما فيها',
          source: 'رواه مسلم (726)',
        ),
        TimelineReward(
          title: 'الصلاة في أول الوقت',
          description: 'أحب الأعمال إلى الله الصلاة على وقتها',
          source: 'رواه البخاري (527)',
        ),
      ],
    ),

    // Asr (Afternoon) Period
    TimelineItem(
      title: 'asr',
      period: AzanDayPeriod.asr,
      rewards: const [
        TimelineReward(
          title: 'من صلى البردين دخل الجنة',
          description: ' من صلى البردين دخل الجنة (العصر و الفجر)',
          source: 'رواه البخاري (574)',
        ),
        // TimelineReward(
        //   title: 'أفضل من عبادة ستين سنة',
        //   description:
        //       'من صلى الصبح في جماعة، ثم جلس يذكر الله حتى تطلع الشمس، ثم صلى ركعتين، كان له كأجر حجة وعمرة',
        //   source: 'رواه الترمذي (586)',
        // ),
        TimelineReward(
          title: 'لن يلج النار',
          description: 'لن يلج النار أحد صلى قبل طلوع الشمس وقبل غروبها',
          source: 'رواه مسلم (634)',
        ),
        TimelineReward(
          title: 'الملائكة تشهد',
          description:
              'يتعاقبون فيكم ملائكة بالليل وملائكة بالنهار، ويجتمعون في صلاة الفجر وصلاة العصر',
          source: 'رواه البخاري (555)',
        ),
        // TimelineReward(
        //   title: 'ساعة الإجابة يوم الجمعة',
        //   description:
        //       'في يوم الجمعة ساعة لا يوافقها عبد مسلم يسأل الله فيها خيرًا إلا أعطاه إياه',
        //   source: 'رواه البخاري (935)',
        // ),
      ],
    ),

    // Maghrib (Sunset) Period
    TimelineItem(
      title: 'maghrib',
      period: AzanDayPeriod.maghrib,
      rewards: const [
        TimelineReward(
          title: 'لآخذن بيده حتى أدخله الجنة',
          description:
              'من قال حين يمسي: رضيت بالله ربًا وبالإسلام دينًا وبمحمد نبيًا، فأنا الزعيم لآخذن بيده حتى أدخله الجنة',
          source: 'رواه أبو داود (4549)',
        ),
        TimelineReward(
          title: 'دعاء لا يرد',
          description: 'الدعاء بين الأذان والإقامة لا يرد',
          source: 'رواه أبو داود (521)',
        ),
        TimelineReward(
          title: 'ركعتان قبل المغرب',
          description:
              'صلوا قبل المغرب ركعتين، صلوا قبل المغرب ركعتين، ثم قال في الثالثة: لمن شاء',
          source: 'رواه البخاري (625)',
        ),

        TimelineReward(
          title: 'قراءة آية الكرسي',
          description:
              'من قرأ آية الكرسي دبر كل صلاة مكتوبة، لم يمنعه من دخول الجنة إلا أن يموت',
          source: 'رواه النسائي في الكبرى (9928)',
        ),
      ],
    ),

    // Isha (Night) Period
    TimelineItem(
      title: 'isha',
      period: AzanDayPeriod.isha,
      rewards: const [
        TimelineReward(
          title: 'كمن قام نصف الليل',
          description:
              'من صلى العشاء في جماعة فكأنما قام نصف الليل، ومن صلى الصبح في جماعة فكأنما صلى الليل كله',
          source: 'رواه مسلم (656)',
        ),
        TimelineReward(
          title: 'ركعتان بعد العشاء',
          description:
              'من حافظ على اثنتي عشرة ركعة من السنة، بنى الله له بيتًا في الجنة',
          source: 'رواه مسلم (728)',
        ),
        TimelineReward(
          title: 'صلاة الوتر',
          description: 'أوتروا يا أهل القرآن',
          source: 'رواه أبو داود (1416)',
        ),
        TimelineReward(
          title: 'قراءة سورة الملك',
          description: 'سورة تبارك هي المانعة من عذاب القبر',
          source: 'رواه الترمذي (2891)',
        ),
        TimelineReward(
          title: 'الأذكار قبل النوم',
          description: 'من قرأ الآيتين من آخر سورة البقرة في ليلة كفتاه',
          source: 'رواه البخاري (5009)',
        ),
      ],
    ),

    // Night Period (After Isha until Midnight)
    TimelineItem(
      title: 'night',
      period: AzanDayPeriod.night,
      rewards: const [
        TimelineReward(
          title: 'قيام الليل',
          description: 'أفضل الصلاة بعد الفريضة صلاة الليل',
          source: 'رواه مسلم (1163)',
        ),
        TimelineReward(
          title: 'الدعاء في الثلث الأخير',
          description:
              'ينزل ربنا تبارك وتعالى كل ليلة إلى السماء الدنيا حين يبقى ثلث الليل الآخر، فيقول: من يدعوني فأستجيب له؟ من يسألني فأعطيه؟ من يستغفرني فأغفر له؟',
          source: 'رواه البخاري (1145)',
        ),
        TimelineReward(
          title: 'صلاة التهجد',
          description:
              'عليكم بقيام الليل، فإنه دأب الصالحين قبلكم، وقربة إلى الله تعالى، ومنهاة عن الإثم، وتكفير للسيئات، ومطردة للداء عن الجسد',
          source: 'رواه الترمذي (3549)',
        ),
        TimelineReward(
          title: 'ركعتا التهجد خير من الدنيا',
          description:
              'ركعتان يركعهما العبد في جوف الليل خير له من الدنيا وما فيها',
          source: 'رواه الحاكم (1159)',
        ),
        TimelineReward(
          title: 'قراءة القرآن',
          description: 'اقرؤوا القرآن فإنه يأتي يوم القيامة شفيعًا لأصحابه',
          source: 'رواه مسلم (804)',
        ),
        TimelineReward(
          title: 'الاستغفار بالأسحار',
          description: 'كانوا قليلاً من الليل ما يهجعون، وبالأسحار هم يستغفرون',
          source: 'سورة الذاريات (17-18)',
        ),
      ],
    ),
  ];
}
