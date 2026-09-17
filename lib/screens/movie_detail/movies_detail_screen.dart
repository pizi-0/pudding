import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:forui_phosphor/forui_phosphor.dart';
import 'package:pudding/screens/movie_detail/model/movie_screen_state.dart';
import 'package:pudding/screens/movie_detail/provider/movie_state_provider.dart';
import 'package:pudding/utils/scroll_to_key_extension.dart';
import 'package:pudding/widgets/detail_scaffold.dart';
import 'package:pudding/widgets/detail_slivers/sliver_collections.dart';
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
  final GlobalKey infoKey = GlobalKey(debugLabel: 'info-section');
  final GlobalKey multipartKey = GlobalKey(debugLabel: 'multipart-section');
  final GlobalKey collectionsKey = GlobalKey(debugLabel: 'collections-section');
  final GlobalKey peopleKey = GlobalKey(debugLabel: 'people-section');
  final GlobalKey similarKey = GlobalKey(debugLabel: 'similar-section');
  List<(GlobalKey, String, IconData)> destinations = [];

  bool favoriteLoading = false;
  bool playedLoading = false;
  bool destinationSet = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.invalidate(movieStateProvider(widget.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    final movieAsync = ref.watch(movieStateProvider(widget.id));

    ref.listen(movieStateProvider(widget.id), (p, n) {
      n.whenOrNull(
        data: (data) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _buildDestinations(data);
          });
        },
      );
    });

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
      sliverBuilder: (context, controller) => movieAsync.when(
        skipLoadingOnReload: true,
        loading: () => [SliverLoader(id: widget.id)],
        error: (error, stackTrace) => [SliverError(error: error.toString())],
        data: (m) {
          return [
            SliverShowcase(
              key: infoKey,
              item: m.movie!,
              maxExtent: size.height - 76 - 96,
              onToggleFavorite: _toggleFavorite,
              onTogglePlayed: _togglePlayed,
              filesize: m.size,
            ),

            if (m.isMultipart)
              SliverMultipart(
                key: multipartKey,
                items: m.multipart,
              ),

            if (m.collections.isNotEmpty)
              SliverCollections(
                key: collectionsKey,
                items: m.collections,
              ),

            SliverPeople(key: peopleKey, media: m.movie!),

            SliverSimilar(key: similarKey, items: m.similars),
          ];
        },
      ),
    );
  }

  void _buildDestinations(MovieScreenState state) {
    destinations = [
      (infoKey, 'Info', FPhosphorBoldIcons.info),
      if (state.isMultipart)
        (multipartKey, 'Additional parts', FPhosphorBoldIcons.television),
      if (state.collections.isNotEmpty)
        (collectionsKey, 'Collections', FPhosphorBoldIcons.package),
      (peopleKey, 'Cast & Crew', FPhosphorBoldIcons.user),
      (similarKey, 'More', FPhosphorBoldIcons.starFour),
    ];

    setState(() {});
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
