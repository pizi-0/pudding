import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:pudding/widgets/detail_slivers/sliver_item_grid.dart';
import 'package:pudding/widgets/detail_slivers/sliver_section.dart';

class SliverCollections extends StatelessWidget {
  final List<JellyfinItem> items;
  const new({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return SliverSection(
      header: FButton(
        variant: .outline,
        onPress: () {},
        child: Text('Collections'),
      ),
      slivers: [
        SliverItemGrid(
          items: items,
          shouldReplace: false,
        ),
      ],
    );
  }
}
