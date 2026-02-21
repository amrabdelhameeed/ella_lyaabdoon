import 'package:easy_localization/easy_localization.dart';
import 'package:ella_lyaabdoon/core/constants/app_routes.dart';
import 'package:ella_lyaabdoon/features/settings/logic/location_cubit.dart';
import 'package:ella_lyaabdoon/features/settings/logic/location_state.dart';
import 'package:ella_lyaabdoon/features/settings/logic/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';

class LocationPermissionScreen extends StatelessWidget {
  const LocationPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LocationCubit()),
        BlocProvider(create: (context) => SettingsCubit()),
      ],
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
        listener: (context, state) {},
        builder: (context, state) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;

          return SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),

                        /// Icon
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

                        const SizedBox(height: 28),

                        /// Headline
                        Text(
                          'location_required'.tr(),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 16),

                        /// Description
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            _getMessage(state.status, state.currentCity),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 32),

                        /// Prayer Settings
                        BlocBuilder<SettingsCubit, SettingsState>(
                          builder: (context, settingsState) {
                            final settingsCubit = context.read<SettingsCubit>();

                            return Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: colorScheme.outlineVariant.withOpacity(
                                    0.5,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.auto_awesome_rounded,
                                        size: 20,
                                        color: colorScheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'prayer_calculation_settings'.tr(),
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme.primary,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  _buildSettingsDropdown<String>(
                                    context: context,
                                    label: 'calculation_method'.tr(),
                                    value: settingsState.calculationMethod,
                                    items: [
                                      _buildDropdownItem(
                                        'egyptian',
                                        'calculation_egyptian',
                                      ),
                                      _buildDropdownItem(
                                        'karachi',
                                        'calculation_karachi',
                                      ),
                                      _buildDropdownItem(
                                        'isna',
                                        'calculation_isna',
                                      ),
                                      _buildDropdownItem(
                                        'muslim_world_league',
                                        'calculation_mwl',
                                      ),
                                      _buildDropdownItem(
                                        'umm_al_qura',
                                        'calculation_umm_al_qura',
                                      ),
                                      _buildDropdownItem(
                                        'dubai',
                                        'calculation_dubai',
                                      ),
                                      _buildDropdownItem(
                                        'kuwait',
                                        'calculation_kuwait',
                                      ),
                                      _buildDropdownItem(
                                        'qatar',
                                        'calculation_qatar',
                                      ),
                                      _buildDropdownItem(
                                        'singapore',
                                        'calculation_singapore',
                                      ),
                                      _buildDropdownItem(
                                        'morocco',
                                        'calculation_morocco',
                                      ),
                                      _buildDropdownItem(
                                        'moonsighting_committee',
                                        'calculation_moonsighting_committee',
                                      ),
                                      _buildDropdownItem(
                                        'turkiye',
                                        'calculation_turkiye',
                                      ),
                                      _buildDropdownItem(
                                        'tehran',
                                        'calculation_tehran',
                                      ),
                                      _buildDropdownItem(
                                        'north_america',
                                        'calculation_north_america',
                                      ),
                                    ],
                                    onChanged: (val) => val != null
                                        ? settingsCubit.setCalculationMethod(
                                            val,
                                          )
                                        : null,
                                  ),

                                  const SizedBox(height: 12),

                                  _buildSettingsDropdown<String>(
                                    context: context,
                                    label: 'madhab'.tr(),
                                    value: settingsState.madhab,
                                    items: [
                                      _buildDropdownItem(
                                        'shafi',
                                        'madhab_shafi',
                                      ),
                                      _buildDropdownItem(
                                        'hanafi',
                                        'madhab_hanafi',
                                      ),
                                    ],
                                    onChanged: (val) => val != null
                                        ? settingsCubit.setMadhab(val)
                                        : null,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 40),

                        /// Button / Loading
                        if (state.status == LocationStatus.loading)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 32),
                            child: CircularProgressIndicator(),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(bottom: 32),
                            child: SizedBox(
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
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _getMessage(LocationStatus status, [String? city]) {
    switch (status) {
      case LocationStatus.permissionDenied:
        return 'location_permission_denied'.tr();
      case LocationStatus.permissionPermanentlyDenied:
        return 'location_permission_permanently_denied'.tr();
      case LocationStatus.servicesDisabled:
        return 'enable_gps'.tr();
      case LocationStatus.loaded:
        return city != null && city.isNotEmpty ? city : 'location_updated'.tr();
      default:
        return 'location_message'.tr();
    }
  }

  String _getButtonLabel(LocationStatus status) {
    if (status == LocationStatus.loaded) {
      return 'start_now'.tr();
    }
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
    if (status == LocationStatus.loaded) {
      context.goNamed(AppRoutes.home);
    } else if (status == LocationStatus.permissionPermanentlyDenied) {
      Geolocator.openAppSettings();
    } else if (status == LocationStatus.servicesDisabled) {
      Geolocator.openLocationSettings();
    } else {
      context.read<LocationCubit>().requestPermission();
    }
  }

  Widget _buildSettingsDropdown<T>({
    required BuildContext context,
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: colorScheme.primary,
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
              dropdownColor: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  DropdownMenuItem<String> _buildDropdownItem(String value, String labelKey) {
    return DropdownMenuItem(
      value: value,
      child: Text(labelKey.tr(), maxLines: 2, overflow: TextOverflow.ellipsis),
    );
  }
}
