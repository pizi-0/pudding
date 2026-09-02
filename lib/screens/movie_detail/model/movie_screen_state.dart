// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:pudding/models/jelly_people.dart';
import 'package:pudding/utils/jellyfin_item_extensions.dart';

class MovieScreenState {
  final JellyfinItem? movie;
  final List<JellyfinItem> multipart;

  const MovieScreenState({this.movie, this.multipart = const []});

  MovieScreenState copyWith({
    JellyfinItem? movie,
    List<JellyfinItem>? multipart,
  }) {
    return MovieScreenState(
      movie: movie ?? this.movie,
      multipart: multipart ?? this.multipart,
    );
  }

  bool get isResumable => movie!.isResumable;
  bool get isFavorite => movie!.isFavorite;
  bool get isPlayed => movie!.userData?.played ?? false;

  String? get overview => movie!.overview;

  bool get hasLogo => movie!.imageTags.containsKey(JellyfinImagesApi.typeLogo);
  bool get hasPrimary =>
      movie!.imageTags.containsKey(JellyfinImagesApi.typePrimary);
  bool get hasBackdrop =>
      movie!.imageTags.containsKey(JellyfinImagesApi.typeBackdrop);

  String get logo => movie!.getLogo();
  String get primary => movie!.getPrimary();
  String get backdrop => movie!.getBackdrop();

  String get name => movie!.getTitle();
  String? get year => movie!.productionYear?.toString();

  List<String> get genres => movie!.genres;
  bool get hasGenres => genres.isNotEmpty;
  List<String> get genresShort =>
      genres.length > 3 ? genres.sublist(0, 3) : genres;

  List<JellyPeople> get peoples => movie!.getPeoples();
  String? get rating => movie!.getCommunityRating()?.toStringAsFixed(2);
  String? get parentalRating => movie!.getOfficialRating();

  bool get isMultipart => (movie!.raw['PartCount'] ?? 1) > 1;
}
