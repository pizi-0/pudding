import 'dart:math';
import 'dart:ui';

import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:morphnext/morphnext.dart';
import 'package:pudding/utils/jellyfin_item_extensions.dart';
import 'package:pudding/widgets/media_card.dart';

class SeasonSelector extends ConsumerStatefulWidget {
  final String seriesId;
  final JellyfinItem? next;
  final JellyfinItem? selectedSeasonItem;
  final Iterable<JellyfinItem?> seasonItems;
  final double maxHeight;
  final void Function(JellyfinItem season) onSeasonChange;

  const SeasonSelector({
    super.key,
    this.next,
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
  bool popup = false;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final style = theme.style;
    final size = MediaQuery.sizeOf(context);

    double maxwidth() {
      final seasons = widget.seasonItems;
      if (seasons.length * 210 > size.width) {
        return size.width - 40;
      }

      return seasons.length * 210;
    }

    double maxHeight() {
      final itemHeight = 16 / 10 * 200;
      final maxColumn = max(1, ((size.width) / 200)).floor();
      final maxRow = (widget.seasonItems.length / maxColumn).ceil();

      if (maxRow * itemHeight > 3 * itemHeight - (maxRow * 10)) {
        return 3 * itemHeight - (maxRow * 10);
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
      onTapHide: () {
        setState(() {
          popup = false;
        });
      },
      constraints: FPortalConstraints(
        maxWidth: maxwidth(),
        maxHeight: maxHeight(),
      ),
      builder: (context, controller, child) => FButton(
        style: .delta(contentStyle: .delta(spacing: 20)),
        key: buttonKey,
        variant: .outline,
        mainAxisAlignment: .spaceBetween,
        onPress: () {
          if (popup) {
            controller.hide();
            popup = false;
          } else {
            controller.show();
            popup = true;
          }

          setState(() {});
        },
        suffix: AnimatedMorphIcon(
          icon: popup ? FLucideIcons.chevronUp : FLucideIcons.chevronDown,
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

            return NewMediaCard(
              item: season,
              selected: season.id == widget.selectedSeasonItem?.id,
              isNext: widget.next?.seasonId == season.id,
              onPressed: () {
                widget.onSeasonChange(season);
                controller.hide();
                popup = false;
                setState(() {});
              },
            );
          },
        );
      },
    );
  }
}
