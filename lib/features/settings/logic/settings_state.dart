part of 'settings_cubit.dart';

class SettingsState {
  final bool isDarkMode;
  final bool isEnglish;
  final String playAyahReciter; // store reciter id, empty string means OFF

  SettingsState({
    required this.isDarkMode,
    required this.isEnglish,
    required this.playAyahReciter,
  });

  SettingsState copyWith({
    bool? isDarkMode,
    bool? isEnglish,
    String? playAyahReciter,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isEnglish: isEnglish ?? this.isEnglish,
      playAyahReciter: playAyahReciter ?? this.playAyahReciter,
    );
  }
}
