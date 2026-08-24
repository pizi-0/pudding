import 'dart:ui';

import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:pudding/screens/detail_screens/widgets/season_card.dart';
import 'package:pudding/utils/jellyfin_item_extensions.dart';

class SeasonSelector extends ConsumerStatefulWidget {
  final String seriesId;
  final JellyfinItem? selectedSeasonItem;
  final Iterable<JellyfinItem?> seasonItems;
  final double maxHeight;
  final void Function(JellyfinItem season) onSeasonChange;

  const SeasonSelector({
    super.key,
    required this.seriesId,
    required this.selectedSeasonItem,
    required this.seasonItems,
    required this.onSeasonChange,
    this.maxHeight = 400,
  });

  @override
  ConsumerState<SeasonSelector> createState() => _SeasonSelectorState();
}

class _SeasonSelectorState extends ConsumerState<SeasonSelector> {
  final GlobalKey buttonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final style = theme.style;

    double maxwidth() {
      if (widget.seasonItems.length * 200 > 5 * 200) {
        return 5 * 200;
      } else {
        return widget.seasonItems.length * 200;
      }
    }

    double maxHeight() {
      final itemHeight = 16 / 10 * 200;
      final maxRow = (widget.seasonItems.length / 5).ceil();

      if (maxRow * itemHeight > 2 * itemHeight - (maxRow * 10)) {
        return 2 * itemHeight - (maxRow * 10);
      } else {
        return itemHeight;
      }
    }

    return FPopover(
      overflow: .flip,
      style: .delta(
        popoverPadding: .value(.all(20)),
        barrierFilter: (context, animation) => .compose(
          outer: ImageFilter.blur(
            sigmaX: animation * 5,
            sigmaY: animation * 5,
          ),
          inner: ColorFilter.mode(
            Color.lerp(
              Colors.transparent,
              Colors.black.withValues(
                alpha: 0.2,
              ),
              animation,
            )!,
            .srcOver,
          ),
        ),
      ),
      cutoutBuilder: (path, bounds) => path.addRRect(
        RRect.fromRectAndRadius(
          bounds,
          style.borderRadius.md.bottomLeft,
        ),
      ), //
      constraints: FPortalConstraints(
        maxWidth: maxwidth(),
        maxHeight: maxHeight(),
      ),
      builder: (context, controller, child) => FButton(
        key: buttonKey,
        variant: .outline,
        mainAxisAlignment: .spaceBetween,
        onPress: () {
          // _findwidget();
          controller.toggle();
        },
        suffix: Icon(
          FLucideIcons.chevronDown,
        ),
        child: Text(
          widget.selectedSeasonItem!.name,
        ),
      ),
      childAnchor: .bottomLeft,
      popoverAnchor: .topLeft,
      popoverBuilder: (context, controller) {
        return GridView.builder(
          itemCount: widget.seasonItems.length,
          shrinkWrap: true,
          padding: .all(10),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio:
                widget.seasonItems.first?.getSeasonCoverAspectRatio() ??
                10 / 16,
          ),
          itemBuilder: (context, index) {
            final season = widget.seasonItems.elementAt(index)!;

            return SeasonCard(
              season: season,
              selected: season.id == widget.selectedSeasonItem?.id,
              onPress: () {
                widget.onSeasonChange(season);
                controller.hide();
              },
            );
          },
        );
      },
    );
  }

  // _findwidget() {
  //   final size = MediaQuery.sizeOf(context);

  //   final renderbox = buttonKey.currentContext?.findRenderObject() as RenderBox;

  //   print(renderbox.localToGlobal(.zero));
  //   print(size);
  // }
}
