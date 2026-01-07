import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:ella_lyaabdoon/presentaion/screens/home_screen.dart';
import 'package:ella_lyaabdoon/presentaion/screens/intro_screen.dart';
import 'package:ella_lyaabdoon/presentaion/screens/settings_screen.dart';
import 'package:ella_lyaabdoon/utils/app_services_database_provider.dart';
import 'package:ella_lyaabdoon/utils/constants/app_routes.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  static final _shellNavigatorHome = GlobalKey<NavigatorState>(
    debugLabel: '_shellNavigatorHome',
  );

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
    initialLocation: AppServicesDBprovider.isFirstOpen()
        ? AppRoutes.intro
        : AppRoutes.home,
    // accountCubit.accountList.isEmpty
    //     ? AppRoutesAF.tradingIntro
    //     : AppRoutesAF.homeMiddleWareAf,
    // initialLocation: AppRoutesAF.signUp,
    // initialLocation: AppServicesDBprovider.isFirstOpen()
    //     ? AppRoutes.chooseLang
    //     : FirebaseAuth.instance.currentUser != null
    //         ? AppRoutes.main
    //         : AppRoutes.signIn,
    // debugLogDiagnostics: true,
    navigatorKey: _rootNavigatorKey,
    onException: (context, state, router) {},

    // errorBuilder: (context, state) {
    //   return Scaffold(
    //     body: Center(
    //       child: AppLoadingWidgets.pulse(context),
    //     ),
    //   );
    // },
    routes: [
      // GoRoute(
      //   parentNavigatorKey: _rootNavigatorKey,
      //   path: AppRoutes.splash,
      //   name: AppRoutes.splash,
      //   builder: (context, state) => SplashScreen(key: state.pageKey),
      // ),
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

      // StatefulShellRoute.indexedStack(
      //   // parentNavigatorKey: _rootNavigatorKey,
      //   builder: (context, state, navigationShell) {
      //     return HomeWrapperGuROW(
      //       navigationShell: navigationShell,
      //     );
      //   },
      //   branches: <StatefulShellBranch>[
      //     /// Brach Home
      //     StatefulShellBranch(
      //       initialLocation: AppRoutes.main,
      //       navigatorKey: _shellNavigatorHome,
      //       routes: <RouteBase>[
      //         GoRoute(
      //           path: AppRoutes.main,
      //           name: AppRoutes.main,
      //           builder: (BuildContext context, GoRouterState state) =>
      //               MainScreen(
      //             key: state.pageKey,
      //           ),
      //           routes: [],
      //         ),
      //       ],
      //     ),

      //     StatefulShellBranch(
      //       // initialLocation: AppRoutes.news,
      //       navigatorKey: _shellNavigatorNews,
      //       routes: <RouteBase>[
      //         StatefulShellRoute.indexedStack(
      //             builder: (context, state, navigationShell) {
      //               return NewsScreen(
      //                   children: [], navigationShell: navigationShell);
      //             },
      //             parentNavigatorKey: _shellNavigatorNews,
      //             branches: [
      //               StatefulShellBranch(routes: [
      //                 GoRoute(
      //                   path: AppRoutes.allNews,
      //                   name: AppRoutes.allNews,
      //                   // parentNavigatorKey: _rootNavigatorKey,
      //                   builder: (BuildContext context, GoRouterState state) =>
      //                       AllNews(),
      //                   routes: [
      //                     GoRoute(
      //                       parentNavigatorKey: _shellNavigatorNews,
      //                       path: AppRoutes.newsDetailWithId,
      //                       name: AppRoutes.newsDetailWithId,
      //                       builder:
      //                           (BuildContext context, GoRouterState state) =>
      //                               NewsDetailWithId(
      //                         // key: state.pageKey,
      //                         id: int.parse(
      //                             state.pathParameters['newdetails']!),
      //                         // newsItem: state.extra as New,
      //                       ),
      //                       routes: [],
      //                     ),
      //                     // GoRoute(
      //                     //   parentNavigatorKey: _rootNavigatorKey,
      //                     //   path: AppRoutes.allNewsDetail,
      //                     //   name: AppRoutes.allNewsDetail,
      //                     //   builder: (BuildContext context, GoRouterState state) => NewsDetail(
      //                     //     // key: state.pageKey,
      //                     //     // id: int.parse(state.pathParameters['newdetails']!),
      //                     //     newsItem: state.extra as New,
      //                     //   ),
      //                     //   routes: [],
      //                     // ),
      //                   ],
      //                 ),
      //               ]),
      //               StatefulShellBranch(routes: [
      //                 GoRoute(
      //                   path: AppRoutes.trendingNews,
      //                   name: AppRoutes.trendingNews,
      //                   builder: (BuildContext context, GoRouterState state) =>
      //                       Trending(),
      //                   routes: [
      //                     GoRoute(
      //                       parentNavigatorKey: _shellNavigatorNews,
      //                       path: AppRoutes.trendingNewsDetail,
      //                       name: AppRoutes.trendingNewsDetail,
      //                       builder:
      //                           (BuildContext context, GoRouterState state) =>
      //                               NewsDetail(
      //                         // key: state.pageKey,
      //                         // id: int.parse(state.pathParameters['newdetails']!),
      //                         newsItem: state.extra as NewsModel,
      //                       ),
      //                       routes: [],
      //                     ),
      //                   ],
      //                 ),
      //               ]),
      //               StatefulShellBranch(routes: [
      //                 GoRoute(
      //                   path: AppRoutes.myNews,
      //                   name: AppRoutes.myNews,
      //                   builder: (BuildContext context, GoRouterState state) =>
      //                       MyNews(),
      //                   routes: [
      //                     GoRoute(
      //                       parentNavigatorKey: _shellNavigatorNews,
      //                       path: AppRoutes.myNewsDetail,
      //                       name: AppRoutes.myNewsDetail,
      //                       builder:
      //                           (BuildContext context, GoRouterState state) =>
      //                               NewsDetail(
      //                         // key: state.pageKey,
      //                         // id: int.parse(state.pathParameters['newdetails']!),
      //                         newsItem: state.extra as NewsModel,
      //                       ),
      //                       routes: [],
      //                     ),
      //                   ],
      //                 ),
      //               ]),
      //               StatefulShellBranch(routes: [
      //                 GoRoute(
      //                   path: AppRoutes.interviews,
      //                   name: AppRoutes.interviews,
      //                   builder: (BuildContext context, GoRouterState state) =>
      //                       interviewScreen.Interviews(),
      //                   routes: [
      //                     GoRoute(
      //                       parentNavigatorKey: _shellNavigatorNews,
      //                       path: AppRoutes.interviewDetail,
      //                       name: AppRoutes.interviewDetail,
      //                       builder:
      //                           (BuildContext context, GoRouterState state) =>
      //                               InterviewDetail(
      //                         state.extra as InterviewContent,
      //                         // key: state.pageKey,
      //                       ),
      //                       routes: [],
      //                     ),
      //                   ],
      //                 ),
      //               ]),
      //               StatefulShellBranch(routes: [
      //                 GoRoute(
      //                   path: AppRoutes.expertTalks,
      //                   name: AppRoutes.expertTalks,
      //                   builder: (BuildContext context, GoRouterState state) =>
      //                       opnionScreen.Opinions(),
      //                   routes: [
      //                     GoRoute(
      //                       parentNavigatorKey: _shellNavigatorNews,
      //                       path: AppRoutes.expertTalksDetail,
      //                       name: AppRoutes.expertTalksDetail,
      //                       builder:
      //                           (BuildContext context, GoRouterState state) =>
      //                               OpinionDetail(
      //                         state.extra as OpnionContent,
      //                         // key: state.pageKey,
      //                       ),
      //                       routes: [],
      //                     ),
      //                   ],
      //                 ),
      //               ]),
      //               StatefulShellBranch(routes: [
      //                 GoRoute(
      //                   path: AppRoutes.categoriesNews,
      //                   name: AppRoutes.categoriesNews,
      //                   // parentNavigatorKey: _rootNavigatorKey,
      //                   builder: (BuildContext context, GoRouterState state) =>
      //                       Categories(),
      //                   routes: [
      //                     GoRoute(
      //                       parentNavigatorKey: _rootNavigatorKey,
      //                       path: AppRoutes.categoryDetail,
      //                       name: AppRoutes.categoryDetail,
      //                       builder:
      //                           (BuildContext context, GoRouterState state) =>
      //                               CategoryDetail(
      //                         state.extra as Category,
      //                         // key: state.pageKey,
      //                       ),
      //                       routes: [],
      //                     ),
      //                   ],
      //                 ),
      //               ])
      //             ]),
      //       ],
      //     ),
      //     StatefulShellBranch(navigatorKey: _shellNavigatorAi, routes: [
      //       GoRoute(
      //         path: '/Z',
      //         name: '/Z',
      //         builder: (context, state) => Container(),
      //       )
      //     ]),
      //     StatefulShellBranch(
      //       navigatorKey: _shellNavigatorWatchList,
      //       routes: <RouteBase>[
      //         StatefulShellRoute.indexedStack(
      //           // parentNavigatorKey: _rootNavigatorKey,
      //           builder: (context, state, navigationShell) {
      //             return WatchlistWrapper(
      //               navigationShell: navigationShell,
      //             );
      //           },
      //           branches: <StatefulShellBranch>[
      //             /// Brach Home
      //             StatefulShellBranch(
      //               // initialLocation: AppRoutes.main,
      //               navigatorKey: _shellNavigatorMyWatchlist,
      //               routes: <RouteBase>[
      //                 GoRoute(
      //                   path: AppRoutes.myWatchlists,
      //                   name: AppRoutes.myWatchlists,
      //                   builder: (BuildContext context, GoRouterState state) =>
      //                       MyWatchlist(
      //                           // key: state.pageKey,
      //                           ),
      //                   routes: [],
      //                 ),
      //               ],
      //             ),

      //             StatefulShellBranch(
      //               navigatorKey: _shellNavigatorSectors,
      //               routes: <RouteBase>[
      //                 GoRoute(
      //                   path: AppRoutes.watchlistSectors,
      //                   name: AppRoutes.watchlistSectors,
      //                   builder: (BuildContext context, GoRouterState state) =>
      //                       WatchlistSectors(),
      //                 ),
      //               ],
      //             ),

      //             StatefulShellBranch(
      //               navigatorKey: _shellNavigatorIndecies,
      //               routes: <RouteBase>[
      //                 GoRoute(
      //                   path: AppRoutes.watchlistIndecies,
      //                   name: AppRoutes.watchlistIndecies,
      //                   builder: (BuildContext context, GoRouterState state) =>
      //                       WatchlistIndices(),
      //                   routes: [],
      //                 ),
      //               ],
      //             ),

      //             /// Brach Setting
      //           ],
      //         ),
      //       ],
      //     ),
      //     StatefulShellBranch(
      //       navigatorKey: _shellNavigatorMore,
      //       routes: <RouteBase>[
      //         GoRoute(
      //           path: AppRoutes.more,
      //           name: AppRoutes.more,
      //           builder: (BuildContext context, GoRouterState state) =>
      //               MoreScreen(key: state.pageKey),
      //           routes: [],
      //         ),
      //       ],
      //     ),

      //     /// Brach Setting
      //   ],
      // ),
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
