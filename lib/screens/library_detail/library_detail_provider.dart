// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pudding/models/pudding_display_prefs.dart';
import 'package:pudding/models/pudding_filters.dart';
import 'package:pudding/screens/library_detail/user_views_provider.dart';
import 'package:pudding/services/di.dart';
import 'package:pudding/utils/jellyfin_display_prefs_extensions.dart';

class LibraryNotifier extends AsyncNotifier<LibraryData> {
  final limit = 50;
  final String id;
  LibraryNotifier({required this.id});
  final client = services<JellyfinClient>();

  @override
  FutureOr<LibraryData> build() async {
    return getLibrary();
  }

  Future<void> refresh() async {
    if (state.hasValue) {
      state = AsyncLoading();
      state = await AsyncValue.guard(() async {
        final currentState = state.value;

        final res = await getLibrary(
          limit: currentState?.items.length ?? limit,
        );

        return res;
      });
    }
  }

  Future<LibraryData> getLibrary({int? limit}) async {
    state = AsyncLoading();

    final views = ref.read(userviewsProvider).value!;
    final lib = views[id]!;

    final applied = state.value?.filters ?? PuddingFilters();

    final (res, displayPrefs, next) = await (
      client.items.list(
        parentId: id,
        excludeItemTypes: [JellyfinItemKind.folder],
        includeItemTypes: _includeItemTypes(lib),
        limit: limit ?? this.limit,
        officialRatings: applied.parentalRating,
        filters: applied.filters,
        genres: applied.genres,
        years: applied.years,
        tags: applied.tags,
        fields: [],
      ),
      client.displayPreferences.get(
        displayPreferencesId: lib.id,
        client: 'pudding',
      ),
      _getSuggestions(),
    ).wait;

    return LibraryData(
      name: lib.name,
      items: res.items,
      count: res.totalRecordCount,
      displayPrefs: displayPrefs,
      next: next,
      filters: applied,
    );
  }

  void applyFilter({
    List<String>? filters,
    List<String>? genres,
    List<String>? parentalRating,
    List<int>? years,
    List<String>? tags,
  }) {
    final current = state.value!;
    final currentFilters = current.filters;

    state = AsyncData(
      current.copyWith(
        filters: currentFilters.copyWith(
          filters: filters ?? currentFilters.filters,
          genres: genres ?? currentFilters.genres,
          parentalRating: parentalRating ?? currentFilters.parentalRating,
          years: years ?? currentFilters.years,
          tags: tags ?? currentFilters.tags,
        ),
      ),
    );
  }

  Future<void> getMore() async {
    if (state is AsyncLoading) return;

    state = AsyncLoading();

    state = await AsyncValue.guard(() async {
      final current = state.value!;
      final views = ref.read(userviewsProvider).value!;
      final lib = views[id]!;

      final applied = state.value?.filters ?? PuddingFilters();

      final items = current.items;
      final res = await client.items.list(
        parentId: id,
        startIndex: current.items.length,
        excludeItemTypes: [JellyfinItemKind.folder],
        includeItemTypes: _includeItemTypes(lib),
        officialRatings: applied.parentalRating,
        filters: applied.filters,
        genres: applied.genres,
        years: applied.years,
        tags: applied.tags,
        limit: limit,
        fields: [],
      );

      return current.copyWith(
        items: [...items, ...res.items],
        count: res.totalRecordCount,
      );
    });
  }

  Future<List<JellyfinItem>> _getSuggestions() async {
    List<JellyfinItem> items = [];
    final views = ref.read(userviewsProvider).value!;
    final lib = views[id]!;

    if (lib.isTvShows) {
      final (nextUp, resume, latest) = await (
        client.tvShows.nextUp(parentId: id, limit: 5),
        client.items.resume(parentId: id, limit: 5),
        client.items.latest(
          parentId: id,
          limit: 5,
          includeItemTypes: [JellyfinItemKind.series],
        ),
      ).wait;

      items.addAll([...nextUp.items, ...resume.items, ...latest]);
    } else if (lib.isMovies) {
      final (resume, latest) = await (
        client.items.resume(parentId: id, limit: 5),
        client.items.latest(parentId: id, limit: 5),
      ).wait;

      items.addAll([...resume.items, ...latest]);
    }

    items.sort(
      (a, b) =>
          ((b.userData?.lastPlayedDate ?? b.premiereDate)
                      ?.microsecondsSinceEpoch ??
                  0)
              .compareTo(
                (a.userData?.lastPlayedDate ?? a.premiereDate)
                        ?.microsecondsSinceEpoch ??
                    0,
              ),
    );

    final map = <String, JellyfinItem>{};

    for (final i in items) {
      map[i.id] = i;
    }

    return map.values.toList();
  }

