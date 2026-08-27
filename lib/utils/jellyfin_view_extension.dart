import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:forui_phosphor/forui_phosphor.dart';
import 'package:pudding/services/di.dart';

extension JellyViewInfo on JellyfinView {
  String getPrimaryImage() {
    return services<JellyfinClient>().images.url(itemId: id);
  }

  Widget getButtonIcon() {
    if (isMovies) {
      return Icon(FPhosphorBoldIcons.filmSlate);
    }

    if (isTvShows) {
      return Icon(FPhosphorBoldIcons.television);
    }

    if (isMusic) {
      return Icon(FPhosphorBoldIcons.musicNote);
    }

    if (isPhotos) {
      return Icon(FPhosphorBoldIcons.image);
    }

    if (isBoxsets) {
      return Icon(FPhosphorBoldIcons.package);
    }

    if (isBooks) {
      return Icon(FPhosphorBoldIcons.book);
    }

    if (isPlaylists) {
      return Icon(FPhosphorBoldIcons.playlist);
    }

    return Icon(FPhosphorBoldIcons.questionMark);
  }

  bool get isBoxsets => collectionType == 'boxsets';
  bool get isPlaylists => collectionType == 'playlists';
  bool get isBooks => collectionType == 'books';
}
