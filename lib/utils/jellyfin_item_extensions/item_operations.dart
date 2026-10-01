import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/rendering.dart';
import 'package:pudding/services/di.dart';
import 'package:pudding/utils/jellyfin_item_copywith_extension.dart';
import 'package:pudding/utils/jellyfin_item_extensions.dart';

final _client = services<JellyfinClient>();

extension JellyUserDataExtension on JellyfinItem {
  Future<JellyfinItem> setPlayed() async {
    try {
      final data = await _client.userData.markPlayed(id);
      return copyWith(userData: data);
    } catch (e) {
      debugPrint(e.toString());
      return this;
    }
  }

  Future<JellyfinItem> setUnplayed() async {
    try {
      final data = await _client.userData.markUnplayed(id);
      return copyWith(userData: data);
    } catch (e) {
      debugPrint(e.toString());
      return this;
    }
  }

  Future<JellyfinItem> togglePlayed() async {
    if (isPlayed) {
      return await setUnplayed();
    } else {
      return await setPlayed();
    }
  }

  Future<JellyfinItem> setFavorite() async {
    try {
      final data = await _client.userData.markFavorite(id);
      return copyWith(userData: data);
    } catch (e) {
      debugPrint(e.toString());
      return this;
    }
  }

  Future<JellyfinItem> unsetFavorite() async {
    try {
      final data = await _client.userData.unmarkFavorite(id);
      return copyWith(userData: data);
    } catch (e) {
      debugPrint(e.toString());
      return this;
    }
  }

  Future<JellyfinItem> toggleFavorite() async {
    if (isFavorite) {
      return await unsetFavorite();
    } else {
      return await setFavorite();
    }
  }

  Future<void> updatePlaybackPosition(int ticks) async {
    JellyfinUserData data =
        userData ??
        JellyfinUserData(
          playCount: 0,
          isFavorite: isFavorite,
          played: isPlayed,
        );

    await _client.userData.update(
      itemId: id,
      userData: data.copyWith(playbackPositionTicks: ticks),
    );
  }
}

extension JellyUserDataCopy on JellyfinUserData {
  JellyfinUserData copyWith({
    int? playCount,
    bool? isFavorite,
    bool? played,
    DateTime? lastPlayedDate,
    bool? likes,
    int? playbackPositionTicks,
  }) {
    return JellyfinUserData(
      playCount: playCount ?? this.playCount,
      isFavorite: isFavorite ?? this.isFavorite,
      played: played ?? this.played,
      lastPlayedDate: lastPlayedDate ?? this.lastPlayedDate,
      likes: likes ?? this.likes,
      playbackPositionTicks:
          playbackPositionTicks ?? this.playbackPositionTicks,
    );
  }
}
