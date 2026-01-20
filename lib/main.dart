// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'dart:async';
import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:ella_lyaabdoon/app_router.dart';
import 'package:ella_lyaabdoon/core/di/di.dart';
import 'package:ella_lyaabdoon/core/services/prayer_widget_service.dart';
import 'package:ella_lyaabdoon/core/services/zikr_widget_service.dart';
import 'package:ella_lyaabdoon/firebase_options.dart';
import 'package:ella_lyaabdoon/core/services/app_services_database_provider.dart';
import 'package:ella_lyaabdoon/features/history/data/history_db_provider.dart';
import 'package:ella_lyaabdoon/core/constants/app_theme.dart';
import 'package:ella_lyaabdoon/core/services/cache_helper.dart';
import 'package:ella_lyaabdoon/core/utils/observer.dart';
import 'package:ella_lyaabdoon/utils/notification_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import "package:path_provider/path_provider.dart" as path;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:home_widget/home_widget.dart';

// ============================================================
// GLOBAL CONFIGURATION
// ============================================================

const Duration kInitTimeout = Duration(seconds: 3);

ClarityConfig? _clarityConfig;
bool _firebaseInitialized = false;
bool _hiveInitialized = false;
bool _allServicesReady = false;

// ============================================================
// WIDGET BACKGROUND CALLBACK
// ============================================================

@pragma('vm:entry-point')
Future<void> widgetBackgroundCallback(Uri? uri) async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('🔔 Widget callback: $uri');

  if (uri?.host == 'refresh') {
    // Prayer widget refresh
    try {
      await _ensureHiveReady();
      await PrayerWidgetService.updateWidget().timeout(kInitTimeout);
    } catch (e) {
      debugPrint('⚠️ Prayer widget refresh failed: $e');
    }
  } else if (uri?.host == 'reward_check') {
    // Reward checkbox toggle
    try {
      await _ensureHiveReady();
      final rewardId = uri?.queryParameters['id'];
      if (rewardId != null) {
        debugPrint('🔄 Toggling reward: $rewardId');
        await RewardWidgetService.toggleReward(rewardId).timeout(kInitTimeout);
      }
    } catch (e) {
      debugPrint('⚠️ Reward toggle failed: $e');
    }
  } else if (uri?.host == 'reward_refresh') {
    // Reward widget refresh with new random rewards
    try {
      await _ensureHiveReady();
      await RewardWidgetService.updateWidget().timeout(kInitTimeout);
    } catch (e) {
      debugPrint('⚠️ Reward widget refresh failed: $e');
    }
  }
}

/// Ensure Hive is initialized for background callbacks
Future<void> _ensureHiveReady() async {
  if (_hiveInitialized) return;

  try {
    final dbPath = await path.getApplicationDocumentsDirectory().timeout(
      Duration(seconds: 3),
    );
    Hive.init(dbPath.path);

    if (!Hive.isBoxOpen(AppDatabaseKeys.appServicesKey)) {
      await Hive.openBox<String>(
        AppDatabaseKeys.appServicesKey,
      ).timeout(Duration(seconds: 3));
    }

    if (!Hive.isBoxOpen('zikrHistoryBox')) {
      await HistoryDBProvider.init().timeout(Duration(seconds: 3));
    }

    _hiveInitialized = true;
    debugPrint('✅ Hive ready for widget callback');
  } catch (e) {
    debugPrint('⚠️ Hive init in callback failed: $e');
  }
}

// ============================================================
// FIREBASE BACKGROUND HANDLER
// ============================================================

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(Duration(seconds: 5));

    await NotificationHelper.firebaseBackgroundHandler(message);
  } catch (e) {
    debugPrint("Background handler error: $e");
  }
}

