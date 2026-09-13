// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:pudding/const/const.dart';
import 'package:pudding/models/settings/library/item_size_prefs.dart';
import 'package:pudding/models/settings/library/user_view_prefs.dart';

class LibraryPrefs {
  final ItemSizePrefs itemSizePrefs;
  final Map<String, UserViewPrefs> userviewPrefs;

  const new({
    this.itemSizePrefs = const ItemSizePrefs(),
    this.userviewPrefs = const {},
  });

  LibraryPrefs copyWith({
    ItemSizePrefs? itemSizePrefs,
    Map<String, UserViewPrefs>? userviewPrefs,
  }) {
    return LibraryPrefs(
      itemSizePrefs: itemSizePrefs ?? this.itemSizePrefs,
      userviewPrefs: userviewPrefs ?? this.userviewPrefs,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'itemSizePrefs': itemSizePrefs.toMap(),
      'userviewPrefs': userviewPrefs,
    };
  }

  factory LibraryPrefs.fromMap(Map<String, dynamic> map) {
    return LibraryPrefs(
      itemSizePrefs: ItemSizePrefs.fromMap(
        (map['itemSizePrefs'] ?? ItemSizePrefs().toMap())
            as Map<String, dynamic>,
      ),
      userviewPrefs: Map<String, UserViewPrefs>.from(
        ((map['userviewPrefs'] ?? UserViewPrefs().toMap())
            as Map<String, UserViewPrefs>),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory LibraryPrefs.fromJson(String source) =>
      LibraryPrefs.fromMap(json.decode(source) as Map<String, dynamic>);

  ///
  ///

  LibraryPrefs updateViewType(String id, String viewType) {
    Map<String, UserViewPrefs> current = Map<String, UserViewPrefs>.from(
      userviewPrefs,
    );
    final toUpdate = userviewPrefs[id] ?? UserViewPrefs();

    current[id] = toUpdate.copyWith(viewType: viewType);

    return LibraryPrefs(userviewPrefs: current);
  }

  LibraryPrefs updateItemSize(String type, int value) {
    final isPoster = type == vtPoster;
    final isThumb = type == vtThumb;
    final isSquare = type == vtSquare;

    return LibraryPrefs(
      itemSizePrefs: itemSizePrefs.copyWith(
        posterWidth: isPoster ? value : itemSizePrefs.posterWidth,
        thumbWidth: isThumb ? value : itemSizePrefs.thumbWidth,
        squareWidth: isSquare ? value : itemSizePrefs.squareWidth,
      ),
    );
  }

  ///
  ///
  ///

  String viewType(String id) {
    final view = userviewPrefs[id] ?? UserViewPrefs();

    return view.viewType;
  }

  int itemWidth(String id) {
    final size = itemSizePrefs;
    final view = userviewPrefs[id] ?? UserViewPrefs();

    if (view.isThumb) {
      return size.thumbWidth;
    } else if (view.isSquare) {
      return size.thumbWidth;
    } else {
      return size.posterWidth;
    }
  }

  double aspectRatio(String id) {
    final view = userviewPrefs[id] ?? UserViewPrefs();

    if (view.isThumb) {
      return kThumbAspectRatio;
    } else if (view.isSquare) {
      return 1;
    } else {
      return kPosterAspectRatio;
    }
  }

  String imageType(String id) {
    final view = userviewPrefs[id] ?? UserViewPrefs();

    if (view.isPoster || view.isSquare) {
      return JellyfinImagesApi.typePrimary;
    }

    return JellyfinImagesApi.typeThumb;
  }
}
