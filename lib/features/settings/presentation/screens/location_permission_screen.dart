import 'package:easy_localization/easy_localization.dart';
import 'package:ella_lyaabdoon/core/constants/app_routes.dart';
import 'package:ella_lyaabdoon/features/settings/logic/location_cubit.dart';
import 'package:ella_lyaabdoon/features/settings/logic/location_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';

class LocationPermissionScreen extends StatelessWidget {
  const LocationPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LocationCubit(),
      child: const LocationPermissionView(),
    );
  }
}

class LocationPermissionView extends StatelessWidget {
  const LocationPermissionView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: BlocConsumer<LocationCubit, LocationState>(
        listener: (context, state) {
          if (state.status == LocationStatus.loaded) {
            context.goNamed(AppRoutes.home);
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Modern M3 Icon Container
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.location_on_rounded,
                      size: 64,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Headline
                  Text(
                    'location_required'.tr(),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      _getMessage(state.status),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Action Area
                  if (state.status == LocationStatus.loading)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 32.0),
                      child: CircularProgressIndicator(),
                    )
                  else
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: FilledButton.icon(
                            onPressed: () =>
                                _handleAction(context, state.status),
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: Icon(_getIcon(state.status)),
                            label: Text(
                              _getButtonLabel(state.status),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getMessage(LocationStatus status) {
    switch (status) {
      case LocationStatus.permissionDenied:
        return 'location_permission_denied'.tr();
      case LocationStatus.permissionPermanentlyDenied:
        return 'location_permission_permanently_denied'.tr();
      case LocationStatus.servicesDisabled:
        return 'enable_gps'.tr();
      default:
        return 'location_message'.tr();
    }
  }

  String _getButtonLabel(LocationStatus status) {
    if (status == LocationStatus.permissionPermanentlyDenied ||
        status == LocationStatus.servicesDisabled) {
      return 'go_to_settings'.tr();
    }
    return 'grant_permission'.tr();
  }

  IconData _getIcon(LocationStatus status) {
    if (status == LocationStatus.permissionPermanentlyDenied ||
        status == LocationStatus.servicesDisabled) {
      return Icons.settings_rounded;
    }
    return Icons.near_me_rounded;
  }

  void _handleAction(BuildContext context, LocationStatus status) {
    if (status == LocationStatus.permissionPermanentlyDenied) {
      Geolocator.openAppSettings();
    } else if (status == LocationStatus.servicesDisabled) {
      Geolocator.openLocationSettings();
    } else {
      context.read<LocationCubit>().requestPermission();
    }
  }
}
