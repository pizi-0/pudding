import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:pudding/providers/media_cache_provider.dart';
import 'package:pudding/providers/series_detail_provider.dart';
import 'package:pudding/utils/jellyfin_item_extensions.dart';

class DetailColumn extends ConsumerWidget {
  final String seriesId;
  const DetailColumn({super.key, required this.seriesId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = FTheme.of(context);
    final style = theme.style;

    final mediaCache = ref.watch(mediaCacheProvider);
    final detAsync = ref.watch(seriesDetailProvider(seriesId));

    return detAsync.when(
      loading: () => FCircularProgress(),
      error: (error, stackTrace) => Center(
        child: Text(error.toString()),
      ),
      data: (data) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: ClipRRect(
            borderRadius: style.borderRadius.lg,
            child: CachedNetworkImage(
              imageUrl: mediaCache[seriesId]!.getImage(),
              fit: .cover,
              imageBuilder: (context, imageProvider) => ClipRRect(
                borderRadius: style.borderRadius.lg,
                child: Image(image: imageProvider),
              ),
              errorBuilder: (context, error, stackTrace) => CachedNetworkImage(
                imageUrl: mediaCache[seriesId]!.getImage(),
                fit: .cover,
              ),
            ),
          ),
        );
      },
    );
  }
}
