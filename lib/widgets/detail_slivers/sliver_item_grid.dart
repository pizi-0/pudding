import 'package:awesome_extensions/awesome_extensions.dart'
    show WidgetCommonExtension;
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pudding/const/const.dart';
import 'package:pudding/utils/jellyfin_item_extensions.dart';
import 'package:pudding/widgets/media_card.dart';

class SliverItemGrid extends StatelessWidget {
  final List<JellyfinItem> items;
  final bool showBottom;
  final bool dimPlayed;
  final bool isPoster;
  const new({
    super.key,
    this.items = const [],
    this.showBottom = false,
    this.dimPlayed = false,
    this.isPoster = false,
  });

  @override
  Widget build(BuildContext context) {
    return SliverGrid.builder(
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: isPoster ? 250 : 350,
        childAspectRatio: isPoster
            ? kPosterAspectRatio
            : showBottom
            ? 16 / 14
            : kThumbAspectRatio,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return NewMediaCard(
          item: item,
          onPressed: () {
            if (item.isMovie) {
              context.pushReplacement('/movie/${item.id}');
            }
          },
          dimPlayed: dimPlayed ? (item.userData?.played ?? false) : false,
          bottom: AspectRatio(aspectRatio: 16 / 4)
              .showIf(showBottom && !isPoster),
        );
      },
    );
  }
}
