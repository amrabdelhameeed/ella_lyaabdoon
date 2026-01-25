import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:ella_lyaabdoon/features/home/presentation/screens/home_screen.dart';
import 'package:ella_lyaabdoon/features/intro/presentation/intro_screen.dart';
import 'package:ella_lyaabdoon/features/settings/presentation/settings_screen.dart';
import 'package:ella_lyaabdoon/core/services/app_services_database_provider.dart';
import 'package:ella_lyaabdoon/core/constants/app_routes.dart';
import 'package:ella_lyaabdoon/core/services/location_storage.dart';
import 'package:ella_lyaabdoon/features/history/presentation/history_screen.dart';
import 'package:ella_lyaabdoon/features/settings/presentation/screens/location_permission_screen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyRouterObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    Clarity.setCurrentScreenName(route.settings.name ?? "");
    debugPrint('Current route: ${route.settings.name}');
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    debugPrint('Back to route: ${previousRoute?.settings.name}');
  }
}

class AppRouter {
  AppRouter._();
  // Private navigators
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter router = GoRouter(
    observers: [
      MyRouterObserver(),
      FirebaseAnalyticsObserver(
        nameExtractor: (settings) {
          return settings.name;
        },
        analytics: FirebaseAnalytics.instance,
        routeFilter: (_) => true, // Or put your own custom check here
      ), // <-- here
    ],
    // initialExtra: "/",
    // initialLocation: AppRoutes.intro,
    initialLocation: !AppServicesDBprovider.isOpenedBefore()
        ? AppRoutes.intro
        : AppRoutes.home,

    // debugLogDiagnostics: true,
    navigatorKey: _rootNavigatorKey,
    onException: (context, state, router) {},

    redirect: (context, state) async {
      final isIntro = state.matchedLocation == AppRoutes.intro;
      final isLocationPermission =
          state.matchedLocation == AppRoutes.locationPermission;

      if (!AppServicesDBprovider.isOpenedBefore()) {
        return isIntro ? null : AppRoutes.intro;
      }

      final hasLocation = await LocationStorage.hasLocation();
      if (!hasLocation) {
        if (isLocationPermission || isIntro) return null;
        return AppRoutes.locationPermission;
      }

      return null;
    },

    routes: [
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.intro,
        name: AppRoutes.intro,
        builder: (context, state) => IntroScreen(),
      ),

      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.settings,
        name: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
        pageBuilder: defaultPageBuilder(const SettingsScreen()),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.home,
        name: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
        pageBuilder: defaultPageBuilder(const HomeScreen()),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.locationPermission,
        name: AppRoutes.locationPermission,
        builder: (context, state) => const LocationPermissionScreen(),
        pageBuilder: defaultPageBuilder(const LocationPermissionScreen()),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.history,
        name: AppRoutes.history,
        builder: (context, state) => const HistoryScreen(),
        pageBuilder: defaultPageBuilder(const HistoryScreen()),
      ),
    ],
  );
}

CustomTransitionPage _buildPageWithDefaultTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    name: state.name,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

Page<dynamic> Function(BuildContext, GoRouterState) defaultPageBuilder<T>(
  Widget child,
) => (BuildContext context, GoRouterState state) {
  return _buildPageWithDefaultTransition<T>(
    context: context,
    state: state,
    child: child,
  );
};
