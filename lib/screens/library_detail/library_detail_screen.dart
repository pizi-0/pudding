// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:awesome_extensions/awesome_extensions.dart'
    show ListExtension, ShimmerEffect;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:forui_phosphor/forui_phosphor.dart';
import 'package:go_router/go_router.dart';
import 'package:pudding/screens/library_detail/library_detail_provider.dart';
import 'package:pudding/screens/library_detail/user_views_provider.dart';
import 'package:pudding/screens/library_detail/widget/sliver_carousel.dart';
import 'package:pudding/screens/library_detail/widget/sliver_library_item_grid.dart';
import 'package:pudding/widgets/bar.dart';
import 'package:pudding/widgets/pudding_scaffold.dart';
import 'package:silky_scroll/silky_scroll.dart';

import '../../utils/jellyfin_view_extension.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(libraryProvider(widget.id!).notifier).refresh();
    });
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
    final userviewAsync = ref.watch(userviewsProvider);

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
                  child: Bar(
                    padding: .all(20),
                    child: Row(
                      children: [
                        FButton.icon(
                          onPress: context.pop,
                          child: Icon(FPhosphorBoldIcons.caretLeft),
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
                                      prefix: v.getButtonIcon(),
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
                              : Icon(FPhosphorBoldIcons.arrowClockwise),
                        ),
                      ].separatedBy(Icon(FPhosphorBoldIcons.dot)),
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
                          SliverCarousel(items: data.next),
                        SliverLibraryItemGrid(id: widget.id!),

                        SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: .only(bottom: 20),
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
}
