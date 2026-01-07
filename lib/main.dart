// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:ella_lyaabdoon/app_router.dart';
import 'package:ella_lyaabdoon/di.dart';
import 'package:ella_lyaabdoon/firebase_options.dart';
import 'package:ella_lyaabdoon/utils/app_services_database_provider.dart';
import 'package:ella_lyaabdoon/utils/constants/app_theme.dart';
import 'package:ella_lyaabdoon/utils/constants/cache_helper.dart';
import 'package:ella_lyaabdoon/utils/constants/observer.dart';
import 'package:ella_lyaabdoon/utils/fcm_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:upgrader/upgrader.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:path_provider/path_provider.dart' as path;

// Global instance for Firebase Messaging
final FirebaseMessaging _messaging = FirebaseMessaging.instance;

// Global Clarity configuration
ClarityConfig? _clarityConfig;

/// Background message handler for Firebase Messaging
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  // FORCE LAUNCH APP - No matter what errors occur, the app MUST launch
  try {
    // Ensure Flutter binding is initialized
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize with default Clarity config first
    _initializeDefaultClarity();

    // Initialize core services
    await _safeInitializeCoreServices();

    // Initialize Firebase
    await _safeInitializeFirebase();

    // Setup error handling
    _safeSetupErrorHandling();

    // Initialize dependency injection
    _safeInitDI();

    // Setup Firebase Messaging and notifications
    await _safeSetupFirebaseMessaging();

    // Initialize local services
    await _safeInitializeLocalServices();

    // Setup UI
    _safeSetupUI();
  } catch (error, stackTrace) {
    debugPrint('CRITICAL ERROR during app initialization: $error');
    debugPrint('Stack trace: $stackTrace');

    // Report to crashlytics if available, but don't let it stop the app
    try {
      FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: false);
    } catch (e) {
      debugPrint('Failed to report to crashlytics: $e');
    }
  } finally {
    // ALWAYS launch the app, regardless of any errors above
    _forceLaunchApp();
  }
}

/// Initialize default Clarity configuration
void _initializeDefaultClarity() {
  try {
    _clarityConfig = ClarityConfig(
      projectId: "toksotegrs",
      userId: "default_user", // Will be updated with actual token later
      logLevel: kDebugMode ? LogLevel.Info : LogLevel.None,
    );
    debugPrint('Default Clarity config initialized');
  } catch (error) {
    debugPrint('Error initializing default Clarity config: $error');
    // Create minimal config as fallback
    _clarityConfig = ClarityConfig(
      projectId: "toksotegrs",
      userId: "fallback_user",
      logLevel: kDebugMode ? LogLevel.Info : LogLevel.None,
    );
  }
}

/// Safely initialize core services that don't depend on Firebase
Future<void> _safeInitializeCoreServices() async {
  try {
    await EasyLocalization.ensureInitialized();
    debugPrint('EasyLocalization initialized successfully');
  } catch (error) {
    debugPrint('Error initializing EasyLocalization: $error');
  }

  try {
    tz.initializeTimeZones();
    debugPrint('Timezone initialized successfully');
  } catch (error) {
    debugPrint('Error initializing timezone: $error');
  }

  try {
    await CacheHelper.init();
    debugPrint('CacheHelper initialized successfully');
  } catch (error) {
    debugPrint('Error initializing CacheHelper: $error');
  }
}

/// Safely initialize Firebase with proper configuration
Future<void> _safeInitializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');

    // Setup Firebase emulators in debug mode
    if (kDebugMode) {
      await _safeSetupFirebaseEmulators();
    }
  } catch (error) {
    debugPrint('CRITICAL: Failed to initialize Firebase: $error');
    // Continue without Firebase - app should still work
  }
}

/// Safely setup Firebase emulators for development
Future<void> _safeSetupFirebaseEmulators() async {
  try {
    // Uncomment and configure as needed
    // firebaseFirestoreInstance.useFirestoreEmulator('localhost', 8080);
    // await firebaseAuthInstance.useAuthEmulator('localhost', 9099);
    debugPrint('Firebase emulators setup completed');
  } catch (e) {
    debugPrint('Failed to setup Firebase emulators: $e');
  }
}

/// Safely setup global error handling
void _safeSetupErrorHandling() {
  try {
    // Handle Flutter errors
    FlutterError.onError = (errorDetails) {
      try {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      } catch (e) {
        debugPrint('Failed to record Flutter error to crashlytics: $e');
      }
    };

    // Handle platform errors
    PlatformDispatcher.instance.onError = (error, stack) {
      try {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: false);
      } catch (e) {
        debugPrint('Failed to record platform error to crashlytics: $e');
      }
      return true; // Continue execution
    };
    debugPrint('Error handling setup successfully');
  } catch (error) {
    debugPrint('Failed to setup error handling: $error');
  }
}

