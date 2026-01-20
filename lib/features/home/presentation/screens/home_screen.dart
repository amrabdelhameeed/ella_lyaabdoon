import 'package:easy_localization/easy_localization.dart';
import 'package:ella_lyaabdoon/core/constants/app_lists.dart';
import 'package:ella_lyaabdoon/core/constants/app_routes.dart';
import 'package:ella_lyaabdoon/core/models/azan_day_period.dart';
import 'package:ella_lyaabdoon/core/models/timeline_item.dart';
import 'package:ella_lyaabdoon/core/services/app_services_database_provider.dart';
import 'package:ella_lyaabdoon/core/services/cache_helper.dart';
import 'package:ella_lyaabdoon/core/services/prayer_widget_service.dart';
import 'package:ella_lyaabdoon/features/history/logic/history_cubit.dart';
import 'package:ella_lyaabdoon/features/home/logic/home_cubit.dart';
import 'package:ella_lyaabdoon/features/home/logic/home_state.dart';
import 'package:ella_lyaabdoon/features/home/logic/quran_audio_cubit.dart';
import 'package:ella_lyaabdoon/features/home/logic/translation_cubit.dart';
import 'package:ella_lyaabdoon/features/home/presentation/widgets/timeline_header.dart';
import 'package:ella_lyaabdoon/features/home/presentation/widgets/timeline_reward_item.dart';
import 'package:ella_lyaabdoon/features/home/presentation/widgets/timeline_show_more_button.dart';
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
  // final GlobalKey _firstRewardKey = GlobalKey();

  // Services
  final InAppReview _inAppReview = InAppReview.instance;
  late RateMyApp _rateMyApp;

  // State
  bool _hasStartedShowcase = false;
  AzanDayPeriod? _currentPeriodForScroll;

  // Constants
  static const String _showcaseKey = 'home_showcase_shown5';
  static const int _reviewMinDays = 3;
  static const int _reviewMinLaunches = 5;
  static const int _reviewRemindDays = 7;
  static const int _reviewRemindLaunches = 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // ADD THIS LINE
    _initializeKeys();
    _initializePulseAnimation();
    _playSavedReciterAyah();
    _initializeRateMyApp();
    _initializeHomeWidget();
    // Add this to test
    Future.delayed(Duration(seconds: 2), () {
      PrayerWidgetService.updateWidget();
      debugPrint('🔴 Widget update called from initState');
    });
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

  void _playSavedReciterAyah() {
    final String reciterId = AppServicesDBprovider.getAyahReciter();

    if (reciterId.isEmpty) {
      debugPrint('Reciter is OFF. Not playing any ayah.');
      return;
    }

    final validReciter = AppLists.reciters.firstWhere(
      (r) => r['id'] == reciterId,
      orElse: () =>
          AppLists.reciters.firstWhere((r) => r['id'] == 'ar.muhammadayyoub'),
    );

    QuranAudioCubit().playAyah(validReciter['id']!, 4731);
    debugPrint('Playing Reciter: ${validReciter['name']}');
  }

  void _scrollToCurrentPeriod(AzanDayPeriod period) {
    final key = _periodKeys[period];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
    }
  }

  String _getPrayerTimeText(
    AzanDayPeriod period,
    Map<AzanDayPeriod, DateTime>? prayerTimes,
  ) {
    if (prayerTimes != null && prayerTimes.containsKey(period)) {
      final time = prayerTimes[period]!;
      return DateFormat.jm(context.locale.toString()).format(time);
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

    if (!CacheHelper.getBool(_showcaseKey)) {
      // Try multiple times to find the widget context
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

        // debugPrint(
        //   'Showcase attempt $attempt: _firstRewardKey.currentContext = ${_firstRewardKey.currentContext}',
        // );
        debugPrint(
          'Showcase attempt $attempt: _historyKey.currentContext = ${_historyKey.currentContext}',
        );
        debugPrint(
          'Showcase attempt $attempt: _settingsKey.currentContext = ${_settingsKey.currentContext}',
        );

        if (
        // _firstRewardKey.currentContext != null &&
        _historyKey.currentContext != null &&
            _settingsKey.currentContext != null) {
          _hasStartedShowcase = true;

          debugPrint('Starting showcase now!');
          ShowCaseWidget.of(showcaseContext).startShowCase([
            _historyKey, _settingsKey,
            //  _firstRewardKey
          ]);
          CacheHelper.setBool(_showcaseKey, true);
        } else {
          debugPrint('Retrying showcase start...');
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // ADD THIS LINE

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
        BlocProvider(create: (_) => QuranAudioCubit()),
        BlocProvider(create: (_) => TranslationCubit()),
        BlocProvider(create: (_) => HomeCubit()),
        BlocProvider(create: (_) => HistoryCubit()),
      ],
      child: UpgradeAlert(
        barrierDismissible: false,
        showIgnore: false,
        showLater: false,
        showReleaseNotes: true,
        upgrader: Upgrader(
          // debugDisplayAlways: kDebugMode,
          durationUntilAlertAgain: const Duration(seconds: 2),
          debugLogging: true,
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
    );
  }

  Widget _buildScaffold(BuildContext showcaseContext) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(showcaseContext),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text('home_screen'.tr()),
      actions: [
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
    return BlocConsumer<HomeCubit, HomeState>(
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
    // Always showcase the first reward of the first prayer (index 0, reward 0)
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
      final visibleRewards = _getVisibleRewards(
        item,
        state.currentPeriod,
        state.expandedPeriods,
      );
      final hasMore = item.rewards.length > 3;
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
                  // Show showcase on very first reward (global counter == 0)
                  isFirstRewardOfFirstPrayer: rewardCounter++ == 0,
                ),
              if (showMoreButton)
                BlocBuilder<HomeCubit, HomeState>(
                  builder: (context, state) {
                    return TimelineShowMoreButton(
                      isExpanded: isExpanded,
                      remainingCount: item.rewards.length - 3,
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

    // Start showcase after all items are built
    _startShowcase(showcaseContext);

    return items;
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
