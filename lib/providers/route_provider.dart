import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pudding/navigation_shell.dart';
import 'package:pudding/screens/auth/auth_provider.dart';
import 'package:pudding/screens/auth/auth_screen.dart';
import 'package:pudding/screens/home/home.dart';
import 'package:pudding/screens/library/library.dart';
import 'package:pudding/screens/settings/settings.dart';
import 'package:pudding/screens/splash/splash.dart';

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
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainNavigationShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: 'Home',
                path: '/',
                builder: (context, state) => Home(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: 'Library',
                path: '/library',
                builder: (context, state) => Library(),
              ),
            ],
          ),
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
