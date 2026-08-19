// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:dart_jellyfin/dart_jellyfin.dart';

class PuddingDisplayPrefs {
  /// 'poster' (10:16), thumb (16:10)
  String puddingLibraryViewType;

  /// 'maxCrossAxisExtent' for 'poster'
  double puddingMaxPosterWidth;

  /// 'maxCrossAxisExtent' for 'thumb'
  double puddingMaxThumbWidth;

  /// 'maxCrossAxisExtent' for 'square'
  double puddingMaxSquareWidth;

  PuddingDisplayPrefs({
    this.puddingLibraryViewType = vtPoster,
    this.puddingMaxPosterWidth = mwPoster,
    this.puddingMaxThumbWidth = mwThumb,
    this.puddingMaxSquareWidth = mwSquare,
  });

  double get aspectRatio => _aspectRatio();
  double get maxImageWidth => _maxImageWidth();
  String get imageType => _imageType();

  bool get isPoster => puddingLibraryViewType == vtPoster;
  bool get isThumb => puddingLibraryViewType == vtThumb;
  bool get isSquare => puddingLibraryViewType == vtSquare;

  PuddingDisplayPrefs setImageWidth(double width) {
    if (isPoster) {
      return copyWith(puddingMaxPosterWidth: width);
    } else if (isSquare) {
      return copyWith(puddingMaxSquareWidth: width);
    }

    return copyWith(puddingMaxThumbWidth: width);
  }

  PuddingDisplayPrefs setViewType(String type) {
    return copyWith(puddingLibraryViewType: type);
  }

  PuddingDisplayPrefs copyWith({
    String? puddingLibraryViewType,
    double? puddingMaxPosterWidth,
    double? puddingMaxThumbWidth,
    double? puddingMaxSquareWidth,
  }) {
    return PuddingDisplayPrefs(
      puddingLibraryViewType:
          puddingLibraryViewType ?? this.puddingLibraryViewType,
      puddingMaxPosterWidth:
          puddingMaxPosterWidth ?? this.puddingMaxPosterWidth,
      puddingMaxThumbWidth: puddingMaxThumbWidth ?? this.puddingMaxThumbWidth,
      puddingMaxSquareWidth:
          puddingMaxSquareWidth ?? this.puddingMaxSquareWidth,
    );
  }

  Map<String, String> toMap() {
    return <String, String>{
      'puddingLibraryViewType': puddingLibraryViewType,
      'puddingMaxPosterWidth': puddingMaxPosterWidth.toString(),
      'puddingMaxThumbWidth': puddingMaxThumbWidth.toString(),
      'puddingMaxSquareWidth': puddingMaxSquareWidth.toString(),
    };
  }

  factory PuddingDisplayPrefs.fromMap(Map<String, String> map) {
    return PuddingDisplayPrefs(
      puddingLibraryViewType: map['puddingLibraryViewType'] ?? vtPoster,
      puddingMaxPosterWidth:
          double.tryParse(map['puddingMaxPosterWidth'] ?? 'null') ?? mwPoster,
      puddingMaxThumbWidth:
          double.tryParse(map['puddingMaxThumbWidth'] ?? 'null') ?? mwThumb,
      puddingMaxSquareWidth:
          double.tryParse(map['puddingMaxSquareWidth'] ?? 'null') ?? mwSquare,
    );
  }

  String toJson() => json.encode(toMap());

  factory PuddingDisplayPrefs.fromJson(String source) =>
      PuddingDisplayPrefs.fromMap(json.decode(source) as Map<String, String>);

  //

  double _maxImageWidth() {
    if (isPoster) {
      return puddingMaxPosterWidth;
    } else if (isSquare) {
      return puddingMaxSquareWidth;
    }

    return puddingMaxThumbWidth;
  }

  String _imageType() {
    if (isPoster || isSquare) {
      return JellyfinImagesApi.typePrimary;
    }

    return JellyfinImagesApi.typeThumb;
  }

  double _aspectRatio() {
    if (isPoster) {
      return 10 / 16;
    } else if (isSquare) {
      return 1;
    }

    return 16 / 10;
  }

  @override
  bool operator ==(covariant PuddingDisplayPrefs other) {
    if (identical(this, other)) return true;

    return other.puddingLibraryViewType == puddingLibraryViewType &&
        other.puddingMaxPosterWidth == puddingMaxPosterWidth &&
        other.puddingMaxThumbWidth == puddingMaxThumbWidth &&
        other.puddingMaxSquareWidth == puddingMaxSquareWidth;
  }

  @override
  int get hashCode {
    return puddingLibraryViewType.hashCode ^
        puddingMaxPosterWidth.hashCode ^
        puddingMaxThumbWidth.hashCode ^
        puddingMaxSquareWidth.hashCode;
  }
}

const String vtPoster = 'poster';
const String vtThumb = 'thumb';
const String vtSquare = 'square';

const double mwPoster = 250;
const double mwThumb = 350;
const double mwSquare = 300;
