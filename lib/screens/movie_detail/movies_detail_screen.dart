import 'package:awesome_extensions/awesome_extensions.dart'
    show ListExtension, StyledText, WidgetCommonExtension;
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:forui_phosphor/forui_phosphor.dart';
import 'package:go_router/go_router.dart';
import 'package:pudding/screens/movie_detail/provider/movie_state_provider.dart';
import 'package:pudding/services/di.dart';
import 'package:pudding/utils/jellyfin_item_extensions.dart';
import 'package:pudding/widgets/icon_text.dart';
import 'package:pudding/widgets/media_card.dart';
import 'package:pudding/widgets/people_grid.dart';
import 'package:pudding/widgets/pudding_scaffold.dart';
import 'package:pudding/widgets/rating_container.dart';
import 'package:pudding/widgets/sliver_section.dart';
import 'package:pudding/widgets/star_rating_container.dart';
import 'package:silky_scroll/silky_scroll.dart';

import '../../const/const.dart';
import '../../widgets/logo_shimmer.dart';
import '../../widgets/sliver_header.dart';
import '../../widgets/topbar.dart';

class MovieDetailScreen extends ConsumerStatefulWidget {
  final String id;
  const MovieDetailScreen({super.key, required this.id});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ShowsDetailScreensState();
}

class _ShowsDetailScreensState extends ConsumerState<MovieDetailScreen> {
  final GlobalKey peopleKey = GlobalKey(debugLabel: 'people-section');

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
                errorBuilder: (context, error, stackTrace) => Align(
                  alignment: .bottomEnd,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Missing \'backdrop\', \'primary\'',
                      style: theme.typography.body.xs.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ).italic(),
                  ),
                ),
              ),
            ),
          );
        },
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

                          return Topbar(
                            prefix: FButton.icon(
                              style: .delta(
                                decoration: .delta([
                                  .all(.boxDelta(boxShadow: [shadow])),
                                ]),
                              ),
                              onPress: context.pop,
                              child: Icon(FPhosphorBoldIcons.caretLeft),
                            ),
                            suffix: FButton.icon(
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
                            children: [
                              FButton(
                                mainAxisAlignment: .start,
                                mainAxisSize: .min,
                                style: .delta(
                                  contentStyle: .delta(
                                    textStyle: .delta([
                                      .all(
                                        .delta(
                                          overflow: () => .ellipsis,
                                        ),
                                      ),
                                    ]),
                                  ),
                                  decoration: .delta([
                                    .all(
                                      .boxDelta(boxShadow: [shadow]),
                                    ),
                                  ]),
                                ),
                                variant: .outline,
                                onPress: () => scrollController.animateTo(
                                  0,
                                  duration: kDefaultAnimationDuration,
                                  curve: Curves.easeInOut,
                                ),
                                suffix: FCircularProgress().showIf(
                                  movieAsync.isLoading,
                                ),
                                child: Flexible(
                                  fit: .loose,
                                  child: Text(
                                    m.name,
                                    overflow: .ellipsis,
                                  ),
                                ),
                              ),
                            ],
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
                                    Expanded(
                                      child: m.hasLogo
                                          ? CachedNetworkImage(
                                              imageUrl: m.logo,
                                              alignment: .bottomCenter,
                                              memCacheWidth: 450,
                                              fit: .contain,
                                            )
                                          : m.hasPrimary
                                          ? ClipRRect(
                                              borderRadius:
                                                  theme.style.borderRadius.md,
                                              child: CachedNetworkImage(
                                                imageUrl: m.primary,
                                                alignment: .bottomCenter,
                                                memCacheWidth: 450,
                                                fit: .contain,
                                              ),
                                            )
                                          : SizedBox(),
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
                                    Row(
                                      mainAxisAlignment: .center,
                                      children:
                                          [
                                            if (m.year != null)
                                              IconText(
                                                text: m.year!,
                                                icon:
                                                    FPhosphorBoldIcons.calendar,
                                              ),
                                            if (m.parentalRating != null)
                                              RatingContainer(
                                                rating: m.parentalRating!,
                                              ),
                                            if (m.rating != null)
                                              StarRatingContainer(
                                                rating: m.rating!,
                                              ),
                                            if (m.duration != null)
                                              IconText(
                                                text: m.duration!,
                                                icon: FPhosphorBoldIcons.clock,
                                              ),
                                            if (m.size != null)
                                              IconText(
                                                text: m.size!,
                                                icon: FPhosphorBoldIcons
                                                    .floppyDisk,
                                              ),
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
                  if (m.isMultipart)
                    SliverSection(
                      header: FButton(
                        variant: .outline,
                        onPress: () {},
                        child: Text('Additional parts'),
                      ),
                      slivers: [
                        SliverPadding(
                          padding: .fromLTRB(20, 0, 20, 20),
                          sliver: SliverGrid.builder(
                            itemCount: m.multipart.length,
                            gridDelegate:
                                SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 350,
                                  childAspectRatio: 16 / 10,
                                ),
                            itemBuilder: (context, index) {
                              final part = m.multipart[index];
                              return NewMediaCard(item: part);
                            },
                          ),
                        ),
                      ],
                    ),
                  SliverPeople(key: peopleKey, media: m.movie!),
                  SliverSection(
                    header: FButton(
                      variant: .outline,
                      onPress: () => ref
                          .read(movieStateProvider(widget.id).notifier)
                          .getAdditionalParts(),
                      child: Text('Info'),
                    ),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Text(
                          m.movie!.getRaw(),
                        ),
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
