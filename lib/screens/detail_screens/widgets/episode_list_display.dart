import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/widgets/progress.dart';
import 'package:pudding/providers/media_cache_provider.dart';
import 'package:pudding/providers/series_detail_provider.dart';
import 'package:pudding/screens/detail_screens/providers/episode_provider.dart';
import 'package:pudding/screens/detail_screens/widgets/episode_card.dart';

import '../../../const/const.dart';

class EpisodeListDisplay extends ConsumerStatefulWidget {
  final String seasonId;
  const EpisodeListDisplay({
    super.key,
    required this.seasonId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EpisodeListDisplayState();
}

class _EpisodeListDisplayState extends ConsumerState<EpisodeListDisplay> {
  ScrollController scrollController = ScrollController();

  bool hasScrolled = false;

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final epAsync = ref.watch(episodeProvider(widget.seasonId));
    final mediaCache = ref.watch(mediaCacheProvider);
    final season = mediaCache[widget.seasonId];
    final seriesId = season!.seriesId!;

    final seriesDetail = ref.watch(seriesDetailProvider(seriesId)).value!;

    return epAsync.when(
      loading: () => Center(
        child: FCircularProgress(),
      ),
      error: (error, stackTrace) => Center(
        child: Text(error.toString()),
      ),
      data: (data) {
        final nextIndex =
            seriesDetail.nextUp == null || seriesDetail.nextUp!.isEmpty
            ? 0
            : data.indexOf(seriesDetail.nextUp!);

        WidgetsBinding.instance.addPostFrameCallback(
          (timeStamp) {
            if (!hasScrolled) {
              hasScrolled = true;

              _scrollTo(nextIndex);
            }
          },
        );

        return ListView.separated(
          physics: ClampingScrollPhysics(),
          padding: .fromLTRB(8, 4, 8, 8),
          controller: scrollController,
          itemCount: data.length,
          separatorBuilder: (context, index) => SizedBox(height: 8),
          itemBuilder: (context, index) {
            final episodeId = data[index];
            final episodeItem = mediaCache[episodeId]!;

            return EpisodeCard(
              episode: episodeItem,
              index: index,
              isNext: index == nextIndex,
            );
          },
        );
      },
    );
  }

  void _scrollTo(int index) {
    final currentOffset = scrollController.offset;
    final targetOffset = index * (kEpisodeCardHeight + 8);

    // if target is below
    if (targetOffset > currentOffset) {
      final targetDistance =
          ((targetOffset - currentOffset) / (kEpisodeCardHeight + 8)).toInt();

      if (targetDistance > 10) {
        scrollController.jumpTo(targetOffset - (kEpisodeCardHeight + 8) * 5);
      }
    } else {
      final targetDistance =
          ((currentOffset - targetOffset) / (kEpisodeCardHeight + 8)).toInt();

      if (targetDistance > 10) {
        scrollController.jumpTo(targetOffset + (kEpisodeCardHeight + 8) * 5);
      }
    }

    scrollController.animateTo(
      targetOffset,
      duration: kDefaultAnimationDuration,
      curve: Curves.easeInCubic,
    );
  }
}
