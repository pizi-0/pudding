// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:collection/collection.dart';
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pudding/screens/tvshow_detail/model/tvshow_screen_state.dart';
import 'package:pudding/services/di.dart';

//"AirTime" "CanDelete" "CanDownload" "ChannelInfo" "Chapters" "Trickplay" "ChildCount" "CumulativeRunTimeTicks" "CustomRating" "DateCreated" "DateLastMediaAdded" "DisplayPreferencesId" "Etag" "ExternalUrls" "Genres" "ItemCounts" "MediaSourceCount" "MediaSources" "OriginalTitle" "Overview" "ParentId" "Path" "People" "PlayAccess" "ProductionLocations" "ProviderIds" "PrimaryImageAspectRatio" "RecursiveItemCount" "Settings" "SeriesStudio" "SortName" "SpecialEpisodeNumbers" "Studios" "Taglines" "Tags" "RemoteTrailers" "MediaStreams" "SeasonUserData" "DateLastRefreshed" "DateLastSaved" "RefreshState" "ChannelImage" "EnableMediaSourceDisplay" "Width" "Height" "ExtraIds" "LocalTrailerCount" "IsHD" "SpecialFeatureCount"

final defaultField = [
  'AirtTime',
  'ChildCount',
  'CumulativeRunTimeTicks',
  'CustomRating',
  'ExternalUrls',
  'Genres',
  'Overview',
  'RecursiveItemCount',
  'SeasonUserData',
  'People',
  'LocalTrailerCount',
  'RemoteTrailers',
];

class TvshowStateNotifier extends AsyncNotifier<TvshowScreenState> {
  final client = services<JellyfinClient>();

  final String id;
  TvshowStateNotifier({required this.id});

  @override
  FutureOr<TvshowScreenState> build() {
    return getState();
  }

  Future<TvshowScreenState> getState() async {
    state = await AsyncValue.guard(() async {
      final current = state.value ?? TvshowScreenState();
      final (tvshow, nextup) = await (
        getTvshow(),
        getNextup(),
      ).wait;

      return current.copyWith(tvshow: tvshow, nextup: nextup);
    });

    state = AsyncLoading();

    state = await AsyncValue.guard(() async {
      final current = state.value ?? TvshowScreenState();
      final seasons = await getSeasons();

      final selectedSeason = seasons.firstWhere(
        (s) => s.id == current.nextup?.seasonId,
        orElse: () => seasons.first,
      );

      final episodes = await getEpisodesForSeason(seasonId: selectedSeason.id);

      return current.copyWith(
        seasons: seasons,
        selectedSeason: selectedSeason,
        episodes: episodes,
      );
    });

    return state.value!;
  }

  Future<JellyfinItem> getTvshow() async {
    try {
      final res = await client.items.list(
        ids: [id],
        fields: defaultField,
      );

      if (res.items.isEmpty) {
        throw Exception(
          'getTvshow: \nQuery returns empty. \nid: $id',
        );
      }

      return res.items.first;
    } on Exception catch (_) {
      rethrow;
    }
  }

  Future<JellyfinItem> getNextup() async {
    try {
      final next = await client.tvShows.nextUp(
        seriesId: id,
        enableResumable: true,
        fields: ['Overview'],
      );

      if (next.items.isEmpty) {
        final first = await client.items.list(
          parentId: id,
          fields: ['Overview'],
          includeItemTypes: [JellyfinItemKind.episode],
        );

        if (first.items.isEmpty) {
          if (first.items.isEmpty) {
            throw Exception(
              'getNextup: \nQuery returns empty. \nid: $id',
            );
          }
        }

        return first.items.first;
      }
      return next.items.first;
    } catch (e) {
      throw Exception(['getNextup:', '$e']);
    }
  }

  Future<List<JellyfinItem>> getSeasons() async {
    try {
      final res = await client.tvShows.seasons(
        seriesId: id,
        fields: ['People', 'ChildCount'],
      );

      return res.items;
    } catch (e) {
      throw Exception(['getSeason:', '$e']);
    }
  }

  Future<List<JellyfinItem>> getEpisodesForSeason({
    required String seasonId,
  }) async {
    try {
      final res = await client.items.list(
        parentId: seasonId,
        fields: ['Overview'],
      );

      return res.items;
    } catch (e) {
      throw Exception(['getEpisodesForSeason:', '$e']);
    }
  }

  Future<void> onSeasonChanged(String seasonId) async {
    state = AsyncLoading();
    state = await AsyncValue.guard(() async {
      final current = state.value ?? TvshowScreenState();

      final res = await getEpisodesForSeason(seasonId: seasonId);

      return current.copyWith(
        episodes: res,
        selectedSeason: current.seasons?.firstWhereOrNull(
          (s) => s.id == seasonId,
        ),
      );
    });
  }

  Future<void> toggleSeriesFavorite() async {
    final isfav = state.value?.tvshow?.isFavorite ?? false;

    state = AsyncLoading();
    state = await AsyncValue.guard(() async {
      final current = state.value ?? TvshowScreenState();

      if (isfav) {
        await client.userData.unmarkFavorite(id);
      } else {
        await client.userData.markFavorite(id);
      }

      final tv = await getTvshow();

      return current.copyWith(tvshow: tv);
    });
  }

  Future<void> toggleSeriesPlayed() async {
    final isplayed = state.value?.tvshow?.userData?.played ?? false;

    state = AsyncLoading();
    state = await AsyncValue.guard(() async {
      final current = state.value ?? TvshowScreenState();

      if (isplayed) {
        await client.userData.markUnplayed(id);
      } else {
        await client.userData.markPlayed(id);
      }

      final (tv, eps) = await (
        getTvshow(),
        getEpisodesForSeason(seasonId: state.value!.selectedSeason!.id),
      ).wait;

      return current.copyWith(tvshow: tv, episodes: eps);
    });
  }
}

final tvshowStateProvider =
    AsyncNotifierProvider.family<
      TvshowStateNotifier,
      TvshowScreenState,
      String
    >((id) => TvshowStateNotifier(id: id));
