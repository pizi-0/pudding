import 'package:animate_do/animate_do.dart';
import 'package:awesome_extensions/awesome_extensions.dart' show StyledText;
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:forui_phosphor/forui_phosphor.dart';
import 'package:intl/intl.dart';
import 'package:pudding/const/const.dart';
import 'package:pudding/providers/userdata_registry_provider.dart';
import 'package:pudding/utils/jellyfin_item_extensions.dart';
import 'package:pudding/widgets/star_rating_container.dart';

class MediaCard extends StatefulWidget {
  final JellyfinItem item;
  final String imageType;
  final bool dimPlayed;
  final Function()? onPressed;
  final bool selected;
  final bool isNext;
  final Widget? bottom;
  final bool showSeriesName;
  const MediaCard({
    super.key,
    required this.item,
    this.imageType = JellyfinImagesApi.typePrimary,
    this.dimPlayed = false,
    this.onPressed,
    this.selected = false,
    this.isNext = false,
    this.showSeriesName = false,
    this.bottom,
  });

  @override
  State<MediaCard> createState() => _MediaCardState();
}

class _MediaCardState extends State<MediaCard> {
  bool hover = false;
  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final imageType = widget.imageType;
    final theme = FTheme.of(context);
    final style = theme.style;

    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, size) {
          final height = size.maxHeight;

          return Column(
            children: [
              Expanded(
                child: FButton.raw(
                  onHoverChange: (value) => setState(() => hover = value),
                  onFocusChange: (value) => setState(() => hover = value),
                  variant: .outline,
                  onPress: widget.onPressed,
                  style: .delta(
                    decoration: .delta([
                      .all(
                        .boxDelta(
                          border: .all(
                            color: widget.selected
                                ? theme.colors.primary
                                : theme.colors.border,
                            width: 2,
                          ),
                        ),
                      ),
                    ]),
                  ),
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
                              child: AnimatedOpacity(
                                duration: kDefaultAnimationDuration,
                                opacity: widget.dimPlayed && !hover
                                    ? 0.4
                                    : hover
                                    ? 0.6
                                    : 1,
                                child: AnimatedScale(
                                  duration: kDefaultAnimationDuration,
                                  alignment: .bottomCenter,
                                  scale: hover ? 1.01 : 1,
                                  child: CachedNetworkImage(
                                    disablePlaceholderOnCacheHit: false,
                                    memCacheHeight: height.ceil(),
                                    fit: item.isPlaceholder ? .contain : .cover,
                                    imageBuilder: (context, imageProvider) {
                                      if (item.isPlaceholder) {
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Image(
                                            image: imageProvider,
                                            fit: .contain,
                                          ),
                                        );
                                      } else {
                                        return Image(
                                          image: imageProvider,
                                          fit: .cover,
                                        );
                                      }
                                    },
                                    imageUrl: item.isPlaceholder
                                        ? item.getLogo()
                                        : item.getImage(type: imageType),
                                    errorBuilder:
                                        (
                                          context,
                                          error,
                                          stackTrace,
                                        ) => Center(
                                          child: Icon(
                                            FPhosphorBoldIcons.imageBroken,
                                          ),
                                        ),
                                  ),
                                ),
                              ),
                            ),

                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: AnimatedContainer(
                                  duration: kDefaultAnimationDuration,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: Colors
                                        .transparent, // Solid overlay shadow
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.colors.background
                                            .withAlpha(245),
                                        blurRadius: height / (hover ? 3 : 4),
                                        spreadRadius: height / (hover ? 3 : 4), // This blur mimics the soft edge of a gradient!
                                        offset: const Offset(0, 52),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned.fill(
                              bottom: -1,
                              top: -1,
                              left: -1,
                              right: -1,
                              child: InfoLayer(
                                item: item,
                                hover: hover,
                                isNext: widget.isNext,
                                showSeriesName: widget.showSeriesName,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (widget.bottom != null)
                AnimatedSize(
                  duration: kDefaultAnimationDuration,
                  child: widget.bottom!,
                ),
            ],
          );
        },
      ),
    );
  }
}

