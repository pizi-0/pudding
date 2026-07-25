import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:pudding/utils/jellyfin_item_extensions.dart';
import 'package:pudding/widgets/card_button.dart';

class MediaCard extends ConsumerWidget {
  final JellyfinItem item;
  const MediaCard({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, size) {
        return Stack(
          fit: .expand,
          children: [
            CardButton(
              child: ShaderMask(
                shaderCallback: (rect) => LinearGradient(
                  begin: .center,
                  end: .bottomCenter,
                  colors: [Colors.black, Colors.black26],
                ).createShader(rect),
                blendMode: .dstIn,
                child: CachedNetworkImage(
                  imageUrl: item.getBackdrop(),
                  height: size.maxHeight * 0.1,
                  fit: .cover,
                ),
              ),
            ),

            Align(
              alignment: .bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: .end,
                  children: [
                    Text(item.getEndsAt(context)),
                    FDeterminateProgress(value: item.getPlayProgress()),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
