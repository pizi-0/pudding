import 'dart:convert';

import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/foundation.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class PuddingFilters {
  final List<String> genres;
  final List<String> tags;
  final List<int> years;
  final List<String> filters;
  final List<String> parentalRating;

  PuddingFilters({
    this.genres = const [],
    this.tags = const [],
    this.years = const [],
    this.filters = const [],
    this.parentalRating = const [],
  });

  PuddingFilters copyWith({
    List<String>? genres,
    List<String>? tags,
    List<int>? years,
    List<String>? filters,
    List<String>? parentalRating,
  }) {
    return PuddingFilters(
      genres: genres ?? this.genres,
      tags: tags ?? this.tags,
      years: years ?? this.years,
      filters: filters ?? this.filters,
      parentalRating: parentalRating ?? this.parentalRating,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'genres': genres,
      'tags': tags,
      'years': years,
      'filters': filters,
      'parentalRating': parentalRating,
    };
  }

  factory PuddingFilters.fromMap(Map<String, dynamic> map) {
    return PuddingFilters(
      genres: List<String>.from((map['genres'] as List<String>)),
      tags: List<String>.from((map['tags'] as List<String>)),
      years: List<int>.from((map['years'] as List<int>)),
      filters: List<String>.from((map['filters'] as List<String>)),
      parentalRating: List<String>.from(
        (map['parentalRating'] as List<String>),
      ),
    );
  }

  factory PuddingFilters.fromLegacyJelly(JellyfinQueryFiltersLegacy legacy) {
    return PuddingFilters(
      filters: [],
      genres: legacy.genres,
      tags: legacy.tags,
      years: legacy.years,
      parentalRating: legacy.officialRatings,
    );
  }

  String toJson() => json.encode(toMap());

  factory PuddingFilters.fromJson(String source) =>
      PuddingFilters.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(covariant PuddingFilters other) {
    if (identical(this, other)) return true;

    return listEquals(other.genres, genres) &&
        listEquals(other.tags, tags) &&
        listEquals(other.years, years) &&
        listEquals(other.filters, filters) &&
        listEquals(other.parentalRating, parentalRating);
  }

  @override
  int get hashCode {
    return genres.hashCode ^
        tags.hashCode ^
        years.hashCode ^
        filters.hashCode ^
        parentalRating.hashCode;
  }
}
