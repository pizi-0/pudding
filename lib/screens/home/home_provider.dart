// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pudding/screens/home/models/home_data_model.dart';
import 'package:pudding/screens/home/providers/showcase_provider.dart';
import 'package:pudding/screens/library_detail/user_views_provider.dart';

import 'package:pudding/services/di.dart';

//"AirTime" "CanDelete" "CanDownload" "ChannelInfo" "Chapters" "Trickplay" "ChildCount" "CumulativeRunTimeTicks" "CustomRating" "DateCreated" "DateLastMediaAdded" "DisplayPreferencesId" "Etag" "ExternalUrls" "Genres" "ItemCounts" "MediaSourceCount" "MediaSources" "OriginalTitle" "Overview" "ParentId" "Path" "People" "PlayAccess" "ProductionLocations" "ProviderIds" "PrimaryImageAspectRatio" "RecursiveItemCount" "Settings" "SeriesStudio" "SortName" "SpecialEpisodeNumbers" "Studios" "Taglines" "Tags" "RemoteTrailers" "MediaStreams" "SeasonUserData" "DateLastRefreshed" "DateLastSaved" "RefreshState" "ChannelImage" "EnableMediaSourceDisplay" "Width" "Height" "ExtraIds" "LocalTrailerCount" "IsHD" "SpecialFeatureCount"

class HomeNotifier extends AsyncNotifier<HomeData> {
  final client = services<JellyfinClient>();
  @override
  FutureOr<HomeData> build() async {
    return getData();
  }

  Future<HomeData> getData() async {
    final (nextup, libraries, continueWatching, showcase) = await (
      _getNextUp(limit: 10),
      ref.read(userviewsProvider.notifier).getUserviews(),
      _getContinueWatching(),
      _getShowcaseItems(),
    ).wait;

    ref.read(showcaseProvider.notifier).setItem(showcase.first);

    return HomeData(
      showcaseItem: showcase,
      libraries: libraries.values.toList(),
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

  // Future<List<JellyfinItem>> _getLatest({int limit = 5}) async {
  //   final res = await client.items.latest(limit: limit);

  //   final items = List<JellyfinItem>.from(res);

  //   for (int i = 0; i < items.length; i++) {
  //     if (items[i].overview == null) {
  //       final newItem = await client.items.byId(items[i].id);

  //       if (newItem == null) continue;
  //       if (newItem.overview == null) continue;

  //       items.removeAt(i);
  //       items.insert(i, newItem);
  //     }
  //   }
  //   return items;
  // }

  Future<List<JellyfinItem>> _getShowcaseItems({int limit = 20}) async {
    final res = await client.items.list(
      limit: limit,
      sortBy: ['Random'],
      fields: ['Overview', 'Genres', 'ChildCount'],
      includeItemTypes: [JellyfinItemKind.movie, JellyfinItemKind.series],
    );

    return res.items;
  }

  Future<void> refreshShowcase() async {
    state = AsyncLoading();
    state = await AsyncValue.guard(() async {
      final current = state.value ?? HomeData();

      final res = await _getShowcaseItems();

      return current.copyWith(showcaseItem: res);
    });
    ref
        .read(showcaseProvider.notifier)
        .setItem(state.value!.showcaseItem.first);
  }

  Future<List<JellyfinItem>> _getContinueWatching({int limit = 10}) async {
    final res = await client.items.resume(limit: limit, mediaTypes: ['Video']);

    return res.items;
  }
}

final homeProvider = AsyncNotifierProvider(() => HomeNotifier());
