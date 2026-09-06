import 'package:awesome_extensions/awesome_extensions.dart' show ListExtension;
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:forui_phosphor/forui_phosphor.dart';
import 'package:morphnext/morphnext.dart';
import 'package:pudding/utils/jellyfin_item_extensions.dart';
import 'package:pudding/widgets/icon_text.dart';
import 'package:pudding/widgets/rating_container.dart';
import 'package:pudding/widgets/star_rating_container.dart';

enum _ShowcaseVariant { general, tv }

class SliverShowcase extends ConsumerStatefulWidget {
  final JellyfinItem item;
  final JellyfinItem? nextup;
  final double? maxExtent;
  final _ShowcaseVariant _variant;
  final void Function()? onToggleFavorite;
  final void Function()? onTogglePlayed;
  const SliverShowcase({
    super.key,
    required this.item,
    this.nextup,
    this.maxExtent,
    this.onToggleFavorite,
    this.onTogglePlayed,
  }) : _variant = .general;

  const SliverShowcase.tv({
    super.key,
    required this.item,
    required this.nextup,
    this.maxExtent,
    this.onToggleFavorite,
    this.onTogglePlayed,
  }) : _variant = .tv;

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

    final parentalRating = item.getOfficialRating();
    final rating = item.getCommunityRating();

    return SliverToBoxAdapter(
      child: Align(
        alignment: .bottomStart,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: widget.maxExtent ?? size.height,
            maxWidth: overviewWidth,
          ),
          child: Column(
            spacing: 10,
            mainAxisAlignment: .end,
            crossAxisAlignment: crossAxisAlignment,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 400),
                  child: Column(
                    spacing: 20,
                    crossAxisAlignment: crossAxisAlignment,
                    children: [
                      FittedBox(
                        child: CachedNetworkImage(
                          imageUrl: item.getLogo(),
                          width: 400,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: .center,
                        children: [
                          Expanded(
                            child: FButton(
                              mainAxisSize: .max,
                              onPress: () {},
                              prefix: Icon(FPhosphorBoldIcons.play),
                              child: _playButtonLabel(item, next),
                            ),
                          ),
                          Icon(FPhosphorBoldIcons.dot),
                          Row(
                            spacing: 8,
                            children: [
                              FButton.icon(
                                onPress: widget.onToggleFavorite,
                                child: AnimatedMorphIcon(
                                  icon: FPhosphorBoldIcons.heart,
                                  color: item.isFavorite
                                      ? theme.colors.primary
                                      : null,
                                ),
                              ),
                              FButton.icon(
                                onPress: widget.onTogglePlayed,
                                child: AnimatedMorphIcon(
                                  icon: FPhosphorBoldIcons.check,
                                  color: (item.userData?.played ?? false)
                                      ? Colors.green
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: .min,
                        children: [
                          IconText(
                            text: item.getYear(),
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
    }

    return Text('Play');
  }
}
