// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pudding/services/di.dart';

class HomeNotifier extends AsyncNotifier<HomeData> {
  final client = services<JellyfinClient>();
  @override
  FutureOr<HomeData> build() async {
    return await getData();
  }

  Future<HomeData> getData() async {
    final showcase = await _getShowcaseItems();
    return HomeData(showcaseItem: showcase);
  }

  Future<List<JellyfinItem>> _getShowcaseItems() async {
    List<JellyfinItem> res = [...await _getNextUp(), ...await _getLatest()];

    print(res.length);

    return res;
  }

  Future<List<JellyfinItem>> _getNextUp({int limit = 5}) async {
    final res = await client.tvShows.nextUp(limit: limit);

    return res.items;
  }

  Future<List<JellyfinItem>> _getLatest({int limit = 5}) async {
    return await client.items.latest(limit: limit);
  }
}

final homeProvider = AsyncNotifierProvider(() => HomeNotifier());

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
