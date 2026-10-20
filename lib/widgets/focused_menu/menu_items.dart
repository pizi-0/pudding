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

extension JellyItemMenus on JellyfinItem {
  FItemGroup headerGroup() {
    return FItemGroup(
      children: [
        FItem.raw(
          child: Text(
            getTitle(),
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
                item: this,
                onToggleFavorite: onToggleFavorite,
              ).expanded(),
              PlayedButton(
                item: this,
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
      onPress: () {},
    );
  }

  FItem playFromHere({required List<JellyfinItem> items}) {
    return FItem(
      prefix: Icon(FPhosphorBoldIcons.play),
      title: Text('Play all from here'),
      onPress: () {},
    );
  }

  FItemGroup playGroup({List<JellyfinItem> playFromList = const []}) {
    return FItemGroup(
      children: [
        play(),
        if (!isSeries && !isBoxsets) playFromHere(items: playFromList),
      ],
    );
  }

  FItem addToCollection() {
    return FItem(
      prefix: Icon(FPhosphorBoldIcons.listPlus),
      title: Text('Add to collection'),
      onPress: () {},
    );
  }

  FItem addToPlaylist() {
    return FItem(
      prefix: Icon(FPhosphorBoldIcons.listPlus),
      title: Text('Add to playlist'),
      onPress: () {},
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
    required FPopoverController controller,
    required UserPolicy policy,
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
