import 'dart:ui';

import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:pudding/const/const.dart';
import 'package:pudding/utils/jellyfin_item_extensions.dart';
import 'package:pudding/widgets/star_rating_container.dart';

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
    final borderRadius = theme.style.borderRadius.xs;

    final item = widget.item;
    final textDirection = Directionality.of(context);

    return AnimatedScale(
      scale: hover ? 1.02 : 1,
      duration: kDefaultAnimationDuration,
      curve: Curves.ease,
      child: FPopoverMenu(
        menuBuilder: (context, controller, menu) => [
          .group(
            children: [
              .item(
                prefix: Icon(FLucideIcons.play),
                title: Text('Play'),
                onPress: () {},
              ),
              .item(
                prefix: Icon(FLucideIcons.play),
                title: Text('Play all from here'),
                onPress: () {},
              ),
              .raw(
                child: FDivider(
                  style: .delta(padding: .value(.zero)),
                ),
              ),
              // if (!(item.userData?.played ?? true))
              .item(
                prefix: Icon(FLucideIcons.eye),
                title: Text('Mark as watched'),
                onPress: () {},
              ),
              // if (item.userData?.played ?? false)
              .item(
                prefix: Icon(FLucideIcons.eyeOff),
                title: Text('Mark as unwatched'),
                onPress: () {},
              ),
              .submenu(
                menuStyle: .delta(barrierFilter: () => null),
                prefix: Icon(FLucideIcons.edit),
                title: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3.5),
                  child: Text('Add to'),
                ),
                submenu: [
                  .group(
                    children: [
                      .item(
                        title: Text('Collection'),
                        prefix: Icon(FLucideIcons.packagePlus),
                        onPress: () {},
                      ),
                      .item(
                        title: Text('Playlist'),
                        prefix: Icon(FLucideIcons.listPlus),
                        onPress: () {},
                      ),
                    ],
                  ),
                ],
              ),
              .raw(
                child: FDivider(
                  style: .delta(padding: .value(.zero)),
                ),
              ),
              .item(
                prefix: Icon(FLucideIcons.info),
                title: Text('Info'),
                onPress: () {},
              ),
              .submenu(
                menuStyle: .delta(barrierFilter: () => null),
                prefix: Icon(FLucideIcons.edit),
                title: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3.5),
                  child: Text('Edit'),
                ),
                submenu: [
                  .group(
                    children: [
                      .item(
                        title: Text('Metadata'),
                        prefix: Icon(FLucideIcons.braces),
                        onPress: () {},
                      ),
                      .item(
                        title: Text('Images'),
                        prefix: Icon(FLucideIcons.image),
                        onPress: () {},
                      ),
                    ],
                  ),
                ],
              ),
              .raw(
                child: FDivider(
                  style: .delta(padding: .value(.zero)),
                ),
              ),
              .item(
                prefix: Icon(FLucideIcons.trash2),
                title: Text('Delete'),
                onPress: () {},
              ),
            ],
          ),
        ],
        cutout: true,
        faded: false,
        menuAnchor: .topLeft,
        childAnchor: .topRight,
        style: .delta(
          tileGroupStyle: .delta(childPadding: .value(.all(100))),
          itemGroupStyle: .delta(
            itemStyles: .delta([
              .all(
                .delta(
                  contentDecoration: .delta([
                    .all(.boxDelta(borderRadius: borderRadius)),
                  ]),
                  contentStyle: .delta(unsuffixedPadding: .value(.all(10))),
                ),
              ),
            ]),
          ),
          barrierFilter: () =>
              (animation) => ImageFilter.compose(
                outer: ImageFilter.blur(
                  sigmaX: animation * 5,
                  sigmaY: animation * 5,
                ),
                inner: ColorFilter.mode(
                  Color.lerp(
                    const Color(0x00000000),
                    const Color(0x33000000),
                    animation,
                  )!,
                  BlendMode.srcOver,
                ),
              ),
        ),
        cutoutBuilder: (path, bounds) => path.addRRect(
          RRect.fromRectAndRadius(
            bounds,
            borderRadius.resolve(textDirection).bottomLeft,
          ),
        ), //
        builder: (context, controller, child) => FButton.raw(
          style: .delta(
            decoration: .delta([
              .all(
                .boxDelta(
                  color: Colors.transparent,
                  border: Border.all(width: 2, color: theme.colors.border),
                ),
              ),
            ]),
          ),
          variant: .outline,
          actions: {},
          onHoverChange: (h) => setState(() => hover = h),
          onFocusChange: (f) => setState(() => hover = f),
          onPress: () {
            if (item.isSeries || item.isSeason || item.isEpisode) {
              context.go('/show/${item.seriesId}');
            }
            if (item.isMovie) context.go('/movie/${item.id}');
          },
          onSecondaryPress: () => controller.toggle(),
          onLongPress: () => controller.toggle(),
          child: child!,
        ),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
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
                    errorBuilder: (context, error, stackTrace) =>
                        CachedNetworkImage(
                          imageUrl: item.getImage(
                            type: JellyfinImagesApi.typePrimary,
                          ),
                          fit: .cover,
                        ),
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
                              Expanded(
                                child: Text(
                                  widget.item.seriesName!,
                                  maxLines: 1,
                                  overflow: .ellipsis,
                                ),
                              ),
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
      ),
    );
  }
}

