import 'dart:async';

import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pudding/screens/collection_detail/model/collection_screen_state.dart';
import 'package:pudding/services/di.dart';
import 'package:pudding/utils/jellyfin_item_copywith_extension.dart';

//"AirTime" "CanDelete" "CanDownload" "ChannelInfo" "Chapters" "Trickplay" "ChildCount" "CumulativeRunTimeTicks" "CustomRating" "DateCreated" "DateLastMediaAdded" "DisplayPreferencesId" "Etag" "ExternalUrls" "Genres" "ItemCounts" "MediaSourceCount" "MediaSources" "OriginalTitle" "Overview" "ParentId" "Path" "People" "PlayAccess" "ProductionLocations" "ProviderIds" "PrimaryImageAspectRatio" "RecursiveItemCount" "Settings" "SeriesStudio" "SortName" "SpecialEpisodeNumbers" "Studios" "Taglines" "Tags" "RemoteTrailers" "MediaStreams" "SeasonUserData" "DateLastRefreshed" "DateLastSaved" "RefreshState" "ChannelImage" "EnableMediaSourceDisplay" "Width" "Height" "ExtraIds" "LocalTrailerCount" "IsHD" "SpecialFeatureCount"

class CollectionStateNotifier extends AsyncNotifier<CollectionScreenState> {
  final client = services<JellyfinClient>();

  final String id;

  CollectionStateNotifier({required this.id});

  @override
  FutureOr<CollectionScreenState> build() {
    return getState();
  }

  Future<CollectionScreenState> getState() async {
    state = AsyncLoading();
    state = await AsyncValue.guard(
      () async {
        final current = state.value ?? CollectionScreenState();
        final coll = await getCollection();

        return current.copyWith(collection: coll);
      },
    );

    state = AsyncLoading();
    state = await AsyncValue.guard(() async {
      final current = state.value!;

      final items = await getItems();

      return current.copyWith(items: items);
    });

    return state.value!;
  }

  Future<JellyfinItem> getCollection() async {
    final res = await client.items.list(
      ids: [id],
      fields: ['Overview', 'Studios', 'Genres'],
    );

    return res.items.first;
  }

  Future<List<JellyfinItem>> getItems() async {
    final res = await client.items.list(
      parentId: id,
      recursive: false,
      fields: ['MediaSources', 'CumulativeRunTimeTicks'],
    );

    return res.items;
  }

  Future<void> toggleFavorite() async {
    state = AsyncLoading();

    state = await AsyncValue.guard(() async {
      final current = state.value!;
      final isFav = current.collection?.isFavorite ?? false;
      JellyfinUserData? data = current.collection?.userData;

      if (isFav) {
        final res = await client.userData.unmarkFavorite(id);
        data = res;
      } else {
        final res = await client.userData.markFavorite(id);
        data = res;
      }

      return current.copyWith(
        collection: current.collection!.copyWith(userData: data),
      );
    });
  }

  Future<void> togglePlayed() async {
    state = AsyncLoading();

    state = await AsyncValue.guard(() async {
      final current = state.value!;
      final isPlayed = current.collection?.userData?.played ?? false;
      JellyfinUserData? data = current.collection?.userData;

      if (isPlayed) {
        data = await client.userData.markUnplayed(id);
      } else {
        data = await client.userData.markPlayed(id);
      }

      return current.copyWith(
        collection: current.collection!.copyWith(userData: data),
      );
    });

    state = await AsyncValue.guard(() async {
      final current = state.value!;
      final res = await getItems();

      return current.copyWith(items: res);
    });
  }
}

final collectionStateProvider =
    AsyncNotifierProvider.family<
      CollectionStateNotifier,
      CollectionScreenState,
      String
    >(
      (id) => CollectionStateNotifier(id: id),
    );
