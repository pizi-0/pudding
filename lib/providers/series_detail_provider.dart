import 'dart:async';

import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pudding/models/series_detail_model.dart';
import 'package:pudding/providers/media_cache_provider.dart';
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
    final mediaCache = ref.read(mediaCacheProvider);
    final seasonCache = ref.read(seasonListCacheProvider);

    bool hasSeries = mediaCache.containsKey(id);
    bool hasSeasons = seasonCache.containsKey(id);

    String? selectedSeason;
    final (series, seasons, nextUp) = await (
      (!hasSeries || refresh)
          ? _getSeriesDetail()
          : Future.value(mediaCache[id]),
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
    final res = await client.tvShows.nextUp(seriesId: id);

    return res.items.firstOrNull;
  }

  Future<String> _getSeriesDetail() async {
    final res = await client.items.byId(id);

    ref.read(mediaCacheProvider.notifier).updateItem(res!);

    return id;
  }

  Future<void> _getSeasonDetail(String seasonId) async {
    final mediaCache = ref.read(mediaCacheProvider);

    if (mediaCache.containsKey(seasonId)) {
      if (mediaCache[seasonId]!.getPeoples().isNotEmpty) {
        return;
      }
    }
    final res = await client.items.byId(seasonId);

    if (res != null) {
      ref.read(mediaCacheProvider.notifier).updateItem(res);
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

    ref.read(mediaCacheProvider.notifier).populateCache(res.items);

    return seasonIds;
  }

  void setSelectedSeason(String seasonId) {
    var currentState = state.value ?? SeriesDetailModel(seriesId: id);
    _getSeasonDetail(seasonId);
    state = AsyncValue.data(currentState.copyWith(selectedSeasonId: seasonId));
  }
}

final seriesDetailProvider = AsyncNotifierProvider.autoDispose
    .family<SeriesDetailNotifier, SeriesDetailModel, String>(
      (id) => SeriesDetailNotifier(id: id),
    );
