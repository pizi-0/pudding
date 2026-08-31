import 'package:flutter/material.dart';
import 'package:pudding/const/const.dart';

class SliverHeader extends SliverPersistentHeaderDelegate {
  final double maxExtentHeight;
  final double minExtentHeight;
  final Widget? title;
  final Widget? suffix;
  final Widget? bar;
  final void Function(double percent)? onScroll;
  final Widget? child;
  final bool shouldRefresh;

  SliverHeader({
    required this.maxExtentHeight,
    required this.minExtentHeight,
    this.title,
    this.suffix,
    this.bar,
    this.onScroll,
    this.child,
    this.shouldRefresh = false,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final percent = shrinkOffset / maxExtent;

    if (onScroll != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onScroll!(percent);
      });
    }

    return Stack(
      clipBehavior: .none,
      fit: StackFit.expand,
      children: [
        if (child != null)
          Positioned(
            bottom: Tween<double>(
              begin: 0,
              end: 0,
            ).transform(percent),
            child: AnimatedOpacity(
              duration: kDefaultAnimationDuration,
              opacity: Tween<double>(
                begin: 1,
                end: 0,
              ).transform(percent > 0.7 ? percent : 0),
              child: child!,
            ),
          ),

        if (bar != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: bar!,
          ),
      ],
    );
  }

  @override
  double get maxExtent => maxExtentHeight;

  @override
  double get minExtent => minExtentHeight;

  @override
  bool shouldRebuild(covariant SliverHeader oldDelegate) {
    return maxExtentHeight != oldDelegate.maxExtentHeight ||
        minExtentHeight != oldDelegate.minExtentHeight ||
        shouldRefresh != oldDelegate.shouldRefresh ||
        child != oldDelegate.child;
  }
}
