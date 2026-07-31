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

  Future<SeriesDetailModel> _populate({bool refresh = false}) async {
    final mediaCache = ref.read(mediaCacheProvider);
    final seasonCache = ref.read(seasonListCacheProvider);
    final episodeCache = ref.read(episodesListCacheProvider);

    bool hasSeries = mediaCache.containsKey(id);
    bool hasSeasons = seasonCache.containsKey(id);
    bool hasEpisode = episodeCache.containsKey(id);

    String? selectedSeason;
    final (series, seasons, episodes, nextUp) = await (
      (!hasSeries || refresh)
          ? _getSeriesDetail()
          : Future.value(mediaCache[id]),
      (!hasSeasons || refresh) ? _getSeasons() : Future.value(seasonCache[id]!),
      (!hasEpisode || refresh)
          ? _getEpisodes()
          : Future.value(episodeCache[id]!),
      _getNextUp(),
    ).wait;

    selectedSeason = nextUp?.seasonId ?? seasons.firstOrNull;

    return SeriesDetailModel(
      seriesId: id,
      seasonIds: seasons,
      episodeIds: episodes,
      selectedSeasonId: selectedSeason,
      nextUp: nextUp?.id,
    );
  }

  Future<void> refreshData() async {
    state = AsyncLoading();
    state = AsyncValue.data(await _populate(refresh: true));
  }

  Future<JellyfinItem?> _getNextUp() async {
    final res = await client.tvShows.nextUp(seriesId: id);

    return res.items.firstOrNull;
  }

  Future<String> _getSeriesDetail() async {
    final res = await client.items.byId(id);

    ref.read(mediaCacheProvider.notifier).updateItem(res!);

    return id;
  }

  Future<List<String>> _getSeasons() async {
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
