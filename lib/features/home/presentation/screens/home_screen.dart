import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:ella_lyaabdoon/app_router.dart';
import 'package:ella_lyaabdoon/core/constants/app_lists.dart';
import 'package:ella_lyaabdoon/core/constants/app_routes.dart';
import 'package:ella_lyaabdoon/core/models/azan_day_period.dart';
import 'package:ella_lyaabdoon/core/models/timeline_item.dart';
import 'package:ella_lyaabdoon/core/services/app_services_database_provider.dart';
import 'package:ella_lyaabdoon/core/services/cache_helper.dart';
import 'package:ella_lyaabdoon/core/services/prayer_widget_service.dart';
import 'package:ella_lyaabdoon/core/utils/ramadan_zeena_permanent.dart';
import 'package:ella_lyaabdoon/features/history/logic/history_cubit.dart';
import 'package:ella_lyaabdoon/features/home/logic/home_cubit.dart';
import 'package:ella_lyaabdoon/features/home/logic/home_state.dart';
import 'package:ella_lyaabdoon/features/home/logic/quran_audio_cubit.dart';
import 'package:ella_lyaabdoon/features/home/logic/translation_cubit.dart';
import 'package:ella_lyaabdoon/core/services/streak_service.dart';
import 'package:ella_lyaabdoon/features/settings/logic/location_cubit.dart';
import 'package:ella_lyaabdoon/features/settings/logic/location_state.dart';
import 'package:ella_lyaabdoon/features/home/presentation/widgets/timeline_header.dart';
import 'package:ella_lyaabdoon/features/home/presentation/widgets/timeline_reward_item.dart';
import 'package:ella_lyaabdoon/features/home/presentation/widgets/timeline_show_more_button.dart';

