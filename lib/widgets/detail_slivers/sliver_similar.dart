import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:pudding/utils/scroll_to_key_extension.dart';
import 'package:pudding/widgets/detail_slivers/sliver_item_grid.dart';
import 'package:pudding/widgets/detail_slivers/sliver_section.dart';

class SliverSimilar extends StatelessWidget {
  final List<JellyfinItem> items;
  const new({super.key, this.items = const []});

  @override
  Widget build(BuildContext context) {
    final matches = GoRouter.of(context)
        .routerDelegate
        .currentConfiguration
        .matches;

    return SliverSection(
      header: FButton(
        variant: .outline,
        onPress: () {
          if (key is GlobalKey) {
            (key as GlobalKey).scrollToKey();
          }
        },
        child: Text('More like this'),
      ),
      slivers: [
        SliverItemGrid(
          items: items,
          shouldReplace: matches.length > 3,
        ),
      ],
    );
  }
}
