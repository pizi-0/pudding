import 'dart:async';

import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pudding/screens/movie_detail/model/movie_screen_state.dart';
import 'package:pudding/services/di.dart';
import 'package:pudding/utils/jellyfin_item_copywith_extension.dart';

//"AirTime" "CanDelete" "CanDownload" "ChannelInfo" "Chapters" "Trickplay" "ChildCount" "CumulativeRunTimeTicks" "CustomRating" "DateCreated" "DateLastMediaAdded" "DisplayPreferencesId" "Etag" "ExternalUrls" "Genres" "ItemCounts" "MediaSourceCount" "MediaSources" "OriginalTitle" "Overview" "ParentId" "Path" "People" "PlayAccess" "ProductionLocations" "ProviderIds" "PrimaryImageAspectRatio" "RecursiveItemCount" "Settings" "SeriesStudio" "SortName" "SpecialEpisodeNumbers" "Studios" "Taglines" "Tags" "RemoteTrailers" "MediaStreams" "SeasonUserData" "DateLastRefreshed" "DateLastSaved" "RefreshState" "ChannelImage" "EnableMediaSourceDisplay" "Width" "Height" "ExtraIds" "LocalTrailerCount" "IsHD" "SpecialFeatureCount"

final fields = [
  'Overview',
  'People',
  'ExternalUrls',
  'Genres',
  'RemoteTrailers',
  'LocalTrailerCount',
];

class MovieStateNotifier extends AsyncNotifier<MovieScreenState> {
  final client = services<JellyfinClient>();

  final String id;
  MovieStateNotifier({required this.id});

  @override
  FutureOr<MovieScreenState> build() {
    return getState();
  }

  Future<MovieScreenState> getState() async {
    state = AsyncLoading();

    state = await AsyncValue.guard(() async {
      final current = state.value ?? MovieScreenState();

      final res = await client.items.list(
        ids: [id],
        fields: fields,
        includeItemTypes: [JellyfinItemKind.movie],
      );

      return current.copyWith(movie: res.items.first);
    });

    return state.value!;
  }

  Future<void> toggleFavorite() async {
    state = AsyncLoading();

    final isfav = state.value!.isFavorite;

    state = await AsyncValue.guard(() async {
      JellyfinUserData newData;
      final current = state.value;

      if (isfav) {
        newData = await client.userData.unmarkFavorite(id);
      } else {
        newData = await client.userData.markFavorite(id);
      }

      return current!.copyWith(
        movie: current.movie!.copyWith(userData: newData),
      );
    });
  }

  Future<void> togglePlayed() async {
    state = AsyncLoading();

    final isplayed = state.value!.isPlayed;

    state = await AsyncValue.guard(() async {
      JellyfinUserData newData;
      final current = state.value;

      if (isplayed) {
        newData = await client.userData.markUnplayed(id);
      } else {
        newData = await client.userData.markPlayed(id);
      }

      return current!.copyWith(
        movie: current.movie!.copyWith(userData: newData),
      );
    });
  }
}

final movieStateProvider =
    AsyncNotifierProvider.family<MovieStateNotifier, MovieScreenState, String>(
      (id) => MovieStateNotifier(id: id),
    );
