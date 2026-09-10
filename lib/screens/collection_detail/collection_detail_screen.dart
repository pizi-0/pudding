import 'dart:math';

import 'package:awesome_extensions/awesome_extensions.dart' show ListExtension;
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:forui_phosphor/forui_phosphor.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pudding/screens/collection_detail/provider/collection_state_provider.dart';
import 'package:pudding/utils/jellyfin_item_extensions.dart';
import 'package:pudding/widgets/detail_scaffold.dart';
import 'package:pudding/widgets/detail_slivers/sliver_error.dart';
import 'package:pudding/widgets/detail_slivers/sliver_item_grid.dart';
import 'package:pudding/widgets/detail_slivers/sliver_loader.dart';
import 'package:pudding/widgets/detail_slivers/sliver_section.dart';
import 'package:pudding/widgets/detail_slivers/sliver_topbar.dart';
import 'package:pudding/widgets/icon_text.dart';
import 'package:pudding/widgets/rating_container.dart';

class CollectionDetailScreen extends ConsumerStatefulWidget {
  final String id;
  const CollectionDetailScreen({super.key, required this.id});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CollectionDetailScreenState();
}

class _CollectionDetailScreenState
    extends ConsumerState<CollectionDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.invalidate(collectionStateProvider(widget.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    final colAsync = ref.watch(collectionStateProvider(widget.id));

    return DetailScaffold(
      backdrop: DetailBackdrop(id: widget.id),
      headerSliver: SliverTopbar(
        suffix: PDetailRefreshButton(),
        children: [
          if (colAsync.hasValue)
            FButton(
              variant: .outline,
              mainAxisSize: .min,
              onPress: () {},
              suffix: colAsync.isLoading ? FCircularProgress() : null,
              child: Flexible(
                child: Text(
                  colAsync.value!.collection!.name,
                  overflow: .ellipsis,
                ),
              ),
            ),
        ],
      ),
      slivers: colAsync.when(
        skipLoadingOnReload: true,
        loading: () => [SliverLoader(id: widget.id)],
        error: (error, stackTrace) => [SliverError(error: error.toString())],
        data: (c) {
          return [
            SliverCollectionStats(id: widget.id),
            SliverToBoxAdapter(
              child: Text(c.collection!.getRaw()),
            ),
            if (c.movies.isNotEmpty)
              SliverSection(
                header: FButton(
                  variant: .outline,
                  onPress: () {},
                  child: Text('Movies'),
                ),
                slivers: [
                  SliverItemGrid(
                    items: c.movies,
                    isPoster: true,
                  ),
                ],
              ),
            if (c.series.isNotEmpty)
              SliverSection(
                header: FButton(
                  variant: .outline,
                  onPress: () {},
                  child: Text('Series'),
                ),
                slivers: [
                  SliverItemGrid(
                    items: c.series,
                    isPoster: true,
                  ),
                ],
              ),
            if (c.seasons.isNotEmpty)
              SliverSection(
                header: FButton(
                  variant: .outline,
                  onPress: () {},
                  child: Text('Seasons'),
                ),
                slivers: [
                  SliverItemGrid(
                    items: c.seasons,
                    isPoster: true,
                  ),
                ],
              ),
            if (c.episodes.isNotEmpty)
              SliverSection(
                header: FButton(
                  variant: .outline,
                  onPress: () {},
                  child: Text('Episodes'),
                ),
                slivers: [
                  SliverItemGrid(
                    items: c.episodes,
                    isPoster: true,
                  ),
                ],
              ),
            if (c.videos.isNotEmpty)
              SliverSection(
                header: FButton(
                  variant: .outline,
                  onPress: () {},
                  child: Text('Videos'),
                ),
                slivers: [
                  SliverItemGrid(
                    items: c.videos,
                    isPoster: true,
                  ),
                ],
              ),
          ];
        },
      ),
    );
  }
}

class SliverCollectionStats extends ConsumerStatefulWidget {
  final String id;
  const new({
    super.key,
    required this.id,
  });

  @override
  ConsumerState<SliverCollectionStats> createState() =>
      _SliverCollectionStatsState();
}

class _SliverCollectionStatsState extends ConsumerState<SliverCollectionStats> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final theme = context.theme;

    final collAsync = ref.watch(collectionStateProvider(widget.id));

    final state = collAsync.value!;
    final item = state.collection!;

    final year = item.productionYear;
    final genres = item.genresShort();
    final parentalRating = item.getOfficialRating();
    final overview = item.getOverview();

    return SliverToBoxAdapter(
      child: SizedBox(
        height: size.height - 76 - 76,
        width: size.width - 40,
        child: Column(
          spacing: 20,
          mainAxisAlignment: .end,
          children: [
            Row(
              crossAxisAlignment: .end,
              children: [
                ClipRRect(
                  borderRadius: theme.style.borderRadius.sm,
                  child: SizedBox(
                    width: 250,
                    child: CachedNetworkImage(
                      imageUrl: item.getPrimary(),
                      filterQuality: .medium,
                      fit: .cover,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      spacing: 10,
                      mainAxisAlignment: .end,
                      crossAxisAlignment: .start,
                      children: [
                        Row(
                          children: genres
                              .map((g) => Text(g))
                              .toList()
                              .separatedBy(Icon(FPhosphorBoldIcons.dot)),
                        ),
                        Row(
                          children: [
                            if (year != null)
                              IconText(
                                text: year.toString(),
                                icon: FPhosphorBoldIcons.calendar,
                              ),
                            if (parentalRating != null)
                              RatingContainer(rating: parentalRating),
                          ].separatedBy(Icon(FPhosphorBoldIcons.dot)),
                        ),
                        Row(
                          children: [
                            if (state.movies.isNotEmpty)
                              IconText(
                                text: '${state.movies.length} movies',
                                icon: FPhosphorBoldIcons.filmSlate,
                              ),
                            if (state.series.isNotEmpty)
                              IconText(
                                text: '${state.series.length} series',
                                icon: FPhosphorBoldIcons.television,
                              ),
                            if (state.seasons.isNotEmpty)
                              IconText(
                                text: '${state.seasons.length} seasons',
                                icon: FPhosphorBoldIcons.television,
                              ),
                            if (state.episodes.isNotEmpty)
                              IconText(
                                text: '${state.episodes.length} episodes',
                                icon: FPhosphorBoldIcons.televisionSimple,
                              ),
                            if (state.videos.isNotEmpty)
                              IconText(
                                text: '${state.videos.length} videos',
                                icon: FPhosphorBoldIcons.video,
                              ),
                          ].separatedBy(Icon(FPhosphorBoldIcons.dot)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (overview != null)
              Row(
                children: [
                  Expanded(child: Text(overview)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Size posterSize(double width) {
    final maxColumn = max(1, (width / 250).ceil());

    final itemWidth = (width - (10 * (maxColumn - 1))) / maxColumn;

    final itemHeight = itemWidth / (10 / 16);

    return Size(itemWidth, itemHeight);
  }
}
