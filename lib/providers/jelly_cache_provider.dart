import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiver/collection.dart';

class JellyCacheNotifier extends Notifier<LruMap<String, JellyfinItem>> {
  @override
  LruMap<String, JellyfinItem> build() {
    return LruMap(maximumSize: 1000);
  }

  void addAll(List<JellyfinItem> items) {
    final newCache = LruMap<String, JellyfinItem>(maximumSize: 1000);
    newCache.addAll(state);

    for (final i in items) {
      newCache[i.id] = i;
    }

    state = newCache;
  }

  void addSingle(JellyfinItem item) => addAll([item]);
}

final jellyCacheProvider =
    NotifierProvider<JellyCacheNotifier, LruMap<String, JellyfinItem>>(
      () => JellyCacheNotifier(),
    );
