import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MediaCacheNotifier extends Notifier<Map<String, JellyfinItem>> {
  @override
  Map<String, JellyfinItem> build() {
    return {};
  }

  void populateCache(List<JellyfinItem> items) {
    state = {...state, for (final item in items) item.id: item};
  }

  void updateItem(JellyfinItem item) {
    state = {...state, item.id: item};
  }
}

final mediaCacheProvider =
    NotifierProvider<MediaCacheNotifier, Map<String, JellyfinItem>>(
      () => MediaCacheNotifier(),
    );
