// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/foundation.dart';

class HomeData {
  final List<JellyfinItem> showcaseItem;
  final List<JellyfinView> libraries;
  final List<JellyfinItem> continueWatching;
  final List<JellyfinItem> nextup;

  HomeData({
    this.showcaseItem = const [],
    this.libraries = const [],
    this.continueWatching = const [],
    this.nextup = const [],
  });

  HomeData copyWith({
    List<JellyfinItem>? showcaseItem,
    List<JellyfinView>? libraries,
    List<JellyfinItem>? continueWatching,
    List<JellyfinItem>? nextup,
  }) {
    return HomeData(
      showcaseItem: showcaseItem ?? this.showcaseItem,
      libraries: libraries ?? this.libraries,
      continueWatching: continueWatching ?? this.continueWatching,
      nextup: nextup ?? this.nextup,
    );
  }

  @override
  bool operator ==(covariant HomeData other) {
    if (identical(this, other)) return true;

    return listEquals(other.showcaseItem, showcaseItem) &&
        listEquals(other.libraries, libraries) &&
        listEquals(other.continueWatching, continueWatching) &&
        listEquals(other.nextup, nextup);
  }

  @override
  int get hashCode {
    return showcaseItem.hashCode ^
        libraries.hashCode ^
        continueWatching.hashCode ^
        nextup.hashCode;
  }
}
