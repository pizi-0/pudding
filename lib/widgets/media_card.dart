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
  State<MediaCard> createState() => _MediaCardState();
}

class _MediaCardState extends State<MediaCard> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);

    return AnimatedScale(
      duration: kDefaultAnimationDuration,
      scale: hover ? 1.02 : 1,
      child: LayoutBuilder(
        builder: (context, size) {
          return Stack(
            fit: .expand,
            children: [
              FButton(
                variant: .ghost,
                style: .delta(contentStyle: .delta(padding: .value(.zero))),
                onPress: () {},
                onHoverChange: (h) => setState(() => hover = h),
                onFocusChange: (f) => setState(() => hover = f),
                crossAxisAlignment: .stretch,
                child: Expanded(
                  child: ClipRRect(
                    borderRadius: theme
                        .buttonStyles
                        .ghost
                        .lg
                        .decoration
                        .base
                        .borderRadius!,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                      ),
                      child: ShaderMask(
                        shaderCallback: (rect) => LinearGradient(
                          begin: .topCenter,
                          end: .bottomCenter,
                          stops: [0.2, 1],
                          colors: [Colors.black12, Colors.black],
                        ).createShader(rect),
                        blendMode: .darken,
                        child: CachedNetworkImage(
                          imageUrl: widget.item.getBackdrop(),

                          fit: .cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: .bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    spacing: 8,
                    mainAxisAlignment: .end,
                    children: [
                      Row(
                        mainAxisAlignment: .spaceBetween,
                        children: [
                          if (widget.item.isResumable)
                            Text(
                              '${widget.item.getRemaining()} left',
                            ),
                          if (hover)
                            Text(
                              'Ends: ${widget.item.getEndsAt(context)}',
                            ),
                        ],
                      ),
                      if (widget.item.isResumable)
                        FDeterminateProgress(
                          value: widget.item.getPlayProgress(),
                          style: .delta(
                            motion: .delta(
                              duration: kDefaultAnimationDuration,
                            ),
                          ),
                        ),
                      Column(
                        crossAxisAlignment: .stretch,
                        spacing: 4,
                        children: [
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
                    ],
                  ),
                ),
              ),
              if (hover)
                Align(
                  alignment: .topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: .min,
                      spacing: 4,
                      children: [
                        FButton.icon(
                          variant: .ghost,
                          onHoverChange: (h) => setState(() => hover = h),
                          onPress: () {},
                          child: Icon(FLucideIcons.check),
                        ),
                        FButton.icon(
                          variant: .ghost,
                          onHoverChange: (h) => setState(() => hover = h),
                          onPress: () {},
                          child: Icon(FLucideIcons.heart),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
