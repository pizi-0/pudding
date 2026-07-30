// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pudding/providers/media_cache_provider.dart';
import 'package:pudding/screens/home/models/home_data_model.dart';
import 'package:pudding/screens/home/providers/showcase_provider.dart';

import 'package:pudding/services/di.dart';
import 'package:pudding/utils/list_extensions.dart';

class HomeNotifier extends AsyncNotifier<HomeData> {
  final client = services<JellyfinClient>();
  @override
  FutureOr<HomeData> build() async {
    return await getData();
  }

  Future<HomeData> getData() async {
    final (nextup, latest, libraries, continueWatching, suggestions) = await (
      _getNextUp(limit: 10),
      _getLatest(),
      _getLibraries(),
      _getContinueWatching(),
      _getSuggestions(),
    ).wait;

    final showcase = [
      ...nextup.sublist(0, 5),
      ...latest,
      ...suggestions,
    ].uniqueBy((e) => e.id).toList();

    ref.read(showcaseProvider.notifier).setItem(showcase.first);
    ref.read(mediaCacheProvider.notifier).populateCache(showcase);

    return HomeData(
      showcaseItem: showcase,
      libraries: libraries,
      continueWatching: continueWatching,
      nextup: nextup,
    );
  }

  Future<List<JellyfinItem>> _getNextUp({int limit = 5}) async {
    final res = await client.tvShows.nextUp(
      limit: limit,
      enableResumable: false,
    );

    final items = List<JellyfinItem>.from(res.items);

    List<Future<JellyfinItem?>> refetch = [];

    for (int i = 0; i < items.length; i++) {
      if (items[i].overview == null) {
        refetch.add(client.items.byId(items[i].id));
      }
    }

    final refetched = await Future.wait(refetch);

    for (int i = 0; i < refetched.length; i++) {
      if (refetched[i] == null) continue;

      items.removeAt(i);
      items.insert(i, refetched[i]!);
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
