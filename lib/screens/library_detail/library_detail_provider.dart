// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pudding/services/di.dart';

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

    final res = await client.items.list(
      parentId: id,
      excludeItemTypes: [JellyfinItemKind.folder],
      includeItemTypes: _includeItemTypes(lib),
    );

    return LibraryData(
      name: lib.name,
      items: res.items,
    );
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
  final List<JellyfinItem> items;

  LibraryData({
    required this.name,
    this.items = const [],
  });

  LibraryData copyWith({
    String? name,
    List<JellyfinItem>? items,
  }) {
    return LibraryData(
      name: name ?? this.name,
      items: items ?? this.items,
    );
  }

  @override
  bool operator ==(covariant LibraryData other) {
    if (identical(this, other)) return true;

    return other.name == name && listEquals(other.items, items);
  }

  @override
  int get hashCode => name.hashCode ^ items.hashCode;
}
