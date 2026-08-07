import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiver/collection.dart';

class EpisodesCacheNotifier extends Notifier<LruMap<String, List<String>>> {
  @override
  LruMap<String, List<String>> build() {
    return LruMap(maximumSize: 1000);
  }

  void add(String seasonId, List<String> episodeIds) {
    var newCache = LruMap<String, List<String>>(maximumSize: 1000);
    newCache.addAll(state);
    newCache[seasonId] = episodeIds;

    state = newCache;
  }
}

final episodesCacheProvider =
    NotifierProvider<EpisodesCacheNotifier, LruMap<String, List<String>>>(
      () => EpisodesCacheNotifier(),
    );
