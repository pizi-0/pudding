import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:pudding/widgets/detail_slivers/sliver_item_grid.dart';
import 'package:pudding/widgets/detail_slivers/sliver_section.dart';

class SliverMultipart extends StatelessWidget {
  final List<JellyfinItem> items;
  const new({super.key, this.items = const []});

  @override
  Widget build(BuildContext context) {
    return SliverSection(
      header: FButton(
        variant: .outline,
        onPress: () {},
        child: Text('Additional parts'),
      ),
      slivers: [
        SliverItemGrid(
          items: items,
        ),
      ],
    );
  }
}
