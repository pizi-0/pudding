import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SeasonListCacheNotifier
    extends Notifier<Map<String, List<JellyfinItem>>> {
  @override
  Map<String, List<JellyfinItem>> build() {
    return {};
  }

  void addDetail({
    required String seriesId,
    required List<JellyfinItem> seasons,
  }) {
    state = {...state, seriesId: seasons};
  }
}

final seasonListCacheProvider =
    NotifierProvider<SeasonListCacheNotifier, Map<String, List<JellyfinItem>>>(
      () => SeasonListCacheNotifier(),
    );
