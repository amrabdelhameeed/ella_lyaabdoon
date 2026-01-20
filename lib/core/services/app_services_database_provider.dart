import 'package:hive/hive.dart';

class AppServicesDBprovider {
  static final _box = Hive.box<String>(AppDatabaseKeys.appServicesKey);

  static Future<void> delete(String key) async => await _box.delete(key);

  static Stream<BoxEvent> listenable() => _box.watch();

  // theme
  static bool isDark() => _box.get(AppDatabaseKeys.themeKey) == '1';
  static Future<void> switchTheme() async {
    await _box.put(AppDatabaseKeys.themeKey, isDark() ? '0' : '1');
  }

  // locale
  static String currentLocale() => _box.get(AppDatabaseKeys.localeKey) ?? "en";
  static Future<void> changeLocale(String locale) async {
    await _box.put(AppDatabaseKeys.localeKey, locale);
  }

  // first-open
  static Future<void> setFirstOpen() async {
    await _box.put(AppDatabaseKeys.firstOpenKey, AppDatabaseKeys.firstOpenKey);
  }

  static bool isOpenedBefore() =>
      _box.get(AppDatabaseKeys.firstOpenKey) != null;

  // token
  static String token() => _box.get(AppDatabaseKeys.tokenKey) ?? "";
  static Future<void> deleteToken() async {
    await _box.delete(AppDatabaseKeys.tokenKey);
  }

  // featureView
  static Future<void> savefeatureView() async {
    await _box.put(
      AppDatabaseKeys.featureViewKey,
      AppDatabaseKeys.featureViewKey,
    );
  }

  static bool isFeatureViewed() =>
      _box.get(AppDatabaseKeys.featureViewKey) != null;

  // rememberMe
  static Future<void> rememberMe({required bool value}) async {
    await _box.put(AppDatabaseKeys.rememberMe, value ? "1" : "0");
  }

  static bool isRememberMe() =>
      (_box.get(AppDatabaseKeys.rememberMe) ?? "0") == "1";

  // AyahReciter
  static Future<void> setAyahReciter(String value) async {
    await _box.put(AppDatabaseKeys.ayahReciterKey, value);
  }

  static String getAyahReciter() =>
      _box.get(AppDatabaseKeys.ayahReciterKey) ?? "";
}

class AppDatabaseKeys {
  AppDatabaseKeys._();

  static const String appServicesKey = 'appServicesKey';
  static const String dahabKey = 'dahabKey';

  static const String achievementKey = 'achievementKey';
  static const String featureViewKey = 'featureViewKey';
  static const String rememberMe = 'rememberMe';
  static const String firstOpenKey = 'firstOpenKey';
  static const String userNameAndPassword = 'userNameAndPassword';

  static const String themeKey = 'themeKey';
  static const String tokenKey = 'tokenKey';
  static const String localeKey = 'localeKey';
  static const String searchListKey = 'searchListKey';

  // New key for AyahReciter
  static const String ayahReciterKey = 'ayahReciterKey';
}