import 'package:ella_lyaabdoon/features/home/presentation/widgets/streak_animation_widget.dart';
import 'package:ella_lyaabdoon/features/home/presentation/widgets/streak_confetti_controller.dart';
import 'package:ella_lyaabdoon/utils/constants/app_colors.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:home_widget/home_widget.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:upgrader/upgrader.dart';
import 'package:showcaseview/showcaseview.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // Controllers
  final ScrollController _scrollController = ScrollController();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Keys
  final Map<AzanDayPeriod, GlobalKey> _periodKeys = {};
  final GlobalKey _historyKey = GlobalKey();
  final GlobalKey _settingsKey = GlobalKey();
  final GlobalKey _streakKey = GlobalKey();

  // final GlobalKey _firstRewardKey = GlobalKey();
  final String _streakShowcaseKey = 'streak_showcase_shown21';

  // Services
  // Services
  final InAppReview _inAppReview = InAppReview.instance;
  late RateMyApp _rateMyApp;
  late StreakConfettiController _confettiController;
  StreamSubscription? _milestoneSubscription;

  // State
  bool _hasStartedShowcase = false;
  AzanDayPeriod? _currentPeriodForScroll;

  // Constants
  static const String _showcaseKey = 'home_showcase_shown5';
  static const int _reviewMinDays = 3;
  static const int _reviewMinLaunches = 5;
  static const int _reviewRemindDays = 7;
  static const int _reviewRemindLaunches = 10;
  // ADD THIS NEW METHOD
  bool isZeenaEnabled = false;
  Future<void> loadConfig() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(days: 1),
      ),
    );
    await remoteConfig.setDefaults({'enable_zeena': true});

    await remoteConfig.fetchAndActivate();

    setState(() {
      isZeenaEnabled = remoteConfig.getBool('enable_zeena');
    });
  }

  // ADD THIS: Cache shuffled rewards
  final Map<AzanDayPeriod, List<dynamic>> _shuffledRewards = {};
  // MODIFY THIS METHOD
  void _shuffleRewardsOnce() {
    for (var item in AppLists.timelineItems) {
      // Create a shuffled copy and store it in our cache
      final shuffledList = List<dynamic>.from(item.rewards)..shuffle();
      _shuffledRewards[item.period] = shuffledList;
    }
    debugPrint(
      '✅ Rewards shuffled and cached: ${_shuffledRewards.length} periods',
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // ADD THIS LINE
    _initializeKeys();
    loadConfig();
    _initializePulseAnimation();
    // _playSavedReciterAyah();
    _initializeRateMyApp();
    _initializeHomeWidget();
    _shuffleRewardsOnce(); // ADD THIS LINE
    _confettiController = StreakConfettiController();

    // Check for milestone achievements after initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndCelebrateMilestone();
    });

    // Listen for new milestone achievements
    _milestoneSubscription = StreakService.milestoneStream.listen((data) {
      if (mounted) {
        debugPrint('🎉 HomeScreen: Received milestone event!');
        _confettiController.initialize(context);
        _confettiController.celebrateMilestone(data);
      }
    });

    // Add this to test
    Future.delayed(Duration(seconds: 2), () {
      PrayerWidgetService.updateWidget();
      debugPrint('🔴 Widget update called from initState');
    });
  }

  void _checkAndCelebrateMilestone() {
    // Check if there's a pending celebration from handleAppOpen()
    final milestoneData = StreakService.getPendingCelebration();

    if (milestoneData != null && mounted) {
      debugPrint(
        '\ud83c\udf8a HomeScreen: Found pending celebration, triggering confetti!',
      );
      _confettiController.initialize(context);
      // Delay celebration to ensure UI is ready
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _confettiController.celebrateMilestone(milestoneData);
        }
      });
    } else {
      debugPrint('\u2139\ufe0f HomeScreen: No pending celebration found');
    }
  }

  void _initializeHomeWidget() {
    HomeWidget.setAppGroupId('group.com.amrabdelhameed.ella_lyaabdoon');
    // Callback is now registered in main.dart, not here

    PrayerWidgetService.updateWidget();
  }

  @pragma('vm:entry-point')
  static Future<void> _handleWidgetClick(Uri? uri) async {
    if (uri != null) {
      debugPrint('Widget clicked with URI: $uri');

      if (uri.path == '/refresh') {
        // Update widget with new random reward
        await PrayerWidgetService.updateWidget();
      }
    }
  }

  void _initializeKeys() {
    for (var period in AzanDayPeriod.values) {
      _periodKeys[period] = GlobalKey();
    }
  }

  void _initializePulseAnimation() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _initializeRateMyApp() {
    _rateMyApp = RateMyApp(
      preferencesPrefix: 'ellaLyaabdoon_',
      minDays: _reviewMinDays,
      minLaunches: _reviewMinLaunches,
      remindDays: _reviewRemindDays,
      remindLaunches: _reviewRemindLaunches,
      googlePlayIdentifier: 'com.amrabdelhameed.ella_lyaabdoon',
    );
    _initReviewPrompt();
  }

  Future<void> _initReviewPrompt() async {
    await _rateMyApp.init();
    await Future.delayed(const Duration(seconds: 3));

    if (mounted && _rateMyApp.shouldOpenDialog) {
      await _showReviewPrompt();
    }
  }

  Future<void> _showReviewPrompt() async {
    final isAvailable = await _inAppReview.isAvailable();

    if (isAvailable) {
      await _inAppReview.requestReview();
      await _rateMyApp.callEvent(RateMyAppEventType.rateButtonPressed);
    } else {
      if (!mounted) return;
      _rateMyApp.showRateDialog(
        context,
        title: 'enjoying_app'.tr(),
        message: 'rate_app_message'.tr(),
        rateButton: 'rate_now'.tr(),
        noButton: 'no_thanks'.tr(),
        laterButton: 'maybe_later'.tr(),
        listener: (button) {
          _logReviewButtonAction(button);
          return true;
        },
        dialogStyle: DialogStyle(
          titleAlign: TextAlign.center,
          messageAlign: TextAlign.center,
          messagePadding: const EdgeInsets.only(bottom: 20),
          dialogShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onDismissed: () {
          _rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed);
        },
      );
    }
  }

  void _logReviewButtonAction(RateMyAppDialogButton button) {
    final actions = {
      RateMyAppDialogButton.rate: 'User chose to rate the app',
      RateMyAppDialogButton.later: 'User chose to rate later',
      RateMyAppDialogButton.no: 'User declined to rate',
    };
    debugPrint(actions[button]);
  }

  // void _playSavedReciterAyah() {
  //   final String reciterId = AppServicesDBprovider.getAyahReciter();

  //   if (reciterId.isEmpty) {
  //     debugPrint('Reciter is OFF. Not playing any ayah.');
  //     return;
  //   }

  //   final validReciter = AppLists.reciters.firstWhere(
  //     (r) => r['id'] == reciterId,
  //     orElse: () =>
  //         AppLists.reciters.firstWhere((r) => r['id'] == 'ar.muhammadayyoub'),
  //   );

  //   QuranAudioCubit().playAyah(validReciter['id']!, 4731);
  //   debugPrint('Playing Reciter: ${validReciter['name']}');
  // }

  void _scrollToCurrentPeriod(AzanDayPeriod period) {
    final key = _periodKeys[period];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.bounceIn,
        alignment: 0.0,
      );
    }
  }

  String _getPrayerTimeText(
    AzanDayPeriod period,
    Map<AzanDayPeriod, DateTime>? prayerTimes,
  ) {
    if (prayerTimes != null && prayerTimes.containsKey(period)) {
      final time = prayerTimes[period]!;
      return easy.DateFormat.jm(context.locale.toString()).format(time);
    }
    return '';
  }

  List<dynamic> _getVisibleRewards(
    TimelineItem item,
    AzanDayPeriod? currentPeriod,
    Set<AzanDayPeriod> expanded,
  ) {
    final isExpanded = expanded.contains(item.period);
    final isCurrent = item.period == currentPeriod;

    if (isCurrent || isExpanded) {
      return item.rewards;
    }
    return item.rewards.take(3).toList();
  }

  void _startShowcase(BuildContext showcaseContext) {
    if (_hasStartedShowcase) return;

    final homeShown = CacheHelper.getBool(_showcaseKey);
    final streakShown = CacheHelper.getBool(_streakShowcaseKey);

    if (!homeShown || !streakShown) {
      _attemptShowcaseStart(showcaseContext, 0);
    }
  }

  void _attemptShowcaseStart(BuildContext showcaseContext, int attempt) {
    if (attempt > 10) {
      debugPrint('Failed to start showcase after 10 attempts');
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 200 * (attempt + 1)), () {
        if (!mounted) return;

        if (_streakKey.currentContext != null &&
            _historyKey.currentContext != null &&
            _settingsKey.currentContext != null) {
          _hasStartedShowcase = true;

          final homeShown = CacheHelper.getBool(_showcaseKey);
          final streakShown = CacheHelper.getBool(_streakShowcaseKey);

          final List<GlobalKey> showcaseTargets = [];

          // Add streak only if not shown before
          if (!streakShown) {
            showcaseTargets.add(_streakKey);
          }

          // Add old ones only if home showcase not fully shown
          if (!homeShown) {
            showcaseTargets.addAll([_historyKey, _settingsKey]);
          }

          if (showcaseTargets.isEmpty) {
            return; // Nothing new to show
          }

          ShowCaseWidget.of(showcaseContext).startShowCase(showcaseTargets);

          // Mark keys as shown
          if (!streakShown) {
            CacheHelper.setBool(_streakShowcaseKey, true);
          }

          if (!homeShown) {
            CacheHelper.setBool(_showcaseKey, true);
          }
        } else {
          _attemptShowcaseStart(showcaseContext, attempt + 1);
        }
      });
    });
  }

  void _onShowcaseComplete() {
    // Scroll to current period header after showcase completes
    if (_currentPeriodForScroll != null) {
      // Add a small delay to ensure smooth transition after showcase
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _scrollToCurrentPeriod(_currentPeriodForScroll!);
        }
      });
    }
  }

  void _navigateToReelsView() {
    AppRouter.router.pushNamed(AppRoutes.reels);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // ADD THIS LINE

    _milestoneSubscription?.cancel();
    _scrollController.dispose();
    _pulseController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      PrayerWidgetService.updateWidget();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // BlocProvider(create: (_) => QuranAudioCubit()),
        BlocProvider(create: (_) => TranslationCubit()),
        BlocProvider(create: (_) => LocationCubit()),
        BlocProvider(create: (context) => HomeCubit()..initialize()),
        BlocProvider(create: (_) => HistoryCubit()),
      ],
      child: BlocListener<LocationCubit, LocationState>(
        listener: (context, state) {
          if (state.status == LocationStatus.loaded &&
              state.latitude != null &&
              state.longitude != null) {
            context.read<HomeCubit>().updateWithLocation(
              state.latitude!,
              state.longitude!,
              state.currentCity ?? "Unknown",
            );
          }
        },
        child: UpgradeAlert(
          barrierDismissible: false,
          showIgnore: false,
          showLater: false,
          showReleaseNotes: true,
          upgrader: Upgrader(
            languageCode: AppServicesDBprovider.currentLocale(),
            // debugDisplayAlways: kDebugMode,
            durationUntilAlertAgain: const Duration(hours: 1),
            // debugLogging: true,
          ),
          child: ShowCaseWidget(
            onComplete: (_, __) => _onShowcaseComplete(),
            autoPlayDelay: const Duration(seconds: 8),
            disableBarrierInteraction: false,
            autoPlay: false,
            builder: (contextOfShowCase) {
              return _buildScaffold(contextOfShowCase);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildScaffold(BuildContext showcaseContext) {
    return Scaffold(
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: _navigateToReelsView,
      //   icon: const Icon(Icons.play_circle_outline),
      //   label: Text('reels_view'.tr()),
      //   tooltip: 'switch_to_reels'.tr(),
      // ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _buildBody(showcaseContext),
          isZeenaEnabled
              ? Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: RamadanZeena(animate: false, height: 20),
                )
              : SizedBox.shrink(),
          // Confetti overlay
          _confettiController.getConfettiWidget(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Stack(
        children: [
          Text('app_title'.tr()),
          isZeenaEnabled
              ? RamadanZeena(
                  isWithRope: false,
                  animate: true,
                  isWillBeHidden: false,
                  height: 20,
                  items: [
                    ZeenaItem(
                      xFraction: 0.4,
                      ropeLength: 25,
                      color: AppColors.greenDark,
                      hasStar: true,
                      moonRadius: 10,
                      swayDelay: 0.1,
                    ),
                    ZeenaItem(
                      xFraction: 0.05,
                      ropeLength: 26,
                      color: Colors.deepOrange,
                      hasStar: false,
                      moonRadius: 9,
                      swayDelay: 0.4,
                    ),
                  ],
                )
              : SizedBox.shrink(),
        ],
      ),
      actions: [
        // Animated Streak Widget
        Showcase(
          key: _streakKey,
          title: 'showcase_streak_title'.tr(),
          description: 'showcase_streak_desc'.tr(),
          child: Hero(
            tag: 'streak_icon',
            child: Material(
              color: Colors.transparent,
              child: ValueListenableBuilder<int>(
                valueListenable: StreakService.streakNotifier,
                builder: (context, count, child) {
                  return StreakAnimationWidget(
                    streakCount: count,
                    onTap: () {
                      context.pushNamed(AppRoutes.streakStatistics);
                    },
                  );
                },
              ),
            ),
          ),
        ),
        _buildShowcaseButton(
          key: _historyKey,
          title: 'showcase_history_title'.tr(),
          description: 'showcase_history_desc'.tr(),
          icon: Icons.history,
          tooltip: 'history'.tr(),
          onPressed: () => context.pushNamed(AppRoutes.history),
        ),
        _buildShowcaseButton(
          key: _settingsKey,
          title: 'showcase_settings_title'.tr(),
          description: 'showcase_settings_desc'.tr(),
          icon: Icons.settings,
          onPressed: () => context.pushNamed(AppRoutes.settings),
        ),
      ],
    );
  }

  Widget _buildShowcaseButton({
    required GlobalKey key,
    required String title,
    required String description,
    required IconData icon,
    String? tooltip,
    required VoidCallback onPressed,
  }) {
    return Showcase(
      key: key,
      title: title,
      description: description,
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }

  Widget _buildBody(BuildContext showcaseContext) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewPadding.bottom,
      ),
      child: BlocConsumer<HomeCubit, HomeState>(
        listenWhen: (previous, current) =>
            previous.currentPeriod != current.currentPeriod,
        listener: (context, state) {
          if (state.status == HomeStatus.loaded) {
            PrayerWidgetService.updateWidget();
          }
          if (state.currentPeriod != null) {
            // Store the current period for later scrolling
            _currentPeriodForScroll = state.currentPeriod;

            // Only scroll immediately if showcase has already been shown
            if (CacheHelper.getBool(_showcaseKey)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToCurrentPeriod(state.currentPeriod!);
              });
            }
          }
        },
        builder: (context, state) {
          if (state.status == HomeStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == HomeStatus.error) {
            return Center(child: Text(state.errorMessage ?? 'Unknown error'));
          }

          return _buildTimeline(state, showcaseContext);
        },
      ),
    );
  }

  Widget _buildTimeline(HomeState state, BuildContext showcaseContext) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(children: _buildTimelineItems(state, showcaseContext)),
    );
  }

  List<Widget> _buildTimelineItems(
    HomeState state,
    BuildContext showcaseContext,
  ) {
    int rewardCounter = 0;

    final items = AppLists.timelineItems.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isCurrent = item.period == state.currentPeriod;
      final timeText = _getPrayerTimeText(item.period, state.prayerTimes);
      final isLeftAligned = index % 2 == 0;
      final isFirst = index == 0;
      final isLast = index == AppLists.timelineItems.length - 1;
      final isExpanded = state.expandedPeriods.contains(item.period);

      // USE CACHED SHUFFLED REWARDS instead of item.rewards
      final shuffledRewards = _shuffledRewards[item.period] ?? item.rewards;

      final visibleRewards = _getVisibleRewardsFromList(
        shuffledRewards,
        isCurrent,
        isExpanded,
      );
      final hasMore = shuffledRewards.length > 3;
      final showMoreButton = !isCurrent && hasMore;

      return Container(
        key: _periodKeys[item.period],
        child: StickyHeader(
          header: TimelineHeader(
            titleKey: item.title,
            time: timeText,
            isCurrent: isCurrent,
            isLeftAligned: isLeftAligned,
            isFirst: isFirst,
            pulseAnimation: _pulseAnimation,
          ),
          content: Column(
            children: [
              for (int i = 0; i < visibleRewards.length; i++)
                _buildRewardItem(
                  reward: visibleRewards[i],
                  isCurrent: isCurrent,
                  isLeftAligned: isLeftAligned,
                  isLast:
                      i == visibleRewards.length - 1 &&
                      !showMoreButton &&
                      isLast,
                  isFirstRewardOfFirstPrayer: rewardCounter++ == 0,
                ),
              if (showMoreButton)
                BlocBuilder<HomeCubit, HomeState>(
                  builder: (context, state) {
                    return TimelineShowMoreButton(
                      isExpanded: isExpanded,
                      remainingCount: shuffledRewards.length - 3,
                      isLeftAligned: isLeftAligned,
                      isCurrent: isCurrent,
                      isLast: isLast,
                      pulseAnimation: _pulseAnimation,
                      onToggle: () => context.read<HomeCubit>().toggleExpansion(
                        item.period,
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      );
    }).toList();

    _startShowcase(showcaseContext);
    return items;
  }

  List<dynamic> _getVisibleRewardsFromList(
    List<dynamic> rewards,
    bool isCurrent,
    bool isExpanded,
  ) {
    if (isCurrent || isExpanded) {
      return rewards;
    }
    return rewards.take(3).toList();
  }

  Widget _buildRewardItem({
    required dynamic reward,
    required bool isCurrent,
    required bool isLeftAligned,
    required bool isLast,
    required bool isFirstRewardOfFirstPrayer,
  }) {
    final rewardWidget = TimelineRewardItem(
      reward: reward,
      isCurrent: isCurrent,
      isLeftAligned: isLeftAligned,
      isLast: isLast,
      pulseAnimation: _pulseAnimation,
    );

    // Wrap only the first reward of the first prayer with Showcase
    if (isFirstRewardOfFirstPrayer) {
      // return Showcase(
      //   key: _firstRewardKey,
      //   title: 'showcase_reward_title'.tr(),
      //   description: 'showcase_reward_desc'.tr(),
      //   child: rewardWidget,
      // );
      return rewardWidget;
    }

    return rewardWidget;
  }
}
