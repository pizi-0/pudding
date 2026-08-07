import 'dart:async';

import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pudding/models/series_detail_model.dart';
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

  Future<SeriesDetailModel> _populate({bool refresh = false}) async {
    final jellyCache = ref.read(jellyCacheProvider);
    final seasonCache = ref.read(seasonListCacheProvider);

    bool hasSeries = jellyCache.containsKey(id);
    bool hasSeasons = seasonCache.containsKey(id);

    String? selectedSeason;
    final (series, seasons, nextUp) = await (
      (!hasSeries || refresh)
          ? _getSeriesDetail()
          : Future.value(jellyCache[id]),
      (!hasSeasons || refresh) ? _getSeasons() : Future.value(seasonCache[id]!),
      _getNextUp(),
    ).wait;

    selectedSeason = nextUp?.seasonId ?? seasons.firstOrNull;

    if (selectedSeason != null) {
      await _getSeasonDetail(selectedSeason);
    }

    return SeriesDetailModel(
      seriesId: id,
      seasonIds: seasons,
      selectedSeasonId: selectedSeason,
      nextUp: nextUp?.id ?? '',
    );
  }

  Future<void> refreshData() async {
    state = AsyncLoading();
    state = AsyncValue.data(await _populate(refresh: true));
  }

  Future<JellyfinItem?> _getNextUp() async {
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
  }

  Future<String> _getSeriesDetail() async {
    final res = await client.items.byId(id);

    ref.read(jellyCacheProvider.notifier).addSingle(res!);

    return id;
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

    ref.read(jellyCacheProvider.notifier).addAll(res.items);

    return seasonIds;
  }

  void setSelectedSeason(String seasonId) {
    var currentState = state.value ?? SeriesDetailModel(seriesId: id);
    _getSeasonDetail(seasonId);
    state = AsyncValue.data(currentState.copyWith(selectedSeasonId: seasonId));
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
