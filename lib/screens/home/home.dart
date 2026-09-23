import 'dart:async';

import 'package:awesome_extensions/awesome_extensions.dart'
    show TxtStyle, ListExtension;
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:forui_phosphor/forui_phosphor.dart';
import 'package:go_router/go_router.dart';
import 'package:pudding/screens/home/home_provider.dart';
import 'package:pudding/screens/home/providers/showcase_provider.dart';
import 'package:pudding/screens/home/widgets/library_card.dart';
import 'package:pudding/screens/home/widgets/showcase.dart';
import 'package:pudding/utils/jellyfin_item_extensions.dart';
import 'package:pudding/widgets/detail_scaffold.dart';
import 'package:pudding/widgets/detail_slivers/sliver_error.dart';

import 'package:pudding/widgets/detail_slivers/sliver_loader.dart';
import 'package:pudding/widgets/detail_slivers/sliver_section.dart';
import 'package:pudding/widgets/detail_slivers/sliver_topbar.dart';
import 'package:pudding/widgets/icon_text.dart';
import 'package:pudding/widgets/media_card.dart';
import 'package:pudding/widgets/rating_container.dart';
import 'package:pudding/widgets/star_rating_container.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final homeAsync = ref.watch(homeProvider);
    final size = MediaQuery.sizeOf(context);

    return DetailScaffold(
      backdrop: ShowcaseItemBackdrop(),
      headerSliver: SliverTopbar(nested: false),
      sliverBuilder: (context, controller) {
        return homeAsync.when(
          skipLoadingOnReload: true,
          loading: () => [SliverLoader(id: '')],
          error: (error, stackTrace) => [SliverError(error: error.toString())],
          data: (data) {
            return [
              SliverToBoxAdapter(
                child: SizedBox(
                  width: size.width,
                  height: size.height - 76 - 76,
                  child: ShowcaseCarousel(
                    key: ValueKey(data.showcaseItem.first.id),
                    data: data.showcaseItem,
                  ),
                ),
              ),
              SliverSection(
                header: FButton(
                  variant: .ghost,
                  onPress: () {},
                  child: Text(
                    'Libraries',
                    style: theme.typography.display.xl.copyWith(height: 1).bold,
                  ),
                ),
                slivers: [
                  SliverGrid.builder(
                    itemCount: data.libraries.length,
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 350,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 16 / 10,
                    ),
                    itemBuilder: (context, index) {
                      final view = data.libraries[index];
                      return LibraryCard(
                        view: view,
                        onPress: () => context.push('/library/${view.id}'),
                      );
                    },
                  ),
                ],
              ),
              SliverSection(
                header: FButton(
                  variant: .ghost,
                  onPress: () {},
                  child: Text(
                    'Continue watching',
                    style: theme.typography.display.xl.copyWith(height: 1).bold,
                  ),
                ),
                slivers: [
                  SliverGrid.builder(
                    itemCount: data.continueWatching.length,
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 350,
                      childAspectRatio: 16 / 10,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) {
                      final item = data.continueWatching[index];

                      return MediaCard(
                        showSeriesName: item.isEpisode,
                        key: ValueKey(item.id),
                        imageType: JellyfinImagesApi.typeThumb,
                        item: item,
                        onPressed: () {
                          if (item.isEpisode) {
                            context.push('/show/${item.seriesId}');
                          }

                          if (item.isMovie) {
                            context.push('/movie/${item.id}');
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
              SliverSection(
                header: FButton(
                  variant: .ghost,
                  onPress: () {},
                  child: Text(
                    'Next up',
                    style: theme.typography.display.xl.copyWith(height: 1).bold,
                  ),
                ),
                slivers: [
                  SliverGrid.builder(
                    itemCount: data.nextup.length,
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 350,
                      childAspectRatio: 16 / 10,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) {
                      final item = data.nextup[index];

                      return MediaCard(
                        key: ValueKey(item.id),
                        showSeriesName: item.isEpisode,
                        imageType: JellyfinImagesApi.typeThumb,
                        item: item,
                        onPressed: () {
                          if (item.isEpisode) {
                            context.push('/show/${item.seriesId}');
                          }

                          if (item.isMovie) {
                            context.push('/movie/${item.id}');
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ];
          },
        );
      },
    );
  }
}

class ShowcaseCarousel extends ConsumerStatefulWidget {
  final List<JellyfinItem> data;

  const ShowcaseCarousel({super.key, required this.data});

  @override
  ConsumerState<ShowcaseCarousel> createState() => _ShowcaseCarouselState();
}

class _ShowcaseCarouselState extends ConsumerState<ShowcaseCarousel> {
  late final CarouselController _controller;
  Timer? autoScrollTimer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = CarouselController();
    _controller.addListener(_handleScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_handleScroll);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final homeAsync = ref.watch(homeProvider);

    return GestureDetector(
      onPanDown: (_) => autoScrollTimer?.cancel(),
      onPanCancel: () => _startAutoScroll(),
      onPanEnd: (_) => _startAutoScroll(),
      child: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return CarouselView.weighted(
                itemClipBehavior: .hardEdge,
                padding: .zero,
                controller: _controller,
                infinite: true,
                itemSnapping: true,
                elevation: 0,
                enableSplash: false,
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: theme.style.borderRadius.md,
                ),
                flexWeights: [1],
                children: widget.data.map((item) {
                  final rating = item.getCommunityRating();
                  final year = item.getYear();
                  final parental = item.getOfficialRating();
                  final overview = item.getOverview();
                  final seasons = item.getSeasons();
                  final durations = item.getRuntime();

                  return FTheme(
                    data: theme,
                    child: OverflowBox(
                      maxHeight: constraints.maxHeight,
                      maxWidth: constraints.maxWidth,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          spacing: 10,
                          crossAxisAlignment: .start,
                          mainAxisAlignment: .end,
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: 400,
                              ),
                              child: CachedNetworkImage(
                                memCacheWidth: 400,
                                fit: .contain,
                                imageUrl: item.getLogo(),
                                errorBuilder: (context, error, stackTrace) =>
                                    Text(
                                      item.getTitle(),
                                      style: theme.typography.display.xl2
                                          .copyWith(
                                            height: 1.3,
                                            fontWeight: .bold,
                                          ),
                                    ),
                              ),
                            ),
                            Row(
                              children: [
                                if (rating != null)
                                  StarRatingContainer(
                                    rating: rating.toStringAsFixed(2),
                                  ),

                                if (parental != null)
                                  RatingContainer(rating: parental),

                                if (year != null)
                                  IconText(
                                    text: year,
                                    icon: FPhosphorBoldIcons.calendar,
                                  ),

                                if (seasons != null) Text('$seasons seasons'),

                                if (durations != null)
                                  IconText(
                                    text: durations,
                                    icon: FPhosphorBoldIcons.clock,
                                  ),
                              ].separatedBy(Icon(FPhosphorBoldIcons.dot)),
                            ),
                            if (overview != null)
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: 500,
                                ),
                                child: Text(
                                  overview,
                                  maxLines: 3,
                                  overflow: .ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          Align(
            alignment: .centerRight,
            child: Column(
              spacing: 10,
              mainAxisSize: .min,
              children: [
                FButton.icon(
                  variant: .ghost,
                  onPress: () => _nextItem(1),
                  child: Icon(FPhosphorBoldIcons.arrowRight),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 36, maxWidth: 36),
                  child: FittedBox(
                    child: Text(
                      '${_currentIndex + 1}/${widget.data.length}',
                      style: theme.typography.display.xs,
                    ),
                  ),
                ),
                FButton.icon(
                  variant: .ghost,
                  onPress: () => _nextItem(-1),
                  child: Icon(FPhosphorBoldIcons.arrowLeft),
                ),
                FButton.icon(
                  variant: .ghost,
                  onPress: () async {
                    ref.invalidate(homeProvider);
                  },
                  child: homeAsync.isLoading
                      ? FCircularProgress()
                      : Icon(FPhosphorBoldIcons.arrowClockwise),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleScroll() async {
    if (!_controller.position.hasPixels) return;

    final double itemWidth = _controller.position.viewportDimension;
    if (itemWidth <= 0) return;

    final int rawIndex = (_controller.position.pixels / itemWidth).round();

    final int totalItems = widget.data.length;
    if (totalItems == 0) return;

    final int normalizedIndex = rawIndex % totalItems;

    if (normalizedIndex != _currentIndex) {
      _currentIndex = normalizedIndex;

      ref
          .read(showcaseProvider.notifier)
          .setItem(
            widget.data[_currentIndex],
          );

      _startAutoScroll();

      setState(() {});
    }
  }

  void _nextItem(int index) {
    autoScrollTimer?.cancel();
    final double itemWidth = _controller.position.viewportDimension;
    if (itemWidth <= 0) return;

    final int nextTargetIndex =
        (_controller.position.pixels / itemWidth).round() + index;

    _controller.animateTo(
      nextTargetIndex * itemWidth,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _startAutoScroll() {
    autoScrollTimer?.cancel();

    autoScrollTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!_controller.hasClients) return;
      if (!_controller.position.hasPixels) return;

      final double itemWidth = _controller.position.viewportDimension;
      if (itemWidth <= 0) return;

      final int nextTargetIndex =
          (_controller.position.pixels / itemWidth).round() + 1;

      _controller.animateTo(
        nextTargetIndex * itemWidth,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }
}
