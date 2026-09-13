import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class ItemSizePrefs {
  final int posterWidth;
  final int thumbWidth;
  final int squareWidth;

  const new({
    this.posterWidth = mwPoster,
    this.thumbWidth = mwThumb,
    this.squareWidth = mwSquare,
  });

  ItemSizePrefs copyWith({
    int? posterWidth,
    int? thumbWidth,
    int? squareWidth,
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
      posterWidth: map['posterWidth'] as int,
      thumbWidth: map['thumbWidth'] as int,
      squareWidth: map['squareWidth'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory ItemSizePrefs.fromJson(String source) =>
      ItemSizePrefs.fromMap(json.decode(source) as Map<String, dynamic>);
}

const int mwPoster = 250;
const int mwThumb = 350;
const int mwSquare = 300;
