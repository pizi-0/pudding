import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiver/collection.dart';

class SeasonsCacheNotifier extends Notifier<LruMap<String, List<String>>> {
  @override
  LruMap<String, List<String>> build() {
    return LruMap(maximumSize: 1000);
  }

  void add(String seriesId, List<String> seasonIds) {
    final newCache = LruMap<String, List<String>>(maximumSize: 1000);
    newCache.addAll(state);

    newCache[seriesId] = seasonIds;
    state = newCache;
  }
}

final seasonsCacheProvider =
    NotifierProvider<SeasonsCacheNotifier, LruMap<String, List<String>>>(
      () => SeasonsCacheNotifier(),
    );
