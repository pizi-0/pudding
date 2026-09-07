import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:pudding/screens/tvshow_detail/provider/tvshow_state_provider.dart';
import 'package:pudding/services/di.dart';
import 'package:pudding/widgets/detail_scaffold.dart';
import 'package:pudding/widgets/detail_slivers/sliver_episode.dart';
import 'package:pudding/widgets/detail_slivers/sliver_people.dart';
import 'package:pudding/widgets/detail_slivers/sliver_showcase.dart';
import 'package:pudding/widgets/detail_slivers/sliver_similar.dart';
import 'package:pudding/widgets/detail_slivers/sliver_topbar.dart';
import 'package:pudding/widgets/logo_shimmer.dart';

final client = services<JellyfinClient>();

class TvshowDetail extends ConsumerStatefulWidget {
  final String id;

  const TvshowDetail({super.key, required this.id});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TvshowDetailState();
}

class _TvshowDetailState extends ConsumerState<TvshowDetail> {
  final GlobalKey seasonKey = GlobalKey(debugLabel: 'season-sliver-header');
  final GlobalKey castsKey = GlobalKey(debugLabel: 'cast-sliver-header');
  ScrollController scrollController = ScrollController();
  bool favoriteLoading = false;
  bool playedLoading = false;
  ValueNotifier<double> scrollOffset = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(tvshowStateProvider(widget.id));
    });
  }

  @override
  void dispose() {
    scrollOffset.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final tvAsync = ref.watch(tvshowStateProvider((widget.id)));

    return DetailScaffold(
      backdrop: DetailBackdrop(id: widget.id),
      headerSliver: SliverTopbar(
        suffix: PDetailRefreshButton(),
        children: [
          if (tvAsync.hasValue)
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
      slivers: tvAsync.when(
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
              item: tv.tvshow!,
              nextup: tv.nextup,
              maxExtent: size.height - 76 - 96,
              onToggleFavorite: _toggleFavorite,
              onTogglePlayed: _togglePlayed,
            ),
            SliverEpisodes(id: widget.id),
            SliverPeople(
              media: tv.tvshow!,
              altMedia: tv.selectedSeason,
            ),
            SliverSimilar(
              items: tv.similars,
            ),
          ];
        },
      ),
    );
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
