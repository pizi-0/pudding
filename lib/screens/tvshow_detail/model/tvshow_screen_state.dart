// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dart_jellyfin/dart_jellyfin.dart';

class TvshowScreenState {
  final JellyfinItem? tvshow;
  final JellyfinItem? nextup;
  final List<JellyfinItem>? seasons;
  final List<JellyfinItem>? episodes;
  final JellyfinItem? selectedSeason;

  TvshowScreenState({
    this.tvshow,
    this.nextup,
    this.seasons,
    this.episodes,
    this.selectedSeason,
  });

  TvshowScreenState copyWith({
    JellyfinItem? tvshow,
    JellyfinItem? nextup,
    List<JellyfinItem>? seasons,
    List<JellyfinItem>? episodes,
    JellyfinItem? selectedSeason,
  }) {
    return TvshowScreenState(
      tvshow: tvshow ?? this.tvshow,
      nextup: nextup ?? this.nextup,
      seasons: seasons ?? this.seasons,
      episodes: episodes ?? this.episodes,
      selectedSeason: selectedSeason ?? this.selectedSeason,
    );
  }
}
