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
      child: FButton(
        variant: .ghost,
        style: .delta(contentStyle: .delta(padding: .value(.zero))),
        onPress: widget.onPress,
        onHoverChange: (h) => setState(() => hover = h),
        onFocusChange: (f) => setState(() => hover = f),
        crossAxisAlignment: .stretch,
        child: Expanded(
          child: ClipRRect(
            borderRadius:
                theme.buttonStyles.primary.lg.decoration.base.borderRadius!,
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
