import 'package:easy_localization/easy_localization.dart';
import 'package:ella_lyaabdoon/core/constants/app_lists.dart';
import 'package:ella_lyaabdoon/core/models/azan_day_period.dart';
import 'package:ella_lyaabdoon/core/services/cache_helper.dart';
import 'package:ella_lyaabdoon/core/services/location_storage.dart';
import 'package:ella_lyaabdoon/core/utils/azan_helper.dart';
import 'package:ella_lyaabdoon/utils/notification_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Call [PeriodNotificationRescheduleService.rescheduleAll()] once on every
/// app open (e.g. in main() after all services are initialized).
///
/// Why: prayer times shift by 1-3 minutes each day. A notification scheduled
/// once with a fixed TimeOfDay will drift. Rescheduling on every open keeps
/// it accurate to today's real calculated times.
///
/// Safe to call unconditionally — it guards all failure cases internally
/// and never throws.
class PeriodNotificationRescheduleService {
  PeriodNotificationRescheduleService._();

  static String _periodNotifKey(AzanDayPeriod period) =>
      'period_notif_enabled_${period.name}';

  static bool _isPeriodNotifEnabled(AzanDayPeriod period) =>
      CacheHelper.getBool(_periodNotifKey(period));

  static int _periodNotifId(AzanDayPeriod period) =>
      8000 + AzanDayPeriod.values.indexOf(period);

  // ──────────────────────────────────────────────────────────
  // Main entry point
  // ──────────────────────────────────────────────────────────

  static Future<void> rescheduleAll() async {
    debugPrint('🔄 PeriodNotificationRescheduleService: Starting...');

    // ── Guard 1: notification permission ────────────────────
    final hasPermission = await _hasNotificationPermission();
    if (!hasPermission) {
      debugPrint(
        '⏭️ PeriodNotificationRescheduleService: '
        'Notifications not permitted — skipping.',
      );
      // Also cancel any stale scheduled period notifs so they don't fire
      // from a previous session when permission was granted.
      await _cancelAllPeriodNotifs();
      return;
    }

    // ── Guard 2: location saved ──────────────────────────────
    final double? lat;
    final double? lng;
    try {
      lat = await LocationStorage.getLat();
      lng = await LocationStorage.getLng();
    } catch (e) {
      debugPrint(
        '❌ PeriodNotificationRescheduleService: '
        'Failed to read location — $e',
      );
      return;
    }

    if (lat == null || lng == null) {
      debugPrint(
        '⏭️ PeriodNotificationRescheduleService: '
        'No location saved — skipping.',
      );
      return;
    }

    // ── Guard 3: valid coordinates ───────────────────────────
    if (!_isValidCoordinate(lat, lng)) {
      debugPrint(
        '⏭️ PeriodNotificationRescheduleService: '
        'Invalid coordinates ($lat, $lng) — skipping.',
      );
      return;
    }

    // ── Guard 4: AzanHelper construction ────────────────────
    AzanHelper helper;
    try {
      helper = AzanHelper(latitude: lat, longitude: lng);
    } catch (e) {
      debugPrint(
        '❌ PeriodNotificationRescheduleService: '
        'AzanHelper failed for ($lat, $lng) — $e',
      );
      return;
    }

    // ── Guard 5: check any period is actually enabled ────────
    final anyEnabled = AzanDayPeriod.values.any(_isPeriodNotifEnabled);
    if (!anyEnabled) {
      debugPrint(
        '⏭️ PeriodNotificationRescheduleService: '
        'No periods enabled — nothing to reschedule.',
      );
      return;
    }

    // ── Reschedule enabled periods ───────────────────────────
    debugPrint(
      '📍 PeriodNotificationRescheduleService: '
      'lat=$lat, lng=$lng',
    );

    int rescheduled = 0;
    int skipped = 0;

    for (final item in AppLists.timelineItems) {
      final period = item.period;

      if (!_isPeriodNotifEnabled(period)) {
        // Make sure any stale notification for disabled periods is cancelled
        await NotificationHelper.cancel(_periodNotifId(period));
        continue;
      }

      // ── Guard 6: prayer time must be a real future DateTime ──
      final DateTime? prayerTime;
      try {
        prayerTime = _getPeriodTime(helper, period);
      } catch (e) {
        debugPrint(
          '❌ PeriodNotificationRescheduleService: '
          'Failed to get time for ${period.name} — $e',
        );
        skipped++;
        continue;
      }

      if (prayerTime == null) {
        debugPrint(
          '⚠️ PeriodNotificationRescheduleService: '
          'Null time for ${period.name} — skipping.',
        );
        skipped++;
        continue;
      }

      final notifTime = TimeOfDay(
        hour: prayerTime.hour,
        minute: prayerTime.minute,
      );

      try {
        await NotificationHelper.cancel(_periodNotifId(period));
        await NotificationHelper.scheduleDaily(
          notificationId: _periodNotifId(period),
          title: 'period_notif_title'.tr(
            namedArgs: {'period': item.title.tr()},
          ),
          body: 'period_notif_body'.tr(),
          time: notifTime,
        );

        debugPrint(
          '✅ Rescheduled: ${period.name} → '
          '${notifTime.hour.toString().padLeft(2, '0')}:'
          '${notifTime.minute.toString().padLeft(2, '0')} '
          '(id: ${_periodNotifId(period)})',
        );
        rescheduled++;
      } catch (e) {
        debugPrint('❌ Failed to reschedule ${period.name}: $e');
        skipped++;
      }
    }

    debugPrint(
      '✅ PeriodNotificationRescheduleService: Done — '
      '$rescheduled rescheduled, $skipped skipped.',
    );
  }

  // ──────────────────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────────────────

  /// Checks whether the app currently has permission to post notifications.
  static Future<bool> _hasNotificationPermission() async {
    try {
      final plugin = FlutterLocalNotificationsPlugin();
      final android = plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android != null) {
        return await android.areNotificationsEnabled() ?? false;
      }
      // iOS / other: assume granted if we can't programmatically check
      return true;
    } catch (e) {
      debugPrint(
        '⚠️ PeriodNotificationRescheduleService: '
        'Could not check notification permission — $e',
      );
      // Fail open: don't block reschedule if the check itself throws
      return true;
    }
  }

  /// Validates that lat/lng are within sane geographic bounds.
  static bool _isValidCoordinate(double lat, double lng) =>
      lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;

  /// Cancels all period notification slots regardless of enabled state.
  /// Used to clean up when permission is revoked.
  static Future<void> _cancelAllPeriodNotifs() async {
    for (final period in AzanDayPeriod.values) {
      try {
        await NotificationHelper.cancel(_periodNotifId(period));
      } catch (_) {}
    }
    debugPrint(
      '🗑️ PeriodNotificationRescheduleService: '
      'All period notifications cancelled.',
    );
  }

  /// Maps a [period] to its real [DateTime] from [AzanHelper].
  static DateTime? _getPeriodTime(AzanHelper helper, AzanDayPeriod period) {
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
        // Night starts after Isha — use Isha + 1h as notification anchor
        return helper.isha.add(const Duration(hours: 1));
    }
  }
}
