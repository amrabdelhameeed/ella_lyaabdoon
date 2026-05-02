import 'dart:io';
import 'package:easy_localization/easy_localization.dart' as ez;
import 'package:ella_lyaabdoon/core/constants/app_lists.dart';
import 'package:ella_lyaabdoon/core/models/azan_day_period.dart';
import 'package:ella_lyaabdoon/core/models/timeline_reward.dart';
import 'package:ella_lyaabdoon/core/services/app_services_database_provider.dart';
import 'package:ella_lyaabdoon/core/services/cache_helper.dart';
import 'package:ella_lyaabdoon/core/services/zikr_widget_service.dart';
import 'package:ella_lyaabdoon/core/utils/ramadan_zeena_permanent.dart';
import 'package:ella_lyaabdoon/features/history/data/history_db_provider.dart';
import 'package:ella_lyaabdoon/features/history/logic/history_cubit.dart';
import 'package:ella_lyaabdoon/features/home/logic/home_cubit.dart';
import 'package:ella_lyaabdoon/features/home/logic/home_state.dart';
import 'package:ella_lyaabdoon/features/home/logic/translation_cubit.dart';
import 'package:ella_lyaabdoon/utils/notification_helper.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ella_lyaabdoon/core/constants/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

// ── Constants ─────────────────────────────────────────────────────────────────

class _AppColors {
  static const Color primaryGreen = Color(0xFF2D5F3F);
  static const Color accentGreen = Color(0xFF4A9B6A);
  static const Color surfaceGreen = Color(0xFF1C4430);
}

const String _kDoubleTapHintKey = 'double_tap_hint1';
const String _kCounterTapHintKey = 'counter_tap_hint1';
const int _kMaxHintShows = 5;

// ─────────────────────────────────────────────────────────────────────────────

