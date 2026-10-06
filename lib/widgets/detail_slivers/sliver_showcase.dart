import 'package:awesome_extensions/awesome_extensions.dart' show ListExtension;
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:forui_phosphor/forui_phosphor.dart';
import 'package:pudding/utils/jellyfin_item_extensions.dart';
import 'package:pudding/widgets/favorite_button.dart';
import 'package:pudding/widgets/icon_text.dart';
import 'package:pudding/widgets/played_button.dart';
import 'package:pudding/widgets/rating_container.dart';
import 'package:pudding/widgets/star_rating_container.dart';

enum _ShowcaseVariant { general, tv, boxsets }

class SliverShowcase extends ConsumerStatefulWidget {
  final JellyfinItem item;
  final JellyfinItem? nextup;
  final double? maxExtent;
  final String? filesize;
  final _ShowcaseVariant _variant;
  final Future Function()? onToggleFavorite;
  final Future Function()? onTogglePlayed;

  const SliverShowcase({
    super.key,
    required this.item,
    this.nextup,
    this.maxExtent,
    this.onToggleFavorite,
    this.onTogglePlayed,
    this.filesize,
  }) : _variant = .general;

  const SliverShowcase.tv({
    super.key,
    required this.item,
    required this.nextup,
    this.maxExtent,
    this.onToggleFavorite,
    this.onTogglePlayed,
    this.filesize,
  }) : _variant = .tv;

  const SliverShowcase.boxsets({
    super.key,
    required this.item,
    this.nextup,
    this.maxExtent,
    this.onToggleFavorite,
    this.onTogglePlayed,
    this.filesize,
  }) : _variant = .boxsets;

  @override
  ConsumerState<SliverShowcase> createState() => _SliverShowcaseState();
}

class _SliverShowcaseState extends ConsumerState<SliverShowcase> {
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final size = MediaQuery.sizeOf(context);
    final item = widget.item;
    final next = widget.nextup;

    final max = size.width < theme.breakpoints.md;

    final overviewWidth = max ? size.width : size.width * 0.5;

    final crossAxisAlignment = max
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;

    final year = item.getYear();
    final parentalRating = item.getOfficialRating();
    final rating = item.getCommunityRating();
    final duration = (next ?? item).getRuntime();
    final hasLogo = item.imageTags[JellyfinImagesApi.typeLogo] != null;
    final endsAt = item.getEndsAt(context);

    return SliverToBoxAdapter(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: widget.maxExtent ?? size.height,
          maxWidth: overviewWidth,
        ),

        child: Column(
          spacing: 10,
          mainAxisAlignment: .end,
          crossAxisAlignment: crossAxisAlignment,
          mainAxisSize: .max,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 250 * 16 / 11),
              child: Row(
                crossAxisAlignment: .end,
                children: [
                  Container(
                    clipBehavior: .hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: theme.style.borderRadius.md,
                      border: .all(color: theme.colors.border, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: theme.style.borderRadius.sm,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 250,
                          minWidth: 250,
                          minHeight: 250 * 16 / 11,
                        ),
                        child: CachedNetworkImage(
                          imageUrl: item.getPrimary(),
                          maxHeightDiskCache: (250 * 16 / 11).toInt(),
                          filterQuality: .medium,
                          fit: .cover,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        spacing: 10,
                        mainAxisAlignment: .end,
                        crossAxisAlignment: .start,
                        children: [
                          if (hasLogo)
                            Flexible(
                              child: FittedBox(
                                child: CachedNetworkImage(
                                  memCacheWidth: 400,
                                  fit: .contain,
                                  imageUrl: item.getLogo(),
                                ),
                              ),
                            ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              FButton(
                                style: .delta(
                                  contentStyle: .delta(
                                    constraints: BoxConstraints(
                                      minWidth: 120,
                                      maxWidth: 120,
                                    ),
                                  ),
                                ),
                                onPress: () {},
                                prefix: Icon(FPhosphorBoldIcons.play),
                                child: _playButtonLabel(item, next),
                              ),
                              Icon(FPhosphorBoldIcons.dot),
                              Row(
                                spacing: 8,
                                children: [
                                  FavoriteButton(
                                    item: item,
                                    onToggleFavorite: () async {
                                      if (widget.onToggleFavorite != null) {
                                        await widget.onToggleFavorite!();
                                      }
                                    },
                                  ),
                                  PlayedButton(
                                    item: item,
                                    onTogglePlayed: () async {
                                      if (widget.onTogglePlayed != null) {
                                        await widget.onTogglePlayed!();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              if (duration != null) Text(duration),
                              Text('Ends at $endsAt'),
                            ].separatedBy(Icon(FPhosphorBoldIcons.dot)),
                          ),
                          Row(
                            children: item.genres
                                .map((g) => Text(g))
                                .toList()
                                .separatedBy(Icon(FPhosphorBoldIcons.dot)),
                          ),
                          Row(
                            children: [
                              if (year != null)
                                IconText(
                                  text: year.toString(),
                                  icon: FPhosphorBoldIcons.calendar,
                                ),
                              if (parentalRating != null)
                                RatingContainer(rating: parentalRating),
                              if (rating != null)
                                StarRatingContainer(
                                  rating: rating.toStringAsFixed(2),
                                ),
                            ].separatedBy(Icon(FPhosphorBoldIcons.dot)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: theme.colors.barrier,
                borderRadius: theme.style.borderRadius.md,
              ),
              padding: .all(10),
              child: Text(item.getOverview() ?? 'No overview'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _playButtonLabel(JellyfinItem? tv, JellyfinItem? next) {
    if (widget._variant == .tv) {
      final progress = tv?.getPlayProgress() ?? 0;

      if (progress < 1) {
        return Text('S${next?.parentIndexNumber}:E${next?.indexNumber}');
      } else if (progress == 1) {
        return Text('Rewatch');
      }
    } else {
      if (tv!.isResumable) {
        return Text('Resume');
      }
    }

    return Text('Play');
  }
}
