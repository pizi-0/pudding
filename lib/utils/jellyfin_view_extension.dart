import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:pudding/services/di.dart';

extension JellyViewInfo on JellyfinView {
  String getPrimaryImage() {
    return services<JellyfinClient>().images.url(itemId: id);
  }

  bool get isBoxsets => collectionType == 'boxsets';
  bool get isPlaylists => collectionType == 'playlists';
  bool get isBooks => collectionType == 'books';
}
