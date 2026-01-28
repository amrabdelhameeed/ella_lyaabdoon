import 'package:ella_lyaabdoon/core/constants/app_lists.dart';
import 'package:ella_lyaabdoon/core/models/azan_day_period.dart';
import 'package:ella_lyaabdoon/core/services/location_storage.dart';
import 'package:ella_lyaabdoon/core/utils/azan_helper.dart';
import 'package:ella_lyaabdoon/features/history/data/history_db_provider.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class RewardWidgetService {
  /// Update the widget with rewards based on actual Azan times
  static Future<void> updateWidget() async {
    try {
      debugPrint('🟢 Starting Reward widget update');

      final now = DateTime.now();

      // 1️⃣ Get current period using actual Azan calculations
      final currentPeriod = await _getCurrentPeriodFromAzan(now);

      // 2️⃣ Get rewards for this period
      final currentItem = AppLists.timelineItems.firstWhere(
        (item) => item.period == currentPeriod,
        orElse: () => AppLists.timelineItems.first,
      );

      final random = Random();
      final allRewards = List.from(currentItem.rewards)..shuffle(random);
      final selectedRewards = allRewards.take(3).toList();

      debugPrint('📊 Selected ${selectedRewards.length} rewards for widget');

      // 3️⃣ Save rewards & check states in Hive + HomeWidget
      for (int i = 0; i < 3; i++) {
        if (i < selectedRewards.length) {
          final reward = selectedRewards[i];

          // Async call
          bool isChecked = await HistoryDBProvider.isCheckedTodayAsync(
            reward.id,
          );

          // Save check in Hive
          await HistoryDBProvider.saveCheckState(reward.id, isChecked);

          // Save to HomeWidget
          await HomeWidget.saveWidgetData<String>(
            'reward_${i + 1}_id',
            reward.id,
          );
          await HomeWidget.saveWidgetData<String>(
            'reward_${i + 1}_title',
            reward.title,
          );
          await HomeWidget.saveWidgetData<bool>(
            'reward_${i + 1}_checked',
            isChecked,
          );
        } else {
          // Clear unused slots
          await HomeWidget.saveWidgetData<String>('reward_${i + 1}_id', '');
          await HomeWidget.saveWidgetData<String>('reward_${i + 1}_title', '');
          await HomeWidget.saveWidgetData<bool>(
            'reward_${i + 1}_checked',
            false,
          );
        }
      }

      // 4️⃣ Save updated time
      final timeFormat = DateFormat('HH:mm');
      await HomeWidget.saveWidgetData<String>(
        'reward_update_time',
        timeFormat.format(now),
      );

      // 5️⃣ Update widget
      // await HomeWidget.updateWidget(androidName: 'ZikrCheckWidgetProvider');

      debugPrint('✅ Reward widget updated successfully');
    } catch (e) {
      debugPrint('❌ Reward widget update error: $e');
    }
  }

  /// Toggle a reward check and persist in Hive
  static Future<void> toggleReward(String rewardId) async {
    try {
      final now = DateTime.now();
      final isChecked = await HistoryDBProvider.isCheckedTodayAsync(rewardId);

      if (isChecked) {
        await HistoryDBProvider.removeCheck(rewardId, now);
      } else {
        await HistoryDBProvider.addCheck(rewardId, now);
      }

      // After Hive write, refresh check states & update time
      await _updateCheckStatesOnly();
    } catch (e) {
      debugPrint('❌ Error toggling reward: $e');
    }
  }

  /// Only update check states without changing rewards
  static Future<void> _updateCheckStatesOnly() async {
    try {
      final now = DateTime.now();
      final timeFormat = DateFormat('HH:mm');

      for (int i = 1; i <= 3; i++) {
        final rewardId = await HomeWidget.getWidgetData<String>(
          'reward_${i}_id',
        );

        if (rewardId != null && rewardId.isNotEmpty) {
          final isChecked = await HistoryDBProvider.isCheckedTodayAsync(
            rewardId,
          );

          // Save Hive + HomeWidget
          await HistoryDBProvider.saveCheckState(rewardId, isChecked);
          await HomeWidget.saveWidgetData<bool>(
            'reward_${i}_checked',
            isChecked,
          );
        }
      }

      await HomeWidget.saveWidgetData<String>(
        'reward_update_time',
        timeFormat.format(now),
      );
      // await HomeWidget.updateWidget(androidName: 'ZikrCheckWidgetProvider');

      debugPrint(
        '✅ Check states & update time refreshed at ${timeFormat.format(now)}',
      );
    } catch (e) {
      debugPrint('❌ Error updating check states: $e');
    }
  }

  /// Get current period using location-based Azan
  static Future<AzanDayPeriod> _getCurrentPeriodFromAzan(DateTime now) async {
    try {
      final lat = await LocationStorage.getLat();
      final lng = await LocationStorage.getLng();

      if (lat != null && lng != null) {
        final azanHelper = AzanHelper(latitude: lat, longitude: lng);
        AzanDayPeriod currentPeriod = azanHelper.getCurrentPeriod();

        // Night logic (after 10 PM)
        final nightTime = DateTime(now.year, now.month, now.day, 22, 0);
        if (now.isAfter(nightTime)) currentPeriod = AzanDayPeriod.night;

        debugPrint('✅ Azan calculation: $currentPeriod at $lat, $lng');
        return currentPeriod;
      }

      debugPrint('⚠️ No location saved, using fallback time-based period');
      return _getCurrentPeriodByTime(now);
    } catch (e) {
      debugPrint('⚠️ Azan calculation failed, using fallback: $e');
      return _getCurrentPeriodByTime(now);
    }
  }

  /// Fallback time-based period
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
}
