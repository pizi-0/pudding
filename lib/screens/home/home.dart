import 'dart:async';

import 'package:awesome_extensions/awesome_extensions.dart' show TxtStyle;
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
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
import 'package:pudding/widgets/media_card.dart';

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
                  child: ShowcaseCarousel(data: data.showcaseItem),
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

                      return NewMediaCard(
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

                      return NewMediaCard(
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

    return GestureDetector(
      onPanDown: (_) => autoScrollTimer?.cancel(),
      onPanCancel: () => _startAutoScroll(),
      onPanEnd: (_) => _startAutoScroll(),
      child: CarouselView.weighted(
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
          return Column();
        }).toList(),
      ),
    );
  }

  void _handleScroll() {
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
    }
  }

  void _startAutoScroll() {
    autoScrollTimer?.cancel();

    autoScrollTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
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
