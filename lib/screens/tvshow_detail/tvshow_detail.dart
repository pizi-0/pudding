import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:forui_phosphor/forui_phosphor.dart';
import 'package:pudding/screens/tvshow_detail/model/tvshow_screen_state.dart';
import 'package:pudding/screens/tvshow_detail/provider/tvshow_state_provider.dart';
import 'package:pudding/utils/scroll_to_key_extension.dart';
import 'package:pudding/widgets/detail_scaffold.dart';
import 'package:pudding/widgets/detail_slivers/sliver_collections.dart';
import 'package:pudding/widgets/detail_slivers/sliver_episode.dart';
import 'package:pudding/widgets/detail_slivers/sliver_people.dart';
import 'package:pudding/widgets/detail_slivers/sliver_showcase.dart';
import 'package:pudding/widgets/detail_slivers/sliver_similar.dart';
import 'package:pudding/widgets/detail_slivers/sliver_topbar.dart';
import 'package:pudding/widgets/logo_shimmer.dart';

class TvshowDetail extends ConsumerStatefulWidget {
  final String id;

  const TvshowDetail({super.key, required this.id});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TvshowDetailState();
}

class _TvshowDetailState extends ConsumerState<TvshowDetail> {
  final GlobalKey infoKey = GlobalKey(debugLabel: 'info-section');
  final GlobalKey episodeKey = GlobalKey(debugLabel: 'episode-section');
  final GlobalKey peopleKey = GlobalKey(debugLabel: 'people-section');
  final GlobalKey similarKey = GlobalKey(debugLabel: 'similar-section');
  final GlobalKey collectionKey = GlobalKey(debugLabel: 'collection-section');

  List<(GlobalKey, String, IconData)> destinations = [];

  bool favoriteLoading = false;
  bool playedLoading = false;
  bool destinationSet = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(tvshowStateProvider(widget.id));
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final tvAsync = ref.watch(tvshowStateProvider((widget.id)));

    ref.listen(tvshowStateProvider(widget.id), (p, n) {
      n.whenOrNull(
        data: (data) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _buildDestinations(data);
          });
        },
      );
    });

    return DetailScaffold(
      backdrop: DetailBackdrop(id: widget.id),
      headerSliver: SliverTopbar(
        suffix: PDetailRefreshButton(),
        children: [
          if (tvAsync.hasValue && tvAsync.value?.tvshow != null)
            FButton(
              variant: .outline,
              mainAxisAlignment: .start,
              mainAxisSize: .min,
              onPress: () {},
              suffix: tvAsync.isLoading ? FCircularProgress() : null,
              child: Flexible(
                child: Text(
                  tvAsync.value!.tvshow!.name,
                  overflow: .ellipsis,
                ),
              ),
            ),
        ],
      ),
      sideChick: Column(
        spacing: 10,
        children: destinations
            .map(
              (d) => FButton.icon(
                onPress: () => d.$1.scrollToKey(),
                child: Icon(d.$3),
              ),
            )
            .toList(),
      ),
      sliverBuilder: (context, controller) => tvAsync.when(
        skipLoadingOnReload: true,
        loading: () => [
          SliverFillViewport(
            delegate: SliverChildListDelegate.fixed([
              Center(child: LogoShimmer(id: widget.id)),
            ]),
          ),
        ],
        error: (error, stackTrace) => [
          SliverFillViewport(
            delegate: SliverChildListDelegate.fixed([
              Center(child: Text(error.toString())),
            ]),
          ),
        ],
        data: (tv) {
          return [
            SliverShowcase.tv(
              key: infoKey,
              item: tv.tvshow!,
              nextup: tv.nextup,
              maxExtent: size.height - 76 - 96,
              onToggleFavorite: _toggleFavorite,
              onTogglePlayed: _togglePlayed,
            ),
            SliverEpisodes(
              key: episodeKey,
              id: widget.id,
            ),
            if (tv.collections.isNotEmpty)
              SliverCollections(
                key: collectionKey,
                items: tv.collections,
              ),
            SliverPeople(
              key: peopleKey,
              media: tv.tvshow!,
              altMedia: tv.selectedSeason,
            ),
            SliverSimilar(
              key: similarKey,
              items: tv.similars,
            ),
          ];
        },
      ),
    );
  }

  void _buildDestinations(TvshowScreenState state) {
    destinations = [
      (infoKey, 'Info', FPhosphorBoldIcons.info),
      (episodeKey, 'Episode', FPhosphorBoldIcons.television),
      if (state.collections.isNotEmpty)
        (collectionKey, 'Collections', FPhosphorBoldIcons.package),
      (peopleKey, 'Cast & Crew', FPhosphorBoldIcons.user),
      (similarKey, 'More', FPhosphorBoldIcons.starFour),
    ];

    setState(() {});
  }

  Future<void> _toggleFavorite() async {
    if (favoriteLoading) return;

    try {
      favoriteLoading = true;

      ref.read(tvshowStateProvider(widget.id).notifier).toggleSeriesFavorite();
    } on Exception catch (e) {
      debugPrint(e.toString());
    } finally {
      favoriteLoading = false;
    }
  }

  Future<void> _togglePlayed() async {
    if (playedLoading) return;

    try {
      playedLoading = true;

      ref.read(tvshowStateProvider(widget.id).notifier).toggleSeriesPlayed();
    } on Exception catch (e) {
      debugPrint(e.toString());
    } finally {
      playedLoading = false;
    }
  }
}
