import 'dart:convert';

import 'package:dart_jellyfin/dart_jellyfin.dart';

class PuddingDisplayPrefs {
  /// 'poster' (10:16), thumb (16:10)
  String puddingLibraryViewType;

  /// 'maxCrossAxisExtent' for 'poster'
  String puddingMaxPosterWidth;

  /// 'maxCrossAxisExtent' for 'thumb'
  String puddingMaxThumbWidth;

  PuddingDisplayPrefs({
    required this.puddingLibraryViewType,
    required this.puddingMaxPosterWidth,
    required this.puddingMaxThumbWidth,
  });

  double get aspectRatio => _aspectRatio();
  double get maxImageWidth => _maxImageWidth();
  String get imageType => _imageType();

  bool get isPoster => puddingLibraryViewType == 'poster';

  PuddingDisplayPrefs setImageWidth(double width) {
    if (isPoster) {
      return copyWith(puddingMaxPosterWidth: width.toString());
    }

    return copyWith(puddingMaxThumbWidth: width.toString());
  }

  PuddingDisplayPrefs setViewType(String type) {
    return copyWith(puddingLibraryViewType: type);
  }

  PuddingDisplayPrefs copyWith({
    String? puddingLibraryViewType,
    String? puddingMaxPosterWidth,
    String? puddingMaxThumbWidth,
  }) {
    return PuddingDisplayPrefs(
      puddingLibraryViewType:
          puddingLibraryViewType ?? this.puddingLibraryViewType,
      puddingMaxPosterWidth:
          puddingMaxPosterWidth ?? this.puddingMaxPosterWidth,
      puddingMaxThumbWidth: puddingMaxThumbWidth ?? this.puddingMaxThumbWidth,
    );
  }

  Map<String, String> toMap() {
    return <String, String>{
      'puddingLibraryViewType': puddingLibraryViewType,
      'puddingMaxPosterWidth': puddingMaxPosterWidth,
      'puddingMaxThumbWidth': puddingMaxThumbWidth,
    };
  }

  factory PuddingDisplayPrefs.fromMap(Map<String, String> map) {
    return PuddingDisplayPrefs(
      puddingLibraryViewType: map['puddingLibraryViewType'] ?? 'poster',
      puddingMaxPosterWidth: map['puddingMaxPosterWidth'] ?? '250',
      puddingMaxThumbWidth: map['puddingMaxThumbWidth'] ?? '350',
    );
  }

  String toJson() => json.encode(toMap());

  factory PuddingDisplayPrefs.fromJson(String source) =>
      PuddingDisplayPrefs.fromMap(json.decode(source) as Map<String, String>);

  //

  double _maxImageWidth() {
    if (isPoster) {
      return double.tryParse(puddingMaxPosterWidth) ?? 250;
    }

    return double.tryParse(puddingMaxThumbWidth) ?? 350;
  }

  String _imageType() {
    if (isPoster) {
      return JellyfinImagesApi.typePrimary;
    }

    return JellyfinImagesApi.typeThumb;
  }

  double _aspectRatio() {
    if (isPoster) {
      return 10 / 16;
    }

    return 16 / 10;
  }
}
