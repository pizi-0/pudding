import 'package:animate_do/animate_do.dart';
import 'package:awesome_extensions/awesome_extensions_dart.dart';
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:pudding/providers/media_cache_provider.dart';
import 'package:pudding/providers/series_detail_provider.dart';
import 'package:pudding/services/di.dart';
import 'package:pudding/utils/jellyfin_item_extensions.dart';
import 'package:pudding/widgets/logo_shimmer.dart';

class TvDetailScreen extends ConsumerStatefulWidget {
  final String? showId;
  const TvDetailScreen({super.key, this.showId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ShowsDetailScreensState();
}

class _ShowsDetailScreensState extends ConsumerState<TvDetailScreen> {
  String selectedSeasonId = '';

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final style = theme.style;

    final mediaCache = ref.watch(mediaCacheProvider);
    final detAsync = ref.watch(seriesDetailProvider(widget.showId!));
    final detNotifier = ref.read(seriesDetailProvider(widget.showId!).notifier);

    return Stack(
      fit: .expand,
      children: [
        Positioned.fill(
          child: CachedNetworkImage(
            imageUrl: services<JellyfinClient>().images.url(
              itemId: widget.showId!,
              type: JellyfinImagesApi.typeBackdrop,
            ),
            errorBuilder: (context, error, stackTrace) => Align(
              alignment: .bottomRight,
              child: Text(
                'Backdrop error: ${error.toString()}',
                style: theme.typography.body.xs2.copyWith(
                  fontStyle: .italic,
                  color: theme.colors.foreground.withAlpha(150),
                ),
              ),
            ),
            fit: .cover,
            color: Colors.black.withAlpha(230),
            colorBlendMode: .darken,
          ),
        ),
        detAsync.when(
          skipLoadingOnReload: true,
          loading: () => Center(
            child: LogoShimmer(
              id: widget.showId!,
            ).fadeIn(delay: 100.milliseconds),
          ),
          error: (error, stackTrace) => Center(
            child: Text(error.toString()),
          ),
          data: (data) {
            final item = ref.watch(mediaCacheProvider)[data.seriesId]!;

            final seasons = data.seasonIds.map((e) => mediaCache[e]);

            final episodes = data.episodeIds
                .map((e) => mediaCache[e])
                .where((e) => e?.seasonId == data.selectedSeasonId);

            return Stack(
              fit: .expand,
              children: [
                Positioned.fill(
                  top: kToolbarHeight + 8,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: IntrinsicWidth(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              spacing: 10,
                              mainAxisAlignment: .center,
                              children: [
                                Row(
                                  spacing: 10,
                                  children: [
                                    FButton.icon(
                                      onPress: () {},
                                      child: Icon(FLucideIcons.chevronLeft),
                                    ),
                                    Expanded(
                                      child: FSelect.rich(
                                        control: .managed(
                                          initial: seasons.firstWhereOrNull(
                                            (e) =>
                                                e?.id == data.selectedSeasonId,
                                          ),
                                          onChange: (value) {
                                            detNotifier.setSelectedSeason(
                                              value!.id,
                                            );
                                          },
                                        ),
                                        format: (value) => value.name,
                                        children: seasons
                                            .map(
                                              (s) => FSelectItem.item(
                                                title: Text(s!.name),
                                                value: s,
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                    FButton.icon(
                                      onPress: () {},
                                      child: Icon(FLucideIcons.chevronRight),
                                    ),
                                  ],
                                ),
                                ClipRRect(
                                  borderRadius: style.borderRadius.lg,
                                  child: CachedNetworkImage(
                                    imageUrl: item.getPrimary(),
                                    fit: .cover,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: .center,
                                  children: [
                                    Text(item.getSeriesRunYears()),
                                    Text('${item.childCount} seasons'),
                                    if (item.getOfficialRating() != null)
                                      Container(
                                        height:
                                            theme.typography.body.lg.fontSize,
                                        decoration: BoxDecoration(
                                          border: .all(
                                            color: theme.colors.foreground,
                                          ),
                                          borderRadius: .circular(4),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 1.5,
                                            horizontal: 3,
                                          ),
                                          child: FittedBox(
                                            child: Text(
                                              item.getOfficialRating()!,
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (item.getCommunityRating() != null)
                                      Row(
                                        spacing: 4,
                                        children: [
                                          Icon(
                                            FLucideIcons.star,
                                            size: theme
                                                .typography
                                                .body
                                                .sm
                                                .fontSize,
                                          ),
                                          Text(
                                            item
                                                .getCommunityRating()!
                                                .toString(),
                                          ),
                                        ],
                                      ),
                                  ].separatedby(Icon(FLucideIcons.dot)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                primary: false,
                                itemCount: episodes.length,
                                itemBuilder: (context, index) {
                                  final item = episodes.elementAt(index);
                                  return Text(item?.name ?? '');
                                },
                              ),
                              FButton(
                                onPress: detNotifier.refreshData,
                                child: Text('refresh'),
                              ),
                              SelectableText(item.getRaw()),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ).fadeIn();
          },
        ),
      ],
    );
  }
}
