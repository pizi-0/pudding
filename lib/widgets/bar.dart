import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class Bar extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry padding;
  const Bar({super.key, this.child, this.padding = const .all(10)});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Container(
      decoration: BoxDecoration(color: theme.colors.background.withAlpha(230)),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
