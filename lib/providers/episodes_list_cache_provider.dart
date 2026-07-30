import 'package:flutter_riverpod/flutter_riverpod.dart';

class EpisodesListCacheNotifier extends Notifier<Map<String, List<String>>> {
  @override
  Map<String, List<String>> build() {
    return {};
  }

  void addEpisodes({
    required String seriesId,
    required List<String> episodesIds,
  }) {
    state = {...state, seriesId: episodesIds};
  }
}

final episodesListCacheProvider =
    NotifierProvider<EpisodesListCacheNotifier, Map<String, List<String>>>(
      () => EpisodesListCacheNotifier(),
    );
