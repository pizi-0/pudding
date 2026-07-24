// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/foundation.dart';

class HomeData {
  final List<JellyfinItem> showcaseItem;
  final List<JellyfinView> libraries;

  HomeData({this.showcaseItem = const [], this.libraries = const []});

  HomeData copyWith({
    List<JellyfinItem>? showcaseItem,
    List<JellyfinView>? libraries,
  }) {
    return HomeData(
      showcaseItem: showcaseItem ?? this.showcaseItem,
      libraries: libraries ?? this.libraries,
    );
  }

  @override
  bool operator ==(covariant HomeData other) {
    if (identical(this, other)) return true;

    return listEquals(other.showcaseItem, showcaseItem) &&
        listEquals(other.libraries, libraries);
  }

  @override
  int get hashCode => showcaseItem.hashCode ^ libraries.hashCode;
}
