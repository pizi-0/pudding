import 'package:awesome_extensions/awesome_extensions.dart' show StyledText;
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:pudding/utils/jellyfin_item_extensions.dart';

class HeroCarouselCard extends StatelessWidget {
  final int index;
  final int total;
  final List<int> flexWeights;
  const HeroCarouselCard({
    super.key,
    required this.item,
    required this.index,
    required this.total,
    required this.flexWeights,
  });

  final JellyfinItem item;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final theme = context.theme;
    final sortedWeight = List<int>.from(flexWeights);
    sortedWeight.sort((a, b) => b.compareTo(a));
    final weight = sortedWeight.first;
    final totalWeight = sortedWeight.fold(0, (prev, e) => prev + e);

    return Stack(
      alignment: .bottomStart,
      children: <Widget>[
        Positioned(
          top: -1,
          left: -1,
          right: -1,
          bottom: -1,
          child: ClipRect(
            child: ShaderMask(
              shaderCallback: (rect) => LinearGradient(
                colors: [
                  Colors.black26,
                  Colors.black,
                ],
                begin: .center,
                end: .bottomCenter,
              ).createShader(rect),
              blendMode: .darken,
              child: OverflowBox(
                maxWidth: size.width * weight / totalWeight,
                minWidth: size.width * weight / totalWeight,
                child: CachedNetworkImage(
                  imageUrl: item.getImage(
                    type: item.isEpisode
                        ? JellyfinImagesApi.typePrimary
                        : JellyfinImagesApi.typeThumb,
                  ),
                  fit: .cover,
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: .topRight,
          child: Padding(
            padding: .all(10),
            child: Text('${index + 1}/$total'),
          ),
        ),
        Padding(
          padding: const .all(10.0),
          child: Column(
            crossAxisAlignment: .start,
            mainAxisSize: .min,
            children: <Widget>[
              Text(
                item.getTitle(),
                overflow: .clip,
                softWrap: false,
              ).bold(),

              DefaultTextStyle(
                style: theme.typography.display.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
                child: Row(
                  spacing: 10,
                  children: [
                    if (item.seriesName != null)
                      Expanded(
                        child: Text(
                          item.seriesName!,
                          overflow: .clip,
                          softWrap: false,
                        ),
                      ),
                    if (item.productionYear != null)
                      Text(item.productionYear.toString()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
