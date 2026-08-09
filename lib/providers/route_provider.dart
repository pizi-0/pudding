import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:go_transitions/go_transitions.dart';
import 'package:pudding/navigation_shell.dart';
import 'package:pudding/screens/auth/auth_provider.dart';
import 'package:pudding/screens/auth/auth_screen.dart';
import 'package:pudding/screens/detail_screens/movies_detail_screen.dart';
import 'package:pudding/screens/home/home.dart';
import 'package:pudding/screens/library_detail/library_detail_screen.dart';
import 'package:pudding/screens/settings/settings.dart';
import 'package:pudding/screens/splash/splash.dart';

import '../screens/detail_screens/tv_detail_screens.dart';

final routeProvider = Provider<GoRouter>(
  (ref) => GoRouter(
    redirect: (context, state) {
      final authState = ref.watch(authStateProvider);

      final matchedLocation = state.matchedLocation;

      switch (authState) {
        case .authd:
          if (matchedLocation == '/login' || matchedLocation == '/splash') {
            return '/';
          }
          return null;
        case .unauthd:
          return '/login';
        default:
          return null;
      }
    },
    initialLocation: '/splash',

    routes: [
      GoRoute(
        name: 'Splash',
        path: '/splash',
        builder: (context, state) => Splash(),
      ),
      GoRoute(
        name: 'Login',
        path: '/login',
        builder: (context, state) => AuthScreen(),
      ),
      GoRoute(
        path: '/library/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          final type = state.uri.queryParameters['type'];

          return LibraryDetail(id: id, type: type);
        },
        pageBuilder: GoTransitions.fade.call,
      ),
      GoRoute(
        name: 'TvShow details',
        path: '/show/:showId',
        builder: (context, state) => TvDetailScreen(
          showId: state.pathParameters['showId'],
        ),
        pageBuilder: GoTransitions.fade.call,
      ),
      GoRoute(
        name: 'Movie details',
        path: '/movie/:movieId',
        builder: (context, state) => MovieDetailScreen(
          movieId: state.pathParameters['movieId'],
        ),
        pageBuilder: GoTransitions.fade.call,
      ),
      StatefulShellRoute(
        builder: (context, state, navigationShell) => navigationShell,
        navigatorContainerBuilder: (context, navigationShell, children) =>
            MainNavigationShell(
              navigationShell: navigationShell,
              children: children,
            ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: 'Home',
                path: '/',
                builder: (context, state) => Home(),
                routes: [],
              ),
            ],
          ),
          // StatefulShellBranch(
          //   routes: [
          //     GoRoute(
          //       name: 'Library',
          //       path: '/library',
          //       builder: (context, state) => Library(),
          //       routes: [
          //         GoRoute(
          //           path: ':id',
          //           builder: (context, state) {
          //             final id = state.pathParameters['id'];

          //             return LibraryDetail(id: id);
          //           },
          //           pageBuilder: GoTransitions.fade.call,
          //         ),
          //       ],
          //     ),
          //   ],
          // ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: 'Settings',
                path: '/settings',
                builder: (context, state) => Settings(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: 'User',
                path: '/user',
                builder: (context, state) => Settings(),
              ),
            ],
          ),
        ],
      ),
    ],
  ),
);
