import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:forui_assets/forui_assets.dart';
import 'package:pudding/services/di.dart';

extension JellyViewInfo on JellyfinView {
  String getPrimaryImage() {
    return services<JellyfinClient>().images.url(itemId: id);
  }

  Widget getButtonIcon() {
    if (isMovies) {
      return Icon(FLucideIcons.film);
    }

    if (isTvShows) {
      return Icon(FLucideIcons.tv);
    }

    if (isMusic) {
      return Icon(FLucideIcons.music);
    }

    if (isPhotos) {
      return Icon(FLucideIcons.image);
    }

    if (isBoxsets) {
      return Icon(FLucideIcons.box);
    }

    if (isBooks) {
      return Icon(FLucideIcons.book);
    }

    if (isPlaylists) {
      return Icon(FLucideIcons.listVideo);
    }

    return Icon(FLucideIcons.fileQuestionMark);
  }

  bool get isBoxsets => collectionType == 'boxsets';
  bool get isPlaylists => collectionType == 'playlists';
  bool get isBooks => collectionType == 'books';
}
