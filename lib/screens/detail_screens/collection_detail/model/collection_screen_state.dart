// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:pudding/utils/jellyfin_item_extensions.dart';
import 'package:pudding/utils/num_extensions.dart';

class CollectionScreenState {
  final JellyfinItem? collection;
  final List<JellyfinItem> items;

  new({this.collection, this.items = const []});

  CollectionScreenState copyWith({
    JellyfinItem? collection,
    List<JellyfinItem>? items,
  }) {
    return CollectionScreenState(
      collection: collection ?? this.collection,
      items: items ?? this.items,
    );
  }

  List<JellyfinItem> get allItems => items;
  List<JellyfinItem> get movies => items.where((e) => e.isMovie).toList();
  List<JellyfinItem> get series => items.where((e) => e.isSeries).toList();
  List<JellyfinItem> get seasons => items.where((e) => e.isSeason).toList();
  List<JellyfinItem> get episodes => items.where((e) => e.isEpisode).toList();
  List<JellyfinItem> get videos => items.where((e) => e.isVideo).toList();

  String get collectionSize =>
      items.fold(0, (val, e) => e.getSize() + val).toLocalizedSize();
}
