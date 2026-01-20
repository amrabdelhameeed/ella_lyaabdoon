import 'package:bloc/bloc.dart';
import 'package:ella_lyaabdoon/core/services/location_service.dart';
import 'package:ella_lyaabdoon/core/services/location_storage.dart';
import 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  LocationCubit() : super(const LocationState()) {
    init();
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

      // fetch fresh location if nothing saved
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
      emit(
        state.copyWith(
          status: LocationStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
