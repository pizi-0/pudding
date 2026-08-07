import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pudding/providers/episodes_list_cache_provider.dart';
import 'package:pudding/providers/jelly_cache_provider.dart';
import 'package:pudding/services/di.dart';

final episodeProvider = FutureProvider.family<List<String>, String>(
  (ref, seasonId) async {
    final episodeCache = ref.read(episodesListCacheProvider);
    if (episodeCache.containsKey(seasonId)) {
      return episodeCache[seasonId]!;
    }

    final res = await services<JellyfinClient>().items.list(
      parentId: seasonId,
      includeItemTypes: [JellyfinItemKind.episode],
    );

    final ids = res.items.map((e) => e.id).toList();
    if (res.items.isNotEmpty) {
      ref
          .read(episodesListCacheProvider.notifier)
          .addEpisodes(
            seriesId: seasonId,
            episodesIds: ids,
          );
      ref.read(jellyCacheProvider.notifier).addAll(res.items);
    }

    return ids;
  },
);