/// Safely initialize dependency injection
void _safeInitDI() {
  try {
    initDI();
    debugPrint('Dependency injection initialized successfully');
  } catch (error) {
    debugPrint('Error initializing dependency injection: $error');
  }
}

/// Safely setup Firebase Messaging with proper APNS handling
Future<void> _safeSetupFirebaseMessaging() async {
  try {
    // Enable auto initialization
    await _messaging.setAutoInitEnabled(true);
    debugPrint('Firebase Messaging auto-init enabled');

    // Get FCM token with proper APNS handling - using new workaround
    await _handleTokenWithWorkaround();

    // Setup background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    debugPrint('Background message handler setup');

    // Initialize basic notification settings
    await _safeInitializeNotifications();

    // Handle APNS token for iOS and subscribe to topics
    await _safeHandleAPNSAndSubscription();
  } catch (error) {
    debugPrint('Error setting up Firebase Messaging: $error');
    // Continue without messaging - app should still work
  }
}

/// Temporary workaround for token handling
Future<void> _handleTokenWithWorkaround() async {
  try {
    // Try to get token immediately but don't block
    String? token;
    try {
      token = await _messaging.getToken().timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          debugPrint('Token request timed out, proceeding without token');
          return null;
        },
      );
    } catch (e) {
      debugPrint('Error getting initial token: $e');
    }

    // Update with whatever we got (even if null)
    await _updateClarityWithToken(
      token ?? 'temp_token_${DateTime.now().millisecondsSinceEpoch}',
    );

    // Listen for token updates in the background
    _messaging.onTokenRefresh.listen((newToken) async {
      debugPrint('Token refreshed: $newToken');
      await _updateClarityWithToken(newToken);
      // Here you can also update your server with the new token
    });
  } catch (error) {
    debugPrint('Error in token workaround: $error');
  }
}

/// Update Clarity configuration with actual token
Future<void> _updateClarityWithToken(String token) async {
  try {
    _clarityConfig = ClarityConfig(
      projectId: "toksotegrs",
      userId: token,
      logLevel: kDebugMode ? LogLevel.Info : LogLevel.None,
    );
    debugPrint('Clarity config updated with token');
  } catch (error) {
    debugPrint('Error updating Clarity config: $error');
  }
}

/// Safely initialize notifications
Future<void> _safeInitializeNotifications() async {
  try {
    await NotificationHelper.initializeBasic();
    debugPrint('Notifications initialized successfully');
  } catch (error) {
    debugPrint('Error initializing notifications: $error');
  }
}

/// Safely handle APNS token and topic subscription with proper iOS handling
Future<void> _safeHandleAPNSAndSubscription() async {
  try {
    if (Platform.isIOS) {
      // Fix for APNS token issue on iOS
      String? apnsToken = await _messaging.getAPNSToken();
      debugPrint('Initial APNS Token: $apnsToken');

      // If APNS token is not available, wait and try again
      if (apnsToken == null) {
        debugPrint('APNS token not available, waiting...');
        await Future.delayed(const Duration(seconds: 2));
        apnsToken = await _messaging.getAPNSToken();
        debugPrint('APNS Token after delay: $apnsToken');
      }

      // Only subscribe to topics after APNS token is available
      if (apnsToken != null) {
        await _safeSubscribeToTopics();
      } else {
        debugPrint(
          'Warning: APNS token still not available, skipping topic subscription',
        );
      }
    } else {
      // For Android, we can subscribe immediately
      await _safeSubscribeToTopics();
    }
  } catch (error) {
    debugPrint('Error handling APNS and subscription: $error');
  }
}

/// Safely subscribe to notification topics
Future<void> _safeSubscribeToTopics() async {
  try {
    // await NotificationHelper.subscribeToTopic('all');
    // debugPrint('Successfully subscribed to topics');
  } catch (error) {
    debugPrint('Error subscribing to topics: $error');
  }
}

