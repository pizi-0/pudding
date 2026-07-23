import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:pudding/services/di.dart';
import 'package:pudding/utils/num_extensions.dart';

extension JellyInfo on JellyfinItem {
  String getTitle() {
    String title = '';

    if (type == JellyfinItemKind.episode) {
      final season = (parentIndexNumber ?? 0).toString().padLeft(2, '0');
      final eps = (indexNumber ?? 0).toString().padLeft(2, '0');

      title = 'S$season: E$eps - $name';
    } else {
      title = name;
    }

    return title;
  }

  String? getOverview() {
    return overview;
  }

  String? getRuntime() {
    return (durationMs ?? 0).toFormattedDuration();
  }

  String getEndsAt(BuildContext context) {
    final playedDurationMs = ((userData?.playbackPositionTicks ?? 0) / 10000);
    final resumable = playedDurationMs != 0;
    final totalDurationMs = durationMs ?? 0;

    if (resumable) {
      return (totalDurationMs - playedDurationMs).toInt().endsAt(context);
    }

    return totalDurationMs.endsAt(context);
  }

  double getPlayProgress() {
    final playedDurationMs = ((userData?.playbackPositionTicks ?? 0) / 10000);
    final totalDurationMs = durationMs ?? 0;

    return (playedDurationMs / totalDurationMs).clamp(0, 1);
  }

  String getLogo() {
    return services<JellyfinClient>().images.url(
      itemId: seriesId ?? id,
      type: JellyfinImagesApi.typeLogo,
    );
  }

  String getBackdrop() {
    return services<JellyfinClient>().images.url(
      itemId: seriesId ?? id,
      type: JellyfinImagesApi.typeBackdrop,
    );
  }

  String getPrimary() {
    return services<JellyfinClient>().images.url(
      itemId: seriesId ?? id,
      type: JellyfinImagesApi.typePrimary,
    );
  }
}
