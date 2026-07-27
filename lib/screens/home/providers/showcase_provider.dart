import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShowcaseNotifier extends Notifier<JellyfinItem?> {
  @override
  JellyfinItem? build() {
    return null;
  }

  void setItem(JellyfinItem item) {
    state = item;
  }

  void clear() {
    state = null;
  }
}

final showcaseProvider = NotifierProvider<ShowcaseNotifier, JellyfinItem?>(
  () => ShowcaseNotifier(),
);
