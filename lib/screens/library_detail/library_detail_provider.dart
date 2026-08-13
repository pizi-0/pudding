// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pudding/models/pudding_display_prefs.dart';

import 'package:pudding/services/di.dart';
import 'package:pudding/utils/jellyfin_display_prefs_extensions.dart';

class LibraryNotifier extends AsyncNotifier<LibraryData> {
  final String id;
  LibraryNotifier({required this.id});
  final client = services<JellyfinClient>();

  @override
  FutureOr<LibraryData> build() async {
    return getLibrary();
  }

  Future<LibraryData> getLibrary() async {
    final lib = ref.read(userviewsProvider)[id]!;

    final (res, displayPrefs) = await (
      client.items.list(
        parentId: id,
        excludeItemTypes: [JellyfinItemKind.folder],
        includeItemTypes: _includeItemTypes(lib),
      ),
      client.displayPreferences.get(
        displayPreferencesId: lib.id,
        client: 'pudding',
      ),
    ).wait;

    return LibraryData(
      name: lib.name,
      items: res.items,
      count: res.totalRecordCount,
      displayPrefs: displayPrefs,
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
      );

      return current.copyWith(items: [...items, ...res.items]);
    });
  }

  Future<void> updateDisplayPrefs(PuddingDisplayPrefs prefs) async {
    state = await AsyncValue.guard(() async {
      final current = state.value!;

      final currentCustom = current.displayPrefs.customPrefs;
      currentCustom.addAll(prefs.toMap());

      final newPrefs = current.displayPrefs.copyWith(
        customPrefs: currentCustom,
      );

      return current.copyWith(displayPrefs: newPrefs);
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
  final JellyfinDisplayPreferences displayPrefs;

  LibraryData({
    required this.name,
    required this.count,
    this.items = const [],
    required this.displayPrefs,
  });

  LibraryData copyWith({
    String? name,
    int? count,
    List<JellyfinItem>? items,
    JellyfinDisplayPreferences? displayPrefs,
  }) {
    return LibraryData(
      name: name ?? this.name,
      count: count ?? this.count,
      items: items ?? this.items,
      displayPrefs: displayPrefs ?? this.displayPrefs,
    );
  }

  @override
  bool operator ==(covariant LibraryData other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.count == count &&
        listEquals(other.items, items) &&
        other.displayPrefs == displayPrefs;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        count.hashCode ^
        items.hashCode ^
        displayPrefs.hashCode;
  }
}
