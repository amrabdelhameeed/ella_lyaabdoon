import 'package:confetti/confetti.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:ella_lyaabdoon/app_router.dart';
import 'package:ella_lyaabdoon/core/constants/app_lists.dart';
import 'package:ella_lyaabdoon/core/constants/app_routes.dart';
import 'package:ella_lyaabdoon/core/models/azan_day_period.dart';
import 'package:ella_lyaabdoon/core/models/timeline_item.dart';
import 'package:ella_lyaabdoon/core/services/app_services_database_provider.dart';
import 'package:ella_lyaabdoon/core/services/cache_helper.dart';
import 'package:ella_lyaabdoon/core/services/period_notification_reschedule_service.dart';
import 'package:ella_lyaabdoon/core/services/prayer_widget_service.dart';
import 'package:ella_lyaabdoon/core/utils/ramadan_zeena_permanent.dart';
import 'package:ella_lyaabdoon/features/history/data/history_db_provider.dart';
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
  static const String _notificationShowcaseKey =
      'notification_settings_showcase_v1';
  final GlobalKey _notificationKey = GlobalKey();

  // Keys
  final Map<AzanDayPeriod, GlobalKey> _periodKeys = {};
  final GlobalKey _historyKey = GlobalKey();
  final GlobalKey _settingsKey = GlobalKey();
  final GlobalKey _streakKey = GlobalKey();

  final String _streakShowcaseKey = 'streak_showcase_shown21';

  // Services
  final InAppReview _inAppReview = InAppReview.instance;
  late RateMyApp _rateMyApp;

  // ── Streak confetti (consecutive days only) ──────────────────────────────
  final StreakConfettiController _streakConfettiController =
      StreakConfettiController();

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

    if (mounted) {
      setState(() {
        isZeenaEnabled = remoteConfig.getBool('enable_zeena');
      });
    }
  }

  // Cache shuffled rewards
  final Map<AzanDayPeriod, List<dynamic>> _shuffledRewards = {};

  void _shuffleRewardsOnce() {
    for (var item in AppLists.timelineItems) {
      final shuffledList = List<dynamic>.from(item.rewards)..shuffle();
      _shuffledRewards[item.period] = shuffledList;
    }
    debugPrint(
      '✅ Rewards shuffled and cached: ${_shuffledRewards.length} periods',
    );
  }

  final Set<String> _celebratedPeriodMilestones = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _initializeKeys();
    loadConfig();
    _initializePulseAnimation();
    _initializeRateMyApp();
    _initializeHomeWidget();
    _shuffleRewardsOnce();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize streak confetti controller with context
      _streakConfettiController.initialize(context);
      _checkAndCelebrateMilestone();
    });

    // Listen for new milestone achievements from the stream (consecutive days)
    _milestoneSubscription = StreakService.milestoneStream.listen((data) {
      if (mounted) {
        debugPrint('🎉 HomeScreen: Received milestone event!');
        _streakConfettiController.celebrateMilestone(data);
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      PrayerWidgetService.updateWidget();
      debugPrint('🔴 Widget update called from initState');
    });
    PeriodNotificationRescheduleService.rescheduleAll();
  }

  void _checkAndCelebrateMilestone() {
    final milestoneData = StreakService.getPendingCelebration();

    if (milestoneData != null && mounted) {
      debugPrint(
        '🎊 HomeScreen: Found pending celebration, triggering confetti!',
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _streakConfettiController.celebrateMilestone(milestoneData);
        }
      });
    }
  }

  void _initializeHomeWidget() {
    HomeWidget.setAppGroupId('group.com.amrabdelhameed.ella_lyaabdoon');
    PrayerWidgetService.updateWidget();
  }

  @pragma('vm:entry-point')
  static Future<void> _handleWidgetClick(Uri? uri) async {
    if (uri != null) {
      debugPrint('Widget clicked with URI: $uri');
      if (uri.path == '/refresh') {
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
      debugPrint('❌ Showcase gave up after 10 attempts');
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 200 * (attempt + 1)), () {
        if (!mounted) return;

        debugPrint('🔍 Showcase attempt $attempt — key contexts:');
        debugPrint(
          '  streak:       ${_streakKey.currentContext != null ? "✅" : "❌ null"}',
        );
        debugPrint(
          '  notification: ${_notificationKey.currentContext != null ? "✅" : "❌ null"}',
        );
        debugPrint(
          '  settings:     ${_settingsKey.currentContext != null ? "✅" : "❌ null"}',
        );

        final appBarKeysReady =
            _streakKey.currentContext != null &&
            _notificationKey.currentContext != null &&
            _settingsKey.currentContext != null;

        if (!appBarKeysReady) {
          debugPrint('⏳ AppBar keys not ready — retrying (attempt $attempt)');
          _attemptShowcaseStart(showcaseContext, attempt + 1);
          return;
        }

        _hasStartedShowcase = true;

        final homeShown = CacheHelper.getBool(_showcaseKey);
        final notifShown = CacheHelper.getBool(_notificationShowcaseKey);

        final List<GlobalKey> showcaseTargets = [];

        if (homeShown && !notifShown) {
          showcaseTargets.add(_notificationKey);
        } else if (!homeShown) {
          showcaseTargets.addAll([_streakKey, _notificationKey, _settingsKey]);
        }

        if (showcaseTargets.isEmpty) {
          debugPrint('⏭️ No showcase targets — already seen everything');
          return;
        }

        debugPrint(
          '🎯 Starting showcase with ${showcaseTargets.length} targets',
        );
        ShowCaseWidget.of(showcaseContext).startShowCase(showcaseTargets);

        CacheHelper.setBool(_notificationShowcaseKey, true);
        CacheHelper.setBool(_streakShowcaseKey, true);
        if (!homeShown) CacheHelper.setBool(_showcaseKey, true);
      });
    });
  }

  void _onShowcaseComplete() {
    if (_currentPeriodForScroll != null) {
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
    WidgetsBinding.instance.removeObserver(this);
    _streakConfettiController.dispose();
    _milestoneSubscription?.cancel();
    _scrollController.dispose();
    _pulseController.dispose();
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
        BlocProvider<HistoryCubit>(create: (_) => HistoryCubit()),
        BlocProvider(create: (_) => TranslationCubit()),
        BlocProvider(create: (_) => LocationCubit()),
        BlocProvider(create: (context) => HomeCubit()..initialize()),
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
          showLater: true,
          showReleaseNotes: true,
          upgrader: Upgrader(
            languageCode: AppServicesDBprovider.currentLocale(),
            durationUntilAlertAgain: const Duration(days: 2),
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(showcaseContext),
      body: Stack(
        children: [
          _buildBody(showcaseContext),

          // Streak confetti overlay (consecutive days only)
          _streakConfettiController.getConfettiWidget(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext showcaseContext) {
    return AppBar(
      title: Text('app_title'.tr()),
      actions: [
        Showcase(
          key: _streakKey,
          title: 'showcase_streak_title'.tr(),
          description: 'showcase_streak_desc'.tr(),
          child: Hero(
            tag: 'streak_icon',
            child: ValueListenableBuilder<int>(
              valueListenable: StreakService.streakNotifier,
              builder: (showcaseContext, count, child) => StreakAnimationWidget(
                streakCount: count,
                onTap: () => showcaseContext.pushNamed(AppRoutes.statistics),
              ),
            ),
          ),
        ),
        _buildShowcaseButton(
          key: _notificationKey,
          title: 'notifications'.tr(),
          description: 'manage_your_notifications'.tr(),
          icon: Icons.notifications_active_outlined,
          onPressed: () => context.pushNamed(AppRoutes.notificationSettings),
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
            _currentPeriodForScroll = state.currentPeriod;

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

          return BlocBuilder<HistoryCubit, HistoryState>(
            builder: (context, historyState) {
              return _buildTimeline(state, historyState, showcaseContext);
            },
          );
        },
      ),
    );
  }

  Widget _buildTimeline(
    HomeState state,
    HistoryState historyState,
    BuildContext showcaseContext,
  ) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: _buildTimelineItems(state, historyState, showcaseContext),
      ),
    );
  }

  List<Widget> _buildTimelineItems(
    HomeState state,
    HistoryState historyState,
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

      final shuffledRewards = _shuffledRewards[item.period] ?? item.rewards;
      final sortedRewards = _sortRewardsByCompletion(shuffledRewards);
      final visibleRewards = _getVisibleRewardsFromList(
        sortedRewards,
        isCurrent,
        isExpanded,
      );
      final hasMore = sortedRewards.length > 3;
      final showMoreButton = !isCurrent && hasMore;

      final totalCount = sortedRewards.length;
      final doneCount = sortedRewards
          .where((r) => HistoryDBProvider.isCheckedToday(r.id))
          .length;

      return Container(
        key: _periodKeys[item.period],
        child: StickyHeader(
          header: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TimelineHeader(
                titleKey: item.title,
                time: timeText,
                isCurrent: isCurrent,
                isLeftAligned: isLeftAligned,
                isFirst: isFirst,
                pulseAnimation: _pulseAnimation,
              ),
              _buildCompletionBar(
                doneCount: doneCount,
                totalCount: totalCount,
                isCurrent: isCurrent,
                isLeftAligned: isLeftAligned,
              ),
            ],
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
                  period: item.period,
                ),
              if (showMoreButton)
                BlocBuilder<HomeCubit, HomeState>(
                  builder: (context, state) {
                    return TimelineShowMoreButton(
                      isExpanded: isExpanded,
                      remainingCount: sortedRewards.length - 3,
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

  List<dynamic> _sortRewardsByCompletion(List<dynamic> rewards) {
    final unchecked = <dynamic>[];
    final checked = <dynamic>[];
    for (final r in rewards) {
      if (HistoryDBProvider.isCheckedToday(r.id)) {
        checked.add(r);
      } else {
        unchecked.add(r);
      }
    }
    return [...unchecked, ...checked];
  }

  Widget _buildCompletionBar({
    required int doneCount,
    required int totalCount,
    required bool isCurrent,
    required bool isLeftAligned,
  }) {
    if (totalCount == 0) return const SizedBox.shrink();

    final progress = doneCount / totalCount;
    final isComplete = doneCount == totalCount;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: isLeftAligned ? 56 : 16,
        right: isLeftAligned ? 16 : 56,
        bottom: 4,
      ),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
                builder: (_, value, __) => LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isComplete
                ? '✅ $doneCount/$totalCount '
                      '(${totalCount == 0 ? 0 : ((doneCount / totalCount) * 100).round()}%)'
                : '$doneCount/$totalCount '
                      '(${totalCount == 0 ? 0 : ((doneCount / totalCount) * 100).round()}%)',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isComplete
                  ? Theme.of(context).colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
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
    required AzanDayPeriod period,
  }) {
    return TimelineRewardItem(
      reward: reward,
      isCurrent: isCurrent,
      isLeftAligned: isLeftAligned,
      isLast: isLast,
      pulseAnimation: _pulseAnimation,
      onChecked: () {
        _checkZikrMilestone();
        final shuffledRewards = _shuffledRewards[period] ?? [];
        final totalCount = shuffledRewards.length;
        final doneCount = shuffledRewards
            .where((r) => HistoryDBProvider.isCheckedToday(r.id))
            .length;
        _checkPeriodMilestone(period, doneCount, totalCount);
      },
    );
  }

  /// Zikr daily milestone — SnackBar only, no confetti.
  void _checkZikrMilestone() {
    final todayZikrs = HistoryDBProvider.getTotalZikrsCompletedForDate(
      DateTime.now(),
    );

    final milestones = [10, 25, 50, 100, 250, 500, 1000];

    if (milestones.contains(todayZikrs)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.emoji_events_rounded, color: Colors.amber),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'daily_zikr_milestone'.tr(
                    namedArgs: {'count': '$todayZikrs'},
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.greenDark,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  /// Period completion milestone — SnackBar only, no confetti.
  void _checkPeriodMilestone(
    AzanDayPeriod period,
    int doneCount,
    int totalCount,
  ) {
    if (totalCount <= 0) return;

    final percentage = (doneCount / totalCount * 100).round();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final thresholds = [25, 50, 75, 100];
    int? achievedThreshold;

    for (final t in thresholds) {
      if (percentage >= t) achievedThreshold = t;
    }

    if (achievedThreshold == null) return;

    final milestoneKey = "${today}_${period.name}_$achievedThreshold";
    if (_celebratedPeriodMilestones.contains(milestoneKey)) return;

    _celebratedPeriodMilestones.add(milestoneKey);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Colors.amber),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'period_${achievedThreshold}_celebration'.tr(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.greenDark,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
