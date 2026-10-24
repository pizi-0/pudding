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
  final bool isCollection;
  final bool isPlaylist;
  final List<JellyfinItem> playFromList;

  final Future Function()? onTogglePlayed;
  final Future Function()? onToggleFavorite;
  final Future Function()? onRemoved;

  new({
    required this.controller,
    required this.item,
    required this.policy,
    this.isCollection = false,
    this.isPlaylist = false,
    this.onTogglePlayed,
    this.onToggleFavorite,
    this.onRemoved,
    this.playFromList = const [],
  });

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

  FItemGroup actionGroup() {
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

  FItem playFromHere() {
    return FItem(
      prefix: Icon(FPhosphorBoldIcons.play),
      title: Text('Play all from here'),
      onPress: () {
        controller.hide();
      },
    );
  }

  FItemGroup playGroup() {
    return FItemGroup(
      children: [
        play(),
        if (!item.isSeries && !item.isBoxsets) playFromHere(),
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

  FItem removeCollection() {
    return FItem(
      prefix: Icon(FPhosphorBoldIcons.minus),
      title: Text('Remove collection'),
      onPress: () {},
    );
  }

  FItem removeFromCollection() {
    return FItem(
      prefix: Icon(FPhosphorBoldIcons.archiveBox),
      title: Text('Remove from collection'),
      onPress: () {},
    );
  }

  FItem removeFromPlaylist() {
    return FItem(
      title: Text('Remove from playlist'),
      onPress: () {},
    );
  }

  FItem deleteMedia() {
    return FItem(
      variant: .destructive,
      prefix: Icon(FPhosphorBoldIcons.trash),
      title: Text('Delete media'),
      onPress: () {},
    );
  }

  FItemGroup removeGroup() {
    return FItemGroup(
      children: [
        if (item.isBoxsets) removeCollection(),
        if (isCollection) removeFromCollection(),
        if (isPlaylist) removeFromPlaylist(),
      ],
    );
  }

  FItemGroup deleteGroup() {
    return FItemGroup(
      children: [
        if (policy.enableContentDeletion && (!item.isBoxsets)) deleteMedia(),
      ],
    );
  }

  ///
  ///

  List<FItemGroup> getMenu() {
    return [
      headerGroup(),
      actionGroup(),
      playGroup(),
      addToGroup(),
      removeGroup(),
      deleteGroup(),
    ];
  }
}
