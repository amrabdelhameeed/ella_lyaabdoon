import 'package:ella_lyaabdoon/core/models/azan_day_period.dart';
import 'package:equatable/equatable.dart';

enum HomeStatus { initial, loading, loaded, error }

class HomeState extends Equatable {
  final HomeStatus status;
  final String? currentCity;
  final AzanDayPeriod? currentPeriod;
  final DateTime? nextPrayerTime;
  final Duration? timeUntilNextPrayer;
  final Map<AzanDayPeriod, DateTime>? prayerTimes;
  final Set<AzanDayPeriod> expandedPeriods;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.currentCity,
    this.currentPeriod,
    this.nextPrayerTime,
    this.timeUntilNextPrayer,
    this.prayerTimes,
    this.expandedPeriods = const {},
    this.errorMessage,
  });

  HomeState copyWith({
    HomeStatus? status,
    String? currentCity,
    AzanDayPeriod? currentPeriod,
    DateTime? nextPrayerTime,
    Duration? timeUntilNextPrayer,
    Map<AzanDayPeriod, DateTime>? prayerTimes,
    Set<AzanDayPeriod>? expandedPeriods,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      currentCity: currentCity ?? this.currentCity,
      currentPeriod: currentPeriod ?? this.currentPeriod,
      nextPrayerTime: nextPrayerTime ?? this.nextPrayerTime,
      timeUntilNextPrayer: timeUntilNextPrayer ?? this.timeUntilNextPrayer,
      prayerTimes: prayerTimes ?? this.prayerTimes,
      expandedPeriods: expandedPeriods ?? this.expandedPeriods,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    currentCity,
    currentPeriod,
    nextPrayerTime,
    timeUntilNextPrayer,
    prayerTimes,
    expandedPeriods,
    errorMessage,
  ];
}
