// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/foundation.dart';

class SeriesDetailModel {
  final List<String> seasonIds;
  final List<String> episodeIds;
  final String? selectedSeasonId;
  final String seriesId;
  final String? nextUp;

  SeriesDetailModel({
    String? selectedSeasonId,
    this.seasonIds = const [],
    this.episodeIds = const [],
    required this.seriesId,
    String? nextUp,
  }) : selectedSeasonId = selectedSeasonId ?? seasonIds.firstOrNull,
       nextUp = nextUp ?? episodeIds.firstOrNull;

  SeriesDetailModel copyWith({
    List<String>? seasonIds,
    List<String>? episodeIds,
    String? selectedSeasonId,
    String? seriesId,
    String? nextUp,
  }) {
    return SeriesDetailModel(
      seasonIds: seasonIds ?? this.seasonIds,
      episodeIds: episodeIds ?? this.episodeIds,
      selectedSeasonId: selectedSeasonId ?? this.selectedSeasonId,
      seriesId: seriesId ?? this.seriesId,
      nextUp: nextUp ?? this.nextUp,
    );
  }

  @override
  bool operator ==(covariant SeriesDetailModel other) {
    if (identical(this, other)) return true;

    return listEquals(other.seasonIds, seasonIds) &&
        listEquals(other.episodeIds, episodeIds) &&
        other.selectedSeasonId == selectedSeasonId &&
        other.seriesId == seriesId &&
        other.nextUp == nextUp;
  }

  @override
  int get hashCode {
    return seasonIds.hashCode ^
        episodeIds.hashCode ^
        selectedSeasonId.hashCode ^
        seriesId.hashCode ^
        nextUp.hashCode;
  }
}
