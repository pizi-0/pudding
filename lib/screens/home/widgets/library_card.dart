import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pudding/utils/jellyfin_view_extension.dart';
import 'package:pudding/widgets/card_button.dart';

class LibraryCard extends ConsumerWidget {
  final JellyfinView view;
  const LibraryCard({super.key, required this.view});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CardButton(
      child: CachedNetworkImage(
        imageUrl: view.getPrimaryImage(),
      ),
    );
  }
}
