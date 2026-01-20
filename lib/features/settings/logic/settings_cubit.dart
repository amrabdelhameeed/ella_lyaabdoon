import 'package:bloc/bloc.dart';
import 'package:ella_lyaabdoon/core/services/app_services_database_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit()
    : super(
        SettingsState(
          isDarkMode: AppServicesDBprovider.isDark(),
          isEnglish: AppServicesDBprovider.currentLocale() == 'en',
          playAyahReciter: AppServicesDBprovider.getAyahReciter(),
        ),
      );

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
}