  // Future getFilters() async {
  //   final res = await client.filter.facets(parentId: id);

  //   return res;
  // }

  Future<PuddingFilters> getLegacyFilters() async {
    final res = await client.filter.legacy(parentId: id);

    return PuddingFilters.fromLegacyJelly(res);
  }

  void setMaxImageWidth(double width) {
    final current = state.value!;
    final currentDisplayPrefs = current.displayPrefs;
    Map<String, String> currentCustom = currentDisplayPrefs.customPrefs;
    PuddingDisplayPrefs puddingPrefs = PuddingDisplayPrefs.fromMap(
      currentCustom,
    );

    puddingPrefs = puddingPrefs.setImageWidth(width);

    currentCustom.addAll(puddingPrefs.toMap());

    state = AsyncValue.data(
      current.copyWith(
        displayPrefs: currentDisplayPrefs.copyWith(customPrefs: currentCustom),
      ),
    );
  }

  void setViewType(String type) {
    final current = state.value!;
    final currentDisplayPrefs = current.displayPrefs;
    final currentCustom = currentDisplayPrefs.customPrefs;
    PuddingDisplayPrefs puddingPrefs = PuddingDisplayPrefs.fromMap(
      currentCustom,
    );

    puddingPrefs = puddingPrefs.setViewType(type);

    currentCustom.addAll(puddingPrefs.toMap());

    state = AsyncValue.data(
      current.copyWith(
        displayPrefs: currentDisplayPrefs.copyWith(customPrefs: currentCustom),
      ),
    );
  }

  /// post to server
  Future<void> updateDisplayPrefs() async {
    state = await AsyncValue.guard(() async {
      final current = state.value!;

      await client.displayPreferences.update(
        displayPreferencesId: current.displayPrefs.id!,
        client: current.displayPrefs.client!,
        preferences: current.displayPrefs,
      );

      return current;
    });
  }

  List<String> _includeItemTypes(JellyfinView view) {
    if (view.isTvShows) {
      return [JellyfinItemKind.series];
    } else if (view.isMovies) {
      return [JellyfinItemKind.movie];
    } else {
      return [];
    }
  }
}

final libraryProvider =
    AsyncNotifierProvider.family<LibraryNotifier, LibraryData, String>(
      (id) => LibraryNotifier(id: id),
    );

class LibraryData {
  final String name;
  final int count;
  final List<JellyfinItem> items;
  final List<JellyfinItem> next;
  final JellyfinDisplayPreferences displayPrefs;
  final PuddingFilters filters;

  LibraryData({
    required this.name,
    required this.count,
    this.items = const [],
    required this.next,
    required this.displayPrefs,
    required this.filters,
  });

  LibraryData copyWith({
    String? name,
    int? count,
    List<JellyfinItem>? items,
    List<JellyfinItem>? next,
    JellyfinDisplayPreferences? displayPrefs,
    PuddingFilters? filters,
  }) {
    return LibraryData(
      name: name ?? this.name,
      count: count ?? this.count,
      items: items ?? this.items,
      next: next ?? this.next,
      displayPrefs: displayPrefs ?? this.displayPrefs,
      filters: filters ?? this.filters,
    );
  }

  @override
  bool operator ==(covariant LibraryData other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.count == count &&
        listEquals(other.items, items) &&
        listEquals(other.next, next) &&
        other.displayPrefs == displayPrefs &&
        other.filters == filters;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        count.hashCode ^
        items.hashCode ^
        next.hashCode ^
        displayPrefs.hashCode ^
        filters.hashCode;
  }
}

final filterProvider = FutureProvider.family<PuddingFilters, String>(
  (ref, id) async {
    final res = await services<JellyfinClient>().filter.legacy(parentId: id);

    return PuddingFilters.fromLegacyJelly(res);
  },
);
