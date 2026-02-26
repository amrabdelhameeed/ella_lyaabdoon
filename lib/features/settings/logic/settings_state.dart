part of 'settings_cubit.dart';

class SettingsState {
  final bool isDarkMode;
  final bool isEnglish;
  final bool isWidgetInstalled;
  final String playAyahReciter; // store reciter id, empty string means OFF
  final String calculationMethod;
  final String madhab;
  final int appColor;

  SettingsState({
    required this.isDarkMode,
    required this.isEnglish,
    required this.isWidgetInstalled,
    required this.playAyahReciter,
    required this.calculationMethod,
    required this.madhab,
    required this.appColor,
  });

  SettingsState copyWith({
    bool? isDarkMode,
    bool? isEnglish,
    bool? isWidgetInstalled,
    String? playAyahReciter,
    String? calculationMethod,
    String? madhab,
    int? appColor,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isEnglish: isEnglish ?? this.isEnglish,
      isWidgetInstalled: isWidgetInstalled ?? this.isWidgetInstalled,
      playAyahReciter: playAyahReciter ?? this.playAyahReciter,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      madhab: madhab ?? this.madhab,
      appColor: appColor ?? this.appColor,
    );
  }
}
