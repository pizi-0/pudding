import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/foundation.dart';

class HomeData {
  final List<JellyfinItem> showcaseItem;

  HomeData({this.showcaseItem = const []});

  HomeData copyWith({
    List<JellyfinItem>? showcaseItem,
  }) {
    return HomeData(
      showcaseItem: showcaseItem ?? this.showcaseItem,
    );
  }

  @override
  bool operator ==(covariant HomeData other) {
    if (identical(this, other)) return true;

    return listEquals(other.showcaseItem, showcaseItem);
  }

  @override
  int get hashCode => showcaseItem.hashCode;
}
