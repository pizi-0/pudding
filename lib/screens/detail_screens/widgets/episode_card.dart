import 'package:awesome_extensions/awesome_extensions_flutter.dart';
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:pudding/const/const.dart';
import 'package:pudding/utils/jellyfin_item_extensions.dart';

class EpisodeCard extends ConsumerStatefulWidget {
  final JellyfinItem episode;
  final bool isLast;
  final int index;
  final bool isNext;

  const EpisodeCard({
    super.key,
    this.isLast = false,
    required this.episode,
    required this.index,
    this.isNext = false,
  });

  @override
  ConsumerState<EpisodeCard> createState() => _EpisodeCardState();
}

class _EpisodeCardState extends ConsumerState<EpisodeCard> {
  final double imageHeight = 180;
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    final double totalItemHeight = imageHeight + 30;

    final theme = FTheme.of(context);
    final style = theme.style;

    final isPlayed = widget.episode.userData?.played ?? false;

    return AnimatedScale(
      duration: kDefaultAnimationDuration,
      scale: hover ? 1.02 : 1,
      child: SizedBox(
        height: totalItemHeight,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            8,
            0,
            8,
            widget.isLast ? 0 : 8.0,
          ),
          child: FButton.raw(
            variant: .outline,
            onPress: () {},
            onFocusChange: (value) => setState(() => hover = !hover),
            onHoverChange: (value) => setState(() => hover = !hover),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(220),
                  borderRadius: style.borderRadius.sm,
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _buildImage(
                        style,
                        widget.episode,
                        isPlayed,
                        widget.isNext,
                      ),
                    ),
                    _buildDetail(
                      widget.episode,
                      widget.index,
                      theme,
                      widget.isNext,
                      context,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetail(
    JellyfinItem item,
    int index,
    FThemeData theme,
    bool isNext,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        spacing: 8,
        mainAxisAlignment: .end,
        crossAxisAlignment: .start,
        children: [
          FDeterminateProgress(
            style: .delta(
              motion: .delta(
                duration: .zero,
              ),
            ),
            value: item.getPlayProgress(),
          ).setOpacity(opacity: isNext ? 1 : 0),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${(item.indexNumber ?? (index + 1))}. ${item.name}',
                  style: theme.typography.body.sm.copyWith(
                    fontWeight: .bold,
                  ),
                ),
              ),
              if (isNext)
                Text(
                  '${item.getRemaining()} left',
                ),
            ],
          ),

          // Text(
          //   item.getOverview() ?? 'No overview provided',
          //   maxLines: 2,
          //   overflow: .ellipsis,
          //   style: theme.typography.body.sm.copyWith(
          //     color: theme.colors.foreground.withAlpha(
          //       150,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  ClipRRect _buildImage(
    FStyle style,
    JellyfinItem item,
    bool isPlayed,
    bool isNext,
  ) {
    return ClipRRect(
      borderRadius: style.borderRadius.sm,
      child: SizedBox(
        height: imageHeight,
        width: 16 / 7 * imageHeight,
        child: Stack(
          fit: .expand,
          children: [
            AnimatedOpacity(
              duration: kDefaultAnimationDuration,
              opacity: hover ? 0.8 : 1,
              child: ShaderMask(
                shaderCallback: (rect) => LinearGradient(
                  colors: [Colors.transparent, Colors.black],
                  begin: .topCenter,
                  end: .bottomCenter,
                ).createShader(rect),
                blendMode: .dstOut,
                child: CachedNetworkImage(
                  key: ValueKey(item.id),
                  imageUrl: item.getImage(
                    type: JellyfinImagesApi.typePrimary,
                  ),
                  useOldImageOnUrlChange: true,
                  fit: .cover,
                  color: isPlayed
                      ? Colors.black.withAlpha(
                          220,
                        )
                      : Colors.transparent,
                  colorBlendMode: .srcATop,
                ),
              ),
            ),
            if (isPlayed)
              Center(
                child: Icon(
                  FLucideIcons.check,
                ),
              ),

            // if (item.getPlayProgress() != 0 || isNext)
            //   Align(
            //     alignment: .bottomCenter,
            //     child: Padding(
            //       padding: const EdgeInsets.all(
            //         8.0,
            //       ),
            //       child: FDeterminateProgress(
            //         style: .delta(
            //           motion: .delta(
            //             duration: .zero,
            //           ),
            //         ),
            //         value: item.getPlayProgress(),
            //       ),
            //     ),
            //   ),
            if (isNext)
              Align(
                alignment: .topRight,
                child: Padding(
                  padding: const EdgeInsets.all(
                    4.0,
                  ),
                  child: FBadge(
                    child: Text(item.isResumable ? 'Continue' : 'Next'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
