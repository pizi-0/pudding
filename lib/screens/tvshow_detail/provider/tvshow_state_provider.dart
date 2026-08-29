// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

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
    final (tvshow, nextup, seasons) = await (
      getTvshow(),
      getNextup(),
      getSeasons(),
    ).wait;

    final selectedSeason = seasons.firstWhere(
      (s) => s.id == nextup.seasonId,
      orElse: () => seasons.first,
    );

    final episodes = await getEpisodesForSeason(seasonId: selectedSeason.id);

    return TvshowScreenState(
      tvshow: tvshow,
      nextup: nextup,
      seasons: seasons,
      episodes: episodes,
      selectedSeason: selectedSeason,
    );
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
      final current = state.value;

      final res = await getEpisodesForSeason(seasonId: seasonId);

      return current!.copyWith(
        episodes: res,
        selectedSeason: current.seasons.firstWhere(
          (s) => s.id == seasonId,
          orElse: () => current.seasons.first,
        ),
      );
    });
  }
}

final tvshowStateProvider =
    AsyncNotifierProvider.family<
      TvshowStateNotifier,
      TvshowScreenState,
      String
    >((id) => TvshowStateNotifier(id: id));
