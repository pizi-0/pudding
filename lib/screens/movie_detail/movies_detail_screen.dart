import 'package:awesome_extensions/awesome_extensions.dart'
    show WidgetCommonExtension, ListExtension;
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:forui_phosphor/forui_phosphor.dart';
import 'package:go_router/go_router.dart';
import 'package:pudding/screens/movie_detail/provider/movie_state_provider.dart';
import 'package:pudding/services/di.dart';
import 'package:pudding/widgets/pudding_scaffold.dart';
import 'package:silky_scroll/silky_scroll.dart';

import '../../const/const.dart';
import '../../widgets/logo_shimmer.dart';
import '../../widgets/sliver_header.dart';

class MovieDetailScreen extends ConsumerStatefulWidget {
  final String id;
  const MovieDetailScreen({super.key, required this.id});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ShowsDetailScreensState();
}

class _ShowsDetailScreensState extends ConsumerState<MovieDetailScreen> {
  final ScrollController scrollController = ScrollController();
  final client = services<JellyfinClient>();

  ValueNotifier<double> scrollOffset = ValueNotifier(0);
  bool favoriteLoading = false;
  bool playedLoading = false;

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final movieAsync = ref.watch(movieStateProvider(widget.id));

    final size = MediaQuery.sizeOf(context);
    final theme = context.theme;

    final max = size.width < theme.breakpoints.md;

    final overviewWidth = max ? size.width : size.width * 0.4;

    final crossAxisAlignment = max
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;

    return PuddingScaffold(
      backdrop: CachedNetworkImage(
        imageUrl: client.images.url(
          itemId: widget.id,
          type: JellyfinImagesApi.typeBackdrop,
        ),
        fit: .cover,
      ),
      child: SilkyCustomScrollView(
        slivers: [
          movieAsync.when(
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
                            onPress: () => ref.invalidate(
                              movieStateProvider(widget.id),
                            ),
                            child: Icon(FPhosphorBoldIcons.caretLeft),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ]),
            ),
            data: (m) {
              return SliverMainAxisGroup(
                slivers: [
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: SliverHeader(
                      onScroll: (value) => scrollOffset.value = value,
                      maxExtentHeight: size.height - 76,
                      minExtentHeight: 76,
                      shouldRefresh: movieAsync.isLoading,
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
                                          movieAsync.isLoading,
                                        ),
                                        child: Text(m.name),
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
                                    if (m.hasLogo)
                                      Expanded(
                                        child: CachedNetworkImage(
                                          imageUrl: m.logo,
                                          alignment: .bottomCenter,
                                          memCacheWidth: 450,
                                          fit: .contain,
                                        ),
                                      ),

                                    if (m.hasGenres)
                                      Row(
                                        mainAxisAlignment: .center,
                                        children: m.genresShort
                                            .map((g) => Text(g))
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
                                            onPress: () {},
                                            prefix: Icon(
                                              FPhosphorFillIcons.play,
                                            ),
                                            child: Text('Play'),
                                          ),
                                          Icon(FPhosphorBoldIcons.dot),
                                          FTooltip(
                                            tipBuilder: (context, controller) =>
                                                Text(
                                                  m.isFavorite
                                                      ? 'Unfavorite'
                                                      : 'Favorite',
                                                ),
                                            child: FButton.icon(
                                              onPress:
                                                  movieAsync.isLoading &&
                                                      favoriteLoading
                                                  ? null
                                                  : _toggleFavorite,
                                              child: Icon(
                                                FPhosphorBoldIcons.heart,
                                                color: m.isFavorite
                                                    ? Colors.pink
                                                    : null,
                                              ),
                                            ),
                                          ),
                                          FButton.icon(
                                            onPress:
                                                movieAsync.isLoading &&
                                                    playedLoading
                                                ? null
                                                : _togglePlayed,
                                            child: Icon(
                                              FPhosphorBoldIcons.check,
                                              color: m.isPlayed
                                                  ? Colors.green
                                                  : null,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Row(
                                    //   mainAxisAlignment: .center,
                                    //   children:
                                    //       [
                                    //         Text('$runYears'),
                                    //         if (seasonCount != null)
                                    //           Text('$seasonCount seasons'),
                                    //         if (episodeCount != null)
                                    //           Text('$episodeCount episodes'),
                                    //         if (unplayed != null)
                                    //           Text('$unplayed unplayed'),
                                    //       ].separatedBy(
                                    //         Icon(FPhosphorBoldIcons.dot),
                                    //       ),
                                    // ),
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
                                      child: Text(m.overview ?? 'No overview'),
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
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFavorite() async {
    if (favoriteLoading) return;

    try {
      favoriteLoading = true;

      ref.read(movieStateProvider(widget.id).notifier).toggleFavorite();
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

      ref.read(movieStateProvider(widget.id).notifier).togglePlayed();
    } on Exception catch (e) {
      debugPrint(e.toString());
    } finally {
      playedLoading = false;
    }
  }
}