// ============================================================
// MAIN FUNCTION - PROPER INITIALIZATION ORDER
// ============================================================

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      debugPrint('🚀 Starting app initialization...');

      // Initialize default clarity
      _clarityConfig = ClarityConfig(
        projectId: "toksotegrs",
        userId: "default_${DateTime.now().millisecondsSinceEpoch}",
        logLevel: kDebugMode ? LogLevel.Info : LogLevel.None,
      );

      // STEP 1: Initialize Firebase FIRST (many services depend on it)
      await _initFirebaseFirst();

      // STEP 2: Initialize Hive (UI depends on it)
      await _initHiveCritical();

      // STEP 3: Initialize EasyLocalization (UI depends on it)
      await _initEasyLocalization();

      // STEP 4: Initialize Timezone
      await _initTimezone();

      // STEP 5: Initialize CacheHelper
      await _initCacheHelper();

      // STEP 6: Initialize DI (NOW Firebase is ready if needed)
      await _initDI();

      // STEP 7: Setup BLoC observer
      _initBlocObserver();

      // Mark all critical services as ready
      _allServicesReady = true;
      debugPrint('✅ All critical services initialized');
      await dotenv.load(fileName: ".env");
      // 🎯 NOW launch app - everything is ready!
      runApp(ClarityWidget(app: const MyApp(), clarityConfig: _clarityConfig!));

      debugPrint('✅ App launched successfully');

      // ✅ Continue with optional initialization in background
      _initializeInBackground();
    },
    (error, stack) {
      debugPrint('❌ FATAL ERROR: $error');
      debugPrint('Stack: $stack');

      // Emergency launch
      // runApp(
      //   MaterialApp(
      //     home: Scaffold(
      //       backgroundColor: Colors.white,
      //       body: Center(
      //         child: Padding(
      //           padding: const EdgeInsets.all(20),
      //           child: Column(
      //             mainAxisAlignment: MainAxisAlignment.center,
      //             children: [
      //               const Icon(
      //                 Icons.error_outline,
      //                 size: 64,
      //                 color: Colors.red,
      //               ),
      //               const SizedBox(height: 20),
      //               const Text(
      //                 'خطأ في التحميل',
      //                 style: TextStyle(
      //                   fontSize: 24,
      //                   fontWeight: FontWeight.bold,
      //                 ),
      //               ),
      //               const SizedBox(height: 10),
      //               const Text(
      //                 'Error loading app',
      //                 style: TextStyle(fontSize: 16, color: Colors.grey),
      //               ),
      //               const SizedBox(height: 20),
      //               Text(
      //                 error.toString(),
      //                 style: const TextStyle(fontSize: 12, color: Colors.red),
      //                 textAlign: TextAlign.center,
      //               ),
      //               const SizedBox(height: 20),
      //               ElevatedButton(
      //                 onPressed: () {
      //                   // Restart app
      //                   runApp(const MyApp());
      //                 },
      //                 child: const Text('إعادة المحاولة / Retry'),
      //               ),
      //             ],
      //           ),
      //         ),
      //       ),
      //     ),
      //   ),
      // );
    },
  );
}

// ============================================================
// STEP 1: INITIALIZE FIREBASE FIRST
// ============================================================

Future<void> _initFirebaseFirst() async {
  try {
    debugPrint('🔧 [1/7] Initializing Firebase...');

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(Duration(seconds: 10));

    _firebaseInitialized = true;
    debugPrint('✅ Firebase initialized (online mode)');
  } catch (e) {
    _firebaseInitialized = false;
    debugPrint('⚠️ Firebase NOT initialized (offline mode): $e');
    debugPrint('📱 App will work without Firebase services');
  }
}

// ============================================================
// STEP 2: INITIALIZE HIVE
// ============================================================

Future<void> _initHiveCritical() async {
  try {
    debugPrint('🔧 [2/7] Initializing Hive...');

    final dbPath = await path.getApplicationDocumentsDirectory().timeout(
      Duration(seconds: 5),
    );

    Hive.init(dbPath.path);

    // Open app services box
    await Hive.openBox<String>(
      AppDatabaseKeys.appServicesKey,
    ).timeout(Duration(seconds: 5));

    // Initialize history DB
    await HistoryDBProvider.init().timeout(Duration(seconds: 5));

    // Set defaults
    await _setDefaultPreferences();

    _hiveInitialized = true;
    debugPrint('✅ Hive initialized');
  } catch (e) {
    debugPrint('❌ Hive error: $e');

    // Try in-memory fallback
    try {
      debugPrint('⚠️ Trying in-memory Hive...');
      await Hive.openBox<String>(AppDatabaseKeys.appServicesKey, path: null);
      _hiveInitialized = true;
      debugPrint('✅ Using in-memory Hive');
    } catch (e2) {
      debugPrint('❌ FATAL: Cannot initialize Hive: $e2');
      rethrow;
    }
  }
}

// ============================================================
// STEP 3: INITIALIZE EASYLOCALIZATION
// ============================================================