class InfoLayer extends StatelessWidget {
  final JellyfinItem item;
  final bool isNext;
  final bool hover;
  final bool showSeriesName;
  const InfoLayer({
    super.key,
    required this.item,
    this.hover = false,
    this.isNext = false,
    this.showSeriesName = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final placeholder = item.isPlaceholder;
    final missing = item.isMissing;
    final upcoming = item.isUpcoming;

    return Padding(
      padding: const EdgeInsets.all(9),
      child: Column(
        spacing: 4,
        crossAxisAlignment: .start,
        mainAxisSize: .min,
        children: [
          Row(
            children: [
              if (missing)
                FBadge(variant: .destructive, child: Text('Missing')),
              if (upcoming)
                FBadge(variant: .secondary, child: Text('Upcoming')),
              Spacer(),
              Align(
                alignment: .centerRight,
                child: FavoriteIndicator(item: item),
              ),
            ],
          ),
          Spacer(),
          ProgressIndicator(item: item).fadeOut(
            animate: hover,
            duration: kDefaultAnimationDuration,
          ),
          Row(
            spacing: 4,
            crossAxisAlignment: .end,
            children: [
              Expanded(
                child: AnimatedSize(
                  duration: kDefaultAnimationDuration,
                  alignment: .topCenter,
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        item.getTitle(),
                        maxLines: hover ? 5 : 1,
                        overflow: .ellipsis,
                      ).bold(),
                    ],
                  ),
                ),
              ),
              if (!placeholder) PlayedIndicator(item: item, isNext: isNext),
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
                if (_getYear(context) != null && !showSeriesName)
                  Text(_getYear(context)!),
                if (showSeriesName) Text(item.seriesName ?? ''),
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
    );
  }

  String? _getYear(BuildContext context) {
    if (item.isSeries) {
      return item.getSeriesRunYears();
    }

    if (item.isMovie || item.isSeason || item.isVideo) {
      return item.productionYear?.toString();
    }

    if (item.isEpisode) {
      final locale = Localizations.localeOf(context).toLanguageTag();
      final fmt = DateFormat.yMMMEd(locale);
      final date = item.premiereDate;

      if (date != null) {
        return fmt.format(date.toLocal());
      }
    }

    return null;
  }
}

class FavoriteIndicator extends ConsumerWidget {
  final JellyfinItem item;
  const FavoriteIndicator({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final override = ref.watch(
      userDataRegistryProvider.select((d) => d[item.id]),
    );

    final isFavorite = override?.isFavorite ?? item.isFavorite;

    return AnimatedSwitcher(
      duration: kDefaultAnimationDuration,
      child: isFavorite
          ? Icon(
              FPhosphorFillIcons.heart,
              color: Colors.pink,
              shadows: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            )
          : SizedBox.shrink(),
    );
  }
}

class PlayedIndicator extends ConsumerWidget {
  final JellyfinItem item;
  final bool isNext;
  const PlayedIndicator({super.key, required this.item, this.isNext = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;

    final override = ref.watch(
      userDataRegistryProvider.select((d) => d[item.id]),
    );

    final isPlayed = override?.played ?? item.isPlayed;

    if (isPlayed) {
      return Icon(FPhosphorBoldIcons.checks, color: Colors.green);
    }

    if (item.isSeries || item.isSeason || item.isBoxsets) {
      return Row(
        spacing: 4,
        children: [
          Icon(
            isNext ? FPhosphorFillIcons.play : FPhosphorBoldIcons.eye,
            color: isNext ? theme.colors.primary : null,
            size: theme.typography.body.sm.fontSize,
          ),
          Text('${item.getUnplayed()}'),
        ],
      );
    } else if (item.isMovie || item.isEpisode || item.isVideo) {
      return Row(
        spacing: 4,
        children: [
          Icon(
            isNext ? FPhosphorFillIcons.play : FPhosphorBoldIcons.clock,
            size: theme.typography.body.sm.fontSize,
            color: isNext ? theme.colors.primary : null,
          ),
          Text(
            item.isResumable ? item.getRemaining() : '${item.getRuntime()}',
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

class ProgressIndicator extends ConsumerWidget {
  final JellyfinItem item;
  const ProgressIndicator({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final override = ref.watch(
      userDataRegistryProvider.select((d) => d[item.id]),
    );

    final ticks =
        override?.playbackPositionTicks ??
        item.userData?.playbackPositionTicks ??
        0;

    final progress = ticks / (item.runTimeTicks ?? 0);

    return AnimatedSwitcher(
      duration: kDefaultAnimationDuration,
      child: item.isResumable
          ? FDeterminateProgress(value: progress)
          : SizedBox.shrink(),
    );
  }
}
