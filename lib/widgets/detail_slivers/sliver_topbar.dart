import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:forui_phosphor/forui_phosphor.dart';
import 'package:pudding/widgets/detail_scaffold.dart';

class SliverTopbar extends StatefulWidget {
  final bool nested;
  final double? extent;
  final Widget? suffix;
  final List<Widget> children;
  final bool showShadowOnPrefix;
  const new({
    super.key,
    this.nested = true,
    this.suffix,
    this.children = const [],
    this.extent,
    this.showShadowOnPrefix = true,
  });

  @override
  State<SliverTopbar> createState() => _SliverTopbarState();
}

class _SliverTopbarState extends State<SliverTopbar> {
  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final offset = constraints.scrollOffset;
        final extent = widget.extent ?? constraints.viewportMainAxisExtent / 2;
        final double percent = (offset / extent).clamp(0, 1);

        return PinnedHeaderSliver(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children:
                  [
                    if (widget.nested) ...[
                      PBackButton(),
                      Icon(FPhosphorBoldIcons.dot),
                    ],
                    Expanded(
                      child: Row(
                        spacing: 10,
                        children: widget.children
                            .map(
                              (c) => Flexible(
                                fit: .loose,
                                child: c.addShadowLerp(context, percent),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    if (widget.suffix != null) ...[
                      Icon(FPhosphorBoldIcons.dot),
                      ?widget.suffix,
                    ],
                  ].addShadowLerp(
                    context,
                    percent,
                    excludedIndex: widget.showShadowOnPrefix ? [] : [0],
                  ),
            ),
          ),
        );
      },
    );
  }
}

extension WidgetShadowLerp on Widget {
  Widget addShadowLerp(BuildContext context, double value) {
    final theme = context.theme;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: theme.style.borderRadius.md,
        boxShadow: [
          BoxShadow(
            color: Color.lerp(
              Colors.transparent,
              theme.colors.background,
              value,
            )!,
            spreadRadius: 10 * value,
            blurRadius: 10,
          ),
        ],
      ),
      child: this,
    );
  }
}

extension WidgetListShadowLerp on List<Widget> {
  List<Widget> addShadowLerp(
    BuildContext context,
    double value, {
    List<int> excludedIndex = const [],
  }) {
    final theme = context.theme;
    return mapIndexed((i, w) {
      if (w is Icon || w is Expanded || excludedIndex.contains(i)) {
        return w;
      }
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: theme.style.borderRadius.md,
          boxShadow: [
            BoxShadow(
              color: Color.lerp(
                Colors.transparent,
                theme.colors.background,
                value,
              )!,
              spreadRadius: 10 * value,
              blurRadius: 10,
            ),
          ],
        ),
        child: w,
      );
    }).toList();
  }
}
