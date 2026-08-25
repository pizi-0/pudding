import 'package:awesome_extensions/awesome_extensions.dart' show ListExtension;
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:pudding/const/const.dart';
import 'package:pudding/screens/detail_screens/widgets/season_selector.dart';
import 'package:pudding/screens/tvshow_detail/provider/tvshow_state_provider.dart';
import 'package:pudding/services/di.dart';
import 'package:pudding/utils/jellyfin_item_extensions.dart';
import 'package:pudding/widgets/logo_shimmer.dart';
import 'package:pudding/widgets/media_card.dart';
import 'package:pudding/widgets/people_grid.dart';
import 'package:pudding/widgets/pudding_scaffold.dart';
import 'package:pudding/widgets/sliver_header.dart';
import 'package:silky_scroll/silky_scroll.dart';

import '../../widgets/sliver_section.dart';

final client = services<JellyfinClient>();

class TvshowDetail extends ConsumerStatefulWidget {
  final String id;

  const TvshowDetail({super.key, required this.id});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TvshowDetailState();
}

class _TvshowDetailState extends ConsumerState<TvshowDetail> {
  final GlobalKey seasonKey = GlobalKey(debugLabel: 'season-sliver-header');
  final GlobalKey castsKey = GlobalKey(debugLabel: 'cast-sliver-header');
  bool favoriteLoading = false;
  bool playedLoading = false;
  ValueNotifier<double> scrollOffset = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(tvshowStateProvider(widget.id));
    });
  }

  @override
  void dispose() {
    scrollOffset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    final size = MediaQuery.sizeOf(context);

    final tvAsync = ref.watch(tvshowStateProvider((widget.id)));
    final tvNotifier = ref.read(tvshowStateProvider(widget.id).notifier);

    final max = size.width < theme.breakpoints.md;

    final overviewWidth = max ? size.width : size.width * 0.6;

    final crossAxisAlignment = max
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;

    return PuddingScaffold(
      backdrop: ValueListenableBuilder(
        valueListenable: scrollOffset,
        builder: (context, value, child) {
          return ImageFiltered(
            imageFilter: .blur(sigmaX: value * 10, sigmaY: value * 10),
            child: CachedNetworkImage(
              imageUrl: client.images.url(
                itemId: widget.id,
                type: JellyfinImagesApi.typeBackdrop,
              ),
              fit: .cover,
              errorBuilder: (context, error, stackTrace) => CachedNetworkImage(
                imageUrl: client.images.url(
                  itemId: widget.id,
                  type: JellyfinImagesApi.typePrimary,
                ),
              ),
            ),
          );
        },
      ),
      child: SilkyCustomScrollView(
        physics: ClampingScrollPhysics(),
        slivers: [
          tvAsync.when(
            skipLoadingOnReload: true,
            loading: () => SliverFillViewport(
              delegate: SliverChildListDelegate.fixed([
                Center(
                  child: LogoShimmer(id: widget.id),
                ),
              ]),
            ),
            error: (error, stackTrace) => SliverFillViewport(
              delegate: SliverChildListDelegate.fixed([
                Center(
                  child: Column(
                    mainAxisAlignment: .center,
                    children: [
                      Text(error.toString()),
                      Row(
                        mainAxisAlignment: .center,
                        children: [
                          FButton.icon(
                            onPress: context.pop,
                            child: Icon(FLucideIcons.chevronLeft),
                          ),

                          FButton.icon(
                            onPress: () =>
                                ref.invalidate(tvshowStateProvider(widget.id)),
                            child: Icon(FLucideIcons.chevronLeft),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ]),
            ),
            data: (state) {
              final tv = state.tvshow;
              final logo = tv.imageTags[JellyfinImagesApi.typeLogo];
              final genres = tv.genres.sublist(
                0,
                tv.genres.length > 3 ? 3 : tv.genres.length,
              );

              final isPlayed = tv.userData?.played ?? false;
              final isFavorite = tv.isFavorite;
              final overview = tv.overview;
              final runYears = tv.getSeriesRunYears();
              final seasonCount = tv.childCount;
              final int? episodeCount = tv.raw['RecursiveItemCount'];
              final unplayed = tv.getUnplayed();

              return SliverMainAxisGroup(
                slivers: [
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: SliverHeader(
                      onScroll: (value) => scrollOffset.value = value,
                      maxExtentHeight: size.height - 76,
                      minExtentHeight: 76,
                      shouldRefresh: tvAsync.isLoading,
                      bar: ValueListenableBuilder(
                        valueListenable: scrollOffset,
                        builder: (context, value, child) {
                          final shadow = BoxShadow(
                            color: theme.colors.background,
                            spreadRadius: 10 * value,
                            blurRadius: 10,
                          );

                          return Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              children: [
                                FButton.icon(
                                  style: .delta(
                                    decoration: .delta([
                                      .all(.boxDelta(boxShadow: [shadow])),
                                    ]),
                                  ),
                                  onPress: context.pop,
                                  child: Icon(FLucideIcons.chevronLeft),
                                ),
                                Icon(FLucideIcons.dot),
                                Expanded(
                                  child: Row(
                                    children: [
                                      FButton(
                                        style: .delta(
                                          decoration: .delta([
                                            .all(
                                              .boxDelta(boxShadow: [shadow]),
                                            ),
                                          ]),
                                        ),
                                        variant: .outline,
                                        onPress: () {},
                                        child: Text(tv.name),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(FLucideIcons.dot),
                                FButton.icon(
                                  style: .delta(
                                    decoration: .delta([
                                      .all(.boxDelta(boxShadow: [shadow])),
                                    ]),
                                  ),
                                  onPress: context.pop,
                                  child: Icon(FLucideIcons.refreshCcw),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      child: SizedBox(
                        height: size.height,
                        width: size.width,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(40, 0, 40, 40),
                          child: Column(
                            crossAxisAlignment: crossAxisAlignment,
                            mainAxisAlignment: .end,
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 450),
                                child: Column(
                                  spacing: 16,
                                  children: [
                                    if (logo != null)
                                      CachedNetworkImage(
                                        imageUrl: tv.getLogo(),
                                      ),

                                    if (genres.isNotEmpty)
                                      Row(
                                        mainAxisAlignment: .center,
                                        children: genres
                                            .map(
                                              (g) => Text(g),
                                            )
                                            .toList()
                                            .separatedBy(
                                              Icon(FLucideIcons.dot),
                                            ),
                                      ),
                                    FittedBox(
                                      child: Row(
                                        mainAxisAlignment: .center,
                                        spacing: 4,
                                        children: [
                                          FTooltip(
                                            tipBuilder: (context, controller) =>
                                                Text('Trailer'),
                                            child: FButton.icon(
                                              onPress: () {},
                                              child: Icon(
                                                FLucideIcons.film,
                                              ),
                                            ),
                                          ),
                                          Icon(FLucideIcons.dot),
                                          FButton(
                                            style: .delta(
                                              contentStyle: .delta(
                                                constraints: BoxConstraints(
                                                  maxWidth: 200,
                                                ),
                                              ),
                                            ),
                                            onPress: () {},
                                            prefix: Icon(FLucideIcons.play),
                                            child: Text('Play'),
                                          ),
                                          Icon(FLucideIcons.dot),
                                          FTooltip(
                                            tipBuilder: (context, controller) =>
                                                Text(
                                                  isFavorite
                                                      ? 'Unfavorite'
                                                      : 'Favorite',
                                                ),
                                            child: FButton.icon(
                                              onPress:
                                                  tvAsync.isLoading &&
                                                      favoriteLoading
                                                  ? null
                                                  : () => _toggleFavorite(
                                                      isFavorite,
                                                    ),
                                              child: Icon(
                                                FLucideIcons.heart,
                                                color: isFavorite
                                                    ? Colors.pink
                                                    : null,
                                              ),
                                            ),
                                          ),
                                          FButton.icon(
                                            onPress:
                                                tvAsync.isLoading &&
                                                    playedLoading
                                                ? null
                                                : () => _togglePlayed(
                                                    isPlayed,
                                                  ),
                                            child: Icon(
                                              FLucideIcons.check,
                                              color: isPlayed
                                                  ? Colors.green
                                                  : null,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: .center,
                                      children: [
                                        Text(runYears),
                                        if (seasonCount != null)
                                          Text('$seasonCount seasons'),
                                        if (episodeCount != null)
                                          Text('$episodeCount episodes'),
                                        if (unplayed != null)
                                          Text('$unplayed unplayed'),
                                      ].separatedBy(Icon(FLucideIcons.dot)),
                                    ),
                                  ],
                                ),
                              ),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: overviewWidth,
                                ),
                                child: Column(
                                  crossAxisAlignment: .start,
                                  children: [
                                    FDivider(),

                                    Text(overview ?? 'No overview'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverSection(
                    key: seasonKey,
                    header: Align(
                      alignment: .centerStart,
                      child: Row(
                        spacing: 20,
                        mainAxisSize: .min,
                        children: [
                          SeasonSelector(
                            seriesId: widget.id,
                            selectedSeasonItem: state.selectedSeason,
                            seasonItems: state.seasons,
                            onSeasonChange: (s) => tvNotifier
                                .onSeasonChanged(s.id)
                                .then((_) => _scrollToKey(seasonKey)),
                          ),
                        ],
                      ),
                    ),
                    slivers: [
                      SliverPadding(
                        padding: .fromLTRB(20, 0, 20, 20),
                        sliver: SliverGrid.builder(
                          itemCount: state.episodes.length,
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 350,
                                childAspectRatio: 16 / 10,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                              ),
                          itemBuilder: (context, index) {
                            final ep = state.episodes[index];

                            return NewMediaCard(item: ep);
                          },
                        ),
                      ),
                    ],
                  ),
                  SliverSection(
                    key: castsKey,
                    header: FButton(
                      variant: .outline,
                      onPress: () {
                        _scrollToKey(castsKey);
                      },
                      child: Text('Cast & Crew'),
                    ),
                    slivers: [
                      SliverPadding(
                        padding: .fromLTRB(20, 0, 20, 20),
                        sliver: PeopleGrid(peoples: tv.getPeoples()),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _scrollToKey(GlobalKey key) {
    if (key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        alignment: 0,
        duration: kDefaultAnimationDuration,
      );
    }
  }

  Future<void> _toggleFavorite(bool isFavorite) async {
    if (favoriteLoading) return;

    try {
      favoriteLoading = true;

      if (isFavorite) {
        await client.userData.unmarkFavorite(
          widget.id,
        );
      } else {
        await client.userData.markFavorite(
          widget.id,
        );
      }

      ref.invalidate(
        tvshowStateProvider(widget.id),
      );
    } on Exception catch (e) {
      debugPrint(e.toString());
    } finally {
      favoriteLoading = false;
    }
  }

  Future<void> _togglePlayed(bool isPlayed) async {
    if (playedLoading) return;

    try {
      playedLoading = true;

      if (isPlayed) {
        await client.userData.markUnplayed(widget.id);
      } else {
        await client.userData.markPlayed(widget.id);
      }

      ref.invalidate(
        tvshowStateProvider(widget.id),
      );
    } on Exception catch (e) {
      debugPrint(e.toString());
    } finally {
      playedLoading = false;
    }
  }
}
