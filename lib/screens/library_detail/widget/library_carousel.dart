import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:pudding/screens/library_detail/widget/hero_carousel_card.dart';

class LibraryCarousel extends StatelessWidget {
  final List<JellyfinItem> items;
  const LibraryCarousel({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return LayoutBuilder(
      builder: (context, size) {
        final weight = _flexWeights(theme.breakpoints, size.maxWidth);
        return CarouselView.weightedBuilder(
          scrollDirection: .horizontal,
          infinite: true,
          itemSnapping: true,
          enableSplash: false,
          shrinkExtent: 100,
          itemCount: items.length,
          flexWeights: weight,
          itemBuilder: (context, index) {
            final item = items[index];
            return Padding(
              padding: const EdgeInsets.only(
                right: 10.0,
              ),
              child: ClipRRect(
                borderRadius: theme.style.borderRadius.sm,
                child: HeroCarouselCard(
                  item: item,
                  index: index,
                  total: items.length,
                  flexWeights: weight,
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<int> _flexWeights(FBreakpoints bp, double width) {
    if (width < bp.md) {
      return [3];
    } else if (width < bp.lg) {
      return [2, 3, 2];
    } else if (width < bp.xl) {
      return [2, 3, 2];
    }

    return [1, 2, 3, 2, 1];
  }
}
