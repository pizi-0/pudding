import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:awesome_extensions/awesome_extensions.dart' show StyledText;
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:forui_phosphor/forui_phosphor.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
                prefix: Icon(FPhosphorBoldIcons.play),
                title: Text('Play'),
                onPress: () {},
              ),
              .item(
                prefix: Icon(FPhosphorBoldIcons.play),
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
                prefix: Icon(FPhosphorBoldIcons.eye),
                title: Text('Mark as watched'),
                onPress: () {},
              ),
              // if (item.userData?.played ?? false)
              .item(
                prefix: Icon(FPhosphorBoldIcons.eyeClosed),
                title: Text('Mark as unwatched'),
                onPress: () {},
              ),
              .submenu(
                menuStyle: .delta(barrierFilter: () => null),
                prefix: Icon(FPhosphorBoldIcons.pencil),
                title: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3.5),
                  child: Text('Add to'),
                ),
                submenu: [
                  .group(
                    children: [
                      .item(
                        title: Text('Collection'),
                        prefix: Icon(FPhosphorBoldIcons.package),
                        onPress: () {},
                      ),
                      .item(
                        title: Text('Playlist'),
                        prefix: Icon(FPhosphorBoldIcons.listPlus),
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
                prefix: Icon(FPhosphorBoldIcons.info),
                title: Text('Info'),
                onPress: () {},
              ),
              .submenu(
                menuStyle: .delta(barrierFilter: () => null),
                prefix: Icon(FPhosphorBoldIcons.pencil),
                title: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3.5),
                  child: Text('Edit'),
                ),
                submenu: [
                  .group(
                    children: [
                      .item(
                        title: Text('Metadata'),
                        prefix: Icon(FPhosphorBoldIcons.bracketsCurly),
                        onPress: () {},
                      ),
                      .item(
                        title: Text('Images'),
                        prefix: Icon(FPhosphorBoldIcons.image),
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
                prefix: Icon(FPhosphorBoldIcons.trash),
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
              (context, animation) => ImageFilter.compose(
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
  final bool dimPlayed;
  final Function()? onPressed;
  final bool selected;
  final bool isNext;
  const NewMediaCard({
    super.key,
    required this.item,
    this.imageType = JellyfinImagesApi.typePrimary,
    this.dimPlayed = false,
    this.onPressed,
    this.selected = false,
    this.isNext = false,
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

    final favorite = item.isFavorite;

    return RepaintBoundary(
      child: FButton.raw(
        onHoverChange: (value) => setState(() => hover = value),
        onFocusChange: (value) => setState(() => hover = value),
        variant: widget.selected ? .primary : .outline,
        onPress: widget.onPressed,
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
                        opacity: widget.dimPlayed && !hover
                            ? 0.4
                            : hover
                            ? 0.8
                            : 1,
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
                            errorBuilder: (context, error, stackTrace) =>
                                CachedNetworkImage(
                                  memCacheHeight: 700,
                                  fit: .cover,
                                  imageUrl: item.getImage(
                                    type: JellyfinImagesApi.typeBanner,
                                  ),
                                  errorBuilder: (context, error, stackTrace) =>
                                      CachedNetworkImage(
                                        memCacheHeight: 700,
                                        fit: .cover,
                                        imageUrl: item.getImage(
                                          type: JellyfinImagesApi.typePrimary,
                                        ),
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                CachedNetworkImage(
                                                  memCacheHeight: 700,
                                                  fit: .cover,
                                                  imageUrl: item.getImage(
                                                    type: JellyfinImagesApi
                                                        .typeBackdrop,
                                                  ),
                                                ),
                                      ),
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (favorite)
                    Align(
                      alignment: .topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          FPhosphorFillIcons.heart,
                          color: Colors.pink,
                        ),
                      ),
                    ),
                  Align(
                    alignment: .bottomCenter,
                    child: BottomData(
                      item: item,
                      hover: hover,
                      isNext: widget.isNext,
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

class BottomData extends StatelessWidget {
  final JellyfinItem item;
  final bool isNext;
  final bool hover;
  const BottomData({
    super.key,
    required this.item,
    this.hover = false,
    this.isNext = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return AnimatedSize(
      duration: kDefaultAnimationDuration,
      alignment: .bottomCenter,
      child: ClipRect(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, theme.colors.background],
              begin: .topCenter,
              end: .bottomCenter,
            ),
          ),
          child: BackdropFilter(
            enabled: hover,
            filter: .blur(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
              child: Column(
                spacing: 4,
                crossAxisAlignment: .stretch,
                mainAxisSize: .min,
                children: [
                  if (item.isResumable)
                    FDeterminateProgress(
                      value: item.getPlayProgress(),
                    ).fadeOut(
                      animate: hover,
                      duration: kDefaultAnimationDuration,
                    ),
                  Row(
                    spacing: 10,
                    crossAxisAlignment: .end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: .start,
                          children: [
                            Text(
                              item.getTitle(),
                              maxLines: hover ? 8 : 1,
                              overflow: hover ? null : .ellipsis,
                            ).bold(),
                          ],
                        ),
                      ),
                      _playStatusIndicator(theme),
                    ],
                  ),
                  DefaultTextStyle(
                    style: theme.typography.body.xs.copyWith(
                      color: theme.colors.foreground.withAlpha(
                        200,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: .spaceBetween,
                      children: [
                        if (_getYear(context) != null) Text(_getYear(context)!),
                        if (item.getCommunityRating() != null)
                          StarRatingContainer(
                            rating: item.getCommunityRating()!.toStringAsFixed(
                              2,
                            ),
                          ),
                      ],
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

  String? _getYear(BuildContext context) {
    if (item.isSeries) {
      return item.getSeriesRunYears();
    }

    if (item.isMovie || item.isSeason) {
      return item.productionYear?.toString();
    }

    if (item.isEpisode) {
      final locale = Localizations.localeOf(context).toLanguageTag();
      final fmt = DateFormat.yMMMEd(locale);
      final date = item.premiereDate;

      if (date != null) {
        return fmt.format(date);
      }
    }

    return null;
  }

  Widget _playStatusIndicator(FThemeData theme) {
    if (item.userData?.played ?? false) {
      return Icon(FPhosphorBoldIcons.check, color: Colors.green);
    }

    if (item.isSeries || item.isSeason) {
      return Row(
        spacing: 4,
        children: [
          Icon(
            isNext ? FPhosphorBoldIcons.play : FPhosphorBoldIcons.eye,
            color: isNext ? theme.colors.primary : null,
            size: theme.typography.body.sm.fontSize,
          ),
          Text('${item.getUnplayed()}'),
        ],
      );
    } else if (item.isMovie || item.isEpisode) {
      return Row(
        spacing: 4,
        children: [
          Icon(
            isNext ? FPhosphorBoldIcons.play : FPhosphorBoldIcons.clock,
            size: theme.typography.body.sm.fontSize,
            color: isNext ? theme.colors.primary : null,
          ),
          Text(
            '${item.getRuntime()}',
            style: theme.typography.body.xs.copyWith(
              color: theme.colors.foreground.withAlpha(
                200,
              ),
            ),
          ),
        ],
      );
    } else {
      return SizedBox();
    }
  }
}
