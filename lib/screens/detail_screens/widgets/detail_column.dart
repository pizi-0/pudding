import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:pudding/providers/media_cache_provider.dart';
import 'package:pudding/providers/series_detail_provider.dart';
import 'package:pudding/utils/jellyfin_item_extensions.dart';

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

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: CustomScrollView(
            slivers: [
              PinnedHeaderSliver(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    spacing: 8,
                    crossAxisAlignment: .center,
                    children: [
                      Flexible(
                        child: CachedNetworkImage(
                          imageUrl: selectedSeason.getLogo(),
                          width: 300,
                          height: 100,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: .start,
                        children: [
                          Row(
                            children: [
                              Text(series.getSeriesRunYears()),
                              Text('${series.childCount} seasons'),
                              if (series.getOfficialRating() != null)
                                Text(series.getOfficialRating() ?? ''),
                            ].separatedby(Icon(FLucideIcons.dot)),
                          ),
                          Row(
                            children: [
                              Text('${data.episodeIds.length} episodes'),

                              Text(
                                '${series.raw['UserData']['UnplayedItemCount'] ?? 0} left',
                              ),
                            ].separatedby(Icon(FLucideIcons.dot)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverMainAxisGroup(
                slivers: [
                  SliverToBoxAdapter(
                    child: Text('Genres'),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: SelectableText(series.getRaw()),
              ),
            ],
          ),
        );

        // return Padding(
        //   padding: const EdgeInsets.all(20.0),
        //   child: SingleChildScrollView(
        //     child: Column(
        //       spacing: 20,
        //       crossAxisAlignment: .start,
        //       children: [
        //         Row(
        //           children: [
        //             CachedNetworkImage(
        //               imageUrl: series.getLogo(),
        //               height: 100,
        //             ),
        //           ],
        //         ),
        //         Column(
        //           crossAxisAlignment: .start,
        //           spacing: 4,
        //           children: [
        //             Text(
        //               'Genres'.toUpperCase(),
        //             ).bold().setOpacity(opacity: 0.5),
        //             Wrap(
        //               runSpacing: 8,
        //               spacing: 8,
        //               children: series.genres
        //                   .map((g) => FBadge(variant: .outline, child: Text(g)))
        //                   .toList(),
        //             ),
        //           ],
        //         ),
        //         Column(
        //           crossAxisAlignment: .start,
        //           spacing: 4,
        //           children: [
        //             Text(
        //               'Tags'.toUpperCase(),
        //             ).bold().setOpacity(opacity: 0.5),
        //             Wrap(
        //               runSpacing: 8,
        //               spacing: 8,
        //               children: series.tags
        //                   .map(
        //                     (g) => FBadge(
        //                       variant: .outline,
        //                       child: Text(g.capitalize),
        //                     ),
        //                   )
        //                   .toList(),
        //             ),
        //           ],
        //         ),
        //         Column(
        //           crossAxisAlignment: .start,
        //           spacing: 4,
        //           children: [
        //             Text(
        //               'Series Summary'.toUpperCase(),
        //             ).bold().setOpacity(opacity: 0.5),
        //             Text(series.getOverview()?.trim() ?? 'No overview'),
        //           ],
        //         ),
        //         Column(
        //           crossAxisAlignment: .start,
        //           spacing: 4,
        //           children: [
        //             Text(
        //               '${selectedSeason.name} Summary'.toUpperCase(),
        //             ).bold().setOpacity(opacity: 0.5),
        //             Text(selectedSeason.getOverview()?.trim() ?? 'No overview'),
        //           ],
        //         ),

        //         // Wrap(
        //         //   spacing: 8,
        //         //   runSpacing: 8,
        //         //   children: series
        //         //       .getPeoples()
        //         //       .map(
        //         //         (p) => Column(
        //         //           children: [
        //         //             Container(
        //         //               clipBehavior: .antiAlias,
        //         //               height: 100,
        //         //               width: 100,
        //         //               decoration: BoxDecoration(
        //         //                 shape: .circle,
        //         //                 color: theme.colors.card,
        //         //               ),
        //         //               child: CachedNetworkImage(
        //         //                 imageUrl: services<JellyfinClient>().images.url(
        //         //                   itemId: p.Id,
        //         //                 ),
        //         //                 fit: .cover,
        //         //                 errorBuilder: (context, error, stackTrace) =>
        //         //                     Icon(
        //         //                       FLucideIcons.user,
        //         //                       size: 50,
        //         //                     ),
        //         //               ),
        //         //             ),
        //         //             Text(p.Name),
        //         //             Text(p.Role),
        //         //           ],
        //         //         ),
        //         //       )
        //         //       .toList(),
        //         // ),
        //         SelectableText(series.getRaw()),
        //       ],
        //     ),
        //   ),
        // );
      },
    );
  }
}
