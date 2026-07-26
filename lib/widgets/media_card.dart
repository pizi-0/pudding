import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:pudding/const/const.dart';
import 'package:pudding/utils/jellyfin_item_extensions.dart';

class MediaCard extends StatefulWidget {
  final JellyfinItem item;
  const MediaCard({super.key, required this.item});

  @override
  State<MediaCard> createState() => MediaCardState();
}

class MediaCardState extends State<MediaCard> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final borderRadius =
        theme.buttonStyles.base.lg.decoration.base.borderRadius ??
        BorderRadius.circular(10);
    final item = widget.item;

    return AnimatedScale(
      scale: hover ? 1.02 : 1,
      duration: kDefaultAnimationDuration,
      curve: Curves.ease,
      child: FButton.raw(
        style: .delta(
          decoration: .delta([.all(.boxDelta(color: Colors.transparent))]),
        ),
        variant: .ghost,
        onHoverChange: (h) => setState(() => hover = h),
        onFocusChange: (f) => setState(() => hover = f),
        onPress: () {},
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Stack(
            fit: .expand,
            children: [
              ShaderMask(
                shaderCallback: (rect) => LinearGradient(
                  begin: .topCenter,
                  end: .bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black,
                  ],
                  stops: [0.2, 1],
                ).createShader(rect),
                blendMode: .darken,
                child: CachedNetworkImage(
                  imageUrl: item.getBackdrop(),
                  fit: .cover,
                  memCacheWidth: 800,
                ),
              ),
              Align(
                alignment: .bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: .stretch,
                    spacing: 6,
                    mainAxisSize: .min,
                    children: [
                      FDeterminateProgress(
                        style: .delta(
                          motion: .delta(
                            duration: kDefaultAnimationDuration,
                          ),
                        ),
                        value: item.getPlayProgress(),
                      ),
                      Text(
                        widget.item.getTitle(),
                        style: theme.typography.body.sm.copyWith(
                          fontWeight: FontWeight(800),
                        ),
                        maxLines: 1,
                        overflow: .ellipsis,
                      ),
                      Row(
                        mainAxisAlignment: .spaceBetween,
                        children: [
                          if (widget.item.seriesName != null)
                            Text(widget.item.seriesName!),
                          Text(widget.item.productionYear.toString()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
