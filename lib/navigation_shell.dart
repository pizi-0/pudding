import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:pudding/const/const.dart';

class MainNavigationShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;
  final List<Widget> children;
  const MainNavigationShell({
    super.key,
    required this.navigationShell,
    required this.children,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final theme = FTheme.of(context);
    final bottomBar = size.width <= theme.breakpoints.md;

    return FScaffold(
      childPad: false,
      child: Column(
        children: [
          Expanded(
            child: AnimatedBranchContainer(
              currentIndex: navigationShell.currentIndex,
              children: children,
            ),
          ),
          AnimatedSwitcher(
            duration: kDefaultAnimationDuration,
            child: bottomBar
                ? FBottomNavigationBar(
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
                  )
                : SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

//from go_router example
class AnimatedBranchContainer extends StatelessWidget {
  const AnimatedBranchContainer({
    super.key,
    required this.currentIndex,
    required this.children,
  });

  final int currentIndex;

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: children.mapIndexed((int index, Widget navigator) {
        return AnimatedOpacity(
          opacity: index == currentIndex ? 1 : 0,
          duration: kDefaultAnimationDuration,
          child: _branchNavigatorWrapper(index, navigator),
        );
      }).toList(),
    );
  }

  Widget _branchNavigatorWrapper(int index, Widget navigator) => IgnorePointer(
    ignoring: index != currentIndex,
    child: TickerMode(enabled: index == currentIndex, child: navigator),
  );
}
