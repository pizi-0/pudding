import 'package:flutter_riverpod/flutter_riverpod.dart';

class EpisodesListCacheNotifier extends Notifier<Map<String, List<String>>> {
  @override
  Map<String, List<String>> build() {
    return {};
  }

  void addEpisodes({
    required String seasonId,
    required List<String> episodesIds,
  }) {
    state = {...state, seasonId: episodesIds};
  }
}

final episodesListCacheProvider =
    NotifierProvider<EpisodesListCacheNotifier, Map<String, List<String>>>(
      () => EpisodesListCacheNotifier(),
    );
