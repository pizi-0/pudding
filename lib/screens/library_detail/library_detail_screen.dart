// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:awesome_extensions/awesome_extensions.dart'
    show ListExtension, ShimmerEffect;
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:pudding/models/pudding_display_prefs.dart';
import 'package:pudding/screens/library_detail/library_detail_provider.dart';
import 'package:pudding/screens/library_detail/user_views_provider.dart';
import 'package:pudding/screens/library_detail/widget/library_carousel.dart';
import 'package:pudding/widgets/pudding_scaffold.dart';
import 'package:silky_scroll/silky_scroll.dart';

import '../../utils/jellyfin_view_extension.dart';
import '../../widgets/media_card.dart';

class LibraryDetail extends ConsumerStatefulWidget {
  final String? id;

  const LibraryDetail({super.key, this.id});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LibraryDetailState();
}

class _LibraryDetailState extends ConsumerState<LibraryDetail> {
  final ScrollController scrollController = ScrollController();
  bool all = false;
  bool manualRefresh = false;
  bool retried = false;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_fetchMore);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _fetchMore() {
    final max = scrollController.position.maxScrollExtent;
    final current = scrollController.offset;

    if (!all) {
      if ((current / max > 0.6) || max == 0) {
        ref.read(libraryProvider(widget.id!).notifier).getMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final libAsync = ref.watch(libraryProvider(widget.id!));
    final libNotifier = ref.read(libraryProvider(widget.id!).notifier);
    final userviewAsync = ref.watch(userviewsProvider);
    final List<double> flexWeight = List.generate(11, (index) => (index * 0.1));

    final theme = context.theme;

    return PuddingScaffold(
      child: Stack(
        children: [
          ScrollConfiguration(
            behavior: ScrollBehavior().copyWith(
              dragDevices: {...PointerDeviceKind.values},
            ),
            child: SilkyCustomScrollView(
              scrollSpeed: 2,
              controller: scrollController,
              slivers: [
                PinnedHeaderSliver(
                  child: Appbar(
                    child: Row(
                      children: [
                        FButton.icon(
                          onPress: context.pop,
                          child: Icon(FLucideIcons.chevronLeft),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: .horizontal,
                            child: Row(
                              spacing: 10,
                              children: [
                                if (userviewAsync.hasValue)
                                  ...userviewAsync.value!.values.map((v) {
                                    return FButton(
                                      variant: widget.id == v.id
                                          ? .primary
                                          : .outline,
                                      onPress: () => context.pushReplacement(
                                        '/library/${v.id}',
                                      ),
                                      prefix: _getButtonIcon(v),
                                      child: Text(v.name),
                                    );
                                  }),
                              ],
                            ),
                          ),
                        ),
                        FButton.icon(
                          onPress: _manualRefresh,
                          child: libAsync.isLoading && manualRefresh
                              ? FCircularProgress()
                              : Icon(FLucideIcons.refreshCcw),
                        ),
                      ].separatedby(Icon(FLucideIcons.dot)),
                    ),
                  ),
                ),
                libAsync.when(
                  skipLoadingOnReload: true,
                  loading: () => SliverPadding(
                    padding: .fromLTRB(10, 0, 10, 10),
                    sliver: SliverGrid.builder(
                      key: ValueKey(widget.id),
                      itemCount: 10,
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200,
                        childAspectRatio: 10 / 16,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                      ),
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            border: .all(
                              color: theme.colors.background,
                              width: 2,
                            ),
                            color: theme.colors.foreground,
                            borderRadius: theme.style.borderRadius.sm,
                          ),
                        ).applyShimmer(
                          baseColor: theme.colors.background,
                          highlightColor: theme.colors.muted,
                        );
                      },
                    ),
                  ),
                  error: (error, stackTrace) => SliverFillRemaining(
                    child: Center(
                      child: Text(error.toString()),
                    ),
                  ),
                  data: (data) {
                    final libs = data.items;
                    all = libs.length == data.count;
                    retried = false;

                    final puddingPrefs = PuddingDisplayPrefs.fromMap(
                      data.displayPrefs.customPrefs,
                    );

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      manualRefresh = false;

                      if (!all &&
                          scrollController.position.maxScrollExtent == 0) {
                        ref
                            .read(libraryProvider(widget.id!).notifier)
                            .getMore();
                      }
                    });

                    return SliverMainAxisGroup(
                      slivers: [
                        if (data.next.isNotEmpty)
                          SliverMainAxisGroup(
                            slivers: [
                              PinnedHeaderSliver(
                                child: Appbar(
                                  padding: .fromLTRB(10, 0, 10, 10),
                                  child: SectionHeader(
                                    title: Text('Continue watching'),
                                  ),
                                ),
                              ),
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const .fromLTRB(10, 0, 0, 10),
                                  child: SizedBox(
                                    height: 250,
                                    child: LibraryCarousel(items: data.next),
                                  ),
                                ),
                              ),
                              SliverPadding(padding: .only(bottom: 10)),
                            ],
                          ),
                        SliverMainAxisGroup(
                          slivers: [
                            PinnedHeaderSliver(
                              child: Appbar(
                                padding: .fromLTRB(10, 0, 10, 0),
                                child: SectionHeader(
                                  title: Text('All'),
                                  subtitle: Row(
                                    spacing: 10,
                                    children: [
                                      Text(
                                        'Showing ${data.items.length} of ${data.count}',
                                        style: theme.typography.body.xs
                                            .copyWith(
                                              color:
                                                  theme.colors.mutedForeground,
                                            ),
                                      ),
                                      if (libAsync.isLoading)
                                        FCircularProgress(
                                          style: .delta(
                                            iconStyle: .delta(
                                              color: theme.colors.primary,
                                              size: theme
                                                  .typography
                                                  .body
                                                  .xs
                                                  .fontSize,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailings: [
                                    Container(
                                      decoration: BoxDecoration(
                                        border: .all(
                                          color: theme.colors.border,
                                          width: 2,
                                        ),
                                        borderRadius:
                                            theme.style.borderRadius.md,
                                      ),
                                      height: 36,
                                      child: Row(
                                        spacing: 10,
                                        children: [
                                          FButton.icon(
                                            variant: .ghost,
                                            onPress: () {
                                              if (libAsync.isLoading) return;

                                              libNotifier
                                                ..setMaxImageWidth(
                                                  (puddingPrefs.maxImageWidth -
                                                          50)
                                                      .clamp(
                                                        200,
                                                        700,
                                                      ),
                                                )
                                                ..updateDisplayPrefs();
                                            },
                                            child: Icon(FLucideIcons.zoomOut),
                                          ),
                                          SizedBox(
                                            width: 120,
                                            child: FSlider(
                                              enabled: !libAsync.isLoading,
                                              control: .liftedDiscrete(
                                                interaction: .tapAndSlideThumb,
                                                value: FSliderValue(
                                                  max:
                                                      ((puddingPrefs.maxImageWidth -
                                                                  200) /
                                                              500)
                                                          .clamp(
                                                            0,
                                                            1,
                                                          ),
                                                ),
                                                onChange: (value) {
                                                  if (libAsync.isLoading) {
                                                    return;
                                                  }
                                                  libNotifier.setMaxImageWidth(
                                                    (value.max * 500) + 200,
                                                  );
                                                },
                                              ),
                                              onEnd: (value) {
                                                libNotifier
                                                    .updateDisplayPrefs();
                                              },
                                              marks: flexWeight
                                                  .map(
                                                    (e) =>
                                                        FSliderMark(value: e),
                                                  )
                                                  .toList(),
                                              style: .delta(
                                                childPadding: .value(.zero),
                                              ),
                                              tooltipBuilder:
                                                  (controller, value) => Text(
                                                    ((value * 500) + 200)
                                                        .toStringAsFixed(0),
                                                  ),
                                            ),
                                          ),
                                          FButton.icon(
                                            variant: .ghost,
                                            onPress: () {
                                              if (libAsync.isLoading) return;

                                              final double maxWidth =
                                                  (puddingPrefs.maxImageWidth +
                                                          50)
                                                      .clamp(200, 700);

                                              libNotifier
                                                ..setMaxImageWidth(maxWidth)
                                                ..updateDisplayPrefs();
                                            },
                                            child: Icon(FLucideIcons.zoomIn),
                                          ),
                                        ],
                                      ),
                                    ),
                                    FButton.icon(
                                      variant: puddingPrefs.isPoster
                                          ? .primary
                                          : .outline,
                                      onPress: () {
                                        if (libAsync.isLoading ||
                                            puddingPrefs.isPoster) {
                                          return;
                                        }
                                        libNotifier
                                          ..setViewType('poster')
                                          ..updateDisplayPrefs();
                                      },
                                      child: Icon(
                                        FLucideIcons.rectangleVertical,
                                      ),
                                    ),
                                    FButton.icon(
                                      variant: puddingPrefs.isThumb
                                          ? .primary
                                          : .outline,
                                      onPress: () {
                                        if (libAsync.isLoading ||
                                            puddingPrefs.isThumb) {
                                          return;
                                        }
                                        libNotifier
                                          ..setViewType('thumb')
                                          ..updateDisplayPrefs();
                                      },
                                      child: Icon(
                                        FLucideIcons.rectangleHorizontal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SliverPadding(
                              padding: .fromLTRB(10, 0, 10, 10),
                              sliver: SliverGrid.builder(
                                key: ValueKey(widget.id),
                                itemCount: libs.length,
                                gridDelegate:
                                    SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent:
                                          puddingPrefs.maxImageWidth,
                                      childAspectRatio:
                                          puddingPrefs.aspectRatio,
                                      mainAxisSpacing: 10,
                                      crossAxisSpacing: 10,
                                    ),
                                itemBuilder: (context, index) {
                                  final item = libs[index];

                                  return NewMediaCard(
                                    key: ValueKey(item.id),
                                    item: item,
                                    imageType: puddingPrefs.imageType,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                        SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: .only(bottom: 10),
                              child: Row(
                                spacing: 10,
                                mainAxisAlignment: .center,
                                children: [
                                  if (libAsync.isLoading) FCircularProgress(),
                                  Text(
                                    'Showing ${libs.length} of ${data.count}',
                                  ),
                                ],
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
          ),
        ],
      ),
    );
  }

  Future<void> _manualRefresh() async {
    manualRefresh = true;
    setState(() {});
    final userviews = await ref.read(userviewsProvider.notifier).getUserviews();

    if (!userviews.containsKey(widget.id)) {
      if (mounted) {
        if (userviews.isEmpty) {
          context.pop();
        }

        context.pushReplacement(
          '/library/${userviews.values.first.id}',
        );
      }
    }

    ref.invalidate(libraryProvider(widget.id!));
    scrollController.jumpTo(0);
  }

  Widget? _getButtonIcon(JellyfinView view) {
    if (view.isMovies) {
      return Icon(FLucideIcons.film);
    }

    if (view.isTvShows) {
      return Icon(FLucideIcons.tv);
    }

    if (view.isMusic) {
      return Icon(FLucideIcons.music);
    }

    if (view.isPhotos) {
      return Icon(FLucideIcons.image);
    }

    if (view.isBoxsets) {
      return Icon(FLucideIcons.box);
    }

    if (view.isBooks) {
      return Icon(FLucideIcons.book);
    }

    if (view.isPlaylists) {
      return Icon(FLucideIcons.listVideo);
    }

    return Icon(FLucideIcons.fileQuestionMark);
  }
}

class SectionHeader extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final List<Widget> trailings;
  const SectionHeader({
    super.key,
    required this.title,
    this.trailings = const [],
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Column(
      spacing: 4,
      children: [
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: DefaultTextStyle(
                style: theme.typography.display.lg.copyWith(fontWeight: .bold),
                child: title,
              ),
            ),
            ...trailings,
          ],
        ),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: DefaultTextStyle(
              style: theme.typography.display.xs.copyWith(
                color: theme.colors.mutedForeground,
              ),
              child: subtitle!,
            ),
          ),
      ],
    );
  }
}

class Appbar extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry padding;
  const Appbar({super.key, this.child, this.padding = const .all(10)});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Container(
      decoration: BoxDecoration(color: theme.colors.background.withAlpha(230)),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
