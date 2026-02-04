import 'dart:io';
import 'dart:ui';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:easy_localization/easy_localization.dart' as ez;
import 'package:ella_lyaabdoon/core/constants/app_lists.dart';
import 'package:ella_lyaabdoon/core/models/azan_day_period.dart';
import 'package:ella_lyaabdoon/core/models/timeline_reward.dart';
import 'package:ella_lyaabdoon/core/services/app_services_database_provider.dart';
import 'package:ella_lyaabdoon/core/services/zikr_widget_service.dart';
import 'package:ella_lyaabdoon/features/history/data/history_db_provider.dart';
import 'package:ella_lyaabdoon/features/history/logic/history_cubit.dart';
import 'package:ella_lyaabdoon/features/home/logic/home_cubit.dart';
import 'package:ella_lyaabdoon/features/home/logic/home_state.dart';
import 'package:ella_lyaabdoon/features/home/logic/translation_cubit.dart';
import 'package:ella_lyaabdoon/features/home/presentation/widgets/reward_dialog.dart';
import 'package:ella_lyaabdoon/utils/notification_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class ReelsViewScreen extends StatelessWidget {
  const ReelsViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => HomeCubit()..initialize()),
        BlocProvider(create: (context) => HistoryCubit()),
        BlocProvider(create: (context) => TranslationCubit()),
      ],
      child: const _ReelsViewContent(),
    );
  }
}

class _ReelsViewContent extends StatefulWidget {
  const _ReelsViewContent();

  @override
  State<_ReelsViewContent> createState() => _ReelsViewContentState();
}

class _ReelsViewContentState extends State<_ReelsViewContent> {
  late PageController _pageController;

  int _currentIndex = 0;
  List<RewardItem> _allRewards = [];
  final ScreenshotController _screenshotController = ScreenshotController();

  // Widget theme colors - matching the Android widget exactly
  static const Color primaryGreen = Color(0xFF2D5F3F);
  static const Color accentGreen = Color(0xFF4A9B6A);
  static const Color surfaceGreen = Color(0xFF1C4430);
  // static const Color goldAccent = Color(0xFFFFD700);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  void _buildRewardsList() {
    _allRewards.clear();
    final currentPeriod = context.read<HomeCubit>().state.currentPeriod;

    // Build rewards list in timeline order (not reordered)
    for (var item in AppLists.timelineItems) {
      for (var reward in item.rewards) {
        _allRewards.add(
          RewardItem(
            reward: reward,
            period: item.period,
            periodTitle: item.title,
          ),
        );
      }
    }

