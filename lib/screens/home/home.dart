import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:pudding/screens/home/home_provider.dart';
import 'package:pudding/screens/home/models/home_data_model.dart';
import 'package:pudding/screens/home/widgets/library_card.dart';
import 'package:pudding/screens/home/widgets/showcase.dart';
import 'package:pudding/widgets/media_card.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  final ScrollController scrollController = ScrollController();
  int alpha = 0;
  final int targetAlpha = 240;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.addListener(_onScroll);
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final scrollPercentage =
        scrollController.offset /
        (scrollController.position.maxScrollExtent - 300);

    if (alpha < targetAlpha) {
      alpha = (scrollPercentage * targetAlpha).toInt().clamp(0, targetAlpha);
    } else {
      alpha = (scrollPercentage * targetAlpha).toInt().clamp(0, targetAlpha);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final data = ref.watch(homeProvider).value ?? HomeData();
    final size = MediaQuery.sizeOf(context);
    final double horizontalPad = size.width < theme.breakpoints.md ? 10 : 30;

    return TapRegion(
      onTapInside: (event) => FocusScope.of(context).unfocus(),
      child: Stack(
        fit: .expand,
        children: [
          if (data.showcaseItem.isNotEmpty)
            ShaderMask(
              shaderCallback: (rect) => LinearGradient(
                colors: [
                  Colors.black.withAlpha(alpha),
                  Colors.black.withAlpha(targetAlpha),
                ],
                stops: [0.3, 1],
                begin: .topCenter,
                end: .bottomCenter,
              ).createShader(rect),
              blendMode: .dstOut,
              child: const ShowcaseItemBackdrop(),
            ),
          CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverMainAxisGroup(
                slivers: [
                  SliverToBoxAdapter(
                    child: Showcase(),
                  ),
                  SliverPadding(padding: .all(20)),
                  SliverPadding(
                    padding: .symmetric(horizontal: horizontalPad),
                    sliver: SliverMainAxisGroup(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Text(
                            'Libraries',
                            style: theme.typography.display.xl2.copyWith(
                              fontWeight: .bold,
                              height: 1.5,
                            ),
                          ),
                        ),
                        SliverPadding(padding: .all(10)),
                        SliverGrid.builder(
                          itemCount: data.libraries.length,
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 310,
                                childAspectRatio: 16 / 9,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                              ),
                          itemBuilder: (context, index) => LibraryCard(
                            view: data.libraries[index],
                            onPress: () {
                              context.go(
                                '/library/${data.libraries[index].id}',
                              );
                            },
                          ),
                        ),
                        SliverPadding(padding: .all(20)),

                        SliverToBoxAdapter(
                          child: Text(
                            'Continue watching',
                            style: theme.typography.display.xl2.copyWith(
                              fontWeight: .bold,
                              height: 1.5,
                            ),
                          ),
                        ),
                        SliverPadding(padding: .all(10)),
                        SliverGrid.builder(
                          itemCount: data.continueWatching.length,
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 310,
                                childAspectRatio: 3 / 2,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                              ),
                          itemBuilder: (context, index) => MediaCard(
                            item: data.continueWatching[index],
                          ),
                        ),
                        SliverPadding(padding: .all(20)),

                        SliverToBoxAdapter(
                          child: Text(
                            'Next up',
                            style: theme.typography.display.xl2.copyWith(
                              fontWeight: .bold,
                              height: 1.5,
                            ),
                          ),
                        ),
                        SliverPadding(padding: .all(10)),
                        SliverGrid.builder(
                          itemCount: data.nextup.length,
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 310,
                                childAspectRatio: 3 / 2,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                              ),
                          itemBuilder: (context, index) => MediaCard(
                            item: data.nextup[index],
                          ),
                        ),
                        SliverPadding(padding: .all(10)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
