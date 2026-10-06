import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:pudding/services/di.dart';
import 'package:pudding/utils/jellyfin_item_extensions.dart';

final _client = services<JellyfinClient>();

extension JellyUserDataExtension on JellyfinItem {
  Future<JellyfinUserData> setPlayed() async {
    try {
      return await _client.userData.markPlayed(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<JellyfinUserData> setUnplayed() async {
    try {
      return await _client.userData.markUnplayed(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<JellyfinUserData> setFavorite() async {
    try {
      return await _client.userData.markFavorite(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<JellyfinUserData> unsetFavorite() async {
    try {
      return await _client.userData.unmarkFavorite(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<JellyfinUserData> updatePlaybackPosition(int ticks) async {
    JellyfinUserData data =
        userData ??
        JellyfinUserData(
          playCount: 0,
          isFavorite: isFavorite,
          played: isPlayed,
        );

    try {
      if (!isPlayed) {
        return await _client.userData.update(
          itemId: id,
          userData: data.copyWith(playbackPositionTicks: ticks),
        );
      } else {
        return await setPlayed();
      }
    } on Exception catch (_) {
      rethrow;
    }
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
