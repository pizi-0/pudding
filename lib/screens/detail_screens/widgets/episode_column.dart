import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:pudding/providers/jelly_cache_provider.dart';
import 'package:pudding/providers/series_detail_provider.dart';
import 'package:pudding/screens/detail_screens/widgets/episode_list_display.dart';

import 'season_selector.dart';

class EpisodesColumn extends ConsumerStatefulWidget {
  final String seriesId;
  const EpisodesColumn({super.key, required this.seriesId});

  @override
  ConsumerState<EpisodesColumn> createState() => EpisodesColumnState();
}

class EpisodesColumnState extends ConsumerState<EpisodesColumn> {
  final scrollController = ScrollController();
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

    final jellyCache = ref.watch(jellyCacheProvider);

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
                    final seasonItems = data.seasonIds
                        .map((s) => jellyCache[s])
                        .where((e) => e != null);

                    final selectedSeasonItem = seasonItems.firstWhere(
                      (s) => s?.id == data.selectedSeasonId,
                      orElse: () => seasonItems.first,
                    );

                    return Column(
                      children: [
                        SeasonSelector(
                          maxHeight: cardSize.maxHeight,
                          seriesId: widget.seriesId,
                          selectedSeasonItem: selectedSeasonItem,
                          seasonItems: seasonItems,
                          onSeasonChange: (s) {},
                        ),
                        Expanded(
                          child: EpisodeListDisplay(
                            key: ValueKey(data.selectedSeasonId),
                            seriesId: widget.seriesId,
                          ),
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
}
