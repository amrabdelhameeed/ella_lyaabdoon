import 'package:bloc/bloc.dart';
import 'package:ella_lyaabdoon/core/services/location_service.dart';
import 'package:ella_lyaabdoon/core/services/location_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'location_state.dart';
import 'dart:async';

class LocationCubit extends Cubit<LocationState> {
  StreamSubscription<ServiceStatus>? _serviceStatusSubscription;

  LocationCubit() : super(const LocationState()) {
    init();
    _subscribeToServiceStatus();
  }

  @override
  Future<void> close() {
    _serviceStatusSubscription?.cancel();
    return super.close();
  }

  void _subscribeToServiceStatus() {
    _serviceStatusSubscription = Geolocator.getServiceStatusStream().listen((
      status,
    ) {
      if (status == ServiceStatus.enabled) {
        updateLocation(fromUserAction: false);
      } else {
        emit(state.copyWith(status: LocationStatus.servicesDisabled));
      }
    });
  }

  Future<void> init() async {
    emit(state.copyWith(status: LocationStatus.loading));

    try {
      final hasSavedLocation = await LocationStorage.hasLocation();

      if (hasSavedLocation) {
        final lat = await LocationStorage.getLat();
        final lng = await LocationStorage.getLng();

        if (lat != null && lng != null) {
          final city =
              await LocationService.getCity(lat, lng) ??
              await LocationService.getCityFromMapsCo(lat, lng);

          emit(
            state.copyWith(
              status: LocationStatus.loaded,
              latitude: lat,
              longitude: lng,
              currentCity: city ?? 'Unknown',
            ),
          );

          return; // don’t force refresh on init
        }
      }

      // If no saved location, check permissions first
      await updateLocation(fromUserAction: false);
    } catch (e) {
      emit(
        state.copyWith(
          status: LocationStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> updateLocation({required bool fromUserAction}) async {
    emit(state.copyWith(status: LocationStatus.loading));

    try {
      final position = await LocationService.determinePosition();

      String? city;

      try {
        city = await LocationService.getCity(
          position.latitude,
          position.longitude,
          forceRefresh: fromUserAction, // important
        );
      } catch (_) {
        city = null;
      }

      // Always fallback if null/Unknown
      if (city == null || city == 'Unknown') {
        city = await LocationService.getCityFromMapsCo(
          position.latitude,
          position.longitude,
        );
      }

      // Save location + city
      if (position.latitude != state.latitude ||
          position.longitude != state.longitude ||
          city != state.currentCity) {
        await LocationStorage.saveLocation(
          position.latitude,
          position.longitude,
        );
        if (city != null && city.isNotEmpty) {
          await LocationStorage.saveCity(city);
        }
      }

      emit(
        state.copyWith(
          status: LocationStatus.loaded,
          latitude: position.latitude,
          longitude: position.longitude,
          currentCity: city ?? 'Unknown',
        ),
      );
    } catch (e) {
      final errorMsg = e.toString();
      LocationStatus status = LocationStatus.error;

      if (errorMsg.contains('Location services are disabled')) {
        status = LocationStatus.servicesDisabled;
      } else if (errorMsg.contains('Location permissions are denied')) {
        status = LocationStatus.permissionDenied;
      } else if (errorMsg.contains(
        'Location permissions are permanently denied',
      )) {
        status = LocationStatus.permissionPermanentlyDenied;
      }

      emit(state.copyWith(status: status, errorMessage: errorMsg));
    }
  }

  Future<void> requestPermission() async {
    await updateLocation(fromUserAction: true);
  }
}
