import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ella_lyaabdoon/core/models/azan_day_period.dart';
import 'package:ella_lyaabdoon/core/services/location_service.dart';
import 'package:ella_lyaabdoon/core/services/location_storage.dart';
import 'package:ella_lyaabdoon/core/utils/azan_helper.dart';
import 'package:ella_lyaabdoon/features/home/logic/home_state.dart';
import 'package:geolocator/geolocator.dart';

class HomeCubit extends Cubit<HomeState> {
  AzanHelper? _azanHelper;
  StreamSubscription<ServiceStatus>? _serviceStatusStreamSubscription;

  HomeCubit() : super(const HomeState()) {
    init();
  }

  @override
  Future<void> close() {
    _serviceStatusStreamSubscription?.cancel();
    return super.close();
  }

  Future<void> init() async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      // Load saved city
      final savedCity = await LocationStorage.getLat().then((lat) async {
        if (lat == null) return null;
        final lng = await LocationStorage.getLng();
        if (lng == null) return null;
        return await LocationService.getCity(lat, lng);
      });

      final lat = await LocationStorage.getLat();
      final lng = await LocationStorage.getLng();

      if (lat != null && lng != null) {
        _azanHelper = AzanHelper(latitude: lat, longitude: lng);
        _updateTime();
      }

      // If no location saved, force update
      if (lat == null) {
        await updateLocation();
      } else {
        emit(
          state.copyWith(
            status: HomeStatus.loaded,
            currentCity: savedCity ?? state.currentCity,
          ),
        );
      }

      _serviceStatusStreamSubscription = Geolocator.getServiceStatusStream()
          .listen((status) {
            if (status == ServiceStatus.enabled) {
              updateLocation();
            }
          });
    } catch (e) {
      emit(
        state.copyWith(status: HomeStatus.error, errorMessage: e.toString()),
      );
    }
  }

  void _updateTime() {
    if (_azanHelper == null) return;

    final now = DateTime.now();
    // Default values from helper
    AzanDayPeriod currentPeriod = _azanHelper!.getCurrentPeriod();
    DateTime nextPrayerTime = _azanHelper!.getNextPrayerTime(now);

    // Night time logic (10:00 PM)
    final nightTime = DateTime(now.year, now.month, now.day, 22, 0);

    // Override currentPeriod/nextPrayerTime for Night logic
    if (now.isAfter(nightTime)) {
      // If it's after 10 PM, it's Night period
      currentPeriod = AzanDayPeriod.night;
      // nextPrayerTime remains whatever helper calculated (likely Fajr next day)
    } else if (currentPeriod == AzanDayPeriod.isha && now.isBefore(nightTime)) {
      // If it's Isha but before 10 PM, next prayer is Night
      nextPrayerTime = nightTime;
    }
    // Note: If it's early morning (before Fajr), helper returns 'night', which is correct.

    final prayerTimes = {
      AzanDayPeriod.fajr: _azanHelper!.fajr,
      AzanDayPeriod.shorouq: _azanHelper!.sunrise,
      AzanDayPeriod.duhr: _azanHelper!.dhuhr,
      AzanDayPeriod.asr: _azanHelper!.asr,
      AzanDayPeriod.maghrib: _azanHelper!.maghrib,
      AzanDayPeriod.isha: _azanHelper!.isha,
      AzanDayPeriod.night: nightTime,
    };

    emit(
      state.copyWith(
        nextPrayerTime: nextPrayerTime,
        currentPeriod: currentPeriod,
        prayerTimes: prayerTimes,
        status: HomeStatus.loaded,
      ),
    );
  }

  Future<void> updateLocation() async {
    try {
      final position = await LocationService.determinePosition();

      _azanHelper = AzanHelper(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      final city = await LocationService.getCity(
        position.latitude,
        position.longitude,
      );

      await LocationStorage.saveLocation(position.latitude, position.longitude);

      emit(state.copyWith(currentCity: city ?? "Unknown"));
      _updateTime();
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  void toggleExpansion(AzanDayPeriod period) {
    final newExpanded = Set<AzanDayPeriod>.from(state.expandedPeriods);
    if (newExpanded.contains(period)) {
      newExpanded.remove(period);
    } else {
      newExpanded.add(period);
    }
    emit(state.copyWith(expandedPeriods: newExpanded));
  }
}
