import 'package:awesome_extensions/awesome_extensions.dart' show StyledText;
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:pudding/const/const.dart';
import 'package:pudding/utils/jellyfin_item_extensions.dart';

class HeroCarouselCard extends StatefulWidget {
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
  State<HeroCarouselCard> createState() => _HeroCarouselCardState();
}

class _HeroCarouselCardState extends State<HeroCarouselCard> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final theme = context.theme;
    final sortedWeight = List<int>.from(widget.flexWeights);
    sortedWeight.sort((a, b) => b.compareTo(a));
    final weight = sortedWeight.first;
    final totalWeight = sortedWeight.fold(0, (prev, e) => prev + e);
    final resumable = widget.item.isResumable;

    return FButton.raw(
      variant: .outline,
      onPress: () {},
      onHoverChange: (value) => setState(() => hover = value),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: ClipRRect(
          borderRadius: theme.style.borderRadius.sm,
          child: Stack(
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
                      child: AnimatedOpacity(
                        duration: kDefaultAnimationDuration,
                        opacity: hover ? 0.8 : 1,
                        child: AnimatedScale(
                          alignment: .bottomCenter,
                          duration: kDefaultAnimationDuration,
                          scale: hover ? 1.02 : 1,
                          child: CachedNetworkImage(
                            imageUrl: widget.item.getImage(
                              type: widget.item.isEpisode
                                  ? JellyfinImagesApi.typePrimary
                                  : JellyfinImagesApi.typeThumb,
                            ),
                            fit: .cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: .topRight,
                child: Padding(
                  padding: .all(10),
                  child: Text('${widget.index + 1}/${widget.total}'),
                ),
              ),
              Padding(
                padding: const .all(10.0),
                child: Column(
                  spacing: 4,
                  crossAxisAlignment: .start,
                  mainAxisSize: .min,
                  children: <Widget>[
                    if (resumable)
                      Opacity(
                        opacity: 0.8,
                        child: FDeterminateProgress(
                          style: .delta(motion: .delta(duration: .zero)),
                          value: widget.item.getPlayProgress(),
                        ),
                      ),
                    Text(
                      widget.item.getTitle(),
                      overflow: .clip,
                      softWrap: false,
                    ).bold(),

                    DefaultTextStyle(
                      style: theme.typography.display.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                      child: Row(
                        children: [
                          if (widget.item.seriesName != null)
                            Expanded(
                              flex: weight,
                              child: Padding(
                                padding: const EdgeInsetsGeometry.only(
                                  right: 8,
                                ),
                                child: Text(
                                  '${widget.item.seriesName!} (${widget.item.productionYear})',
                                  overflow: .clip,
                                  softWrap: false,
                                ),
                              ),
                            ),
                          if (widget.item.isMovie)
                            Expanded(
                              flex: 3,
                              child: Text(
                                widget.item.productionYear.toString(),
                                overflow: .clip,
                                softWrap: false,
                              ),
                            ),
                          Expanded(
                            child: Text(
                              widget.item.getRemaining(),
                              textAlign: .end,
                              overflow: .clip,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
