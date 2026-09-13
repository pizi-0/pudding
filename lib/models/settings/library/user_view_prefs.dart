import 'dart:convert';

import 'package:dart_jellyfin/dart_jellyfin.dart';

import '../../../const/const.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class UserViewPrefs {
  final String viewType;

  const new({this.viewType = vtPoster});

  UserViewPrefs copyWith({String? viewType}) {
    return UserViewPrefs(viewType: viewType ?? this.viewType);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'viewType': viewType};
  }

  factory UserViewPrefs.fromMap(Map<String, dynamic> map) {
    return UserViewPrefs(
      viewType: map['viewType'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserViewPrefs.fromJson(String source) =>
      UserViewPrefs.fromMap(json.decode(source) as Map<String, dynamic>);

  double get aspectRatio => _aspectRatio();
  String get imageType => _imageType();

  bool get isPoster => viewType == vtPoster;
  bool get isSquare => viewType == vtSquare;
  bool get isThumb => viewType == vtThumb;

  double _aspectRatio() {
    if (isPoster) {
      return kPosterAspectRatio;
    } else if (isSquare) {
      return 1;
    }

    return kThumbAspectRatio;
  }

  String _imageType() {
    if (isPoster || isSquare) {
      return JellyfinImagesApi.typePrimary;
    }

    return JellyfinImagesApi.typeThumb;
  }
}

const String vtPoster = 'poster';
const String vtThumb = 'thumb';
const String vtSquare = 'square';
