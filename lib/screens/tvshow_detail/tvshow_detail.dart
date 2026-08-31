import 'package:awesome_extensions/awesome_extensions.dart'
    show ListExtension, OpacityExtension, StyledText, WidgetCommonExtension;
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:forui_phosphor/forui_phosphor.dart';
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
  ScrollController scrollController = ScrollController();
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
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    final size = MediaQuery.sizeOf(context);

    final tvAsync = ref.watch(tvshowStateProvider((widget.id)));
    final tvNotifier = ref.read(tvshowStateProvider(widget.id).notifier);

    final max = size.width < theme.breakpoints.md;

    final overviewWidth = max ? size.width : size.width * 0.4;

    final crossAxisAlignment = max
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;

    return PuddingScaffold(
      backdrop: ValueListenableBuilder(
        valueListenable: scrollOffset,
        builder: (context, value, child) {
          return ImageFiltered(
            imageFilter: .compose(
              outer: .blur(
                sigmaX: (value * 250).clamp(0, 100),
                sigmaY: (value * 250).clamp(0, 100),
                tileMode: .clamp,
              ),
              inner: ColorFilter.mode(
                Color.lerp(
                  theme.colors.background.withAlpha(180),
                  theme.colors.background.withAlpha(200),
                  value,
                )!,
                .dstOut,
              ),
            ),
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
        controller: scrollController,
        scrollSpeed: 2,
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
                            child: Icon(FPhosphorBoldIcons.caretLeft),
                          ),

                          FButton.icon(
                            onPress: () =>
                                ref.invalidate(tvshowStateProvider(widget.id)),
                            child: Icon(FPhosphorBoldIcons.caretLeft),
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
              final next = state.nextup;
              final season = state.selectedSeason;
              final logo = tv?.imageTags[JellyfinImagesApi.typeLogo];
              final genres = tv?.genres.sublist(
                0,
                tv.genres.length > 3 ? 3 : tv.genres.length,
              );

              final isPlayed = tv?.userData?.played ?? false;
              final isFavorite = tv?.isFavorite ?? false;
              final overview = tv?.overview;
              final runYears = tv?.getSeriesRunYears();
              final seasonCount = tv?.childCount;
              final int? episodeCount = tv?.raw['RecursiveItemCount'];
              final unplayed = tv?.getUnplayed();

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
                            color: Color.lerp(
                              Colors.transparent,
                              theme.colors.background,
                              value,
                            )!,
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
                                  child: Icon(FPhosphorBoldIcons.caretLeft),
                                ),
                                Icon(FPhosphorBoldIcons.dot),
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
                                        onPress: () =>
                                            scrollController.animateTo(
                                              0,
                                              duration:
                                                  kDefaultAnimationDuration,
                                              curve: Curves.easeInOut,
                                            ),
                                        suffix: FCircularProgress().showIf(
                                          tvAsync.isLoading,
                                        ),
                                        child: Text('${tv?.name}'),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(FPhosphorBoldIcons.dot),
                                FButton.icon(
                                  style: .delta(
                                    decoration: .delta([
                                      .all(.boxDelta(boxShadow: [shadow])),
                                    ]),
                                  ),
                                  onPress: context.pop,
                                  child: Icon(
                                    FPhosphorBoldIcons.arrowClockwise,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      child: SizedBox(
                        height: size.height - 76,
                        width: size.width,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          child: Column(
                            crossAxisAlignment: crossAxisAlignment,
                            mainAxisAlignment: .end,
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: 450,
                                  maxHeight: 450,
                                ),
                                child: Column(
                                  spacing: 16,
                                  children: [
                                    if (logo != null)
                                      Expanded(
                                        child: CachedNetworkImage(
                                          imageUrl: tv!.getLogo(),
                                          alignment: .bottomCenter,
                                          memCacheWidth: 450,
                                          fit: .contain,
                                        ),
                                      ),

                                    if (genres != null && genres.isNotEmpty)
                                      Row(
                                        mainAxisAlignment: .center,
                                        children: genres
                                            .map(
                                              (g) => Text(g),
                                            )
                                            .toList()
                                            .separatedBy(
                                              Icon(FPhosphorBoldIcons.dot),
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
                                                FPhosphorBoldIcons.filmStrip,
                                              ),
                                            ),
                                          ),
                                          Icon(FPhosphorBoldIcons.dot),
                                          FButton(
                                            style: .delta(
                                              contentStyle: .delta(
                                                constraints: BoxConstraints(
                                                  maxWidth: 200,
                                                ),
                                              ),
                                            ),
                                            onPress: next == null
                                                ? null
                                                : () {},
                                            prefix: Icon(
                                              FPhosphorFillIcons.play,
                                            ),
                                            child: _playButtonLabel(tv, next),
                                          ),
                                          Icon(FPhosphorBoldIcons.dot),
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
                                                  : _toggleFavorite,
                                              child: Icon(
                                                FPhosphorBoldIcons.heart,
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
                                                : _togglePlayed,
                                            child: Icon(
                                              FPhosphorBoldIcons.check,
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
                                      children:
                                          [
                                            Text('$runYears'),
                                            if (seasonCount != null)
                                              Text('$seasonCount seasons'),
                                            if (episodeCount != null)
                                              Text('$episodeCount episodes'),
                                            if (unplayed != null)
                                              Text('$unplayed unplayed'),
                                          ].separatedBy(
                                            Icon(FPhosphorBoldIcons.dot),
                                          ),
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
                                    Container(
                                      decoration: BoxDecoration(
                                        color: theme.colors.barrier,
                                        borderRadius:
                                            theme.style.borderRadius.md,
                                      ),
                                      padding: .all(20),
                                      child: Text(overview ?? 'No overview'),
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
                  SliverSection(
                    key: seasonKey,
                    header: Align(
                      alignment: .centerStart,
                      child: Row(
                        spacing: 20,
                        mainAxisSize: .min,
                        children: [
                          if (tvAsync.isLoading && state.seasons == null)
                            FButton(
                              variant: .outline,
                              onPress: () {},
                              child: FCircularProgress(),
                            )
                          else if (state.seasons != null)
                            SeasonSelector(
                              next: next,
                              seriesId: widget.id,
                              selectedSeasonItem: state.selectedSeason,
                              seasonItems: state.seasons!,
                              onSeasonChange: (s) => tvNotifier
                                  .onSeasonChanged(s.id)
                                  .then((_) => _scrollToKey(seasonKey)),
                            ),
                        ],
                      ),
                    ),
                    slivers: [
                      if (tvAsync.isLoading && state.episodes == null)
                        SliverPadding(
                          padding: .fromLTRB(20, 0, 20, 20),
                          sliver: SliverToBoxAdapter(
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: FCircularProgress(),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (state.episodes != null &&
                          state.episodes!.isNotEmpty)
                        SliverPadding(
                          padding: .fromLTRB(20, 0, 20, 20),
                          sliver: SliverGrid.builder(
                            itemCount: state.episodes!.length,
                            gridDelegate:
                                SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 350,
                                  childAspectRatio: 16 / 13,
                                  mainAxisSpacing: 20,
                                  crossAxisSpacing: 10,
                                ),
                            itemBuilder: (context, index) {
                              final ep = state.episodes![index];
                              final ov = ep.getOverview();

                              return NewMediaCard(
                                item: ep,
                                dimPlayed: ep.userData?.played ?? false,
                                selected: ep.id == state.nextup?.id,
                                isNext: ep.id == next?.id,
                                bottom: SizedBox(
                                  height: 36,
                                  child: Row(
                                    crossAxisAlignment: .start,
                                    children: [
                                      Expanded(
                                        child: Text(ov ?? '').setOpacity(
                                          opacity:
                                              ep.id == next?.id ||
                                                  ep.getPlayProgress() == 1
                                              ? 1
                                              : 0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      else
                        SliverPadding(
                          padding: .fromSTEB(28, 0, 20, 20),
                          sliver: SliverToBoxAdapter(
                            child: Row(
                              children: [
                                Text('No items. LIBRARY. MUST. GROW').italic(),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (tv != null)
                    SliverPeople(key: castsKey, tv: tv, season: season),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _playButtonLabel(JellyfinItem? tv, JellyfinItem? next) {
    final progress = tv?.getPlayProgress() ?? 0;
    if (progress < 1) {
      return Text('S${next?.parentIndexNumber}:E${next?.indexNumber}');
    } else if (progress == 1) {
      return Text('Rewatch');
    }

    return Text('Play');
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

  Future<void> _toggleFavorite() async {
    if (favoriteLoading) return;

    try {
      favoriteLoading = true;

      ref.read(tvshowStateProvider(widget.id).notifier).toggleSeriesFavorite();
    } on Exception catch (e) {
      debugPrint(e.toString());
    } finally {
      favoriteLoading = false;
    }
  }

  Future<void> _togglePlayed() async {
    if (playedLoading) return;

    try {
      playedLoading = true;

      ref.read(tvshowStateProvider(widget.id).notifier).toggleSeriesPlayed();
    } on Exception catch (e) {
      debugPrint(e.toString());
    } finally {
      playedLoading = false;
    }
  }
}
