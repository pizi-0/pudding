import 'dart:convert';

import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:pudding/models/jelly_people.dart';
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

  String getSeriesRunYears() {
    final startYear = productionYear?.toString() ?? '';
    final endYear = DateTime.tryParse(raw['EndDate']);
    final status = raw['Status'];

    if (status == 'Continuing') {
      return '$startYear-Present';
    }
    return '$startYear-${endYear?.year ?? ''}';
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

  String getRemaining() {
    final playedDurationMs = ((userData?.playbackPositionTicks ?? 0) / 10000);
    final totalDurationMs = durationMs ?? 0;

    return (totalDurationMs - playedDurationMs).toInt().toFormattedDuration();
  }

  int getSeasonPlayPercentage() {
    final unplayed = raw['UserData']['UnplayedItemCount'] ?? 0;
    final totalEpisodes = childCount ?? 0;

    return ((1 - (unplayed / totalEpisodes)) * 100).floor();
  }

  double getPlayProgress() {
    if (isSeason || isSeries) return 0;

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

  String getThumb() {
    return services<JellyfinClient>().images.url(
      itemId: id,
      type: JellyfinImagesApi.typeThumb,
    );
  }

  String getPrimary() {
    return services<JellyfinClient>().images.url(
      itemId: seriesId ?? id,
      type: JellyfinImagesApi.typePrimary,
    );
  }

  double getSeasonCoverAspectRatio() {
    return (raw['PrimaryImageAspectRatio'] ?? 0.68);
  }

  String getImage({
    String type = JellyfinImagesApi.typePrimary,
  }) {
    return services<JellyfinClient>().images.url(itemId: id, type: type);
  }

  String? getOfficialRating() {
    return raw['OfficialRating'];
  }

  num? getCommunityRating() {
    return raw['CommunityRating'];
  }

  int? getSeasons() {
    return childCount;
  }

  String getRaw() {
    final JsonEncoder encoder = JsonEncoder.withIndent(' ');
    String pretty = encoder.convert(raw);
    return pretty;
  }

  List<JellyPeople> getPeoples() {
    final people = raw['People'] as List<dynamic>;

    return people.map((p) => JellyPeople.fromMap(p)).toList();
  }

  bool get isSeries => type == JellyfinItemKind.series;
  bool get isMovie => type == JellyfinItemKind.movie;
  bool get isEpisode => type == JellyfinItemKind.episode;
  bool get isSeason => type == JellyfinItemKind.season;
  bool get showRuntime =>
      (durationMs != null || durationMs != 0) && (isMovie || isEpisode);
  bool get isResumable => userData?.playbackPositionTicks != 0;
}
