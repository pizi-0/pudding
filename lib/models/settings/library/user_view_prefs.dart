import 'dart:convert';

import 'package:dart_jellyfin/dart_jellyfin.dart';

import '../../../const/const.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class UserViewPrefs {
  final ViewType viewType;

  const new({this.viewType = .poster});

  UserViewPrefs copyWith({
    ViewType? viewType,
  }) {
    return UserViewPrefs(
      viewType: viewType ?? this.viewType,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'viewType': viewType.name,
    };
  }

  factory UserViewPrefs.fromMap(Map<String, dynamic> map) {
    return UserViewPrefs(
      viewType: ViewType.values.firstWhere(
        (v) => v.name == map['viewType'],
        orElse: () => .poster,
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserViewPrefs.fromJson(String source) =>
      UserViewPrefs.fromMap(json.decode(source) as Map<String, dynamic>);

  double get aspectRatio => _aspectRatio();
  String get imageType => _imageType();

  bool get isPoster => viewType == .poster;
  bool get isSquare => viewType == .square;
  bool get isThumb => viewType == .thumb;

  double _aspectRatio() {
    switch (viewType) {
      case .thumb:
        return kThumbAspectRatio;
      case .square:
        return 1;
      default:
        return kPosterAspectRatio;
    }
  }

  String _imageType() {
    switch (viewType) {
      case .poster || .square:
        return JellyfinImagesApi.typePrimary;

      default:
        return JellyfinImagesApi.typeThumb;
    }
  }
}

enum ViewType { poster, thumb, square }
