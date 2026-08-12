import 'package:dart_jellyfin/dart_jellyfin.dart';

extension JellyDisplayPrefs on JellyfinDisplayPreferences {
  JellyfinDisplayPreferences copyWith({
    String? viewType,
    String? sortBy,
    String? sortOrder,
    String? indexBy,
    String? scrollDirection,
    bool? rememberIndexing,
    bool? rememberSorting,
    bool? showBackdrop,
    bool? showSidebar,
    int? primaryImageHeight,
    int? primaryImageWidth,
    Map<String, String>? customPrefs,
    Map<String, dynamic>? raw,
  }) {
    return JellyfinDisplayPreferences(
      id: id,
      client: client,
      viewType: viewType ?? this.viewType,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      indexBy: indexBy ?? this.indexBy,
      scrollDirection: scrollDirection ?? this.scrollDirection,
      rememberIndexing: rememberIndexing ?? this.rememberIndexing,
      rememberSorting: rememberSorting ?? this.rememberSorting,
      showBackdrop: showBackdrop ?? this.showBackdrop,
      showSidebar: showSidebar ?? this.showSidebar,
      primaryImageHeight: primaryImageHeight ?? this.primaryImageHeight,
      primaryImageWidth: primaryImageWidth ?? this.primaryImageWidth,
      customPrefs: customPrefs ?? this.customPrefs,
      raw: raw ?? this.raw,
    );
  }
}
