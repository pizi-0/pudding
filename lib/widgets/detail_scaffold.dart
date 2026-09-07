import 'dart:math';

import 'package:awesome_extensions/awesome_extensions.dart' show StyledText;
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:forui_phosphor/forui_phosphor.dart';
import 'package:go_router/go_router.dart';
import 'package:pudding/services/di.dart';
import 'package:silky_scroll/silky_scroll.dart';

class DetailScaffold<T> extends ConsumerStatefulWidget {
  /// for premade  use [DetailBackdrop]
  final Widget? backdrop;
  final Widget? headerSliver;
  final bool? nested;
  final List<Widget> slivers;
  const new({
    super.key,
    this.backdrop,
    this.slivers = const [],
    this.nested = true,
    this.headerSliver,
  });

  @override
  ConsumerState<DetailScaffold<T>> createState() => _DetailScaffoldState();
}

class _DetailScaffoldState<T> extends ConsumerState<DetailScaffold<T>> {
  final scrollController = ScrollController();
  ValueNotifier<double> scrollOffset = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return TapRegion(
      onTapInside: (event) {
        final primary = FocusManager.instance.primaryFocus;

        if (primary != null) {
          primary.unfocus();
        }
      },
      child: Listener(
        onPointerDown: (event) {
          if (event.buttons == kBackMouseButton) {
            if (context.canPop()) {
              context.pop();
            }
          }
        },
        child: FScaffold(
          childPad: false,
          child: Stack(
            fit: .expand,
            children: [
              if (widget.backdrop != null)
                Positioned(
                  child: ValueListenableBuilder(
                    valueListenable: scrollOffset,
                    builder: (context, value, child) {
                      return ImageFiltered(
                        imageFilter: .compose(
                          outer: .blur(
                            sigmaX: (value * 250).clamp(0, 100),
                            sigmaY: (value * 250).clamp(0, 100),
                            tileMode: .clamp,
                          ),
                          inner: ColorFilter.mode(
                            Color.lerp(
                              theme.colors.background.withAlpha(180),
                              theme.colors.background.withAlpha(200),
                              value,
                            )!,
                            .dstOut,
                          ),
                        ),
                        child: child!,
                      );
                    },
                    child: widget.backdrop,
                  ),
                ),
              Positioned.fill(
                child: SilkyCustomScrollView(
                  controller: scrollController,
                  slivers: [
                    if (widget.headerSliver != null) widget.headerSliver!,

                    ...widget.slivers.map(
                      (s) => SliverPadding(
                        padding: .fromLTRB(20, 0, 20, 40),
                        sliver: s,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onScroll() {
    final offset = scrollController.offset;
    final viewport = scrollController.position.viewportDimension;
    final threshold = viewport * 0.2;

    scrollOffset.value = max(0, (offset - threshold) / viewport);
  }
}

class PBackButton extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return FButton.icon(
      onPress: context.pop,
      child: Icon(FPhosphorBoldIcons.caretLeft),
    );
  }
}

class PDetailRefreshButton extends StatelessWidget {
  final void Function()? onPress;
  const new({super.key, this.onPress});

  @override
  Widget build(BuildContext context) {
    return FButton.icon(
      onPress: onPress,
      child: Icon(FPhosphorBoldIcons.arrowClockwise),
    );
  }
}

class DetailBackdrop extends StatelessWidget {
  final String id;
  const new({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final client = services<JellyfinClient>();

    final theme = context.theme;

    return CachedNetworkImage(
      imageUrl: client.images.url(
        itemId: id,
        type: JellyfinImagesApi.typeBackdrop,
      ),
      fit: .cover,
      errorBuilder: (context, error, stackTrace) => CachedNetworkImage(
        imageUrl: client.images.url(
          itemId: id,
          type: JellyfinImagesApi.typePrimary,
        ),
        fit: .cover,
        errorBuilder: (context, error, stackTrace) => Align(
          alignment: .bottomEnd,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Missing \'backdrop\', \'primary\'',
              style: theme.typography.body.xs.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ).italic(),
          ),
        ),
      ),
    );
  }
}
