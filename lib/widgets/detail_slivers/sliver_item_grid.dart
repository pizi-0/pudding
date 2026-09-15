import 'package:awesome_extensions/awesome_extensions.dart'
    show WidgetCommonExtension;
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pudding/const/const.dart';
import 'package:pudding/models/settings/library/user_view_prefs.dart';
import 'package:pudding/providers/settings_provider.dart';
import 'package:pudding/utils/jellyfin_item_extensions.dart';
import 'package:pudding/widgets/media_card.dart';

class SliverItemGrid extends ConsumerWidget {
  final List<JellyfinItem> items;
  final bool showBottom;
  final bool dimPlayed;
  final ViewType viewType;
  final bool shouldReplace;
  const new({
    super.key,
    this.items = const [],
    this.showBottom = false,
    this.dimPlayed = false,
    this.viewType = .poster,
    this.shouldReplace = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(
      settingsProvider.select((s) => s.value!.libraryPrefs),
    );

    return SliverGrid.builder(
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: prefs.itemWidth(viewType).toDouble(),
        childAspectRatio: viewType == .poster
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
            item.push(context, shouldReplace: shouldReplace);
          },
          dimPlayed: dimPlayed ? (item.userData?.played ?? false) : false,
          bottom: AspectRatio(aspectRatio: 16 / 4)
              .showIf(showBottom && viewType != .poster),
        );
      },
    );
  }
}

extension JellyItemNavigator on JellyfinItem {
  void push(BuildContext context, {bool shouldReplace = true}) {
    if (shouldReplace) {
      context.pushReplacement(_destination());
    } else {
      context.push(_destination());
    }
  }

  String _destination() {
    if (isMovie) {
      return '/movie/$id';
    } else if (isSeries) {
      return '/show/$id';
    } else if (isBoxsets) {
      return '/collection/$id';
    } else {
      return '/home';
    }
  }
}
