// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/foundation.dart';

class SeriesDetailModel {
  final List<String> seasonIds;
  final String? selectedSeasonId;
  final String seriesId;
  final String? nextUp;
  final bool showSeriesCast;

  SeriesDetailModel({
    String? selectedSeasonId,
    this.seasonIds = const [],
    this.showSeriesCast = false,
    required this.seriesId,
    this.nextUp,
  }) : selectedSeasonId = selectedSeasonId ?? seasonIds.firstOrNull;

  SeriesDetailModel copyWith({
    List<String>? seasonIds,
    String? selectedSeasonId,
    String? seriesId,
    String? nextUp,
    bool? showSeriesCast,
  }) {
    return SeriesDetailModel(
      seasonIds: seasonIds ?? this.seasonIds,
      selectedSeasonId: selectedSeasonId ?? this.selectedSeasonId,
      seriesId: seriesId ?? this.seriesId,
      nextUp: nextUp ?? this.nextUp,
      showSeriesCast: showSeriesCast ?? this.showSeriesCast,
    );
  }

  @override
  bool operator ==(covariant SeriesDetailModel other) {
    if (identical(this, other)) return true;

    return listEquals(other.seasonIds, seasonIds) &&
        other.selectedSeasonId == selectedSeasonId &&
        other.seriesId == seriesId &&
        other.nextUp == nextUp &&
        other.showSeriesCast == showSeriesCast;
  }

  @override
  int get hashCode {
    return seasonIds.hashCode ^
        selectedSeasonId.hashCode ^
        seriesId.hashCode ^
        nextUp.hashCode ^
        showSeriesCast.hashCode;
  }
}
