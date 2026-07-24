// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pudding/screens/home/models/home_data_model.dart';

import 'package:pudding/services/di.dart';
import 'package:pudding/utils/list_extensions.dart';

class HomeNotifier extends AsyncNotifier<HomeData> {
  final client = services<JellyfinClient>();
  @override
  FutureOr<HomeData> build() async {
    return await getData();
  }

  Future<HomeData> getData() async {
    final (showcase, libraries, continueWatching) = await (
      _getShowcaseItems(),
      _getLibraries(),
      _getContinueWatching(),
    ).wait;

    return HomeData(
      showcaseItem: showcase,
      libraries: libraries,
      continueWatching: continueWatching,
    );
  }

  Future<List<JellyfinItem>> _getShowcaseItems() async {
    List<Future<List<JellyfinItem>>> futures = [
      _getNextUp(),
      _getLatest(),
      _getSuggestions(),
    ];

    final res = await Future.wait(futures);

    return res.expand((element) => element).uniqueBy((e) => e.id).toList();
  }

  Future<List<JellyfinItem>> _getNextUp({int limit = 5}) async {
    final res = await client.tvShows.nextUp(limit: limit);

    final items = List<JellyfinItem>.from(res.items);

    for (int i = 0; i < items.length; i++) {
      if (items[i].overview == null) {
        final newItem = await client.items.byId(items[i].id);

        if (newItem == null) continue;
        if (newItem.overview == null) continue;

        items.removeAt(i);
        items.insert(i, newItem);
      }
    }

    return items;
  }

  Future<List<JellyfinItem>> _getLatest({int limit = 5}) async {
    final res = await client.items.latest(limit: limit);

    final items = List<JellyfinItem>.from(res);

    for (int i = 0; i < items.length; i++) {
      if (items[i].overview == null) {
        final newItem = await client.items.byId(items[i].id);

        if (newItem == null) continue;
        if (newItem.overview == null) continue;

        items.removeAt(i);
        items.insert(i, newItem);
      }
    }
    return items;
  }

  Future<List<JellyfinItem>> _getSuggestions({int limit = 10}) async {
    final res = await client.suggestions.list(
      limit: limit,
      type: [JellyfinItemKind.movie, JellyfinItemKind.series],
    );

    return res.items;
  }

  Future<List<JellyfinView>> _getLibraries() async {
    final res = await client.userViews.list();

    return res.items;
  }

  Future<List<JellyfinItem>> _getContinueWatching({int limit = 10}) async {
    final res = await client.items.resume(limit: limit);

    return res.items;
  }
}

final homeProvider = AsyncNotifierProvider(() => HomeNotifier());