Future<void> _initEasyLocalization() async {
  try {
    debugPrint('🔧 [3/7] Initializing EasyLocalization...');
    await EasyLocalization.ensureInitialized().timeout(Duration(seconds: 5));
    debugPrint('✅ EasyLocalization initialized');
  } catch (e) {
    debugPrint('⚠️ EasyLocalization failed: $e');
  }
}

// ============================================================
// STEP 4: INITIALIZE TIMEZONE
// ============================================================

Future<void> _initTimezone() async {
  try {
    debugPrint('🔧 [4/7] Initializing Timezone...');
    tz.initializeTimeZones();

    final tzName = await FlutterTimezone.getLocalTimezone().timeout(
      kInitTimeout,
    );
    tz.setLocalLocation(tz.getLocation(tzName.identifier));

    debugPrint('✅ Timezone: ${tzName.identifier}');
  } catch (e) {
    debugPrint('⚠️ Timezone failed, using UTC: $e');
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));
  }
}

// ============================================================
// STEP 5: INITIALIZE CACHEHELPER
// ============================================================

Future<void> _initCacheHelper() async {
  try {
    debugPrint('🔧 [5/7] Initializing CacheHelper...');
    await CacheHelper.init().timeout(kInitTimeout);
    debugPrint('✅ CacheHelper initialized');
  } catch (e) {
    debugPrint('⚠️ CacheHelper failed: $e');
  }
}

// ============================================================
// STEP 6: INITIALIZE DI (after Firebase)
// ============================================================

Future<void> _initDI() async {
  try {
    debugPrint('🔧 [6/7] Initializing Dependency Injection...');

    // Wrap in Future to ensure it doesn't block
    await Future.microtask(() {
      initDI();
    }).timeout(Duration(seconds: 5));

    debugPrint('✅ DI initialized');
  } catch (e) {
    debugPrint('⚠️ DI failed: $e');
    debugPrint('⚠️ Some features may not work properly');
  }
}

// ============================================================
// STEP 7: INITIALIZE BLOC OBSERVER
// ============================================================

void _initBlocObserver() {
  try {
    debugPrint('🔧 [7/7] Setting up BLoC observer...');
    Bloc.observer = MyBlocObserver();
    debugPrint('✅ BLoC observer setup');
  } catch (e) {
    debugPrint('⚠️ BLoC observer failed: $e');
  }
}

// ============================================================
// DEFAULT PREFERENCES
// ============================================================

Future<void> _setDefaultPreferences() async {
  try {
    if (!_hiveInitialized) return;

    final box = Hive.box<String>(AppDatabaseKeys.appServicesKey);

    // Locale
    if (!box.containsKey(AppDatabaseKeys.localeKey)) {
      try {
        final deviceLocale = Platform.localeName.substring(0, 2);
        const supported = ['ar', 'en'];
        final locale = supported.contains(deviceLocale) ? deviceLocale : 'ar';
        await box.put(AppDatabaseKeys.localeKey, locale);
      } catch (e) {
        await box.put(AppDatabaseKeys.localeKey, 'ar');
      }
    }

    // Theme
    if (!box.containsKey(AppDatabaseKeys.themeKey)) {
      try {
        final brightness = PlatformDispatcher.instance.platformBrightness;
        await box.put(
          AppDatabaseKeys.themeKey,
          brightness == Brightness.dark ? "1" : "0",
        );
      } catch (e) {
        await box.put(AppDatabaseKeys.themeKey, "0");
      }
    }

    // Reciter
    try {
      if (AppServicesDBprovider.getAyahReciter().isEmpty &&
          !AppServicesDBprovider.isOpenedBefore()) {
        AppServicesDBprovider.setAyahReciter('ar.muhammadayyoub');
      }
    } catch (e) {
      debugPrint('⚠️ Could not set reciter: $e');
    }
  } catch (e) {
    debugPrint('⚠️ Error setting defaults: $e');
  }
}

// ============================================================
// BACKGROUND INITIALIZATION - OPTIONAL SERVICES
// ============================================================

Future<void> _initializeInBackground() async {
  debugPrint('🔧 Starting optional services...');

  // Widget setup
  _initWidget();

  // Error handling (only if Firebase available)
  if (_firebaseInitialized) {
    _setupErrorHandling();
  }

  // Firebase Messaging (only if Firebase available)
  if (_firebaseInitialized) {
    await _initMessaging();
  }

  // UI setup
  _setupUI();

  debugPrint('✅ Optional services complete');
}

