import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:pudding/const/const.dart';
import 'package:pudding/utils/jellyfin_view_extension.dart';

class LibraryCard extends StatefulWidget {
  final JellyfinView view;
  final Function()? onPress;
  const LibraryCard({
    super.key,
    required this.view,
    this.onPress,
  });

  @override
  State<LibraryCard> createState() => _LibraryCardState();
}

class _LibraryCardState extends State<LibraryCard> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);

    return AnimatedScale(
      duration: kDefaultAnimationDuration,
      scale: hover ? 1.02 : 1,
      curve: Curves.ease,
      child: FButton.raw(
        variant: .outline,
        style: .delta(
          decoration: .delta([
            .all(
              .boxDelta(
                color: Colors.transparent,
                border: Border.all(width: 2, color: theme.colors.border),
              ),
            ),
          ]),
        ),
        onPress: widget.onPress,
        onHoverChange: (h) => setState(() => hover = h),
        onFocusChange: (f) => setState(() => hover = f),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: ClipRRect(
            borderRadius:
                theme.buttonStyles.outline.xs.decoration.base.borderRadius!,
            child: CachedNetworkImage(
              imageUrl: widget.view.getPrimaryImage(),
              fit: .cover,
            ),
          ),
        ),
      ),
    );
  }
}
