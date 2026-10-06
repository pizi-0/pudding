import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pudding/services/di.dart';
import 'package:pudding/utils/jellyfin_item_extensions.dart';
import 'package:pudding/utils/jellyfin_item_extensions/item_operations.dart';

class UserdataRegistryNotifier extends Notifier<Map<String, JellyfinUserData>> {
  final _client = services<JellyfinClient>();

  @override
  Map<String, JellyfinUserData> build() {
    return {};
  }

  void _upsert(String itemId, JellyfinUserData userData) {
    final current = Map<String, JellyfinUserData>.from(state);

    current[itemId] = userData;

    state = current;
  }

  Future<void> toggleFavorite(JellyfinItem item) async {
    try {
      final isFavorite = state[item.id]?.isFavorite ?? item.isFavorite;
      JellyfinUserData data;

      if (isFavorite) {
        data = await _client.userData.unmarkFavorite(item.id);
      } else {
        data = await _client.userData.markFavorite(item.id);
      }

      _upsert(item.id, data);
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> togglePlayed(JellyfinItem item) async {
    try {
      final isPlayed = state[item.id]?.played ?? item.isPlayed;
      JellyfinUserData data;

      if (isPlayed) {
        data = await _client.userData.markUnplayed(item.id);
      } else {
        data = await _client.userData.markPlayed(item.id);
      }

      _upsert(item.id, data);
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> updatePlaybackPosition(
    JellyfinItem item,
    int ticks,
  ) async {
    try {
      final data = await item.updatePlaybackPosition(ticks);
      _upsert(item.id, data);
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}

final userDataRegistryProvider =
    NotifierProvider<UserdataRegistryNotifier, Map<String, JellyfinUserData>>(
      () => UserdataRegistryNotifier(),
    );
