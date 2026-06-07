import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:ella_lyaabdoon/core/constants/app_lists.dart';
import 'package:ella_lyaabdoon/core/models/azan_day_period.dart';
import 'package:ella_lyaabdoon/core/services/app_services_database_provider.dart';
import 'package:ella_lyaabdoon/core/services/cache_helper.dart';
import 'package:ella_lyaabdoon/core/services/motivational_notification_service.dart';
import 'package:ella_lyaabdoon/core/services/streak_service.dart';
import 'package:ella_lyaabdoon/core/utils/azan_helper.dart';
import 'package:ella_lyaabdoon/utils/notification_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ella_lyaabdoon/core/services/location_storage.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  List<PendingNotificationRequest> _scheduledNotifications = [];
  bool _isLoadingNotifications = true;
  AzanHelper? _azanHelper;

  static const int _fastingNotifIdSunday = 9001;
  static const int _fastingNotifIdWednesday = 9002;
  static const String _mondayFastingNotifKey = 'monday_fasting_notif_enabled';
  static const String _thursdayFastingNotifKey =
      'thursday_fasting_notif_enabled';

  bool _isMondayFastingNotifEnabled() =>
      CacheHelper.getBool(_mondayFastingNotifKey);
  bool _isThursdayFastingNotifEnabled() =>
      CacheHelper.getBool(_thursdayFastingNotifKey);

  @override
  void initState() {
    super.initState();
    _initAzanHelper().then((_) => setState(() {}));
    _loadScheduledNotifications();
  }

  Future<void> _initAzanHelper() async {
    try {
      final lat = await LocationStorage.getLat();
      final lng = await LocationStorage.getLng();
      if (lat != null && lng != null) {
        _azanHelper = AzanHelper(latitude: lat, longitude: lng);
      }
    } catch (_) {
      // Location not saved yet — _azanHelper stays null
    }
  }

  Future<void> _loadScheduledNotifications() async {
    if (!mounted) return;
    setState(() => _isLoadingNotifications = true);

    try {
      final notifications = await NotificationHelper.getPendingNotifications();
      if (!mounted) return;

      // ✅ Filter out streak notifications AND all period notifications.
      // Period notifs are managed by their own switches — no delete button needed.
      final periodIds = AzanDayPeriod.values
          .map((p) => _periodNotifId(p))
          .toSet();

      final fastingIds = {
        _fastingNotifIdSunday,
        _fastingNotifIdWednesday,
        9003,
      };

      final filtered = notifications.where((n) {
        if (n.id == StreakService.notificationId) return false;
        if (periodIds.contains(n.id)) return false;
        if (fastingIds.contains(n.id)) return false;
        return true;
      }).toList();

      setState(() {
        _scheduledNotifications = filtered;
        _isLoadingNotifications = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingNotifications = false);
    }
  }

  String _periodNotifKey(AzanDayPeriod period) =>
      'period_notif_enabled_${period.name}';

  bool _isPeriodNotifEnabled(AzanDayPeriod period) =>
      CacheHelper.getBool(_periodNotifKey(period));

  int _periodNotifId(AzanDayPeriod period) =>
      8000 + AzanDayPeriod.values.indexOf(period);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('notification_settings'.tr()),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildSectionHeader(context, 'period_notifications'.tr()),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Text(
                    'period_notifications_desc'.tr(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
                ...AppLists.timelineItems.map((item) {
                  return StatefulBuilder(
                    builder: (context, setTileState) {
                      final enabled = _isPeriodNotifEnabled(item.period);

                      final prayerTime = _getPeriodTime(item.period);
                      String? formattedTime;
                      if (prayerTime != null) {
                        formattedTime = DateFormat(
                          'hh:mm a',
                          AppServicesDBprovider.currentLocale(),
                        ).format(prayerTime);
                      }

                      return SwitchListTile(
                        secondary: Icon(
                          _getPeriodIcon(item.period),
                          color: colorScheme.primary,
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item.title.tr()),
                            if (formattedTime != null)
                              Text(
                                formattedTime,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.primary.withOpacity(0.6),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                        value: enabled,
                        onChanged: (value) async {
                          CacheHelper.setBool(
                            _periodNotifKey(item.period),
                            value,
                          );
                          if (value) {
                            final prayerTime = _getPeriodTime(item.period);
                            if (prayerTime == null) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'location_required_for_notifications'
                                          .tr(),
                                    ),
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              }
                              CacheHelper.setBool(
                                _periodNotifKey(item.period),
                                false,
                              );
                              setTileState(() {});
                              return;
                            }
                            final notifTime = TimeOfDay(
                              hour: prayerTime.hour,
                              minute: prayerTime.minute,
                            );
                            await NotificationHelper.scheduleDaily(
                              notificationId: _periodNotifId(item.period),
                              title: 'period_notif_title'.tr(
                                namedArgs: {'period': item.title.tr()},
                              ),
                              body: 'period_notif_body'.tr(),
                              time: notifTime,
                            );
                          } else {
                            await NotificationHelper.cancel(
                              _periodNotifId(item.period),
                            );
                          }
                          setTileState(() {});
                          _loadScheduledNotifications();
                        },
                      );
                    },
                  );
                }),
              ],
            ),
          ),

          // ── Friday Prayer Reminder ───────────────
          _buildSectionHeader(context, 'prayer_reminder_friday'.tr()),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                StatefulBuilder(
                  builder: (context, setTileState) {
                    final enabled = CacheHelper.getBool(
                      'prayer_reminder_friday_enabled',
                    );
                    return SwitchListTile(
                      secondary: Icon(Icons.mosque, color: colorScheme.primary),
                      title: Text('prayer_reminder_friday_title'.tr()),
                      subtitle: Text(
                        'prayer_reminder_friday_desc'.tr(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      value: enabled,
                      onChanged: (value) async {
                        CacheHelper.setBool(
                          'prayer_reminder_friday_enabled',
                          value,
                        );
                        if (value) {
                          await NotificationHelper.scheduleWeekly(
                            notificationId: 9003,
                            title: 'prayer_reminder_friday_title'.tr(),
                            body: 'prayer_reminder_friday_body'.tr(),
                            dayOfWeek: DateTime.friday,
                            time: const TimeOfDay(hour: 14, minute: 0),
                          );
                        } else {
                          await NotificationHelper.cancel(9003);
                        }
                        setTileState(() {});
                        _loadScheduledNotifications();
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          // ── Fasting Notifications Toggle ───────────────
          _buildSectionHeader(context, 'fasting_notifications'.tr()),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                StatefulBuilder(
                  builder: (context, setTileState) {
                    final enabled = _isMondayFastingNotifEnabled();
                    return SwitchListTile(
                      secondary: Icon(
                        Icons.no_food_rounded,
                        color: colorScheme.primary,
                      ),
                      title: Text('monday_fasting_reminder'.tr()),
                      subtitle: Text(
                        'monday_fasting_reminder_desc'.tr(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      value: enabled,
                      onChanged: (value) async {
                        CacheHelper.setBool(_mondayFastingNotifKey, value);
                        if (value) {
                          await NotificationHelper.scheduleWeekly(
                            notificationId: _fastingNotifIdSunday,
                            title: 'fasting_notif_title'.tr(),
                            body: 'fasting_notif_body'.tr(),
                            dayOfWeek: DateTime.sunday,
                            time: const TimeOfDay(hour: 21, minute: 0),
                          );
                        } else {
                          await NotificationHelper.cancel(
                            _fastingNotifIdSunday,
                          );
                        }
                        setTileState(() {});
                        _loadScheduledNotifications();
                      },
                    );
                  },
                ),
                const Divider(height: 1),
                StatefulBuilder(
                  builder: (context, setTileState) {
                    final enabled = _isThursdayFastingNotifEnabled();
                    return SwitchListTile(
                      secondary: Icon(
                        Icons.no_food_rounded,
                        color: colorScheme.primary,
                      ),
                      title: Text('thursday_fasting_reminder'.tr()),
                      subtitle: Text(
                        'thursday_fasting_reminder_desc'.tr(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      value: enabled,
                      onChanged: (value) async {
                        CacheHelper.setBool(_thursdayFastingNotifKey, value);
                        if (value) {
                          await NotificationHelper.scheduleWeekly(
                            notificationId: _fastingNotifIdWednesday,
                            title: 'fasting_notif_title'.tr(),
                            body: 'fasting_notif_body'.tr(),
                            dayOfWeek: DateTime.wednesday,
                            time: const TimeOfDay(hour: 21, minute: 0),
                          );
                        } else {
                          await NotificationHelper.cancel(
                            _fastingNotifIdWednesday,
                          );
                        }
                        setTileState(() {});
                        _loadScheduledNotifications();
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Motivational Notifications Toggle ──────────
          // _buildSectionHeader(context, 'motivational_notifications'.tr()),
          // Card(
          //   margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          //   child: StatefulBuilder(
          //     builder: (context, setTileState) {
          //       final enabled = MotivationalNotificationService.isEnabled();
          //       return SwitchListTile(
          //         secondary: Icon(
          //           Icons.auto_awesome,
          //           color: colorScheme.primary,
          //         ),
          //         title: Text('motivational_notifications'.tr()),
          //         subtitle: Text(
          //           'motivational_notifications_desc'.tr(),
          //           style: theme.textTheme.bodySmall?.copyWith(
          //             color: Colors.grey,
          //           ),
          //         ),
          //         value: enabled,
          //         onChanged: (value) {
          //           MotivationalNotificationService.setEnabled(value);
          //           setTileState(() {});
          //         },
          //       );
          //     },
          //   ),
          // ),
          const SizedBox(height: 16),

          // ── Scheduled Reminders ────────────────────────
          _buildSectionHeader(context, 'reminders'.tr()),
          if (_isLoadingNotifications)
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                leading: Icon(Icons.alarm, color: colorScheme.primary),
                title: Text('Loading scheduled reminders...'.tr()),
                trailing: const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else if (_scheduledNotifications.isEmpty)
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                leading: Icon(
                  Icons.notifications_off_outlined,
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
                title: Text(
                  'no_scheduled_reminders'.tr(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ),
            )
          else
            // ✅ Flat list — all reminders shown directly, no ExpansionTile
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        Icon(Icons.alarm, color: colorScheme.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${'Scheduled Reminders'.tr()} (${_scheduledNotifications.length})',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  ..._scheduledNotifications.map((notif) {
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      leading: SizedBox(
                        width: 80,
                        child: Builder(
                          builder: (context) {
                            try {
                              if (notif.payload == null ||
                                  notif.payload!.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              final payloadData = jsonDecode(notif.payload!);
                              final timestamp = payloadData['timestamp'];
                              if (timestamp == null) {
                                return const SizedBox.shrink();
                              }
                              final milliseconds = timestamp is int
                                  ? timestamp
                                  : int.tryParse(timestamp.toString());
                              if (milliseconds == null) {
                                return const SizedBox.shrink();
                              }
                              final dateTime =
                                  DateTime.fromMillisecondsSinceEpoch(
                                    milliseconds,
                                  );
                              final formattedDate = DateFormat(
                                'yyyy-MM-dd\nhh:mm a',
                                AppServicesDBprovider.currentLocale(),
                              ).format(dateTime);
                              return Text(
                                formattedDate,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              );
                            } catch (e) {
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                      ),
                      title: Text(
                        notif.title ?? 'No Title',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontFamily: 'kufi',
                        ),
                      ),
                      subtitle: Text(
                        notif.body ?? 'No Description',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontFamily: 'kufi',
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: colorScheme.error,
                        ),
                        tooltip: 'delete_reminder'.tr(),
                        onPressed: () async {
                          await NotificationHelper.cancel(notif.id);
                          await _loadScheduledNotifications();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Notification cancelled'.tr()),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 16, 32, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  IconData _getPeriodIcon(AzanDayPeriod period) {
    switch (period) {
      case AzanDayPeriod.fajr:
        return Icons.wb_twilight;
      case AzanDayPeriod.shorouq:
        return Icons.wb_sunny_outlined;
      case AzanDayPeriod.duhr:
        return Icons.wb_sunny;
      case AzanDayPeriod.asr:
        return Icons.sunny_snowing;
      case AzanDayPeriod.maghrib:
        return Icons.wb_twilight;
      case AzanDayPeriod.isha:
        return Icons.nights_stay_outlined;
      case AzanDayPeriod.night:
        return Icons.dark_mode;
    }
  }

  /// Returns the actual prayer time from AzanHelper for the given period.
  /// Returns null if location is unavailable (user should be informed to set location).
  DateTime? _getPeriodTime(AzanDayPeriod period) {
    final helper = _azanHelper;
    if (helper == null) return null;
    final now = DateTime.now();
    switch (period) {
      case AzanDayPeriod.fajr:
        return helper.fajr;
      case AzanDayPeriod.shorouq:
        return helper.sunrise;
      case AzanDayPeriod.duhr:
        return helper.dhuhr;
      case AzanDayPeriod.asr:
        return helper.asr;
      case AzanDayPeriod.maghrib:
        return helper.maghrib;
      case AzanDayPeriod.isha:
        return helper.isha;
      case AzanDayPeriod.night:
        return DateTime(now.year, now.month, now.day, 22, 0);
    }
  }
}
