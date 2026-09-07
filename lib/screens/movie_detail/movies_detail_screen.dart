import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:pudding/screens/movie_detail/provider/movie_state_provider.dart';
import 'package:pudding/services/di.dart';
import 'package:pudding/widgets/detail_scaffold.dart';
import 'package:pudding/widgets/detail_slivers/sliver_error.dart';
import 'package:pudding/widgets/detail_slivers/sliver_loader.dart';
import 'package:pudding/widgets/detail_slivers/sliver_multipart.dart';
import 'package:pudding/widgets/detail_slivers/sliver_people.dart';
import 'package:pudding/widgets/detail_slivers/sliver_showcase.dart';
import 'package:pudding/widgets/detail_slivers/sliver_similar.dart';
import 'package:pudding/widgets/detail_slivers/sliver_topbar.dart';

class MovieDetailScreen extends ConsumerStatefulWidget {
  final String id;
  const MovieDetailScreen({super.key, required this.id});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ShowsDetailScreensState();
}

class _ShowsDetailScreensState extends ConsumerState<MovieDetailScreen> {
  final GlobalKey peopleKey = GlobalKey(debugLabel: 'people-section');

  final ScrollController scrollController = ScrollController();
  final client = services<JellyfinClient>();

  ValueNotifier<double> scrollOffset = ValueNotifier(0);
  bool favoriteLoading = false;
  bool playedLoading = false;

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final movieAsync = ref.watch(movieStateProvider(widget.id));

    final size = MediaQuery.sizeOf(context);

    return DetailScaffold(
      backdrop: DetailBackdrop(id: widget.id),
      headerSliver: SliverTopbar(
        suffix: PDetailRefreshButton(),
        children: [
          if (movieAsync.hasValue)
            FButton(
              variant: .outline,
              mainAxisAlignment: .start,
              mainAxisSize: .min,
              onPress: () {},
              suffix: movieAsync.isLoading ? FCircularProgress() : null,
              child: Flexible(
                child: Text(
                  movieAsync.value!.movie!.name,
                  overflow: .ellipsis,
                ),
              ),
            ),
        ],
      ),
      slivers: movieAsync.when(
        skipLoadingOnReload: true,
        loading: () => [SliverLoader(id: widget.id)],
        error: (error, stackTrace) => [SliverError(error: error.toString())],
        data: (m) {
          return [
            SliverShowcase(
              item: m.movie!,
              maxExtent: size.height - 76 - 96,
              onToggleFavorite: _toggleFavorite,
              onTogglePlayed: _togglePlayed,
            ),

            if (m.isMultipart) SliverMultipart(items: m.multipart),

            SliverPeople(media: m.movie!),

            SliverSimilar(items: m.similars),
          ];
        },
      ),
    );
  }

  Future<void> _toggleFavorite() async {
    if (favoriteLoading) return;

    try {
      favoriteLoading = true;

      ref.read(movieStateProvider(widget.id).notifier).toggleFavorite();
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

      ref.read(movieStateProvider(widget.id).notifier).togglePlayed();
    } on Exception catch (e) {
      debugPrint(e.toString());
    } finally {
      playedLoading = false;
    }
  }
}
