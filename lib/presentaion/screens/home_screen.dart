import 'package:easy_localization/easy_localization.dart';
import 'package:ella_lyaabdoon/app_router.dart';
import 'package:ella_lyaabdoon/buissness_logic/translation/translation_cubit.dart';
import 'package:ella_lyaabdoon/presentaion/widgets/timeline_header.dart';
import 'package:ella_lyaabdoon/presentaion/widgets/timeline_description_item.dart';
import 'package:ella_lyaabdoon/presentaion/widgets/timeline_show_more_button.dart';
import 'package:ella_lyaabdoon/presentaion/widgets/translation_dialog.dart';
import 'package:ella_lyaabdoon/utils/azan_helper.dart';
import 'package:ella_lyaabdoon/utils/constants/app_lists.dart';
import 'package:ella_lyaabdoon/utils/constants/app_routes.dart';
import 'package:ella_lyaabdoon/utils/location_storage.dart';
import 'package:ella_lyaabdoon/utils/location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sticky_headers/sticky_headers.dart';

class TimelineItem {
  final String title;
  final List<String> descriptions;
  final AzanDayPeriod period;

  const TimelineItem({
    required this.title,
    required this.descriptions,
    required this.period,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  AzanDayPeriod? _currentPeriod;
  bool _loading = true;
  late AzanHelper _azanHelper;
  String? _currentCity;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Track expanded periods
  final Set<AzanDayPeriod> _expandedPeriods = {};

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _init();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final hasLocation = await LocationStorage.hasLocation();

    if (!hasLocation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showLocationDialog();
      });
      return;
    }

    await _loadLocationData();
  }

  Future<void> _loadLocationData() async {
    final lat = await LocationStorage.getLat();
    final lng = await LocationStorage.getLng();

    if (lat == null || lng == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showLocationDialog();
      });
      return;
    }

    _azanHelper = AzanHelper(latitude: lat, longitude: lng);
    _currentCity = await LocationService.getCity(lat, lng);

    if (!mounted) return;

    setState(() {
      _currentPeriod = _azanHelper.getCurrentPeriod();
      _loading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentPeriod();
    });
  }

  void _scrollToCurrentPeriod() {
    if (_currentPeriod == null) return;

    final currentIndex = AppLists.timelineItems.indexWhere(
      (item) => item.period == _currentPeriod,
    );

    if (currentIndex == -1) return;

    double position = 0;
    for (int i = 0; i < currentIndex; i++) {
      position += 80;
      position += AppLists.timelineItems[i].descriptions.length * 80;
    }

    _scrollController.animateTo(
      position,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  void _toggleExpansion(AzanDayPeriod period) {
    setState(() {
      if (_expandedPeriods.contains(period)) {
        _expandedPeriods.remove(period);
      } else {
        _expandedPeriods.add(period);
      }
    });
  }

  List<String> _getVisibleDescriptions(
    TimelineItem item,
    AzanDayPeriod? currentPeriod,
  ) {
    // Current period OR expanded - show all
    if (item.period == currentPeriod ||
        _expandedPeriods.contains(item.period)) {
      return item.descriptions;
    }
    // Not current and not expanded - show first 3
    return item.descriptions.take(3).toList();
  }

  void _showLocationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.greenAccent),
            const SizedBox(width: 8),
            Text('location_required'.tr()),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('location_message'.tr()),
            const SizedBox(height: 16),
            if (_currentCity != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_city, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${'current_location'.tr()}: $_currentCity',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              AppRouter.router.pushNamed(AppRoutes.settings);
            },
            child: Text('cancel'.tr()),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.of(context).pop();
              await _updateLocation();
            },
            icon: const Icon(Icons.my_location),
            label: Text('update_location'.tr()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateLocation() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text('getting_location'.tr()),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final position = await LocationService.determinePosition();
      final city = await LocationService.getCity(
        position.latitude,
        position.longitude,
      );

      await LocationStorage.saveLocation(position.latitude, position.longitude);

      if (!mounted) return;

      Navigator.of(context).pop();

      setState(() {
        _loading = true;
      });

      await _loadLocationData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('${'location_updated'.tr()}: $city')),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('${'location_error'.tr()}: ${e.toString()}'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  String _getPrayerTimeText(AzanDayPeriod period) {
    DateTime? time;

    switch (period) {
      case AzanDayPeriod.fajr:
        time = _azanHelper.fajr;
        break;
      case AzanDayPeriod.shorouq:
        time = _azanHelper.sunrise;
        break;
      case AzanDayPeriod.duhr:
        time = _azanHelper.dhuhr;
        break;
      case AzanDayPeriod.asr:
        time = _azanHelper.asr;
        break;
      case AzanDayPeriod.maghrib:
        time = _azanHelper.maghrib;
        break;
      case AzanDayPeriod.isha:
        time = _azanHelper.isha;
        break;
      case AzanDayPeriod.night:
        return '10:00 PM';
    }

    if (time == null) return '--:--';

    int hour = time.hour;
    String periodStr = hour >= 12 ? 'PM' : 'AM';
    hour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return '${hour.toString()}:${time.minute.toString().padLeft(2, '0')} $periodStr';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return BlocProvider(
      create: (context) => TranslationCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('home_screen'.tr()),
          actions: [
            if (_currentCity != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 20),
                    const SizedBox(width: 4),
                    Text(_currentCity!, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _updateLocation,
              tooltip: 'update_location'.tr(),
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                AppRouter.router.push(AppRoutes.settings);
              },
              tooltip: 'settings'.tr(),
            ),
          ],
        ),
        body: ListView.builder(
          controller: _scrollController,
          itemCount: AppLists.timelineItems.length,
          itemBuilder: (context, index) {
            final item = AppLists.timelineItems[index];
            final isCurrent = item.period == _currentPeriod;
            final timeText = _getPrayerTimeText(item.period);
            final isLeftAligned = index % 2 == 0;
            final isFirst = index == 0;
            final isLast = index == AppLists.timelineItems.length - 1;

            final visibleDescriptions = _getVisibleDescriptions(
              item,
              _currentPeriod,
            );
            final isExpanded = _expandedPeriods.contains(item.period);
            final hasMore = item.descriptions.length > 3;
            final showMoreButton = !isCurrent && hasMore;

            return StickyHeader(
              header: TimelineHeader(
                title: item.title,
                time: timeText,
                isCurrent: isCurrent,
                isLeftAligned: isLeftAligned,
                isFirst: isFirst,
                pulseAnimation: _pulseAnimation,
              ),
              content: Column(
                children: [
                  for (int i = 0; i < visibleDescriptions.length; i++)
                    TimelineDescriptionItem(
                      description: visibleDescriptions[i],
                      isCurrent: isCurrent,
                      isLeftAligned: isLeftAligned,
                      isLast:
                          i == visibleDescriptions.length - 1 &&
                          !showMoreButton &&
                          isLast,
                      pulseAnimation: _pulseAnimation,
                      onTranslate: () {
                        showDialog(
                          context: context,
                          builder: (dialogContext) => BlocProvider.value(
                            value: context.read<TranslationCubit>(),
                            child: TranslationDialog(
                              arabicText: item.descriptions[i],
                            ),
                          ),
                        );
                      },
                    ),
                  if (showMoreButton)
                    TimelineShowMoreButton(
                      isExpanded: isExpanded,
                      remainingCount: item.descriptions.length - 3,
                      isLeftAligned: isLeftAligned,
                      isCurrent: isCurrent,
                      isLast: isLast,
                      pulseAnimation: _pulseAnimation,
                      onToggle: () => _toggleExpansion(item.period),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
