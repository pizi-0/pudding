import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pudding/services/di.dart';

final client = services<JellyfinClient>();

//"AirTime" "CanDelete" "CanDownload" "ChannelInfo" "Chapters" "Trickplay" "ChildCount" "CumulativeRunTimeTicks" "CustomRating" "DateCreated" "DateLastMediaAdded" "DisplayPreferencesId" "Etag" "ExternalUrls" "Genres" "ItemCounts" "MediaSourceCount" "MediaSources" "OriginalTitle" "Overview" "ParentId" "Path" "People" "PlayAccess" "ProductionLocations" "ProviderIds" "PrimaryImageAspectRatio" "RecursiveItemCount" "Settings" "SeriesStudio" "SortName" "SpecialEpisodeNumbers" "Studios" "Taglines" "Tags" "RemoteTrailers" "MediaStreams" "SeasonUserData" "DateLastRefreshed" "DateLastSaved" "RefreshState" "ChannelImage" "EnableMediaSourceDisplay" "Width" "Height" "ExtraIds" "LocalTrailerCount" "IsHD" "SpecialFeatureCount"

final defaultField = [
  'AirtTime',
  'ChildCount',
  'CumulativeRunTimeTicks',
  'CustomRating',
  'ExternalUrls',
  'Genres',
  'Overview',
  'RecursiveItemCount',
  'SeasonUserData',
];

final tvshowDetailProvider = FutureProvider.family<JellyfinItem, String>(
  (ref, id) async {
    final res = await client.items.list(
      ids: [id],
      fields: defaultField,
      includeItemTypes: [JellyfinItemKind.series],
    );

    return res.items.first;
  },
);
