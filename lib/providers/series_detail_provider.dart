import 'dart:async';

import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pudding/models/series_detail_model.dart';
import 'package:pudding/providers/episodes_list_cache_provider.dart';
import 'package:pudding/providers/media_cache_provider.dart';
import 'package:pudding/providers/season_list_cache_provider.dart';
import 'package:pudding/services/di.dart';

class SeriesDetailNotifier extends AsyncNotifier<SeriesDetailModel> {
  final client = services<JellyfinClient>();
  final String id;

  SeriesDetailNotifier({required this.id});

  @override
  FutureOr<SeriesDetailModel> build() async {
    return _populate();
  }

  Future<SeriesDetailModel> _populate() async {
    final (series, seasons, episodes) = await (
      _getSeriesDetail(),
      _getSeasons(),
      _getEpisodes(),
    ).wait;

    return SeriesDetailModel(
      seriesId: id,
      seasonIds: seasons,
      episodeIds: episodes,
    );
  }

  Future<String> _getSeriesDetail() async {
    final cache = ref.read(mediaCacheProvider);

    if (cache.containsKey(id)) {
      return cache[id]!.id;
    }

    final res = await client.items.byId(id);

    ref.read(mediaCacheProvider.notifier).updateItem(res!);

    return id;
  }

  Future<List<String>> _getSeasons() async {
    final cache = ref.read(seasonListCacheProvider);

    if (cache.containsKey(id)) {
      return cache[id]!;
    }

    final res = await client.items.list(
      parentId: id,
      includeItemTypes: [JellyfinItemKind.season],
    );

    final seasonIds = res.items.map((e) => e.id).toList();

    ref
        .read(seasonListCacheProvider.notifier)
        .addDetail(
          seriesId: id,
          seasons: seasonIds,
        );

    ref.read(mediaCacheProvider.notifier).populateCache(res.items);

    return seasonIds;
  }

  Future<List<String>> _getEpisodes() async {
    final cache = ref.read(episodesListCacheProvider);

    if (cache.containsKey(id)) {
      return cache[id]!;
    }

    final res = await client.items.list(
      parentId: id,
      includeItemTypes: [JellyfinItemKind.episode],
    );

    final episodeIds = res.items.map((e) => e.id).toList();

    ref
        .read(episodesListCacheProvider.notifier)
        .addEpisodes(
          seriesId: id,
          episodesIds: episodeIds,
        );

    ref.read(mediaCacheProvider.notifier).populateCache(res.items);

    return episodeIds;
  }

  void setSelectedSeason(String seasonId) {
    var currentState = state.value ?? SeriesDetailModel(seriesId: id);
    state = AsyncValue.data(currentState.copyWith(selectedSeasonId: seasonId));
  }
}

final seriesDetailProvider =
    AsyncNotifierProvider.family<
      SeriesDetailNotifier,
      SeriesDetailModel,
      String
    >(
      (id) => SeriesDetailNotifier(id: id),
    );
