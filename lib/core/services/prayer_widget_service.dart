import 'package:ella_lyaabdoon/core/constants/app_lists.dart';
import 'package:ella_lyaabdoon/core/models/azan_day_period.dart';
import 'package:ella_lyaabdoon/core/services/location_storage.dart';
import 'package:ella_lyaabdoon/core/utils/azan_helper.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class PrayerWidgetService {
  static Future<void> updateWidget() async {
    try {
      debugPrint('🟢 ========== Starting widget update ==========');

      final now = DateTime.now();

      // Get current period using actual prayer times
      final currentPeriod = await _getCurrentPeriodFromAzan(now);

      final currentItem = AppLists.timelineItems.firstWhere(
        (item) => item.period == currentPeriod,
        orElse: () => AppLists.timelineItems.first,
      );

      final random = Random();
      final randomReward = currentItem.rewards.isNotEmpty
          ? currentItem.rewards[random.nextInt(currentItem.rewards.length)]
          : null;

      final periodName = _getArabicPeriodName(currentPeriod);

      // debugPrint('📊 Widget Data:');
      // debugPrint('   Period: $periodName');
      // debugPrint('   Title: ${randomReward?.title ?? "No reward"}');

      await HomeWidget.saveWidgetData<String>('current_period', periodName);

      if (randomReward != null) {
        await HomeWidget.saveWidgetData<String>(
          'reward_title',
          randomReward.title,
        );

        await HomeWidget.saveWidgetData<String>(
          'reward_description',
          randomReward.description,
        );
      }

      final timeFormat = DateFormat('HH:mm');
      await HomeWidget.saveWidgetData<String>(
        'update_time',
        timeFormat.format(now),
      );

      // ✅ Only update the XML widget
      await HomeWidget.updateWidget(androidName: 'PrayerRewardWidgetProvider');
      // ❌ REMOVED: await HomeWidget.updateWidget(androidName: 'HomeWidgetReceiver');

      debugPrint('✅ Widget updated successfully');
    } catch (e) {
      debugPrint('❌ Widget update error: $e');
    }
  }

  /// Get current period using actual Azan calculations
  static Future<AzanDayPeriod> _getCurrentPeriodFromAzan(DateTime now) async {
    try {
      // Try to get saved location
      final lat = await LocationStorage.getLat();
      final lng = await LocationStorage.getLng();

      if (lat != null && lng != null) {
        // Use AzanHelper with actual location
        final azanHelper = AzanHelper(latitude: lat, longitude: lng);

        // Get current period from AzanHelper
        AzanDayPeriod currentPeriod = azanHelper.getCurrentPeriod();

        // Apply night time logic (after 10 PM)
        final nightTime = DateTime(now.year, now.month, now.day, 22, 0);
        if (now.isAfter(nightTime)) {
          currentPeriod = AzanDayPeriod.night;
        }

        debugPrint('✅ Using Azan calculation: $currentPeriod at $lat, $lng');
        return currentPeriod;
      } else {
        // Fallback to time-based if no location
        debugPrint('⚠️ No location saved, using time-based fallback');
        return _getCurrentPeriodByTime(now);
      }
    } catch (e) {
      debugPrint('⚠️ Error getting Azan period: $e, using time-based fallback');
      return _getCurrentPeriodByTime(now);
    }
  }

  /// Fallback method using hardcoded hours (used when location unavailable)
  static AzanDayPeriod _getCurrentPeriodByTime(DateTime now) {
    final hour = now.hour;

    if (hour >= 22 || hour < 4) return AzanDayPeriod.night;
    if (hour >= 4 && hour < 6) return AzanDayPeriod.fajr;
    if (hour >= 6 && hour < 12) return AzanDayPeriod.shorouq;
    if (hour >= 12 && hour < 15) return AzanDayPeriod.duhr;
    if (hour >= 15 && hour < 18) return AzanDayPeriod.asr;
    if (hour >= 18 && hour < 19) return AzanDayPeriod.maghrib;
    if (hour >= 19 && hour < 22) return AzanDayPeriod.isha;

    return AzanDayPeriod.fajr;
  }

  static String _getArabicPeriodName(AzanDayPeriod period) {
    switch (period) {
      case AzanDayPeriod.fajr:
        return 'الفجر';
      case AzanDayPeriod.shorouq:
        return 'الشروق';
      case AzanDayPeriod.duhr:
        return 'الظهر';
      case AzanDayPeriod.asr:
        return 'العصر';
      case AzanDayPeriod.maghrib:
        return 'المغرب';
      case AzanDayPeriod.isha:
        return 'العشاء';
      case AzanDayPeriod.night:
        return 'الليل';
    }
  }
}
