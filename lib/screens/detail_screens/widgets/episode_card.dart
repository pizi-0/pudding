import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:pudding/utils/jellyfin_item_extensions.dart';

class EpisodeCard extends ConsumerWidget {
  final double imageHeight = 120;
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
  Widget build(BuildContext context, WidgetRef ref) {
    final double totalItemHeight = imageHeight + 30;

    final theme = FTheme.of(context);
    final style = theme.style;

    final isPlayed = episode.userData?.played ?? false;

    return SizedBox(
      height: totalItemHeight,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          8,
          0,
          8,
          isLast ? 0 : 8.0,
        ),
        child: FButton(
          variant: .outline,
          onPress: () {},
          mainAxisAlignment: .start,
          child: Expanded(
            child: Row(
              spacing: 10,
              children: [
                _buildImage(
                  style,
                  episode,
                  isPlayed,
                  isNext,
                ),
                Expanded(
                  child: _buildDetail(
                    episode,
                    index,
                    theme,
                    isNext,
                    context,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Column _buildDetail(
    JellyfinItem item,
    int index,
    FThemeData theme,
    bool isNext,
    BuildContext context,
  ) {
    return Column(
      spacing: 8,
      mainAxisAlignment: .center,
      crossAxisAlignment: .start,
      children: [
        Text(
          '${(item.indexNumber ?? (index + 1))}. ${item.name}',
          style: theme.typography.body.sm.copyWith(
            fontWeight: .bold,
          ),
        ),
        Text(
          item.getOverview() ?? 'No overview provided',
          maxLines: 3,
          overflow: .ellipsis,
          style: theme.typography.body.sm.copyWith(
            color: theme.colors.foreground.withAlpha(
              100,
            ),
          ),
        ),
        if (isNext)
          Text(
            'Ends: ${item.getEndsAt(context)}',
          ),
      ],
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
        width: 16 / 10 * imageHeight,
        child: Stack(
          fit: .expand,
          children: [
            CachedNetworkImage(
              key: ValueKey(item.id),
              imageUrl: item.getImage(
                type: JellyfinImagesApi.typePrimary,
              ),
              useOldImageOnUrlChange: true,
              height: 150,
              memCacheHeight: 150,
              fit: .cover,
              color: isPlayed
                  ? Colors.black.withAlpha(
                      220,
                    )
                  : Colors.transparent,
              colorBlendMode: .srcATop,
            ),
            if (isPlayed)
              Center(
                child: Icon(
                  FLucideIcons.check,
                ),
              ),

            if (item.getPlayProgress() != 0 || isNext)
              Align(
                alignment: .bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(
                    8.0,
                  ),
                  child: FDeterminateProgress(
                    style: .delta(
                      motion: .delta(
                        duration: .zero,
                      ),
                    ),
                    value: item.getPlayProgress(),
                  ),
                ),
              ),

            if (isNext)
              Align(
                alignment: .topRight,
                child: Padding(
                  padding: const EdgeInsets.all(
                    8.0,
                  ),
                  child: Text('Resume'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
