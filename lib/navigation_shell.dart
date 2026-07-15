import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:pudding/const/const.dart';

class MainNavigationShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;
  const MainNavigationShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final isLandscape = size.width >= size.height;

    return FScaffold(
      child: Column(
        children: [
          Expanded(child: navigationShell),
          AnimatedSwitcher(
            duration: kDefaultAnimationDuration,
            child: isLandscape
                ? SizedBox.shrink()
                : FBottomNavigationBar(
                    index: navigationShell.currentIndex,
                    onChange: (value) {
                      navigationShell.goBranch(
                        value,
                        initialLocation: value == navigationShell.currentIndex,
                      );
                    },
                    children: [
                      FBottomNavigationBarItem(
                        icon: Icon(FLucideIcons.home),
                      ),
                      FBottomNavigationBarItem(
                        icon: Icon(FLucideIcons.library),
                      ),
                      FBottomNavigationBarItem(
                        icon: Icon(FLucideIcons.settings),
                      ),
                      FBottomNavigationBarItem(
                        icon: Icon(FLucideIcons.user),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
