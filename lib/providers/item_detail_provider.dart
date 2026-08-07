import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pudding/providers/jelly_cache_provider.dart';
import 'package:pudding/services/di.dart';

final itemDetailProvider = FutureProvider.family<JellyfinItem?, String>((
  ref,
  id,
) async {
  final cache = ref.watch(jellyCacheProvider);

  if (cache[id] != null) {
    return cache[id]!;
  }

  final res = await services<JellyfinClient>().items.byId(id);

  if (res != null) {
    ref.read(jellyCacheProvider.notifier).addSingle(res);
  }

  return res;
});
