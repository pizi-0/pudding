import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:pudding/screens/library_detail/library_detail_provider.dart';
import 'package:pudding/utils/jellyfin_item_extensions.dart';

class LibraryDetail extends ConsumerStatefulWidget {
  final String? id;
  const LibraryDetail({super.key, this.id});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LibraryDetailState();
}

class _LibraryDetailState extends ConsumerState<LibraryDetail> {
  @override
  Widget build(BuildContext context) {
    final libAsync = ref.watch(libraryProvider(widget.id!));
    final size = MediaQuery.sizeOf(context);

    return Container(
      color: Colors.black,
      height: size.height,
      width: size.width,
      child: libAsync.when(
        loading: () => Center(
          child: FCircularProgress(),
        ),
        error: (error, stackTrace) => Center(
          child: Text(error.toString()),
        ),
        data: (data) {
          final libs = data.items;

          return GridView.builder(
            key: ValueKey(widget.id),
            itemCount: libs.length,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
            ),
            itemBuilder: (context, index) {
              final item = libs[index];

              return CachedNetworkImage(
                imageUrl: item.getPrimary(),
              );
            },
          );
        },
      ),
    );
  }
}