class ReelsViewScreen extends StatelessWidget {
  const ReelsViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => HomeCubit()..initialize()),
        BlocProvider(create: (_) => HistoryCubit()),
        BlocProvider(create: (_) => TranslationCubit()),
      ],
      child: const _ReelsViewContent(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ReelsViewContent extends StatefulWidget {
  const _ReelsViewContent();

  @override
  State<_ReelsViewContent> createState() => _ReelsViewContentState();
}

class _ReelsViewContentState extends State<_ReelsViewContent>
    with SingleTickerProviderStateMixin {
  // ── Page / data ──────────────────────────────────────────────────────
  late final PageController _pageController;
  int _currentIndex = 0;
  List<RewardItem> _allRewards = [];

  // ── Counter ──────────────────────────────────────────────────────────
  final Map<int, int> _counters = {};
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  // ── Translation visibility per page ─────────────────────────────────
  final Map<int, bool> _showTranslation = {};

  // ── Tafsir visibility per page ───────────────────────────────────────
  final Map<int, bool> _showTafsir = {};

  // ── Hint: double-tap (mark done) ────────────────────────────────────
  bool _showDoubleTapHint = false;

  // ── Hint: counter tap ───────────────────────────────────────────────
  bool _showCounterTapHint = false;
  bool _counterHintActive = false;

  // ── Screenshot ───────────────────────────────────────────────────────
  final ScreenshotController _screenshotController = ScreenshotController();

  // ─────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    )..addListener(() => setState(() {}));

    _maybeShowDoubleTapHint();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────
  // Analytics
  // ─────────────────────────────────────────────────────────────────────

  void _logEvent(String name, {Map<String, Object>? parameters}) {
    if (kReleaseMode) {
      FirebaseAnalytics.instance.logEvent(name: name, parameters: parameters);
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // Hint: double-tap
  // ─────────────────────────────────────────────────────────────────────

  Future<void> _maybeShowDoubleTapHint() async {
    final n = CacheHelper.getInt(_kDoubleTapHintKey);
    if (n >= _kMaxHintShows) return;
    CacheHelper.setInt(_kDoubleTapHintKey, n + 1);

    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _showDoubleTapHint = true);

    await Future.delayed(const Duration(seconds: 3));
    if (mounted) setState(() => _showDoubleTapHint = false);
  }

  void _dismissDoubleTapHint() {
    if (_showDoubleTapHint) setState(() => _showDoubleTapHint = false);
  }

  // ─────────────────────────────────────────────────────────────────────
  // Hint: counter tap
  // ─────────────────────────────────────────────────────────────────────

  Future<void> _maybeShowCounterTapHint() async {
    if (_counterHintActive) return;
    if (_currentIndex >= _allRewards.length) return;
    final reward = _allRewards[_currentIndex].reward as TimelineReward;
    if (!reward.isWithCounter) return;

    final n = CacheHelper.getInt(_kCounterTapHintKey);
    if (n >= _kMaxHintShows) return;
    CacheHelper.setInt(_kCounterTapHintKey, n + 1);

    _counterHintActive = true;

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    setState(() => _showCounterTapHint = true);

    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() {
        _showCounterTapHint = false;
        _counterHintActive = false;
      });
    }
  }

  void _dismissCounterTapHint() {
    if (_showCounterTapHint) {
      setState(() {
        _showCounterTapHint = false;
        _counterHintActive = false;
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // Page change handler
  // ─────────────────────────────────────────────────────────────────────

  void _onPageLanded(int index) {
    setState(() {
      _currentIndex = index;
      _showTranslation[index] = false;
      // Tafsir collapses when swiping to a new page
      _showTafsir[index] = false;
    });
    context.read<TranslationCubit>().reset();
    _dismissDoubleTapHint();
    _dismissCounterTapHint();
    _maybeShowCounterTapHint();
  }

  // ─────────────────────────────────────────────────────────────────────
  // Rewards list builder
  // ─────────────────────────────────────────────────────────────────────

  void _buildRewardsList() {
    _allRewards.clear();
    final currentPeriod = context.read<HomeCubit>().state.currentPeriod;

    for (final item in AppLists.timelineItems) {
      final shuffled = List.from(item.rewards)..shuffle();
      for (final reward in shuffled) {
        _allRewards.add(
          RewardItem(
            reward: reward,
            period: item.period,
            periodTitle: item.title,
          ),
        );
      }
    }

    if (currentPeriod != null && _allRewards.isNotEmpty) {
      final idx = _allRewards.indexWhere((r) => r.period == currentPeriod);
      if (idx != -1) _currentIndex = idx;
    }

    if (mounted) setState(() {});

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_currentIndex);
      }
      _maybeShowCounterTapHint();
    });
  }

  // ─────────────────────────────────────────────────────────────────────
  // Counter helpers
  // ─────────────────────────────────────────────────────────────────────

  int _getCount(int page) => _counters[page] ?? 0;

  void _increment(int page) {
    _dismissCounterTapHint();
    setState(() => _counters[page] = (_counters[page] ?? 0) + 1);
    _pulseController.forward(from: 0);
  }

  void _resetCount(int page) => setState(() => _counters[page] = 0);

  // ─────────────────────────────────────────────────────────────────────
  // Translation helpers
  // ─────────────────────────────────────────────────────────────────────

  bool _isShowingTranslation(int page) => _showTranslation[page] ?? false;

  void _toggleTranslation(int page, String text) {
    final nowShowing = !(_showTranslation[page] ?? false);
    setState(() => _showTranslation[page] = nowShowing);
    if (nowShowing) {
      context.read<TranslationCubit>().translate(text);
    } else {
      context.read<TranslationCubit>().reset();
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // Tafsir helpers
  // ─────────────────────────────────────────────────────────────────────

  bool _isShowingTafsir(int page) => _showTafsir[page] ?? false;

  void _toggleTafsir(int page) {
    setState(() => _showTafsir[page] = !(_showTafsir[page] ?? false));
  }

  // ─────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isArabic = AppServicesDBprovider.currentLocale() == 'ar';

    return Scaffold(
      appBar: _buildAppBar(),
      body: BlocConsumer<HomeCubit, HomeState>(
        listenWhen: (prev, curr) =>
            prev.currentPeriod != curr.currentPeriod ||
            prev.status != curr.status,
        listener: (context, state) {
          if (state.status != HomeStatus.loaded) return;
          _buildRewardsList();
        },
        builder: (context, state) {
          if (state.status == HomeStatus.loading || _allRewards.isEmpty) {
            return _buildLoadingState();
          }
          if (state.status == HomeStatus.error) {
            return _buildErrorState(state.errorMessage);
          }
          return _buildBody(state, isArabic);
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // AppBar
  // ─────────────────────────────────────────────────────────────────────

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      title: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (_currentIndex >= _allRewards.length)
            return const SizedBox.shrink();
          final current = _allRewards[_currentIndex];
          return Row(
            children: [
              Text(
                current.periodTitle.tr(),
                style: const TextStyle(
                  color: _AppColors.accentGreen,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '⏰ ${ez.DateFormat.jm(context.locale.toString()).format(state.prayerTimes![current.period!]!)}',
                style: const TextStyle(fontSize: 15),
              ),
            ],
          );
        },
      ),
      centerTitle: true,
      actions: [
        IconButton(
          tooltip: 'switch_to_normal'.tr(),
          icon: const Icon(Icons.view_agenda_outlined),
          onPressed: () async {
            await AppServicesDBprovider.setReelsView(value: false);
            if (context.mounted) context.goNamed(AppRoutes.home);
          },
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Body
  // ─────────────────────────────────────────────────────────────────────

  Widget _buildBody(HomeState state, bool isArabic) {
    return Stack(
      children: [
        PageView.builder(
          restorationId: 'reels_view',
          controller: _pageController,
          scrollDirection: Axis.vertical,
          itemCount: _allRewards.length,
          onPageChanged: _onPageLanded,
          itemBuilder: (context, index) {
            final item = _allRewards[index];
            return _buildRewardPage(
              pageIndex: index,
              rewardItem: item,
              isCurrent: item.period == state.currentPeriod,
              state: state,
              isArabic: isArabic,
            );
          },
        ),

        Positioned(
          right: 3,
          top: 20,
          bottom: 80,
          child: _buildProgressIndicator(),
        ),

        if (_showDoubleTapHint)
          Positioned.fill(child: _buildDoubleTapHintOverlay()),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Hint overlay
  // ─────────────────────────────────────────────────────────────────────

  Widget _buildDoubleTapHintOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.center,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
        ),
      ),
      child: Center(
        child: IgnorePointer(
          child: _HintContent(
            label: 'double_tap_to_check'.tr(),
            sublabel: 'tap_twice_to_mark_done'.tr(),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Loading / error states
  // ─────────────────────────────────────────────────────────────────────

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('Loading...'.tr()),
        ],
      ),
    );
  }

  Widget _buildErrorState(String? message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(message ?? 'Unknown error', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Progress indicator
  // ─────────────────────────────────────────────────────────────────────

  Widget _buildProgressIndicator() {
    return Container(
      width: 4,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemH = constraints.maxHeight / _allRewards.length;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                top: _currentIndex * itemH,
                child: Container(
                  width: 4,
                  height: itemH,
                  decoration: BoxDecoration(
                    color: _AppColors.accentGreen,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Reward page
  // ─────────────────────────────────────────────────────────────────────

  Widget _buildRewardPage({
    required int pageIndex,
    required RewardItem rewardItem,
    required bool isCurrent,
    required HomeState state,
    required bool isArabic,
  }) {
    final reward = rewardItem.reward as TimelineReward;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final isEnglish = AppServicesDBprovider.currentLocale() == 'en';
    final count = _getCount(pageIndex);
    final showingTranslation = _isShowingTranslation(pageIndex);
    final showingTafsir = _isShowingTafsir(pageIndex);
    final hasTafsir = reward.tafsir != null && reward.tafsir!.isNotEmpty;

    return BlocBuilder<HistoryCubit, HistoryState>(
      builder: (context, _) {
        final isChecked = HistoryDBProvider.isCheckedToday(reward.id);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Period bar + level badge
                Row(
                  children: [
                    Expanded(
                      child: _buildPeriodCompletionBar(
                        rewardItem.period,
                        isCurrent,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildLevelBadge(reward.zikrLevel),
                  ],
                ),
                const SizedBox(height: 10),

                // Counter
                if (reward.isWithCounter) ...[
                  _buildCounter(context, pageIndex, count),
                  const SizedBox(height: 10),
                ],

                // Main card
                Expanded(
                  child: GestureDetector(
                    onDoubleTap: () async {
                      _dismissDoubleTapHint();
                      context.read<HistoryCubit>().toggleCheck(reward.id);
                      await RewardWidgetService.updateWidget();
                    },
                    child: _buildMainCard(
                      reward: reward,
                      isChecked: isChecked,
                      isRtl: isRtl,
                      isEnglish: isEnglish,
                      showingTranslation: showingTranslation,
                      showingTafsir: showingTafsir,
                      hasTafsir: hasTafsir,
                      pageIndex: pageIndex,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                _buildActionBar(
                  context: context,
                  pageIndex: pageIndex,
                  reward: reward,
                  isEnglish: isEnglish,
                  showingTranslation: showingTranslation,
                  isChecked: isChecked,
                ),

                const SizedBox(height: 10),

                Center(
                  child: Column(
                    children: [
                      const Icon(Icons.keyboard_arrow_up_rounded, size: 24),
                      Text(
                        'swipe_for_more'.tr(),
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Main card
  // ─────────────────────────────────────────────────────────────────────

  Widget _buildMainCard({
    required TimelineReward reward,
    required bool isChecked,
    required bool isRtl,
    required bool isEnglish,
    required bool showingTranslation,
    required bool showingTafsir,
    required bool hasTafsir,
    required int pageIndex,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isChecked
              ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
              : Theme.of(context).colorScheme.primary.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // ── Title row ──
          Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Text(
                  reward.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                    color: AppServicesDBprovider.isDark()
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),
              Positioned(
                right: isRtl ? null : 0,
                left: isRtl ? 0 : null,
                child: AnimatedOpacity(
                  opacity: isChecked ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: AnimatedSlide(
                    offset: isChecked
                        ? Offset.zero
                        : Offset(isRtl ? -0.3 : 0.3, 0),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    child: const Text('✅', style: TextStyle(fontSize: 20)),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Divider ──
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Theme.of(context).colorScheme.primary.withOpacity(0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Description ──
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    reward.description,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    softWrap: true,
                    overflow: TextOverflow.visible,
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: _getFontSize(reward.description.length),
                      height: 1.7,
                    ),
                  ),

                  // ── Translation section ──
                  if (isEnglish) ...[
                    const SizedBox(height: 12),
                    _buildTranslationSection(showingTranslation),
                  ],

                  // ── Tafsir toggle + content ──
                  if (hasTafsir) ...[
                    const SizedBox(height: 12),
                    _buildTafsirToggleRow(pageIndex, reward),
                    if (showingTafsir) ...[
                      const SizedBox(height: 8),
                      _buildTafsirSection(reward),
                    ],
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Source badge ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.menu_book_rounded,
                  size: 14,
                  color: _AppColors.accentGreen,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    reward.source,
                    style: TextStyle(
                      fontFamily: 'kufi',
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Translation section (existing, unchanged)
  // ─────────────────────────────────────────────────────────────────────

  Widget _buildTranslationSection(bool showingTranslation) {
    return BlocBuilder<TranslationCubit, TranslationState>(
      builder: (context, state) {
        if (!showingTranslation) return const SizedBox.shrink();
        if (state is TranslationLoading) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(
                  Theme.of(context).primaryColor,
                ),
              ),
            ),
          );
        }
        if (state is TranslationError) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red.withOpacity(0.4)),
            ),
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        if (state is TranslationLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Disclaimer: The translation is not 100% accurate',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[300],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.translate, color: Colors.blue[200], size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'English Translation',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[200],
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _copyToClipboard(state.translatedText),
                    icon: Icon(
                      Icons.copy,
                      size: 16,
                      color: Colors.white.withOpacity(0.6),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                state.translatedText,
                style: TextStyle(
                  fontSize: _getFontSize(state.translatedText.length),
                  height: 1.6,
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Tafsir toggle row — matches translation toggle style
  // ─────────────────────────────────────────────────────────────────────

  Widget _buildTafsirToggleRow(int pageIndex, TimelineReward reward) {
    final isShowing = _isShowingTafsir(pageIndex);

    return GestureDetector(
      onTap: () => _toggleTafsir(pageIndex),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isShowing
              ? Colors.blue.withOpacity(0.2)
              : Colors.blue.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isShowing
                ? Colors.blue.withOpacity(0.6)
                : Colors.blue.withOpacity(0.25),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lightbulb_outline_rounded,
              color: Colors.blue[isShowing ? 200 : 300],
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              AppServicesDBprovider.currentLocale() == 'ar'
                  ? 'تفسير'
                  : 'Tafsir / Explanation',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Colors.blue[isShowing ? 200 : 300],
              ),
            ),
            const SizedBox(width: 6),
            AnimatedRotation(
              turns: isShowing ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.blue[300],
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Tafsir content — mirrors the translation content card style
  // ─────────────────────────────────────────────────────────────────────

  Widget _buildTafsirSection(TimelineReward reward) {
    final isArabic = AppServicesDBprovider.currentLocale() == 'ar';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: Colors.blue[200],
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                isArabic ? 'تفسير' : 'Tafsir / Explanation',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[200],
                  fontFamily: 'kufi',
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _copyToClipboard(reward.tafsir!),
                icon: Icon(
                  Icons.copy,
                  size: 14,
                  color: Colors.white.withOpacity(0.55),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Tafsir text
          Text(
            reward.tafsir!,
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: _getFontSize(reward.tafsir!.length),
              height: 1.65,
              color: Colors.blue[100],
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Counter widget
  // ─────────────────────────────────────────────────────────────────────

  Widget _buildCounter(BuildContext context, int pageIndex, int count) {
    final theme = Theme.of(context);
    final sw = MediaQuery.of(context).size.width;

    final buttonSize = (sw * 0.13).clamp(44.0, 68.0);
    final iconSize = buttonSize * 0.5;
    final countFont = (sw * 0.07).clamp(24.0, 40.0);
    const radius = Radius.circular(14);

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Main card
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => _increment(pageIndex),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.04,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: const BorderRadius.all(radius),
                border: Border.all(
                  color: theme.primaryColor.withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'zikr_done_count'.tr(),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: (sw * 0.028).clamp(10.0, 13.0),
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Transform.scale(
                          scale: _pulseAnimation.value,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '$count',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: countFont,
                              height: 1,
                              color: theme.textTheme.headlineMedium?.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: count > 0
                        ? IconButton(
                            key: const ValueKey('reset'),
                            onPressed: () =>
                                setState(() => _resetCount(pageIndex)),
                            icon: const Icon(Icons.refresh_rounded),
                            tooltip: 'reset'.tr(),
                            iconSize: (sw * 0.055).clamp(18.0, 24.0),
                            padding: const EdgeInsets.all(6),
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          )
                        : SizedBox(
                            key: const ValueKey('empty'),
                            width: (sw * 0.055).clamp(18.0, 24.0) + 12,
                          ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _increment(pageIndex),
                    child: Container(
                      width: buttonSize,
                      height: buttonSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withOpacity(0.7),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withOpacity(0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: iconSize,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Hint overlay
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: AnimatedOpacity(
                opacity: _showCounterTapHint ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 350),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(radius),
                  child: Container(
                    color: Colors.black.withOpacity(0.75),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 500),
                          builder: (_, v, __) => Transform.scale(
                            scale: 0.7 + v * 0.3,
                            child: Opacity(
                              opacity: v,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.35),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.touch_app_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'tap_anywhere_to_increment'.tr(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'tap_the_card_to_add'.tr(),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.75),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Action bar
  // ─────────────────────────────────────────────────────────────────────

  Widget _buildActionBar({
    required BuildContext context,
    required int pageIndex,
    required TimelineReward reward,
    required bool isEnglish,
    required bool showingTranslation,
    required bool isChecked,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Checkbox(
          value: isChecked,
          onChanged: (v) async {
            context.read<HistoryCubit>().toggleCheck(reward.id);
            await RewardWidgetService.updateWidget();
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          side: const BorderSide(color: _AppColors.accentGreen, width: 2),
          checkColor: Colors.white,
          activeColor: _AppColors.accentGreen,
        ),
        _iconBtn(
          icon: Icons.copy_rounded,
          tooltip: 'Copy Hadith'.tr(),
          onPressed: () => _copyToClipboard(reward.description),
        ),
        _iconBtn(
          icon: Icons.share_rounded,
          tooltip: 'Share'.tr(),
          onPressed: () => _shareReward(reward),
        ),
        _iconBtn(
          icon: Icons.alarm_rounded,
          tooltip: 'Schedule Reminder'.tr(),
          onPressed: () => _scheduleNotification(reward),
        ),
        if (isEnglish)
          BlocBuilder<TranslationCubit, TranslationState>(
            builder: (context, state) {
              if (state is TranslationLoading) {
                return SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                );
              }
              return _iconBtn(
                icon: showingTranslation
                    ? Icons.g_translate_rounded
                    : Icons.translate_rounded,
                tooltip: showingTranslation
                    ? 'Hide Translation'
                    : 'Translate to English',
                onPressed: () =>
                    _toggleTranslation(pageIndex, reward.description),
              );
            },
          ),
        _iconBtn(
          icon: Icons.report_gmailerrorred_outlined,
          tooltip: 'report'.tr(),
          color: Colors.red[300]!,
          onPressed: () {
            _launchUrl(
              'https://wa.me/201121009270',
              message:
                  'يوجد مشكلة في هذا الذكر : ${reward.title} و المعرف الخاص به ${reward.id}',
            );
            _logEvent('zikr_complain');
          },
        ),
      ],
    );
  }

  Widget _iconBtn({
    required IconData icon,
    required VoidCallback onPressed,
    String? tooltip,
    Color? color = _AppColors.accentGreen,
  }) {
    return IconButton(
      icon: Icon(icon, color: color ?? Theme.of(context).primaryColor),
      onPressed: onPressed,
      tooltip: tooltip,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Period completion bar
  // ─────────────────────────────────────────────────────────────────────

  Widget _buildPeriodCompletionBar(AzanDayPeriod period, bool isCurrent) {
    final periodRewards = _allRewards.where((r) => r.period == period).toList();
    final total = periodRewards.length;
    if (total == 0) return const SizedBox.shrink();

    final done = periodRewards
        .where(
          (r) =>
              HistoryDBProvider.isCheckedToday((r.reward as TimelineReward).id),
        )
        .length;
    final progress = done / total;
    final isComplete = done == total;

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              builder: (_, value, __) =>
                  LinearProgressIndicator(value: value, minHeight: 6),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          isComplete
              ? '✅ $done/$total (${((done / total) * 100).round()}%)'
              : '$done/$total (${((done / total) * 100).round()}%)',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Level badge
  // ─────────────────────────────────────────────────────────────────────

  Widget _buildLevelBadge(ZikrLevel level) {
    final isEasy = level == ZikrLevel.easy;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: (isEasy ? Colors.blue : Colors.orange).withOpacity(0.5),
        ),
      ),
      child: Text(
        isEasy ? 'easy'.tr() : 'hard'.tr(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isEasy ? Colors.blue[200] : Colors.orange[200],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Utilities
  // ─────────────────────────────────────────────────────────────────────

  double _getFontSize(int len) {
    if (len > 300) return 16;
    if (len > 200) return 18;
    if (len > 150) return 22;
    if (len > 100) return 26;
    if (len > 60) return 32;
    if (len > 30) return 38;
    return 44;
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('Copied'.tr()),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _launchUrl(String url, {String? message}) async {
    if (message != null) url = '$url?text=${Uri.encodeComponent(message)}';
    _logEvent('url_launched', parameters: {'url': url});
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  Future<void> _shareReward(TimelineReward reward) async {
    final theme = Theme.of(context);
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_AppColors.accentGreen),
          ),
        ),
      );

      final captureWidget = Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: const BoxDecoration(color: _AppColors.primaryGreen),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    reward.title,
                    style: const TextStyle(
                      fontFamily: 'kufi',
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 60,
                    height: 2,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    reward.description,
                    style: TextStyle(
                      fontFamily: 'kufi',
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _AppColors.surfaceGreen.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.menu_book_rounded,
                          size: 14,
                          color: _AppColors.accentGreen,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          reward.source,
                          style: TextStyle(
                            fontFamily: 'kufi',
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'shared_with'.tr(),
                    style: theme.textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Image.asset('assets/playstore.png', height: 50, width: 50),
                ],
              ),
            ),
          ],
        ),
      );

      final image = await _screenshotController.captureFromLongWidget(
        InheritedTheme.captureAll(
          context,
          Material(
            child: MediaQuery(
              data: MediaQuery.of(context),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: captureWidget,
              ),
            ),
          ),
        ),
        delay: const Duration(milliseconds: 100),
        context: context,
        pixelRatio: 2.0,
        constraints: const BoxConstraints(maxWidth: 400),
      );

      if (image == null) {
        if (mounted) Navigator.pop(context);
        throw Exception('Failed to capture screenshot');
      }

      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/reward_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(path);
      await file.writeAsBytes(image);
      if (mounted) Navigator.pop(context);

      final shareText = AppServicesDBprovider.currentLocale() == 'ar'
          ? 'تم التقاطها بتطبيق إلا ليعبدون\n\nhttps://play.google.com/store/apps/details?id=com.amrabdelhameed.ella_lyaabdoon'
          : 'Captured with Ella Lyaabdoon app\n\nhttps://play.google.com/store/apps/details?id=com.amrabdelhameed.ella_lyaabdoon';

      await Share.shareXFiles([XFile(path)], text: shareText);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('جزاك الله خيراً'),
            backgroundColor: Colors.green,
          ),
        );
      }
      Future.delayed(const Duration(seconds: 2), () {
        try {
          if (file.existsSync()) file.deleteSync();
        } catch (_) {}
      });
    } catch (e) {
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _scheduleNotification(TimelineReward reward) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null || !mounted) return;

    try {
      final id = reward.id.hashCode.abs() % 2147483647;
      final isScheduled = await NotificationHelper.isNotificationScheduled(id);

      if (isScheduled && mounted) {
        final replace = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Already Scheduled'.tr()),
            content: Text(
              'A reminder for this reward already exists. Do you want to replace it?'
                  .tr(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('cancel'.tr()),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Replace'.tr()),
              ),
            ],
          ),
        );
        if (replace != true) return;
      }

      await NotificationHelper.scheduleDaily(
        notificationId: id,
        payload: {
          'reward_id': reward.id.toString(),
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        },
        title: reward.title,
        body: reward.description,
        time: time,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 3),
            content: Text(
              '${'Reminder scheduled for'.tr()} ${time.format(context)}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Schedule Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to schedule reminder'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable hint widget
// ─────────────────────────────────────────────────────────────────────────────

class _HintContent extends StatelessWidget {
  const _HintContent({
    required this.label,
    required this.sublabel,
    this.useThemedBox = false,
  });

  final String label;
  final String sublabel;
  final bool useThemedBox;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          builder: (context, value, _) => Transform.scale(
            scale: 0.8 + value * 0.2,
            child: Opacity(
              opacity: value,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(width: 2),
                ),
                child: const Icon(Icons.touch_app_rounded, size: 40),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (useThemedBox)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  sublabel,
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else ...[
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
            ),
          ),
          const SizedBox(height: 8),
          Text(sublabel, style: const TextStyle(fontSize: 13)),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────────────────────────────────────

class RewardItem {
  const RewardItem({
    required this.reward,
    required this.period,
    required this.periodTitle,
  });

  final dynamic reward;
  final AzanDayPeriod period;
  final String periodTitle;
}
