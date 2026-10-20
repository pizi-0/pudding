import 'package:awesome_extensions/awesome_extensions.dart'
    show StyledText, ExpandedExtension;
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:forui/forui.dart';
import 'package:forui_phosphor/forui_phosphor.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pudding/models/jelly_user_policy.dart';
import 'package:pudding/widgets/favorite_button.dart';
import 'package:pudding/widgets/played_button.dart';

import '../../utils/jellyfin_item_extensions.dart';

class MenuBuilder {
  final FPopoverController controller;
  final JellyfinItem item;
  final UserPolicy policy;

  new({required this.controller, required this.item, required this.policy});

  FItemGroup headerGroup() {
    return FItemGroup(
      children: [
        FItem.raw(
          child: Text(
            item.getTitle(),
            maxLines: 2,
          ).bold(),
        ),
      ],
    );
  }

  FItemGroup actionGroup({
    Future<dynamic> Function()? onTogglePlayed,
    Future<dynamic> Function()? onToggleFavorite,
  }) {
    return FItemGroup(
      children: [
        FItem.raw(
          child: Row(
            spacing: 10,
            children: [
              FavoriteButton(
                item: item,
                onToggleFavorite: onToggleFavorite,
              ).expanded(),
              PlayedButton(
                item: item,
                onTogglePlayed: onTogglePlayed,
              ).expanded(),
              FButton.icon(
                onPress: () {},
                child: Icon(FPhosphorBoldIcons.info),
              ).expanded(),
            ],
          ),
        ),
      ],
    );
  }

  FItem play() {
    return FItem(
      prefix: Icon(FPhosphorBoldIcons.play),
      title: Text('Play'),
      onPress: () {
        controller.hide();
      },
    );
  }

  FItem playFromHere({
    required List<JellyfinItem> items,
  }) {
    return FItem(
      prefix: Icon(FPhosphorBoldIcons.play),
      title: Text('Play all from here'),
      onPress: () {
        controller.hide();
      },
    );
  }

  FItemGroup playGroup({
    List<JellyfinItem> playFromList = const [],
  }) {
    return FItemGroup(
      children: [
        play(),
        if (!item.isSeries && !item.isBoxsets)
          playFromHere(items: playFromList),
      ],
    );
  }

  FItem addToCollection() {
    return FItem(
      prefix: Icon(FPhosphorBoldIcons.listPlus),
      title: Text('Add to collection'),
      onPress: () {
        controller.hide();
      },
    );
  }

  FItem addToPlaylist() {
    return FItem(
      prefix: Icon(FPhosphorBoldIcons.listPlus),
      title: Text('Add to playlist'),
      onPress: () {
        controller.hide();
      },
    );
  }

  FItemGroup addToGroup() {
    return FItemGroup(
      children: [
        addToCollection(),
        addToPlaylist(),
      ],
    );
  }

  ///
  ///

  List<FItemGroup> getMenu({
    Future<dynamic> Function()? onTogglePlayed,
    Future<dynamic> Function()? onToggleFavorite,
    List<JellyfinItem> playFromList = const [],
  }) {
    return [
      headerGroup(),
      actionGroup(
        onTogglePlayed: onTogglePlayed,
        onToggleFavorite: onToggleFavorite,
      ),
      playGroup(playFromList: playFromList),
      addToGroup(),
    ];
  }
}
