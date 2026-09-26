// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:pudding/models/settings/library/library_prefs.dart';

class PuddingSettings {
  final LibraryPrefs libraryPrefs;

  new({this.libraryPrefs = const LibraryPrefs()});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'libraryPrefs': libraryPrefs.toMap(),
    };
  }

  factory PuddingSettings.fromMap(Map<String, dynamic> map) {
    return PuddingSettings(
      libraryPrefs: LibraryPrefs.fromMap(
        (map['libraryPrefs'] ?? LibraryPrefs().toMap()) as Map<String, dynamic>,
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory PuddingSettings.fromJson(String source) =>
      PuddingSettings.fromMap(json.decode(source) as Map<String, dynamic>);

  ///

  PuddingSettings copyWith({
    LibraryPrefs? libraryPrefs,
  }) {
    return PuddingSettings(
      libraryPrefs: libraryPrefs ?? this.libraryPrefs,
    );
  }
}
