import 'package:equatable/equatable.dart';

enum LocationStatus {
  initial,
  loading,
  loaded,
  error,
  permissionDenied,
  permissionPermanentlyDenied,
  servicesDisabled,
}

class LocationState extends Equatable {
  final LocationStatus status;
  final String? currentCity;
  final double? latitude;
  final double? longitude;
  final String? errorMessage;

  const LocationState({
    this.status = LocationStatus.initial,
    this.currentCity,
    this.latitude,
    this.longitude,
    this.errorMessage,
  });

  LocationState copyWith({
    LocationStatus? status,
    String? currentCity,
    double? latitude,
    double? longitude,
    String? errorMessage,
  }) {
    return LocationState(
      status: status ?? this.status,
      currentCity: currentCity ?? this.currentCity,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    currentCity,
    latitude,
    longitude,
    errorMessage,
  ];
}
