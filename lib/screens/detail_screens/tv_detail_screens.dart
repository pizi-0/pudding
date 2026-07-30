import 'package:animate_do/animate_do.dart';
import 'package:awesome_extensions/awesome_extensions_dart.dart';
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:pudding/providers/media_cache_provider.dart';
import 'package:pudding/providers/series_detail_provider.dart';
import 'package:pudding/services/di.dart';
import 'package:pudding/utils/jellyfin_item_extensions.dart';

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
    final style = theme.style;

    final size = MediaQuery.sizeOf(context);
    final detAsync = ref.watch(seriesDetailProvider(widget.showId!));

    return AnimatedSwitcher(
      duration: 5.seconds,
      child: Container(
        color: Colors.black,
        child: detAsync.when(
          loading: () => Center(
            child: CachedNetworkImage(
              imageUrl: services<JellyfinClient>().images.url(
                itemId: widget.showId!,
                type: JellyfinImagesApi.typeLogo,
                width: 200,
              ),
              errorBuilder: (context, error, stackTrace) => FCircularProgress(),
            ),
          ),
          error: (error, stackTrace) => Center(
            child: Text(error.toString()),
          ),
          data: (data) {
            final item = ref.watch(mediaCacheProvider)[data.seriesId]!;

            return Stack(
              fit: .expand,
              children: [
                CachedNetworkImage(
                  imageUrl: item.getBackdrop(),
                  fit: .cover,
                  color: Colors.black.withAlpha(230),
                  colorBlendMode: .darken,
                ),
                Positioned.fill(
                  top: kToolbarHeight + 8,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: IntrinsicWidth(
                          child: Column(
                            mainAxisAlignment: .center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Container(
                                  height: size.height * 0.6,
                                  clipBehavior: .antiAlias,
                                  decoration: BoxDecoration(
                                    borderRadius: style.borderRadius.lg,
                                    border: .all(
                                      color: theme.colors.border,
                                      width: 2,
                                    ),
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: item.getPrimary(),
                                    fit: .cover,
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: .center,
                                children: [
                                  Text(item.getSeriesRunYears()),
                                  Text('${item.childCount} seasons'),
                                  if (item.getOfficialRating() != null)
                                    Container(
                                      height: theme.typography.body.lg.fontSize,
                                      decoration: BoxDecoration(
                                        border: .all(
                                          color: theme.colors.foreground,
                                        ),
                                        borderRadius: .circular(4),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 1.5,
                                          horizontal: 3,
                                        ),
                                        child: FittedBox(
                                          child: Text(
                                            item.getOfficialRating()!,
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (item.getCommunityRating() != null)
                                    Row(
                                      spacing: 4,
                                      children: [
                                        Icon(
                                          FLucideIcons.star,
                                          size:
                                              theme.typography.body.sm.fontSize,
                                        ),
                                        Text(
                                          item.getCommunityRating()!.toString(),
                                        ),
                                      ],
                                    ),
                                ].separatedby(Icon(FLucideIcons.dot)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              SelectableText(item.getRaw()),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ).fadeIn();
          },
        ),
      ),
    );
  }
}
