import 'package:awesome_extensions/awesome_extensions.dart' show StyledText;
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:pudding/screens/library_detail/library_detail_provider.dart';

import '../../widgets/media_card.dart';

class LibraryDetail extends ConsumerStatefulWidget {
  final String? id;

  const LibraryDetail({super.key, this.id});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LibraryDetailState();
}

class _LibraryDetailState extends ConsumerState<LibraryDetail> {
  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final libAsync = ref.watch(libraryProvider(widget.id!));

    return Listener(
      onPointerDown: (event) {
        if (event.buttons == kBackMouseButton) {
          context.pop();
        }
      },
      child: FScaffold(
        childPad: false,
        child: libAsync.when(
          loading: () => Center(
            child: FCircularProgress(),
          ),
          error: (error, stackTrace) => Center(
            child: Text(error.toString()),
          ),
          data: (data) {
            final libs = data.items;

            return CustomScrollView(
              slivers: [
                PinnedHeaderSliver(
                  child: Appbar(
                    prefix: FButton.icon(
                      onPress: context.pop,
                      child: Icon(FLucideIcons.chevronLeft),
                    ),
                    title: Row(
                      children: [
                        Text(
                          data.name,
                          style: theme.typography.display.lg,
                        ).bold(),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: .fromLTRB(10, 0, 10, 10),
                  sliver: SliverGrid.builder(
                    key: ValueKey(widget.id),
                    itemCount: libs.length,
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      childAspectRatio: 10 / 16,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) {
                      final item = libs[index];

                      return NewMediaCard(
                        key: ValueKey(item.id),
                        item: item,
                        imageType: JellyfinImagesApi.typePrimary,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class Appbar extends StatelessWidget {
  final Widget? prefix;
  final Widget? suffix;
  final Widget? title;
  const Appbar({super.key, this.prefix, this.title, this.suffix});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Colors.transparent],
          begin: .topCenter,
          end: .bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          spacing: 10,
          children: [
            ?prefix,
            ?title,
            ?suffix,
          ],
        ),
      ),
    );
  }
}
