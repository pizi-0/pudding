import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:pudding/providers/media_cache_provider.dart';
import 'package:pudding/providers/series_detail_provider.dart';
import 'package:pudding/utils/jellyfin_item_extensions.dart';
import 'package:pudding/widgets/rating_container.dart';
import 'package:pudding/widgets/star_rating_container.dart';

class DetailColumn extends ConsumerStatefulWidget {
  final String seriesId;
  const DetailColumn({super.key, required this.seriesId});

  @override
  ConsumerState<DetailColumn> createState() => _DetailColumnState();
}

class _DetailColumnState extends ConsumerState<DetailColumn>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final mediaCache = ref.watch(mediaCacheProvider);
    final series = mediaCache[widget.seriesId]!;
    final detAsync = ref.watch(seriesDetailProvider(widget.seriesId));

    return detAsync.when(
      loading: () => FCircularProgress(),
      error: (error, stackTrace) => Center(
        child: Text(error.toString()),
      ),
      data: (data) {
        final selectedSeason = mediaCache[data.selectedSeasonId]!;
        final nextUpItem = mediaCache[data.nextUp];

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            spacing: 10,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IntrinsicHeight(
                  child: Row(
                    spacing: 10,
                    children: [
                      Flexible(
                        child: CachedNetworkImage(
                          imageUrl: series.getLogo(),
                          height: 100,
                          width: 300,
                        ),
                      ),
                      SizedBox(
                        height: 100,
                        child: FDivider(
                          axis: .vertical,
                          style: .delta(padding: .value(.zero)),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: .start,
                        mainAxisAlignment: .center,
                        spacing: 10,
                        children: [
                          Row(
                            children: [
                              Text(series.getSeriesRunYears()),
                              if (series.getOfficialRating() != null)
                                RatingContainer(
                                  rating: series.getOfficialRating()!,
                                ),
                              if (series.getCommunityRating() != null)
                                StarRatingContainer(
                                  rating: series
                                      .getCommunityRating()!
                                      .toStringAsFixed(1),
                                ),
                            ].separatedby(Icon(FLucideIcons.dot)),
                          ),
                          if (nextUpItem != null)
                            Row(
                              spacing: 8,
                              children: [
                                FButton(
                                  onPress: () {},
                                  prefix: Icon(FLucideIcons.play),
                                  child: Row(
                                    children: [
                                      Text(nextUpItem.getTitle(short: true)),
                                      Text(
                                        'Ends at ${nextUpItem.getEndsAt(context)}',
                                      ),
                                    ].separatedby(Icon(FLucideIcons.dot)),
                                  ),
                                ),
                                Row(
                                  spacing: 8,
                                  children: [
                                    FButton.icon(
                                      onPress: () {},
                                      child: Icon(FLucideIcons.heart),
                                    ),
                                    FButton.icon(
                                      onPress: () {},
                                      child: Icon(FLucideIcons.check),
                                    ),
                                  ],
                                ),
                              ].separatedby(Icon(FLucideIcons.dot)),
                            ),

                          // Row(
                          //   children: [
                          //     Text('${series.getSeasons().toString()} seasons'),
                          //   ].separatedby(Icon(FLucideIcons.dot)),
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              FDivider(
                style: .delta(padding: .value(.zero)),
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    spacing: 20,
                    crossAxisAlignment: .start,
                    children: [
                      Column(
                        crossAxisAlignment: .start,
                        spacing: 4,
                        children: [
                          Text(
                            'Genres'.toUpperCase(),
                          ).bold().setOpacity(opacity: 0.5),
                          Wrap(
                            runSpacing: 8,
                            spacing: 8,
                            children: series.genres
                                .map(
                                  (g) =>
                                      FBadge(variant: .outline, child: Text(g)),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: .start,
                        spacing: 4,
                        children: [
                          Text(
                            'Tags'.toUpperCase(),
                          ).bold().setOpacity(opacity: 0.5),
                          Wrap(
                            runSpacing: 8,
                            spacing: 8,
                            children: series.tags
                                .map(
                                  (g) => FBadge(
                                    variant: .outline,
                                    child: Text(g.capitalize),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: .start,
                        spacing: 4,
                        children: [
                          Text(
                            'Series Summary'.toUpperCase(),
                          ).bold().setOpacity(opacity: 0.5),
                          if (series.getOverview() != null &&
                              (series.getOverview()?.isNotEmpty ?? false))
                            Text(series.getOverview()!.trim())
                          else
                            Text(
                              'No overview',
                              style: theme.typography.body.sm.copyWith(
                                fontStyle: .italic,
                              ),
                            ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: .start,
                        spacing: 4,
                        children: [
                          Text(
                            '${selectedSeason.name} Summary'.toUpperCase(),
                          ).bold().setOpacity(opacity: 0.5),
                          if (selectedSeason.getOverview() != null &&
                              (selectedSeason.getOverview()?.isNotEmpty ??
                                  false))
                            Text(selectedSeason.getOverview()!.trim())
                          else
                            Text(
                              'No overview',
                              style: theme.typography.body.sm.copyWith(
                                fontStyle: .italic,
                              ),
                            ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: .start,
                        spacing: 4,
                        children: [
                          Text(
                            'Next episode Summary'.toUpperCase(),
                          ).bold().setOpacity(opacity: 0.5),
                          if (nextUpItem!.getOverview() != null &&
                              (nextUpItem.getOverview()?.isNotEmpty ?? false))
                            Text(nextUpItem.getOverview()!.trim())
                          else
                            Text(
                              'No overview',
                              style: theme.typography.body.sm.copyWith(
                                fontStyle: .italic,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
