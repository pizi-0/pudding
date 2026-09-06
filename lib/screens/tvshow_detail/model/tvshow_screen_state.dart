// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dart_jellyfin/dart_jellyfin.dart';

class TvshowScreenState {
  final JellyfinItem? tvshow;
  final JellyfinItem? nextup;
  final List<JellyfinItem> seasons;
  final List<JellyfinItem> episodes;
  final List<JellyfinItem> similars;
  final JellyfinItem? selectedSeason;

  TvshowScreenState({
    this.tvshow,
    this.nextup,
    this.seasons = const [],
    this.episodes = const [],
    this.similars = const [],
    this.selectedSeason,
  });

  TvshowScreenState copyWith({
    JellyfinItem? tvshow,
    JellyfinItem? nextup,
    List<JellyfinItem>? seasons,
    List<JellyfinItem>? episodes,
    List<JellyfinItem>? similars,
    JellyfinItem? selectedSeason,
  }) {
    return TvshowScreenState(
      tvshow: tvshow ?? this.tvshow,
      nextup: nextup ?? this.nextup,
      seasons: seasons ?? this.seasons,
      episodes: episodes ?? this.episodes,
      similars: similars ?? this.similars,
      selectedSeason: selectedSeason ?? this.selectedSeason,
    );
  }
}
