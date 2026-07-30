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
    return await _populate();
  }

  Future<SeriesDetailModel> _populate() async {
    final (series, seasons, episodes) = await (
      _getSeriesDetail(),
      _getSeasons(),
      _getEpisodes(),
    ).wait;

    return SeriesDetailModel(
      seriesId: id,
      seasonIds: seasons.map((e) => e.id).toList(),
      episodeIds: episodes.map((e) => e.id).toList(),
    );
  }

  Future<String> _getSeriesDetail() async {
    final cache = ref.watch(mediaCacheProvider);

    if (cache.containsKey(id)) {
      return cache[id]!.id;
    }

    final res = await client.items.byId(id);

    ref.read(mediaCacheProvider.notifier).updateItem(res!);

    return id;
  }

  Future<List<JellyfinItem>> _getSeasons() async {
    final cache = ref.watch(seasonListCacheProvider);

    if (cache.containsKey(id)) {
      return cache[id]!;
    }

    final res = await client.items.list(parentId: id);

    ref
        .read(seasonListCacheProvider.notifier)
        .addDetail(seriesId: id, seasons: res.items);

    ref.read(mediaCacheProvider.notifier).populateCache(res.items);

    return res.items;
  }

  Future<List<JellyfinItem>> _getEpisodes() async {
    final cache = ref.watch(seasonListCacheProvider);

    if (cache.containsKey(id)) {
      return cache[id]!;
    }

    final res = await client.items.list(
      parentId: state.value?.selectedSeasonId,
    );

    ref
        .read(episodesListCacheProvider.notifier)
        .addEpisodes(
          seasonId: state.value!.selectedSeasonId!,
          episodesIds: res.items.map((e) => e.id).toList(),
        );

    ref.read(mediaCacheProvider.notifier).populateCache(res.items);

    return res.items;
  }

  void setSelectedSeason(String id) {
    var currentState = state.value ?? SeriesDetailModel(seriesId: id);
    state = AsyncValue.data(currentState.copyWith(selectedSeasonId: id));
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
