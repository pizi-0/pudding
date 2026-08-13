// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:awesome_extensions/awesome_extensions.dart'
    show ListExtension, ShimmerEffect;
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:pudding/models/pudding_display_prefs.dart';
import 'package:pudding/screens/library_detail/library_detail_provider.dart';
import 'package:pudding/widgets/pudding_scaffold.dart';

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
    final userviews = ref.watch(userviewsProvider);

    final theme = context.theme;

    return PuddingScaffold(
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          PinnedHeaderSliver(
            child: Appbar(
              child: FCard(
                style: .delta(
                  decoration: .boxDelta(
                    color: theme.colors.background.withAlpha(200),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
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
                              ...userviews.values.map((v) {
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
                              if (libAsync.hasValue && libAsync.value != null)
                                Text(
                                  '${libAsync.value!.displayPrefs.customPrefs}',
                                ),
                            ],
                          ),
                        ),
                      ),
                      FButton.icon(
                        onPress: () {
                          manualRefresh = true;
                          setState(() {});
                          ref.invalidate(libraryProvider(widget.id!));
                        },
                        child: libAsync.isLoading && manualRefresh
                            ? FCircularProgress()
                            : Icon(FLucideIcons.refreshCcw),
                      ),
                    ].separatedby(Icon(FLucideIcons.dot)),
                  ),
                ),
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
              final puddingPrefs = PuddingDisplayPrefs.fromMap(
                data.displayPrefs.customPrefs,
              );

              WidgetsBinding.instance.addPostFrameCallback((_) {
                manualRefresh = false;

                if (libs.length == data.count) {
                  all = true;
                }

                if (!all && scrollController.position.maxScrollExtent == 0) {
                  ref.read(libraryProvider(widget.id!).notifier).getMore();
                }
              });

              return SliverMainAxisGroup(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: .only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: .end,
                        crossAxisAlignment: .center,
                        spacing: 10,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: .all(
                                color: theme.colors.border,
                                width: 2,
                              ),
                              borderRadius: theme.style.borderRadius.md,
                            ),
                            height: 36,
                            child: Row(
                              spacing: 10,
                              children: [
                                FButton.icon(
                                  variant: .ghost,
                                  onPress: () {},
                                  child: Icon(FLucideIcons.zoomOut),
                                ),
                                SizedBox(
                                  width: 150,
                                  child: FSlider(
                                    control: .managedDiscrete(
                                      interaction: .tapAndSlideThumb,
                                      initial: FSliderValue(
                                        max:
                                            (puddingPrefs.maxImageWidth - 250) /
                                            500,
                                      ),
                                      onChange: (value) {
                                        libNotifier.updateDisplayPrefs(
                                          puddingPrefs.copyWith(
                                            puddingMaxImageWidth:
                                                ((value.max * 250) + 250)
                                                    .toString(),
                                          ),
                                        );
                                      },
                                    ),
                                    marks: [
                                      .mark(value: 0),
                                      .mark(value: 0.2),
                                      .mark(value: 0.4),
                                      .mark(value: 0.6),
                                      .mark(value: 0.8),
                                      .mark(value: 1),
                                    ],
                                    style: .delta(
                                      childPadding: .value(.zero),
                                    ),
                                    tooltipBuilder: (controller, value) {
                                      if (value == 0) {
                                        return Text('Default (250)');
                                      } else {
                                        return Text(
                                          ((value * 250) + 250).toStringAsFixed(
                                            0,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                                FButton.icon(
                                  variant: .ghost,
                                  onPress: () {},
                                  child: Icon(FLucideIcons.zoomIn),
                                ),
                              ],
                            ),
                          ),
                          FButton.icon(
                            variant:
                                puddingPrefs.puddingLibraryViewType == 'poster'
                                ? .primary
                                : .outline,
                            onPress: () => libNotifier.updateDisplayPrefs(
                              puddingPrefs.copyWith(
                                puddingLibraryViewType: 'poster',
                              ),
                            ),
                            child: Icon(FLucideIcons.rectangleVertical),
                          ),
                          FButton.icon(
                            variant:
                                puddingPrefs.puddingLibraryViewType == 'thumb'
                                ? .primary
                                : .outline,
                            onPress: () => libNotifier.updateDisplayPrefs(
                              puddingPrefs.copyWith(
                                puddingLibraryViewType: 'thumb',
                              ),
                            ),
                            child: Icon(FLucideIcons.rectangleHorizontal),
                          ),
                          Text(puddingPrefs.puddingLibraryViewType),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: .fromLTRB(10, 0, 10, 10),
                    sliver: SliverGrid.builder(
                      key: ValueKey(widget.id),
                      itemCount: libs.length,
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: puddingPrefs.maxImageWidth,
                        childAspectRatio: puddingPrefs.aspectRatio,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                      ),
                      itemBuilder: (context, index) {
                        final item = libs[index];

                        return NewMediaCard(
                          key: ValueKey(item.id),
                          item: item,
                          imageType: JellyfinImagesApi.typePrimary,
                        );
                      },
                    ),
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
    );
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

class Appbar extends StatelessWidget {
  final Widget? child;
  const Appbar({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Colors.transparent],
          begin: .topCenter,
          end: .bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: child,
      ),
    );
  }
}