class NewMediaCard extends StatefulWidget {
  final JellyfinItem item;
  final String imageType;
  const NewMediaCard({
    super.key,
    required this.item,
    this.imageType = JellyfinImagesApi.typePrimary,
  });

  @override
  State<NewMediaCard> createState() => _NewMediaCardState();
}

class _NewMediaCardState extends State<NewMediaCard> {
  bool hover = false;
  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final imageType = widget.imageType;
    final theme = FTheme.of(context);
    final style = theme.style;

    return RepaintBoundary(
      child: FButton.raw(
        onHoverChange: (value) => setState(() => hover = !hover),
        onFocusChange: (value) => setState(() => hover = !hover),
        variant: .outline,
        onPress: () => context.go('/show/${item.id}'),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: ClipRRect(
            borderRadius: style.borderRadius.sm,
            child: Container(
              color: Colors.black,
              child: Stack(
                fit: .expand,
                children: [
                  Positioned(
                    left: -1,
                    top: -1,
                    right: -1,
                    bottom: -1,
                    child: ShaderMask(
                      shaderCallback: (rect) => LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black,
                        ],
                        begin: .center,
                        end: .bottomCenter,
                      ).createShader(rect),
                      blendMode: .dstOut,
                      child: AnimatedOpacity(
                        duration: kDefaultAnimationDuration,
                        opacity: hover ? 0.8 : 1,
                        child: AnimatedScale(
                          duration: kDefaultAnimationDuration,
                          alignment: .bottomCenter,
                          scale: hover ? 1.01 : 1,
                          child: CachedNetworkImage(
                            memCacheHeight: 700,
                            fit: .cover,
                            imageUrl: item.getImage(
                              type: imageType,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: .bottomCenter,
                    child: AnimatedSize(
                      duration: kDefaultAnimationDuration,
                      alignment: .bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          spacing: 4,
                          crossAxisAlignment: .stretch,
                          mainAxisSize: .min,
                          children: [
                            Text(
                              item.name,
                              maxLines: hover ? null : 1,
                              overflow: hover ? null : .ellipsis,
                            ).bold(),
                            Row(
                              mainAxisAlignment: .spaceBetween,
                              children: [
                                Text(
                                  item.getSeriesRunYears(),
                                  style: theme.typography.body.xs.copyWith(
                                    color: theme.colors.foreground.withAlpha(
                                      200,
                                    ),
                                  ),
                                ),
                                if (item.getCommunityRating() != null)
                                  StarRatingContainer(
                                    rating: item
                                        .getCommunityRating()!
                                        .toStringAsFixed(2),
                                    style: theme.typography.body.xs.copyWith(
                                      color: theme.colors.foreground.withAlpha(
                                        200,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
