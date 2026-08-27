import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:forui_phosphor/forui_phosphor.dart';
import 'package:pudding/const/const.dart';
import 'package:pudding/utils/jellyfin_item_extensions.dart';

class EpisodeCard extends ConsumerStatefulWidget {
  final JellyfinItem episode;
  final int index;
  final bool isNext;

  const EpisodeCard({
    super.key,
    required this.episode,
    required this.index,
    this.isNext = false,
  });

  @override
  ConsumerState<EpisodeCard> createState() => _EpisodeCardState();
}

class _EpisodeCardState extends ConsumerState<EpisodeCard> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final style = theme.style;

    final isPlayed = widget.episode.userData?.played ?? false;

    return AnimatedScale(
      duration: kDefaultAnimationDuration,
      scale: hover ? 1.02 : 1,
      child: SizedBox(
        height: kEpisodeCardHeight,
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
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: _buildImage(
                      style,
                      widget.episode,
                      isPlayed,
                      widget.isNext,
                    ),
                  ),
                  Positioned.fill(
                    child: _buildDetail(
                      widget.episode,
                      widget.index,
                      theme,
                      widget.isNext,
                      isPlayed,
                    ),
                  ),
                ],
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
    bool isPlayed,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: AnimatedSwitcher(
              duration: kDefaultAnimationDuration,
              child: isPlayed
                  ? Icon(
                      FPhosphorBoldIcons.check,
                      color: Colors.green,
                    )
                  : SizedBox.shrink(),
            ),
          ),
          Expanded(
            child: Column(
              spacing: 8,
              mainAxisAlignment: .center,
              crossAxisAlignment: .start,
              children: [
                Row(
                  spacing: 10,
                  children: [
                    Expanded(
                      child: Text(
                        '${(item.indexNumber ?? (index + 1))}. ${item.name}',
                        style: theme.typography.body.sm.copyWith(
                          fontWeight: .bold,
                        ),
                      ),
                    ),
                  ],
                ),
                AnimatedSize(
                  duration: kDefaultAnimationDuration,
                  alignment: .topCenter,
                  child: SizedBox(
                    height: hover || isNext || isPlayed ? null : 0,
                    child: Text(
                      item.getOverview() ?? 'No overview provided',
                      overflow: .ellipsis,
                      maxLines: 5,
                      style: theme.typography.body.sm.copyWith(
                        color: theme.colors.foreground.withAlpha(
                          150,
                        ),
                      ),
                    ),
                  ),
                ),
                if (isNext)
                  Text(
                    '${item.getRemaining()} left',
                  ),
              ],
            ),
          ),
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
        height: kEpisodeCardHeight,
        width: 16 / 9 * kEpisodeCardHeight,
        child: Stack(
          fit: .expand,
          children: [
            AnimatedOpacity(
              duration: kDefaultAnimationDuration,
              opacity: hover ? 0.8 : 1,
              child: ShaderMask(
                shaderCallback: (rect) => LinearGradient(
                  colors: [Colors.transparent, Colors.black],
                  begin: .centerLeft,
                  end: .centerRight,
                  stops: [0.4, 1],
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
                          200,
                        )
                      : Colors.transparent,
                  colorBlendMode: .srcATop,
                ),
              ),
            ),
            if (isNext)
              Align(
                alignment: .topLeft,
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
