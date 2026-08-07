import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:pudding/models/jelly_people.dart';
import 'package:pudding/providers/jelly_cache_provider.dart';
import 'package:pudding/providers/series_detail_provider.dart';
import 'package:pudding/services/di.dart';
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
    final style = theme.style;
    final jellyCache = ref.watch(jellyCacheProvider);
    final series = jellyCache[widget.seriesId]!;
    final detAsync = ref.watch(seriesDetailProvider(widget.seriesId));
    final detNoti = ref.read(seriesDetailProvider(widget.seriesId).notifier);

    return detAsync.when(
      skipLoadingOnRefresh: true,
      skipLoadingOnReload: true,
      loading: () => FCircularProgress(),
      error: (error, stackTrace) => Center(
        child: Text(error.toString()),
      ),
      data: (data) {
        final selectedSeason = jellyCache[data.selectedSeasonId]!;
        final nextUpItem = jellyCache[data.nextUp];

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
                        child: SizedBox(
                          height: 150,
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: CachedNetworkImage(
                              imageUrl: series.getLogo(),
                              height: 150,
                              errorBuilder: (context, error, stackTrace) =>
                                  ClipRRect(
                                    borderRadius: style.borderRadius.sm,
                                    child: CachedNetworkImage(
                                      imageUrl: series.getBackdrop(),
                                      height: 150,
                                      fit: .cover,
                                    ),
                                  ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 150,
                        child: FDivider(
                          axis: .vertical,
                          style: .delta(padding: .value(.zero)),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: .start,
                          mainAxisAlignment: .center,
                          spacing: 10,
                          children: [
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        series.getTitle(),
                                        style: theme.typography.display.xl
                                            .copyWith(height: 1.5),
                                      ).bold(),
                                    ),
                                  ],
                                ),
                                if (series.getTitle().toLowerCase() !=
                                    series.raw['OriginalTitle']
                                        ?.toString()
                                        .toLowerCase())
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          series.raw['OriginalTitle'],
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
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
                      ),
                    ],
                  ),
                ),
              ),
              FDivider(
                style: .delta(padding: .value(.zero)),
              ),

              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SectionSliver(
                      title: 'Genres',
                      sliver: SliverToBoxAdapter(
                        child: Wrap(
                          runSpacing: 8,
                          spacing: 8,
                          children: series.genres
                              .map(
                                (g) => FBadge(
                                  variant: .outline,
                                  child: Text(g.capitalize),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                    SectionSliver(
                      title: 'Tags',
                      sliver: SliverToBoxAdapter(
                        child: Wrap(
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
                      ),
                    ),
                    SectionSliver(
                      title: 'Series Summary',
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: .start,
                          children: [
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
                      ),
                    ),
                    SectionSliver(
                      title: '${selectedSeason.name} Summary',
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: .start,
                          children: [
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
                      ),
                    ),
                    SectionSliver(
                      title: 'Next episode Summary',
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: .start,
                          children: [
                            if (nextUpItem?.getOverview() != null &&
                                (nextUpItem?.getOverview()?.isNotEmpty ??
                                    false))
                              Text(nextUpItem!.getOverview()!.trim())
                            else
                              Text(
                                'No overview',
                                style: theme.typography.body.sm.copyWith(
                                  fontStyle: .italic,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    SectionSliver(
                      title: data.showSeriesCast
                          ? 'Series casts & crews'
                          : '${selectedSeason.name} Casts & Crews',
                      titleTrailing: FButton.icon(
                        variant: .ghost,
                        onPress: detNoti.toggleSeriesCast,
                        child: Icon(FLucideIcons.arrowLeftRight),
                      ),
                      sliver: PeopleGrid(
                        peoples: data.showSeriesCast
                            ? series.getPeoples()
                            : selectedSeason.getPeoples(),
                      ),
                    ),
                    // SliverToBoxAdapter(
                    //   child: SelectableText(
                    //     series.getRaw(),
                    //   ),
                    // ),
                  ].separatedby(SliverPadding(padding: .only(bottom: 20))),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class PeopleGrid extends StatelessWidget {
  final List<JellyPeople> peoples;

  const PeopleGrid({
    super.key,
    required this.peoples,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final style = theme.style;
    return SliverGrid.builder(
      key: ValueKey(peoples.toString()),
      itemCount: peoples.length,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1 / 1.35,
        maxCrossAxisExtent: 180,
      ),
      itemBuilder: (context, index) {
        final people = peoples[index];

        return FButton.raw(
          variant: .outline,
          onPress: () {},
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: ClipRRect(
              borderRadius: style.borderRadius.sm,
              child: Stack(
                fit: .expand,
                children: [
                  Positioned.fill(
                    child: ShaderMask(
                      shaderCallback: (rect) => LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black,
                        ],
                        stops: [0.4, 1],
                        begin: .topCenter,
                        end: .bottomCenter,
                      ).createShader(rect),
                      blendMode: .darken,
                      child: CachedNetworkImage(
                        imageUrl: services<JellyfinClient>().images.url(
                          itemId: people.Id,
                        ),
                        fit: .cover,
                        height: 50,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.black,
                          child: Icon(
                            FLucideIcons.user,
                            size: 50,
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
                        mainAxisSize: .min,
                        children: [
                          FittedBox(
                            child: Text(
                              people.Name,
                              textAlign: .center,
                              style: theme.typography.body.sm,
                            ).bold(),
                          ),
                          Text(
                            'as ${people.Role}',
                            textAlign: .center,
                            style: theme.typography.body.xs,
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
      },
    );
  }
}

class SectionSliver extends StatelessWidget {
  final String title;
  final Widget? titleTrailing;
  final Widget sliver;
  const SectionSliver({
    super.key,
    this.titleTrailing,
    required this.title,
    required this.sliver,
  });

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        PinnedHeaderSliver(
          child: Row(
            children: [
              Icon(FLucideIcons.dot),
              Text(
                title.toUpperCase(),
              ).bold(),
              ?titleTrailing,
            ],
          ).setOpacity(opacity: 0.5),
        ),
        sliver,
      ].separatedby(SliverPadding(padding: .only(bottom: 4))),
    );
  }
}
