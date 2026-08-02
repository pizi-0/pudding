import 'dart:ui';

import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:pudding/providers/series_detail_provider.dart';
import 'package:pudding/screens/detail_screens/widgets/season_card.dart';
import 'package:pudding/utils/jellyfin_item_extensions.dart';

class SeasonSelector extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = FTheme.of(context);
    final style = theme.style;
    final detNotifier = ref.read(
      seriesDetailProvider(seriesId).notifier,
    );

    return LayoutBuilder(
      builder: (context, constraints) => FPopover(
        overflow: .allow,
        style: .delta(
          barrierFilter: (animation) => .compose(
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
          maxWidth: constraints.maxWidth,
          minWidth: constraints.maxWidth,
          maxHeight: maxHeight - 36,
        ),
        builder: (context, controller, child) => FButton(
          variant: .outline,
          mainAxisAlignment: .spaceBetween,
          onPress: controller.toggle,
          suffix: Icon(
            FLucideIcons.chevronDown,
          ),
          child: Text(
            selectedSeasonItem!.name,
          ),
        ),
        popoverBuilder: (context, controller) {
          return GridView.builder(
            itemCount: seasonItems.length,
            shrinkWrap: true,
            padding: .all(10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio:
                  seasonItems.first?.getSeasonCoverAspectRatio() ?? 1,
            ),
            itemBuilder: (context, index) {
              final season = seasonItems.elementAt(
                index,
              )!;

              return SeasonCard(
                season: season,
                selected: season.id == selectedSeasonItem?.id,
                onPress: () {
                  detNotifier.setSelectedSeason(season.id);
                  onSeasonChange(season);
                  controller.hide();
                },
              );
            },
          );
        },
      ),
    );
  }
}
