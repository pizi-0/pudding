import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:pudding/const/const.dart';
import 'package:pudding/models/series_detail_model.dart';
import 'package:pudding/providers/media_cache_provider.dart';
import 'package:pudding/providers/series_detail_provider.dart';
import 'package:pudding/screens/detail_screens/widgets/episode_card.dart';

import 'season_selector.dart';

class EpisodesColumn extends ConsumerStatefulWidget {
  final String seriesId;
  const EpisodesColumn({super.key, required this.seriesId});

  @override
  ConsumerState<EpisodesColumn> createState() => EpisodesColumnState();
}

class EpisodesColumnState extends ConsumerState<EpisodesColumn> {
  final scrollController = ScrollController();
  final double itemHeight = 120;
  late final double totalItemHeight =
      itemHeight + 30; // hwit padding and hwat not
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

    final mediaCache = ref.watch(mediaCacheProvider);

    return TapRegion(
      onTapInside: (event) => FocusScope.of(context).unfocus(),
      child: SizedBox(
        width: 550,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: LayoutBuilder(
            builder: (context, cardSize) {
              return Container(
                clipBehavior: .hardEdge,
                decoration: BoxDecoration(
                  color: theme.colors.card,
                  border: .all(color: theme.colors.border),
                  borderRadius: style.borderRadius.lg,
                ),
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
                          (e) =>
                              e != null && e.seasonId == data.selectedSeasonId,
                        );

                    final seasonItems = data.seasonIds
                        .map((s) => mediaCache[s])
                        .where((e) => e != null);

                    final selectedSeasonItem = seasonItems.firstWhere(
                      (s) => s?.id == data.selectedSeasonId,
                      orElse: () => seasonItems.first,
                    );

                    final nextUpIndex = episodeItems
                        .map((e) => e!.id)
                        .toList()
                        .indexOf(data.nextUp ?? episodeItems.first!.id);

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!hasScrolled) {
                        hasScrolled = true;
                        if (scrollController.position.maxScrollExtent > 0) {
                          _scrollTo(
                            (nextUpIndex).clamp(0, episodeItems.length - 1),
                          );
                        }
                      }
                    });

                    return CustomScrollView(
                      physics: ClampingScrollPhysics(),
                      controller: scrollController,
                      slivers: [
                        PinnedHeaderSliver(
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.colors.card,
                              borderRadius: style.borderRadius.lg,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: SeasonSelector(
                                      maxHeight: cardSize.maxHeight,
                                      seriesId: widget.seriesId,
                                      selectedSeasonItem: selectedSeasonItem,
                                      seasonItems: seasonItems,
                                      onSeasonChange: (s) =>
                                          _scrollOnSeasonSelect(
                                            data,
                                            mediaCache,
                                            s,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SliverList.builder(
                          itemCount: episodeItems.length,
                          itemBuilder: (context, index) {
                            final episode = episodeItems.elementAt(index)!;

                            final isNext = episode.id == data.nextUp;

                            return EpisodeCard(
                              episode: episode,
                              index: index,
                              isLast: index == episodeItems.length - 1,
                              isNext: isNext,
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _scrollOnSeasonSelect(
    SeriesDetailModel data,
    Map<String, JellyfinItem> mediaCache,
    JellyfinItem s,
  ) {
    final episodeItems = data.episodeIds
        .map((e) => mediaCache[e])
        .where(
          (e) => e != null && e.seasonId == s.id,
        );

    final episodes = episodeItems.map((e) => e!.id).toList();

    final nextUpIndex = episodes.indexOf(data.nextUp!);

    if (scrollController.position.maxScrollExtent > 0) {
      _scrollTo((nextUpIndex).clamp(0, episodeItems.length - 1));
    }
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
