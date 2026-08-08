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
    final res = await client.items.list(
      parentId: id,
      includeItemTypes: [JellyfinItemKind.series],
    );

    return LibraryData(items: res.items);
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
  final List<JellyfinItem> items;

  LibraryData({
    this.items = const [],
  });

  LibraryData copyWith({
    List<JellyfinItem>? items,
  }) {
    return LibraryData(
      items: items ?? this.items,
    );
  }

  @override
  bool operator ==(covariant LibraryData other) {
    if (identical(this, other)) return true;

    return listEquals(other.items, items);
  }

  @override
  int get hashCode => items.hashCode;
}
