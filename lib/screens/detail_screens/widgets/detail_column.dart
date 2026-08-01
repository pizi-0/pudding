import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:pudding/const/const.dart';
import 'package:pudding/providers/media_cache_provider.dart';
import 'package:pudding/providers/series_detail_provider.dart';
import 'package:pudding/utils/jellyfin_item_extensions.dart';

class DetailColumn extends ConsumerStatefulWidget {
  final String seriesId;
  const DetailColumn({super.key, required this.seriesId});

  @override
  ConsumerState<DetailColumn> createState() => _DetailColumnState();
}

class _DetailColumnState extends ConsumerState<DetailColumn> {
  final scrollController = ScrollController();
  final double totalItemHeight = 180;
  bool hasScrolled = false;

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final style = theme.style;

    final detAsync = ref.watch(seriesDetailProvider(widget.seriesId));
    final detNotifier = ref.read(
      seriesDetailProvider(widget.seriesId).notifier,
    );
    final mediaCache = ref.watch(mediaCacheProvider);

    return TapRegion(
      onTapInside: (event) => FocusScope.of(context).unfocus(),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FCard(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: detAsync.when(
              skipLoadingOnReload: true,
              loading: () => FCircularProgress(),
              error: (error, stackTrace) => Center(
                child: Text(error.toString()),
              ),
              data: (data) {
                final episodeItems = data.episodeIds
                    .map((e) => mediaCache[e])
                    .where(
                      (e) => e != null && e.seasonId == data.selectedSeasonId,
                    );

                final seasonItems = data.seasonIds
                    .map((s) => mediaCache[s])
                    .where((e) => e != null);

                final nextUpIndex = episodeItems
                    .map((e) => e!.id)
                    .toList()
                    .indexOf(data.nextUp ?? episodeItems.first!.id);

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!hasScrolled) {
                    hasScrolled = true;
                    if (nextUpIndex > 0 && scrollController.hasClients) {
                      _scrollTo(nextUpIndex);
                    } else {
                      _scrollTo(0);
                    }
                  }
                });

                return CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    PinnedHeaderSliver(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: FSelect.rich(
                                control: .managed(
                                  initial: seasonItems.firstWhereOrNull(
                                    (s) => s?.id == data.selectedSeasonId,
                                  ),
                                  onChange: (s) {
                                    detNotifier.setSelectedSeason(s!.id);

                                    final episodeItems = data.episodeIds
                                        .map((e) => mediaCache[e])
                                        .where(
                                          (e) =>
                                              e != null && e.seasonId == s.id,
                                        );

                                    final episodes = episodeItems
                                        .map((e) => e!.id)
                                        .toList();

                                    if (episodes.contains(data.nextUp)) {
                                      final next = episodes.indexOf(
                                        data.nextUp!,
                                      );

                                      _scrollTo(next);
                                    } else {
                                      _scrollTo(0);
                                    }
                                  },
                                ),
                                format: (value) => value.name,
                                children: seasonItems
                                    .map(
                                      (s) => FSelectItem.item(
                                        title: Text(s!.name),
                                        value: s,
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverList.builder(
                      itemCount: episodeItems.length,
                      itemBuilder: (context, index) {
                        final item = episodeItems.elementAt(index)!;

                        final isPlayed = item.userData?.played ?? false;
                        final isNext = item.id == data.nextUp;

                        return SizedBox(
                          height: totalItemHeight,
                          child: Padding(
                            padding: EdgeInsets.only(
                              bottom: index == episodeItems.length - 1
                                  ? 0
                                  : 8.0,
                            ),
                            child: FButton(
                              variant: .outline,
                              onPress: () {},
                              mainAxisAlignment: .start,
                              child: Expanded(
                                child: Row(
                                  spacing: 10,
                                  children: [
                                    ClipRRect(
                                      borderRadius: style.borderRadius.sm,
                                      child: SizedBox(
                                        height: 150,
                                        width: 16 / 9 * 150,
                                        child: Stack(
                                          fit: .expand,
                                          children: [
                                            CachedNetworkImage(
                                              key: ValueKey(item.id),
                                              imageUrl: item.getImage(
                                                type: JellyfinImagesApi
                                                    .typePrimary,
                                              ),
                                              useOldImageOnUrlChange: true,
                                              height: 150,
                                              memCacheHeight: 150,
                                              fit: .cover,
                                              color: isPlayed
                                                  ? Colors.black.withAlpha(
                                                      220,
                                                    )
                                                  : Colors.transparent,
                                              colorBlendMode: .srcATop,
                                            ),
                                            if (isPlayed)
                                              Center(
                                                child: Icon(
                                                  FLucideIcons.check,
                                                ),
                                              ),

                                            if (item.getPlayProgress() != 0 ||
                                                isNext)
                                              Align(
                                                alignment: .bottomCenter,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    8.0,
                                                  ),
                                                  child: FDeterminateProgress(
                                                    style: .delta(
                                                      motion: .delta(
                                                        duration: .zero,
                                                      ),
                                                    ),
                                                    value: item
                                                        .getPlayProgress(),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        spacing: 10,
                                        crossAxisAlignment: .start,
                                        children: [
                                          Text(
                                            '${(item.indexNumber ?? (index + 1))}. ${item.name}',
                                            style: theme.typography.body.md
                                                .copyWith(
                                                  fontWeight: .bold,
                                                ),
                                          ),
                                          Text(
                                            item.getOverview() ??
                                                'No overview provided',
                                            maxLines: 4,
                                            overflow: .ellipsis,
                                            style: theme.typography.body.sm
                                                .copyWith(
                                                  color: theme.colors.foreground
                                                      .withAlpha(
                                                        100,
                                                      ),
                                                ),
                                          ),
                                          if (isNext)
                                            Text(
                                              'Ends: ${item.getEndsAt(context)}',
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _scrollTo(int index) {
    final currentOffset = scrollController.offset;
    final targetOffset = index * totalItemHeight;

    // if target is below
    if (targetOffset > currentOffset) {
      final targetDistance = ((targetOffset - currentOffset) / totalItemHeight)
          .toInt();

      if (targetDistance > 10) {
        scrollController.jumpTo(targetOffset - totalItemHeight * 5);
      }
    } else {
      final targetDistance = ((currentOffset - targetOffset) / totalItemHeight)
          .toInt();

      if (targetDistance > 10) {
        scrollController.jumpTo(targetOffset + totalItemHeight * 5);
      }
    }

    scrollController.animateTo(
      targetOffset,
      duration: kDefaultAnimationDuration,
      curve: Curves.easeInCubic,
    );
  }
}
