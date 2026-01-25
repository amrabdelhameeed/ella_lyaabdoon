import 'package:bloc/bloc.dart';
import 'package:ella_lyaabdoon/core/services/app_services_database_provider.dart';
import 'package:ella_lyaabdoon/core/services/prayer_widget_service.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit()
    : super(
        SettingsState(
          isDarkMode: AppServicesDBprovider.isDark(),
          isEnglish: AppServicesDBprovider.currentLocale() == 'en',
          isWidgetInstalled: true,
          playAyahReciter: AppServicesDBprovider.getAyahReciter(),
        ),
      ) {
    checkWidgetStatus();
  }

  void toggleTheme(bool value) {
    AppServicesDBprovider.switchTheme();
    emit(state.copyWith(isDarkMode: AppServicesDBprovider.isDark()));
  }

  void toggleLanguage(bool isEnglish) {
    final lang = isEnglish ? 'en' : 'ar';
    AppServicesDBprovider.changeLocale(lang);
    emit(state.copyWith(isEnglish: isEnglish));
  }

  void setAyahReciter(String reciterId) {
    // If the user selects OFF, save empty string
    final valueToSave = reciterId == 'OFF' ? '' : reciterId;
    AppServicesDBprovider.setAyahReciter(valueToSave);

    emit(
      state.copyWith(
        playAyahReciter: valueToSave, // empty string means OFF
      ),
    );
  }

  Future<void> checkWidgetStatus() async {
    try {
      final installedWidgets = await HomeWidget.getInstalledWidgets();
      // Check if either of our widgets is installed
      final isInstalled = installedWidgets.any(
        (w) => w.androidClassName == 'PrayerRewardWidgetProvider',
      );
      emit(state.copyWith(isWidgetInstalled: isInstalled));
    } catch (e) {
      // If check fails, assume not installed or keep current state
      emit(state.copyWith(isWidgetInstalled: false));
    }
  }

  Future<void> requestPinWidget() async {
    try {
      // Update widget BEFORE pinning
      await PrayerWidgetService.updateWidget();
      await Future.delayed(Duration(milliseconds: 800));

      // Pin widget
      await HomeWidget.requestPinWidget(
        androidName: 'PrayerRewardWidgetProvider',
      );

      // Update AFTER pinning
      await Future.delayed(Duration(milliseconds: 500));
      await PrayerWidgetService.updateWidget();

      await checkWidgetStatus();
    } catch (e) {
      debugPrint('Error: $e');
    }
  }
}
