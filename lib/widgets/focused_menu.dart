import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class FocusedMenu extends StatefulWidget {
  final List<FItemGroupMixin>? menu;
  final Widget Function(BuildContext, FPopoverController, Widget?) builder;

  const FocusedMenu({
    super.key,
    this.menu,
    required this.builder,
  });

  @override
  State<FocusedMenu> createState() => _FocusedMenuState();
}

class _FocusedMenuState extends State<FocusedMenu>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final borderRadius = theme.style.borderRadius.sm;

    return FPopoverMenu(
      menu: widget.menu,
      cutout: true,
      faded: false,
      menuAnchor: .topLeft,
      childAnchor: .topRight,
      style: .delta(
        tileGroupStyle: .delta(childPadding: .value(.all(100))),
        itemGroupStyle: .delta(
          itemStyles: .delta([
            .all(
              .delta(
                contentDecoration: .delta([
                  .all(.boxDelta(borderRadius: borderRadius)),
                ]),
                contentStyle: .delta(unsuffixedPadding: .value(.all(10))),
              ),
            ),
          ]),
        ),
        barrierFilter: () =>
            (animation) => ImageFilter.compose(
              outer: ImageFilter.blur(
                sigmaX: animation * 0,
                sigmaY: animation * 0,
              ),
              inner: ColorFilter.mode(
                Color.lerp(
                  const Color(0x00000000),
                  Colors.black.withAlpha(200),
                  animation,
                )!,
                BlendMode.srcOver,
              ),
            ),
      ),
      cutoutBuilder: (path, bounds) => path.addRRect(
        RRect.fromRectAndRadius(
          bounds,
          borderRadius.bottomLeft,
        ),
      ),
      builder: widget.builder,
    );
  }
}