void _initWidget() {
  try {
    HomeWidget.registerInteractivityCallback(widgetBackgroundCallback);
    HomeWidget.setAppGroupId('group.com.amrabdelhameed.ella_lyaabdoon')
        .timeout(kInitTimeout)
        .catchError((e) => debugPrint('⚠️ Widget setup: $e'));

    // Update both widgets
    PrayerWidgetService.updateWidget()
        .timeout(kInitTimeout)
        .catchError((e) => null);

    RewardWidgetService.updateWidget()
        .timeout(kInitTimeout)
        .catchError((e) => null);

    debugPrint('✅ Widget setup');
  } catch (e) {
    debugPrint('⚠️ Widget failed: $e');
  }
}

void _setupErrorHandling() {
  try {
    FlutterError.onError = (details) {
      FirebaseCrashlytics.instance
          .recordFlutterFatalError(details)
          .catchError((_) => null);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance
          .recordError(error, stack, fatal: false)
          .catchError((_) => null);
      return true;
    };

    debugPrint('✅ Error handling');
  } catch (e) {
    debugPrint('⚠️ Error handling failed: $e');
  }
}

Future<void> _initMessaging() async {
  try {
    debugPrint('🔧 Initializing messaging...');
    final messaging = FirebaseMessaging.instance;

    await messaging
        .setAutoInitEnabled(true)
        .timeout(kInitTimeout)
        .catchError((_) => null);

    messaging
        .getToken()
        .timeout(Duration(seconds: 5))
        .then((token) {
          if (token != null) {
            _clarityConfig = ClarityConfig(
              projectId: "toksotegrs",
              userId: token,
              logLevel: kDebugMode ? LogLevel.Info : LogLevel.None,
            );
            debugPrint('✅ FCM token');
          }
        })
        .catchError((e) => debugPrint('⚠️ Token failed: $e'));

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(
      NotificationHelper.handleForegroundMessage,
    );

    await NotificationHelper.initialize()
        .timeout(Duration(seconds: 5))
        .catchError((_) => null);

    if (Platform.isIOS) {
      final apnsToken = await messaging
          .getAPNSToken()
          .timeout(Duration(seconds: 3))
          .catchError((_) => null);

      if (apnsToken != null) {
        NotificationHelper.subscribeToTopic(
          'ALL',
        ).timeout(kInitTimeout).catchError((_) => null);
      }
    } else {
      NotificationHelper.subscribeToTopic(
        'ALL',
      ).timeout(kInitTimeout).catchError((_) => null);
    }

    debugPrint('✅ Messaging');
  } catch (e) {
    debugPrint('⚠️ Messaging failed: $e');
  }
}

void _setupUI() {
  try {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    debugPrint('✅ UI setup');
  } catch (e) {
    debugPrint('⚠️ UI setup failed: $e');
  }
}

// ============================================================
// APP WIDGET
// ============================================================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Safety check
    if (!_hiveInitialized || !_allServicesReady) {
      return MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                const Text(
                  'جاري التحميل...',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  _firebaseInitialized ? 'متصل بالإنترنت' : 'وضع عدم الاتصال',
                  style: TextStyle(
                    fontSize: 14,
                    color: _firebaseInitialized ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return StreamBuilder<BoxEvent>(
      stream: AppServicesDBprovider.listenable(),
      builder: (context, snapshot) {
        final currentLocale = AppServicesDBprovider.currentLocale();
        final isDark = AppServicesDBprovider.isDark();

        return EasyLocalization(
          supportedLocales: const [Locale('en'), Locale('ar')],
          path: 'assets/translations',
          fallbackLocale: const Locale('ar'),
          startLocale: Locale(currentLocale),
          useOnlyLangCode: true,
          child: Builder(
            builder: (context) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                title: 'الإ ليعبدون',
                supportedLocales: context.supportedLocales,
                localizationsDelegates: context.localizationDelegates,
                locale: context.locale,
                themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
                theme: AppTheme.lightTheme(currentLocale),
                darkTheme: AppTheme.darkTheme(currentLocale),
                routerConfig: AppRouter.router,
              );
            },
          ),
        );
      },
    );
  }
}
