import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class PuddingDisplayPrefs {
  /// 'poster' (10:16), thumb (16:10)
  String puddingLibraryViewType;

  /// grid 'maxCrossAxisExtent'
  String puddingMaxImageWidth;

  PuddingDisplayPrefs({
    required this.puddingLibraryViewType,
    required this.puddingMaxImageWidth,
  });

  double get aspectRatio => _aspectRatio();
  double get maxImageWidth => double.tryParse(puddingMaxImageWidth) ?? 250;

  double _aspectRatio() {
    final type = puddingLibraryViewType.toLowerCase();
    if (type == 'thumb') {
      return 16 / 10;
    }

    return 10 / 16;
  }

  PuddingDisplayPrefs copyWith({
    String? puddingLibraryViewType,
    String? puddingMaxImageWidth,
  }) {
    return PuddingDisplayPrefs(
      puddingLibraryViewType:
          puddingLibraryViewType ?? this.puddingLibraryViewType,
      puddingMaxImageWidth: puddingMaxImageWidth ?? this.puddingMaxImageWidth,
    );
  }

  Map<String, String> toMap() {
    return <String, String>{
      'puddingLibraryViewType': puddingLibraryViewType,
      'puddingMaxImageWidth': puddingMaxImageWidth,
    };
  }

  factory PuddingDisplayPrefs.fromMap(Map<String, String> map) {
    return PuddingDisplayPrefs(
      puddingLibraryViewType: map['puddingLibraryViewType'] ?? 'poster',
      puddingMaxImageWidth: map['puddingMaxImageWidth'] ?? '250',
    );
  }

  String toJson() => json.encode(toMap());

  factory PuddingDisplayPrefs.fromJson(String source) =>
      PuddingDisplayPrefs.fromMap(json.decode(source) as Map<String, String>);
}
