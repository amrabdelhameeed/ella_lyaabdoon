// import 'package:default_app/core/utils/shared_pref_helper.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class LanguageCacheHelper {
//   Future<void> cacheLanguageCode(String languageCode) async {
//     await SharedPrefHelper.init();
//     final sharedPreferences = SharedPrefHelper.sharedPreferences;
//     sharedPreferences.setString("LOCALE", languageCode).then((value) {
//       print(value);
//     });
//   }

//   Future<String> getCachedLanguageCode() async {
//     final sharedPreferences = await SharedPreferences.getInstance();
//     final cachedLanguageCode = sharedPreferences.getString("LOCALE");
//     if (cachedLanguageCode != null) {
//       return cachedLanguageCode;
//     } else {
//       return "en";
//     }
//   }
// }
