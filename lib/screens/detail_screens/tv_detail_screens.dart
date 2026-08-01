import 'package:animate_do/animate_do.dart';
import 'package:awesome_extensions/awesome_extensions_dart.dart';
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:pudding/providers/series_detail_provider.dart';
import 'package:pudding/screens/detail_screens/widgets/detail_column.dart';
import 'package:pudding/screens/detail_screens/widgets/poster_column.dart';
import 'package:pudding/services/di.dart';
import 'package:pudding/widgets/logo_shimmer.dart';

class TvDetailScreen extends ConsumerStatefulWidget {
  final String? showId;
  const TvDetailScreen({super.key, this.showId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ShowsDetailScreensState();
}

class _ShowsDetailScreensState extends ConsumerState<TvDetailScreen> {
  String selectedSeasonId = '';

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);

    final detAsync = ref.watch(seriesDetailProvider(widget.showId!));

    return Stack(
      fit: .expand,
      children: [
        Positioned.fill(
          child: CachedNetworkImage(
            imageUrl: services<JellyfinClient>().images.url(
              itemId: widget.showId!,
              type: JellyfinImagesApi.typeBackdrop,
            ),
            errorBuilder: (context, error, stackTrace) => Align(
              alignment: .bottomRight,
              child: Text(
                'Backdrop error: ${error.toString()}',
                style: theme.typography.body.xs2.copyWith(
                  fontStyle: .italic,
                  color: theme.colors.foreground.withAlpha(150),
                ),
              ),
            ),
            fit: .cover,
            color: Colors.black.withAlpha(230),
            colorBlendMode: .darken,
          ),
        ),
        detAsync.when(
          skipLoadingOnReload: true,
          loading: () => Center(
            child: LogoShimmer(
              id: widget.showId!,
            ).fadeIn(delay: 100.milliseconds),
          ),
          error: (error, stackTrace) => Center(
            child: Text(error.toString()),
          ),
          data: (data) {
            return Stack(
              fit: .expand,
              children: [
                Positioned.fill(
                  top: kToolbarHeight + 8,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Center(
                          child: PosterColumn(
                            seriesId: widget.showId!,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: DetailColumn(seriesId: widget.showId!),
                      ),
                    ],
                  ),
                ),
              ],
            ).fadeIn();
          },
        ),
      ],
    );
  }
}