    // Find the index of the first reward in current period
    if (currentPeriod != null && _allRewards.isNotEmpty) {
      final currentPeriodIndex = _allRewards.indexWhere(
        (item) => item.period == currentPeriod,
      );

      if (currentPeriodIndex != -1) {
        _currentIndex = currentPeriodIndex;
        // Update PageController to start at current period
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController.hasClients) {
            _pageController.jumpToPage(_currentIndex);
          }
        });
      }
    }

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = AppServicesDBprovider.currentLocale() == "ar";

    return Scaffold(
      backgroundColor: primaryGreen,
      appBar: AppBar(
        backgroundColor: surfaceGreen,
        elevation: 0,
        // leading: IconButton(
        //   icon: const Icon(Icons.close, color: Colors.white),
        //   onPressed: () => Navigator.pop(context),
        // ),
        title: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (_currentIndex < _allRewards.length) {
              final currentReward = _allRewards[_currentIndex];
              return Row(
                children: [
                  Text(
                    currentReward.periodTitle.tr(),
                    style: const TextStyle(
                      color: accentGreen,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  Text(
                    '⏰ ${ez.DateFormat.jm(context.locale.toString()).format(state.prayerTimes![currentReward.period!]!)}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 15,
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<HomeCubit, HomeState>(
        listenWhen: (prev, curr) =>
            prev.currentPeriod != curr.currentPeriod ||
            prev.status != curr.status,

        listener: (context, state) {
          if (state.status != HomeStatus.loaded) return;

          _buildRewardsList(); // now currentPeriod is guaranteed

          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (_pageController.hasClients) {
              _pageController.jumpToPage(
                _currentIndex,
                // duration: const Duration(milliseconds: 1000),
                // curve: Curves.easeInCubic,
              );
            }
          });
        },

        builder: (context, state) {
          if (state.status == HomeStatus.loading || _allRewards.isEmpty) {
            return _buildLoadingState();
          }

          if (state.status == HomeStatus.error) {
            return _buildErrorState(state.errorMessage);
          }

          return Stack(
            children: [
              // Main PageView
              PageView.builder(
                restorationId: 'reels_view',
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: _allRewards.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                  // Reset translation when page changes
                  context.read<TranslationCubit>().reset();
                },
                itemBuilder: (context, index) {
                  final rewardItem = _allRewards[index];
                  final isCurrent = rewardItem.period == state.currentPeriod;

                  return _buildRewardPage(
                    rewardItem: rewardItem,
                    isCurrent: isCurrent,
                    state: state,
                    isArabic: isArabic,
                  );
                },
              ),

              // Progress indicator (right side)
              Positioned(
                right: 3,
                top: 20,
                bottom: 80,
                child: _buildProgressIndicator(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(accentGreen),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading...'.tr(),
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String? errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage ?? 'Unknown error',
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      width: 4,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemHeight = constraints.maxHeight / _allRewards.length;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                top: _currentIndex * itemHeight,
                child: Container(
                  width: 4,
                  height: itemHeight,
                  decoration: BoxDecoration(
                    color: accentGreen,
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

  Widget _buildRewardPage({
    required RewardItem rewardItem,
    required bool isCurrent,
    required HomeState state,
    required bool isArabic,
  }) {
    final reward = rewardItem.reward as TimelineReward;
    final prayerTime = state.prayerTimes?[rewardItem.period];
    final timeText = prayerTime != null
        ? ez.DateFormat.jm(context.locale.toString()).format(prayerTime)
        : '';
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    return BlocBuilder<HistoryCubit, HistoryState>(
      builder: (context, historyState) {
        final isChecked = HistoryDBProvider.isCheckedToday(reward.id);

        return Container(
          color: primaryGreen,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top gold line (like widget)
                  Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: accentGreen,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Header with period (like widget header)
                  // Container(
                  //   padding: const EdgeInsets.symmetric(
                  //     horizontal: 16,
                  //     vertical: 12,
                  //   ),
                  //   decoration: BoxDecoration(
                  //     color: surfaceGreen,
                  //     borderRadius: BorderRadius.circular(12),
                  //   ),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: [
                  //       const Text('🕌', style: TextStyle(fontSize: 20)),
                  //       const SizedBox(width: 10),
                  //       Text(
                  //         rewardItem.periodTitle.tr(),
                  //         style: const TextStyle(
                  //           color: accentGreen,
                  //           fontSize: 18,
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //       ),
                  //       if (timeText.isNotEmpty) ...[
                  //         const SizedBox(width: 12),
                  //         Text(
                  //           '⏰ $timeText',
                  //           style: TextStyle(
                  //             color: Colors.white.withOpacity(0.8),
                  //             fontSize: 15,
                  //           ),
                  //         ),
                  //       ],
                  //     ],
                  //   ),
                  // ),
                  const SizedBox(height: 16),

                  // Main card (like widget content area)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isChecked
                              ? Colors.green.withOpacity(0.5)
                              : Colors.white.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Title
                          // 1. Detect if the current language is RTL (like Arabic)
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // 1. The Title - Stays centered
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                style: TextStyle(
                                  fontFamily: 'kufi',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  height: 1.4,
                                  // color: isChecked
                                  //     ? Colors.greenAccent
                                  //     : Colors.white,
                                  // decoration: isChecked
                                  //     ? TextDecoration.lineThrough
                                  //     : TextDecoration.none,
                                  decorationColor: Colors.green,
                                ),
                                child: Text(
                                  reward.title,
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              // 2. The Checkmark Layer
                              // We use IgnorePointer so this layer doesn't block taps to the title
                              IgnorePointer(
                                child: Row(
                                  mainAxisSize: MainAxisSize
                                      .min, // Vital: Keeps the row only as wide as its content
                                  children: [
                                    // Invisible spacer: Same text as title to push the checkmark to the edge
                                    Opacity(
                                      opacity: 0,
                                      child: Text(
                                        reward.title,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                    // The actual checkmark
                                    AnimatedOpacity(
                                      opacity: isChecked ? 1.0 : 0.0,
                                      duration: const Duration(
                                        milliseconds: 400,
                                      ),
                                      child: AnimatedSlide(
                                        // Slide in from the side based on language
                                        offset: isChecked
                                            ? Offset(isRtl ? -0.5 : 0.7, 0)
                                            : Offset(isRtl ? -0.1 : 0.3, 0),
                                        duration: const Duration(
                                          milliseconds: 400,
                                        ),
                                        curve: Curves.easeOutBack,
                                        child: Text(
                                          isRtl ? " ✅" : " ✅",
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Divider line (like widget)
                          Container(
                            width: 60,
                            height: 2,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Description
                          Expanded(
                            child: SingleChildScrollView(
                              child:
                                  BlocBuilder<
                                    TranslationCubit,
                                    TranslationState
                                  >(
                                    builder: (context, state) {
                                      String textToShow = reward.description;
                                      if (state is TranslationLoaded) {
                                        textToShow = state.translatedText;
                                      }

                                      return AnimatedTextKit(
                                        key: ValueKey(textToShow),
                                        isRepeatingAnimation: false,
                                        animatedTexts: [
                                          TypewriterAnimatedText(
                                            textAlign: TextAlign.center,
                                            textToShow,
                                            textStyle: TextStyle(
                                              fontFamily:
                                                  state is TranslationLoaded
                                                  ? null
                                                  : 'kufi',
                                              color: Colors.white.withOpacity(
                                                0.95,
                                              ),
                                              fontSize: _getFontSize(
                                                textToShow.length,
                                              ),
                                              height: 1.6,
                                            ),
                                            speed: const Duration(
                                              milliseconds: 45,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Source badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: surfaceGreen.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.menu_book_rounded,
                                  size: 14,
                                  color: accentGreen,
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
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Action buttons row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 1. Check Toggle
                      Checkbox(
                        value: isChecked,
                        // Maintains your Cubit logic
                        onChanged: (bool? value) async {
                          context.read<HistoryCubit>().toggleCheck(reward.id);
                          await RewardWidgetService.updateWidget();
                        },
                        // Ensures the shape is slightly rounded like your original BoxDecoration
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),

                      // 2. Copy
                      IconButton(
                        icon: const Icon(
                          Icons.copy_rounded,
                          color: accentGreen,
                        ),
                        onPressed: () => _copyToClipboard(reward.description),
                      ),

                      // 3. Share
                      IconButton(
                        icon: const Icon(
                          Icons.share_rounded,
                          color: accentGreen,
                        ),
                        onPressed: () => _shareReward(reward),
                      ),

                      // 4. Schedule
                      IconButton(
                        icon: const Icon(
                          Icons.alarm_rounded,
                          color: accentGreen,
                        ),
                        onPressed: () => _scheduleNotification(reward),
                      ),

                      // 5. Translate
                      BlocBuilder<TranslationCubit, TranslationState>(
                        builder: (context, state) {
                          if (state is TranslationLoading) {
                            return const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  accentGreen,
                                ),
                              ),
                            );
                          }
                          return IconButton(
                            icon: const Icon(
                              Icons.translate_rounded,
                              color: accentGreen,
                            ),
                            onPressed: () => _translate(reward.description),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Swipe hint
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.keyboard_arrow_up_rounded,
                          color: Colors.white.withOpacity(0.4),
                          size: 24,
                        ),
                        Text(
                          'swipe_for_more'.tr(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
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
        );
      },
    );
  }

  void _translate(String text) {
    context.read<TranslationCubit>().translate(text);
  }

  double _getFontSize(int textLength) {
    if (textLength > 200) return 15;
    if (textLength > 150) return 16;
    if (textLength > 100) return 17;
    if (textLength > 60) return 18;
    return 20;
  }

  Widget _buildActionButton({
    required String icon,
    required String label,
    required Color color,
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(19),
        border: borderColor != null ? Border.all(color: borderColor) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(19),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(icon, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

  Future<void> _shareReward(TimelineReward reward) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(accentGreen),
          ),
        ),
      );

      // Build widget for screenshot
      final captureWidget = Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: const BoxDecoration(color: primaryGreen),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header

            // Content
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

                      color: Colors.white.withOpacity(0.95),
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
                      color: surfaceGreen.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.menu_book_rounded,
                          size: 14,
                          color: accentGreen,
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

            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.3),
                  ),
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
                      // textAlign: TextAlign.center,
                    ),
                    const SizedBox(width: 4),
                    Image.asset('assets/playstore.png', height: 50, width: 50),
                    // const SizedBox(height: 4),
                    // Text(
                    //   'تطبيق فضائل الصلوات',
                    //   style: theme.textTheme.bodySmall!.copyWith(
                    //     color: Colors.green[600],
                    //   ),
                    // ),
                  ],
                ),
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

      final directory = await getTemporaryDirectory();
      final imagePath =
          '${directory.path}/reward_${DateTime.now().millisecondsSinceEpoch}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(image);

      if (mounted) Navigator.pop(context);

      final translations = {
        "ar":
            "تم التقاطها بتطبيق إلا ليعبدون\n\nhttps://play.google.com/store/apps/details?id=com.amrabdelhameed.ella_lyaabdoon",
        "en":
            "Captured with Ella Lyaabdoon app\n\nhttps://play.google.com/store/apps/details?id=com.amrabdelhameed.ella_lyaabdoon",
      };
      final shareText = translations[AppServicesDBprovider.currentLocale()]!;

      await Share.shareXFiles([XFile(imagePath)], text: shareText);

      // Cleanup
      Future.delayed(const Duration(seconds: 2), () {
        try {
          if (imageFile.existsSync()) {
            imageFile.deleteSync();
          }
        } catch (e) {
          debugPrint('Error deleting temp file: $e');
        }
      });
    } catch (e) {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

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

    if (time != null && mounted) {
      try {
        final notificationId = reward.id.hashCode.abs() % 2147483647;

        final isScheduled = await NotificationHelper.isNotificationScheduled(
          notificationId,
        );

        if (isScheduled && mounted) {
          final shouldReplace = await showDialog<bool>(
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

          if (shouldReplace != true) return;
        }

        await NotificationHelper.scheduleDaily(
          notificationId: notificationId,
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
              duration: const Duration(seconds: 5),
              content: Text(
                '${'Reminder scheduled for'.tr()} ${time.format(context)}',
              ),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'Undo'.tr(),
                textColor: Colors.white,
                onPressed: () async {
                  await NotificationHelper.cancel(notificationId);
                },
              ),
            ),
          );
        }
      } catch (e) {
        debugPrint("Schedule Error: $e");

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

  void _showRewardDetails(TimelineReward reward) {
    showDialog(
      context: context,
      builder: (context) => RewardDetailDialog(reward: reward),
    );
  }
}

class RewardItem {
  final dynamic reward;
  final AzanDayPeriod period;
  final String periodTitle;

  RewardItem({
    required this.reward,
    required this.period,
    required this.periodTitle,
  });
}
