import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:forui_phosphor/forui_phosphor.dart';
import 'package:morphnext/morphnext.dart';
import 'package:pudding/const/const.dart';
import 'package:pudding/screens/tvshow_detail/provider/tvshow_state_provider.dart';
import 'package:pudding/widgets/media_card.dart';

class SeasonSelector extends ConsumerStatefulWidget {
  final String seriesId;
  final Function()? onSeasonChanged;

  const SeasonSelector({
    super.key,
    required this.seriesId,
    this.onSeasonChanged,
  });

  @override
  ConsumerState<SeasonSelector> createState() => _SeasonSelectorState();
}

class _SeasonSelectorState extends ConsumerState<SeasonSelector> {
  final GlobalKey buttonKey = GlobalKey();
  String? selected;
  bool popup = false;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final style = theme.style;
    final tvAsync = ref.watch(tvshowStateProvider(widget.seriesId));
    final tvNotifier = ref.read(tvshowStateProvider(widget.seriesId).notifier);

    final size = MediaQuery.sizeOf(context);

    final maxColumn = max(1, (((size.width * 0.6)) / 200)).floor();

    return tvAsync.when(
      skipLoadingOnReload:
          tvAsync.isReloading && tvAsync.value?.selectedSeason != null,
      loading: () => FButton(
        onPress: () {},
        variant: .outline,
        suffix: FCircularProgress(),
        child: Text('Season'),
      ),
      error: (error, stackTrace) => FButton(
        onPress: () {},
        variant: .destructive,
        child: Text(error.toString()),
      ),
      data: (data) {
        double maxWidth() {
          final bp = theme.breakpoints.lg;
          final usableWidth = size.width - 40;

          if (data.seasons.length > maxColumn) {
            if (size.width < bp) {
              return usableWidth;
            }

            return usableWidth * 0.6;
          } else {
            return (data.seasons.length * 200)
                .clamp(200.0, usableWidth)
                .toDouble();
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
                  Colors.black.withValues(alpha: 0.2),
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
            maxWidth: maxWidth(),
            maxHeight: size.height - 40,
            minWidth: 200,
          ),
          builder: (context, controller, child) => FButton(
            style: .delta(contentStyle: .delta(spacing: 20)),
            key: buttonKey,
            variant: .outline,
            mainAxisAlignment: .spaceBetween,
            onPress: tvAsync.isLoading
                ? () {}
                : () {
                    controller.toggle();
                    popup = !popup;
                    setState(() {});
                  },
            suffix: tvAsync.isLoading
                ? FCircularProgress()
                : AnimatedMorphIcon(
                    icon: popup
                        ? FPhosphorBoldIcons.caretUp
                        : FPhosphorBoldIcons.caretDown,
                  ),
            child: Text(
              data.selectedSeason!.name,
            ),
          ),
          childAnchor: .bottomLeft,
          popoverAnchor: .topLeft,
          popoverBuilder: (context, controller) {
            return GridView.builder(
              itemCount: data.seasons.length,
              shrinkWrap: true,
              padding: .all(10),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: kPosterAspectRatio,
              ),
              itemBuilder: (context, index) {
                final season = data.seasons.elementAt(index);

                return Stack(
                  children: [
                    NewMediaCard(
                      item: season,
                      selected: season.id == data.selectedSeason!.id,
                      isNext: data.nextup?.seasonId == season.id,
                      onPressed: () async {
                        selected = season.id;
                        setState(() {});
                        await tvNotifier.onSeasonChanged(season.id);

                        controller.hide();

                        popup = false;
                        if (mounted) setState(() {});

                        if (widget.onSeasonChanged != null) {
                          widget.onSeasonChanged!();
                        }
                      },
                    ),
                    if (tvAsync.isLoading && selected == season.id)
                      Positioned.fill(
                        bottom: 2,
                        right: 2,
                        left: 2,
                        top: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colors.background.withAlpha(200),
                            borderRadius: style.borderRadius.sm,
                          ),
                          child: FCircularProgress(),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
