import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class SliverSection extends StatefulWidget {
  final Widget header;
  final List<Widget> slivers;
  const SliverSection({super.key, required this.header, required this.slivers});

  @override
  State<SliverSection> createState() => _SliverSectionState();
}

class _SliverSectionState extends State<SliverSection> {
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return SliverMainAxisGroup(
      slivers: [
        SliverLayoutBuilder(
          builder: (context, constraints) {
            final percent = constraints.overlap / 76;

            return SliverPadding(
              padding: .all(20),
              sliver: PinnedHeaderSliver(
                child: Align(
                  alignment: .centerStart,
                  child: Row(
                    mainAxisSize: .min,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: theme.style.borderRadius.md,
                          boxShadow: [
                            BoxShadow(
                              color: theme.colors.background,
                              spreadRadius: 15 * percent,
                              blurRadius: 15,
                            ),
                          ],
                        ),
                        child: widget.header,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        ...widget.slivers,
      ],
    );
  }
}
