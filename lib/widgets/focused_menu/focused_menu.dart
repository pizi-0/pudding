import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:pudding/models/jelly_user_policy.dart';
import 'package:pudding/screens/auth/auth_provider.dart';

class FocusedMenu extends ConsumerStatefulWidget {
  final List<FItemGroupMixin> Function(
    FPopoverController controller,
    UserPolicy policy,
  )?
  menuBuilder;
  final Widget Function(
    bool shown,
    FPopoverController control,
    Widget? child,
  )
  builder;

  const FocusedMenu({
    super.key,
    this.menuBuilder,
    required this.builder,
  });

  @override
  ConsumerState<FocusedMenu> createState() => _FocusedMenuState();
}

class _FocusedMenuState extends ConsumerState<FocusedMenu>
    with SingleTickerProviderStateMixin {
  bool shown = false;
  late final FPopoverController controller = FPopoverController(vsync: this);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final borderRadius = theme.style.borderRadius.sm;
    final user = ref.watch(authProvider).value;
    final policy = UserPolicy.fromMap(user?.raw['Policy'] ?? {});

    return FPopoverMenu(
      control: .managed(
        controller: controller,
        onChange: (b) {
          shown = b;
          setState(() {});
        },
      ),
      menu: widget.menuBuilder == null
          ? []
          : widget.menuBuilder!(controller, policy),
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
            (context, animation) => ImageFilter.compose(
              outer: ImageFilter.blur(
                sigmaX: animation * 5,
                sigmaY: animation * 5,
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
      builder: (context, controller, child) =>
          widget.builder(shown, controller, child),
    );
  }
}