/// Safely initialize local services
Future<void> _safeInitializeLocalServices() async {
  try {
    // Setup BLoC observer
    Bloc.observer = MyBlocObserver();
    debugPrint('BLoC observer setup successfully');
  } catch (error) {
    debugPrint('Error setting up BLoC observer: $error');
  }

  try {
    // Initialize Hive databases
    await _initHiveBoxes();
    debugPrint('Hive boxes initialized successfully');
  } catch (error) {
    debugPrint('Error initializing Hive boxes: $error');
  }

  try {
    // Clear upgrader settings
    Upgrader.clearSavedSettings();
    debugPrint('Upgrader settings cleared successfully');
  } catch (error) {
    debugPrint('Error clearing upgrader settings: $error');
  }
}

/// Safely setup UI configurations
void _safeSetupUI() {
  try {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    debugPrint('UI setup completed successfully');
  } catch (error) {
    debugPrint('Error setting up UI: $error');
  }
}

/// Force launch the application - this will ALWAYS run
void _forceLaunchApp() {
  try {
    debugPrint('FORCE LAUNCHING APP...');

    // Ensure we have a valid Clarity config
    _clarityConfig ??= ClarityConfig(
      projectId: "toksotegrs",
      userId: "emergency_fallback_${DateTime.now().millisecondsSinceEpoch}",
      logLevel: LogLevel.None,
    );

    runApp(ClarityWidget(app: MyApp(), clarityConfig: _clarityConfig!));

    debugPrint('APP LAUNCHED SUCCESSFULLY!');
  } catch (error, stackTrace) {
    debugPrint('CRITICAL ERROR in force launch: $error');
    debugPrint('Stack trace: $stackTrace');

    // Last resort - launch without Clarity
    try {
      runApp(const MyApp());
      debugPrint('APP LAUNCHED WITHOUT CLARITY!');
    } catch (finalError) {
      debugPrint('FINAL CRITICAL ERROR: $finalError');
      // At this point, create the most basic app possible
      runApp(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('GuROW')),
            body: const Center(child: Text('App launched in emergency mode')),
          ),
        ),
      );
    }
  }
}

/// Initialize Hive database boxes
Future<void> _initHiveBoxes() async {
  try {
    final dbPath = await path.getApplicationDocumentsDirectory();
    Hive.init(dbPath.path);

    // Initialize app services box
    await _initAppServicesBox();
  } catch (error) {
    debugPrint('Error initializing Hive boxes: $error');
  }
}

/// Initialize app services Hive box with default values
Future<void> _initAppServicesBox() async {
  try {
    final box = await Hive.openBox<String>(AppDatabaseKeys.appServicesKey);

    // Check for existing token
    if (box.get(AppDatabaseKeys.tokenKey) != null) {
      debugPrint('Existing token found');
      // Handle existing token logic here
    }

    // Set default locale if not exists
    if (!box.containsKey(AppDatabaseKeys.localeKey)) {
      final deviceLocale = Platform.localeName.substring(0, 2);

      // List of supported locales
      const supportedLocales = ['ar', 'en'];

      // Use device locale if supported, otherwise default to 'en'
      final defaultLocale = supportedLocales.contains(deviceLocale)
          ? deviceLocale
          : 'en';

      box.put(AppDatabaseKeys.localeKey, defaultLocale);
      debugPrint(
        'Set default locale: $defaultLocale (device locale: $deviceLocale)',
      );
    }

    // Set default theme if not exists
    if (!box.containsKey(AppDatabaseKeys.themeKey)) {
      box.put(AppDatabaseKeys.themeKey, "0"); // Default to light theme
      debugPrint('Set default theme: light');
    }
  } catch (error) {
    debugPrint('Error initializing app services box: $error');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BoxEvent>(
      stream: AppServicesDBprovider.listenable(),
      builder: (context, snapshot) {
        return EasyLocalization(
          supportedLocales: const [Locale('en'), Locale('ar')],
          path: 'assets/translations',
          fallbackLocale: const Locale('en'),
          startLocale: Locale(AppServicesDBprovider.currentLocale()),
          useOnlyLangCode: true,
          child: MyMaterialApp(),
        );
      },
    );
  }
}

class MyMaterialApp extends StatefulWidget {
  const MyMaterialApp({super.key});

  @override
  State<MyMaterialApp> createState() => _MyMaterialAppState();
}

class _MyMaterialAppState extends State<MyMaterialApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'الإ ليعبدون',
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      locale: context.locale,
      themeMode: AppServicesDBprovider.isDark()
          ? ThemeMode.dark
          : ThemeMode.light,
      theme: AppServicesDBprovider.isDark()
          ? AppTheme.darkTheme(AppServicesDBprovider.currentLocale())
          : AppTheme.lightTheme(AppServicesDBprovider.currentLocale()),
      routerConfig: AppRouter.router,
    );
  }
}
