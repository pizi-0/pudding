import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:pudding/utils/jellyfin_item_extensions.dart';

class SeasonCard extends StatelessWidget {
  final JellyfinItem season;
  final bool selected;
  final Function()? onPress;

  const SeasonCard({
    super.key,
    required this.season,
    this.onPress,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final style = theme.style;
    final seasonProgress = season.getSeasonPlayPercentage();

    final isPlayed = seasonProgress == 100;

    return FButton.raw(
      variant: selected ? .primary : .outline,
      onPress: onPress,
      child: Padding(
        padding: const EdgeInsets.all(
          2.0,
        ),
        child: Stack(
          fit: .expand,
          children: [
            ClipRRect(
              borderRadius: style.borderRadius.sm,
              child: ShaderMask(
                shaderCallback: (rect) =>
                    LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black,
                      ],
                      begin: .topCenter,
                      end: .bottomCenter,
                    ).createShader(
                      rect,
                    ),
                blendMode: .darken,
                child: CachedNetworkImage(
                  imageUrl: season.getImage(
                    type: JellyfinImagesApi.typePrimary,
                  ),
                  fit: .cover,
                  errorBuilder: (context, error, stackTrace) =>
                      CachedNetworkImage(
                        imageUrl: season.getPrimary(),
                        fit: .cover,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Text(
                            season.indexNumber?.toString() ?? '',
                            style: theme.typography.display.xl,
                          ).bold(),
                        ),
                      ),
                ),
              ),
            ),
            Align(
              alignment: .bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(
                  10.0,
                ),
                child: Row(
                  mainAxisAlignment: .spaceBetween,
                  children:
                      [
                        Text(
                          season.name,
                        ),
                        isPlayed
                            ? Icon(
                                FLucideIcons.check,
                                color: Colors.green,
                              )
                            : Text(
                                '${season.getSeasonPlayPercentage()}%',
                              ),
                      ].separatedby(
                        Icon(
                          FLucideIcons.dot,
                        ),
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
