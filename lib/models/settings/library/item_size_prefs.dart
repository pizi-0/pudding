import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class ItemSizePrefs {
  final double posterWidth;
  final double thumbWidth;
  final double squareWidth;

  const new({
    this.posterWidth = mwPoster,
    this.thumbWidth = mwThumb,
    this.squareWidth = mwSquare,
  });

  ItemSizePrefs copyWith({
    double? posterWidth,
    double? thumbWidth,
    double? squareWidth,
  }) {
    return ItemSizePrefs(
      posterWidth: posterWidth ?? this.posterWidth,
      thumbWidth: thumbWidth ?? this.thumbWidth,
      squareWidth: squareWidth ?? this.squareWidth,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'posterWidth': posterWidth,
      'thumbWidth': thumbWidth,
      'squareWidth': squareWidth,
    };
  }

  factory ItemSizePrefs.fromMap(Map<String, dynamic> map) {
    return ItemSizePrefs(
      posterWidth: map['posterWidth'] as double,
      thumbWidth: map['thumbWidth'] as double,
      squareWidth: map['squareWidth'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory ItemSizePrefs.fromJson(String source) =>
      ItemSizePrefs.fromMap(json.decode(source) as Map<String, dynamic>);
}

const double mwPoster = 250;
const double mwThumb = 350;
const double mwSquare = 300;
