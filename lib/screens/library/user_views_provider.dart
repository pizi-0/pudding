import 'dart:async';

import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pudding/services/di.dart';

class UserviewsNotifier extends AsyncNotifier<Map<String, JellyfinView>> {
  final client = services<JellyfinClient>();

  @override
  FutureOr<Map<String, JellyfinView>> build() {
    return getUserviews();
  }

  Future<Map<String, JellyfinView>> getUserviews() async {
    state = await AsyncValue.guard(() async {
      Map<String, JellyfinView> viewMap = {};
      final res = await client.userViews.list();

      for (final view in res.items) {
        viewMap[view.id] = view;
      }

      return viewMap;
    });

    return state.value!;
  }
}

final userviewsProvider =
    AsyncNotifierProvider<UserviewsNotifier, Map<String, JellyfinView>>(
      () => UserviewsNotifier(),
    );
