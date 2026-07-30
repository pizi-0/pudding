import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pudding/providers/item_detail_provider.dart';
import 'package:pudding/utils/jellyfin_item_extensions.dart';

class MovieDetailScreen extends ConsumerStatefulWidget {
  final String? movieId;
  const MovieDetailScreen({super.key, this.movieId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ShowsDetailScreensState();
}

class _ShowsDetailScreensState extends ConsumerState<MovieDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final itemAsync = ref.watch(itemDetailProvider(widget.movieId!));
    final item = itemAsync.value;

    if (itemAsync.hasError) {
      return Center(
        child: Text(itemAsync.error.toString()),
      );
    }

    if (item == null) {
      return Center(
        child: Text('item == null'),
      );
    }

    return Stack(
      fit: .expand,
      children: [
        CachedNetworkImage(
          imageUrl: item.getBackdrop(),
          fit: .cover,
          color: Colors.black.withAlpha(230),
          colorBlendMode: .darken,
        ),
      ],
    );
  }
}
