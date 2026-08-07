import 'dart:async';

import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pudding/models/series_detail_model.dart';
import 'package:pudding/providers/episodes_list_cache_provider.dart';
import 'package:pudding/providers/jelly_cache_provider.dart';
import 'package:pudding/providers/season_list_cache_provider.dart';
import 'package:pudding/services/di.dart';
import 'package:pudding/utils/jellyfin_item_extensions.dart';

class SeriesDetailNotifier extends AsyncNotifier<SeriesDetailModel> {
  final client = services<JellyfinClient>();
  final String id;

  SeriesDetailNotifier({required this.id});

  @override
  FutureOr<SeriesDetailModel> build() async {
    return _populate();
  }

  late SeriesDetailModel empty = SeriesDetailModel(seriesId: id);

  Future<SeriesDetailModel> _populate({bool refresh = false}) async {
    try {
      String? selectedSeason;
      List<String> episodes = [];

      final (series, seasons, nextUp) = await (
        _getSeriesDetail(refresh: refresh),
        _getSeasons(refresh: refresh),
        _getNextUp(),
      ).wait;

      selectedSeason = nextUp?.seasonId ?? seasons.firstOrNull;

      if (selectedSeason != null) {
        final (_, eps) = await (
          _getSeasonDetail(selectedSeason),
          _getEpisodeForSeason(selectedSeason),
        ).wait;

        episodes = eps;
      }

      return SeriesDetailModel(
        seriesId: id,
        seasonIds: seasons,
        selectedSeasonId: selectedSeason,
        episodesForSeason: episodes,
        nextUp: nextUp?.id,
      );
    } on Exception catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> manualEpisode(String seasonId) async {
    final current = state.value ?? empty;

    state = AsyncValue.data(current.copyWith(selectedSeasonId: seasonId));
    state = AsyncLoading();
    state = await AsyncValue.guard(() async {
      final res = await _getEpisodeForSeason(seasonId);
      return current.copyWith(
        episodesForSeason: res,
        selectedSeasonId: seasonId,
      );
    });
  }

  Future<List<String>> _getEpisodeForSeason(
    String seasonId, {
    bool refresh = false,
  }) async {
    try {
      final cache = ref.read(episodesCacheProvider);

      if (cache.containsKey(seasonId) && !refresh) {
        return cache[seasonId]!;
      }

      final episodes = await client.items.list(
        parentId: seasonId,
        includeItemTypes: [JellyfinItemKind.episode],
      );

      final episodeIds = episodes.items.map((e) => e.id).toList();

      if (episodeIds.isNotEmpty) {
        ref.read(episodesCacheProvider.notifier).add(seasonId, episodeIds);
        ref.read(jellyCacheProvider.notifier).addAll(episodes.items);
      }

      return episodeIds;
    } on Exception catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> manualRefresh() async {
    state = AsyncData(await _populate(refresh: true));
  }

  Future<void> refreshData() async {
    state = AsyncLoading();
    state = AsyncValue.data(await _populate(refresh: true));
  }

  Future<JellyfinItem?> _getNextUp() async {
    try {
      JellyfinItem? item;
      final next = await client.tvShows.nextUp(seriesId: id);

      if (next.items.isEmpty) {
        final firstEpisode = await client.items.list(
          parentId: id,
          limit: 1,
          includeItemTypes: [JellyfinItemKind.episode],
        );

        item = firstEpisode.items.firstOrNull;
      } else {
        item = next.items.firstOrNull;

        if (item != null) {
          if (item.getOverview() == null) {
            final byId = await client.items.byId(item.id);
            item = byId;
          }
        }
      }

      if (item != null) {
        ref.read(jellyCacheProvider.notifier).addSingle(item);
      }

      return item;
    } on Exception catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<String> _getSeriesDetail({bool refresh = false}) async {
    try {
      final cache = ref.read(jellyCacheProvider);

      if (cache.containsKey(id) && !refresh) {
        return id;
      }

      final res = await client.items.byId(id);
      ref.read(jellyCacheProvider.notifier).addSingle(res!);

      return id;
    } on Exception catch (e) {
      if (state.hasValue) {
        return id;
      }

      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> _getSeasonDetail(String seasonId) async {
    final jellyCache = ref.read(jellyCacheProvider);

    if (jellyCache.containsKey(seasonId)) {
      if (jellyCache[seasonId]!.getPeoples().isNotEmpty) {
        return;
      }
    }
    final res = await client.items.byId(seasonId);

    if (res != null) {
      ref.read(jellyCacheProvider.notifier).addSingle(res);
    }
  }

  Future<List<String>> _getSeasons({bool refresh = false}) async {
    try {
      final cache = ref.read(seasonsCacheProvider);

      if (cache.containsKey(id) && !refresh) {
        return cache[id]!;
      }

      final res = await client.items.list(
        parentId: id,
        includeItemTypes: [JellyfinItemKind.season],
      );

      final seasonIds = res.items.map((e) => e.id).toList();

      ref.read(seasonsCacheProvider.notifier).add(id, seasonIds);
      ref.read(jellyCacheProvider.notifier).addAll(res.items);

      return seasonIds;
    } on Exception catch (e) {
      if (state.hasValue) {
        return state.value!.seasonIds;
      }
      debugPrint(e.toString());
      rethrow;
    }
  }

  void setSelectedSeason(String seasonId) {
    _getSeasonDetail(seasonId);
    manualEpisode(seasonId);
  }

  void toggleSeriesCast() {
    var currentState = state.value ?? SeriesDetailModel(seriesId: id);

    state = AsyncValue.data(
      currentState.copyWith(showSeriesCast: !currentState.showSeriesCast),
    );
  }
}

final seriesDetailProvider = AsyncNotifierProvider.autoDispose
    .family<SeriesDetailNotifier, SeriesDetailModel, String>(
      (id) => SeriesDetailNotifier(id: id),
    );
