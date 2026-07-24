// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/foundation.dart';

class HomeData {
  final List<JellyfinItem> showcaseItem;
  final List<JellyfinView> libraries;
  final List<JellyfinItem> continueWatching;

  HomeData({
    this.showcaseItem = const [],
    this.libraries = const [],
    this.continueWatching = const [],
  });

  HomeData copyWith({
    List<JellyfinItem>? showcaseItem,
    List<JellyfinView>? libraries,
    List<JellyfinItem>? continueWatching,
  }) {
    return HomeData(
      showcaseItem: showcaseItem ?? this.showcaseItem,
      libraries: libraries ?? this.libraries,
      continueWatching: continueWatching ?? this.continueWatching,
    );
  }

  @override
  bool operator ==(covariant HomeData other) {
    if (identical(this, other)) return true;

    return listEquals(other.showcaseItem, showcaseItem) &&
        listEquals(other.libraries, libraries) &&
        listEquals(other.continueWatching, continueWatching);
  }

  @override
  int get hashCode =>
      showcaseItem.hashCode ^ libraries.hashCode ^ continueWatching.hashCode;
}
