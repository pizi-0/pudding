import 'package:flutter/material.dart';

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
    return SliverMainAxisGroup(
      slivers: [
        SliverLayoutBuilder(
          builder: (context, constraints) {
            return PinnedHeaderSliver(
              child: widget.header,
            );
          },
        ),
        ...widget.slivers,
      ],
    );
  }
}
