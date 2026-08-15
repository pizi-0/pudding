import 'package:awesome_extensions/awesome_extensions_dart.dart';
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:pudding/utils/jellyfin_item_extensions.dart';

class ImagesSlideshow extends StatefulWidget {
  final List<JellyfinItem> items;
  final int currentIndex;
  const ImagesSlideshow({
    super.key,
    required this.items,
    this.currentIndex = 0,
  });

  @override
  State<ImagesSlideshow> createState() => _ImagesSlideshowState();
}

class _ImagesSlideshowState extends State<ImagesSlideshow> {
  @override
  Widget build(BuildContext context) {
    final currentIndex = widget.currentIndex;

    return Stack(
      fit: .expand,
      children: widget.items.mapIndexed(
        (index, item) {
          return AnimatedOpacity(
            key: ValueKey(item.id),
            duration: 500.milliseconds,
            opacity: currentIndex == index ? 1 : 0,
            child: CachedNetworkImage(
              imageUrl: item.getBackdrop(),
              fit: .cover,
            ),
          );
        },
      ).toList(),
    );
  }
}
