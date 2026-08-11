// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:awesome_extensions/awesome_extensions.dart'
    show ListExtension, ShimmerEffect;
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:pudding/screens/library_detail/library_detail_provider.dart';
import 'package:pudding/widgets/pudding_scaffold.dart';

import '../../utils/jellyfin_view_extension.dart';
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
    final libAsync = ref.watch(libraryProvider(widget.id!));
    final userviews = ref.watch(userviewsProvider);

    final theme = context.theme;

    return PuddingScaffold(
      child: CustomScrollView(
        slivers: [
          PinnedHeaderSliver(
            child: Appbar(
              child: FCard(
                style: .delta(
                  decoration: .boxDelta(
                    color: theme.colors.background.withAlpha(200),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    children: [
                      FButton.icon(
                        onPress: context.pop,
                        child: Icon(FLucideIcons.chevronLeft),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: .horizontal,
                          child: Row(
                            spacing: 10,
                            children: [
                              ...userviews.values.map((v) {
                                return FButton(
                                  variant: widget.id == v.id
                                      ? .primary
                                      : .outline,
                                  onPress: () => context.pushReplacement(
                                    '/library/${v.id}',
                                  ),
                                  prefix: _getButtonIcon(v),
                                  child: Text(v.name),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ].separatedby(Icon(FLucideIcons.dot)),
                  ),
                ),
              ),
            ),
          ),
          libAsync.when(
            loading: () => SliverPadding(
              padding: .fromLTRB(10, 0, 10, 10),
              sliver: SliverGrid.builder(
                key: ValueKey(widget.id),
                itemCount: 10,
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 10 / 16,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      border: .all(
                        color: theme.colors.background,
                        width: 2,
                      ),
                      color: theme.colors.foreground,
                      borderRadius: theme.style.borderRadius.sm,
                    ),
                  ).applyShimmer(
                    baseColor: theme.colors.background,
                    highlightColor: theme.colors.muted,
                  );
                },
              ),
            ),
            error: (error, stackTrace) => SliverFillRemaining(
              child: Center(
                child: Text(error.toString()),
              ),
            ),
            data: (data) {
              final libs = data.items;

              return SliverMainAxisGroup(
                slivers: [
                  SliverPadding(
                    padding: .fromLTRB(10, 0, 10, 50),
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
        ],
      ),
    );
  }

  Widget? _getButtonIcon(JellyfinView view) {
    if (view.isMovies) {
      return Icon(FLucideIcons.film);
    }

    if (view.isTvShows) {
      return Icon(FLucideIcons.tv);
    }

    if (view.isMusic) {
      return Icon(FLucideIcons.music);
    }

    if (view.isPhotos) {
      return Icon(FLucideIcons.image);
    }

    if (view.isBoxsets) {
      return Icon(FLucideIcons.box);
    }

    if (view.isBooks) {
      return Icon(FLucideIcons.book);
    }

    if (view.isPlaylists) {
      return Icon(FLucideIcons.listVideo);
    }

    return Icon(FLucideIcons.fileQuestionMark);
  }
}

class Appbar extends StatelessWidget {
  final Widget? child;
  const Appbar({super.key, this.child});

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
        child: child,
      ),
    );
  }
}
