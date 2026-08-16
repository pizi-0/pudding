// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pudding/models/pudding_display_prefs.dart';
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

  Future<LibraryData> getLibrary() async {
    final lib = ref.read(userviewsProvider)[id]!;

    final (res, displayPrefs, next) = await (
      client.items.list(
        parentId: id,
        excludeItemTypes: [JellyfinItemKind.folder],
        includeItemTypes: _includeItemTypes(lib),
        limit: limit,
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
    );
  }

  Future<void> getMore() async {
    if (state is AsyncLoading) return;

    final current = state.value!;
    final lib = ref.read(userviewsProvider)[id]!;

    state = AsyncLoading();

    state = await AsyncValue.guard(() async {
      final items = current.items;
      final res = await client.items.list(
        parentId: id,
        startIndex: current.items.length,
        excludeItemTypes: [JellyfinItemKind.folder],
        includeItemTypes: _includeItemTypes(lib),
        limit: limit,
      );

      return current.copyWith(items: [...items, ...res.items]);
    });
  }

  Future<List<JellyfinItem>> _getSuggestions() async {
    List<JellyfinItem> items = [];
    final lib = ref.read(userviewsProvider)[id]!;

    if (lib.isTvShows) {
      final (nextUp, resume) = await (
        client.tvShows.nextUp(parentId: id, limit: 5),
        client.items.resume(parentId: id, limit: 5),
      ).wait;

      items.addAll([...nextUp.items, ...resume.items]);
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

class UserviewsNotifier extends Notifier<Map<String, JellyfinView>> {
  @override
  Map<String, JellyfinView> build() {
    return {};
  }

  void addAll(List<JellyfinView> libraries) {
    state = {...state, for (final l in libraries) l.id: l};
  }
}

final userviewsProvider =
    NotifierProvider<UserviewsNotifier, Map<String, JellyfinView>>(
      () => UserviewsNotifier(),
    );

class LibraryData {
  final String name;
  final int count;
  final List<JellyfinItem> items;
  final List<JellyfinItem> next;
  final JellyfinDisplayPreferences displayPrefs;

  LibraryData({
    required this.name,
    required this.count,
    this.items = const [],
    required this.next,
    required this.displayPrefs,
  });

  LibraryData copyWith({
    String? name,
    int? count,
    List<JellyfinItem>? items,
    List<JellyfinItem>? next,
    JellyfinDisplayPreferences? displayPrefs,
  }) {
    return LibraryData(
      name: name ?? this.name,
      count: count ?? this.count,
      items: items ?? this.items,
      next: next ?? this.next,
      displayPrefs: displayPrefs ?? this.displayPrefs,
    );
  }

  @override
  bool operator ==(covariant LibraryData other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.count == count &&
        listEquals(other.items, items) &&
        listEquals(other.next, next) &&
        other.displayPrefs == displayPrefs;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        count.hashCode ^
        items.hashCode ^
        next.hashCode ^
        displayPrefs.hashCode;
  }
}
