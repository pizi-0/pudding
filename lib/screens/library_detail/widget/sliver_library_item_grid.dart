import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:morphnext/morphnext.dart';
import 'package:pudding/models/pudding_display_prefs.dart';
import 'package:pudding/screens/library_detail/library_detail_provider.dart';
import 'package:pudding/widgets/bar.dart';
import 'package:pudding/widgets/media_card.dart';
import 'package:pudding/widgets/section_header.dart';

class SliverLibraryItemGrid extends ConsumerStatefulWidget {
  final String id;
  const SliverLibraryItemGrid({super.key, required this.id});

  @override
  ConsumerState<SliverLibraryItemGrid> createState() =>
      _SliverLibraryItemGridState();
}

class _SliverLibraryItemGridState extends ConsumerState<SliverLibraryItemGrid> {
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final libAsync = ref.watch(libraryProvider(widget.id));
    final libNotifier = ref.read(libraryProvider(widget.id).notifier);

    final data = libAsync.value!;
    final prefs = PuddingDisplayPrefs.fromMap(data.displayPrefs.customPrefs);
    final List<double> marks = List.generate(11, (index) => (index * 0.1));

    return SliverMainAxisGroup(
      slivers: [
        PinnedHeaderSliver(
          child: Bar(
            padding: .fromLTRB(10, 0, 10, 0),
            child: SectionHeader(
              title: Row(
                spacing: 10,
                children: [
                  Text('All'),
                  FButton.icon(
                    onPress: () {},
                    child: Icon(FLucideIcons.filter),
                  ),
                ],
              ),
              subtitle: Row(
                spacing: 10,
                children: [
                  Text(
                    'Showing ${data.items.length} of ${data.count}',
                    style: theme.typography.body.xs.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                  if (libAsync.isLoading)
                    FCircularProgress(
                      style: .delta(
                        iconStyle: .delta(
                          color: theme.colors.primary,
                          size: theme.typography.body.xs.fontSize,
                        ),
                      ),
                    ),
                ],
              ),
              trailings: [
                Container(
                  decoration: BoxDecoration(
                    border: .all(
                      color: theme.colors.border,
                      width: 2,
                    ),
                    borderRadius: theme.style.borderRadius.md,
                  ),
                  height: 36,
                  child: Row(
                    spacing: 10,
                    children: [
                      FButton.icon(
                        size: .sm,
                        variant: .ghost,
                        style: .delta(
                          decoration: .delta([
                            .all(
                              .boxDelta(
                                borderRadius: theme.style.borderRadius.sm,
                              ),
                            ),
                          ]),
                        ),
                        onPress: () {
                          if (libAsync.isLoading) return;

                          libNotifier
                            ..setMaxImageWidth(
                              (prefs.maxImageWidth - 50).clamp(200, 700),
                            )
                            ..updateDisplayPrefs();
                        },
                        child: Icon(FLucideIcons.zoomOut),
                      ),
                      SizedBox(
                        width: 120,
                        child: FSlider(
                          enabled: !libAsync.isLoading,
                          control: .liftedDiscrete(
                            interaction: .tapAndSlideThumb,
                            value: FSliderValue(
                              max: ((prefs.maxImageWidth - 200) / 500).clamp(
                                0,
                                1,
                              ),
                            ),
                            onChange: (value) {
                              if (libAsync.isLoading) {
                                return;
                              }
                              libNotifier.setMaxImageWidth(
                                (value.max * 500) + 200,
                              );
                            },
                          ),
                          onEnd: (value) {
                            libNotifier.updateDisplayPrefs();
                          },
                          marks: marks
                              .map(
                                (e) => FSliderMark(value: e),
                              )
                              .toList(),
                          style: .delta(
                            childPadding: .value(.zero),
                          ),
                          tooltipBuilder: (controller, value) => Text(
                            ((value * 500) + 200).toStringAsFixed(0),
                          ),
                        ),
                      ),
                      FButton.icon(
                        size: .sm,
                        style: .delta(
                          decoration: .delta([
                            .all(
                              .boxDelta(
                                borderRadius: theme.style.borderRadius.sm,
                              ),
                            ),
                          ]),
                        ),
                        variant: .ghost,
                        onPress: () {
                          if (libAsync.isLoading) return;

                          final double maxWidth = (prefs.maxImageWidth + 50)
                              .clamp(200, 700);

                          libNotifier
                            ..setMaxImageWidth(maxWidth)
                            ..updateDisplayPrefs();
                        },
                        child: Icon(FLucideIcons.zoomIn),
                      ),
                    ],
                  ),
                ),
                FPopover(
                  style: .delta(
                    barrierFilter: (context, animation) => ImageFilter.compose(
                      outer: ImageFilter.blur(),
                      inner: ColorFilter.mode(
                        Color.lerp(
                          const Color(0x00000000),
                          Colors.black.withAlpha(200),
                          animation,
                        )!,
                        BlendMode.srcOver,
                      ),
                    ),
                  ),
                  builder: (context, controller, child) => FButton.icon(
                    onPress: controller.toggle,
                    child: AnimatedMorphIcon(
                      icon: prefs.isPoster
                          ? FLucideIcons.rectangleVertical
                          : prefs.isThumb
                          ? FLucideIcons.rectangleHorizontal
                          : FLucideIcons.square,
                    ),
                  ),
                  popoverBuilder: (context, controller) {
                    final viewList = [vtPoster, vtThumb, vtSquare];

                    return FCard(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Column(
                          spacing: 4,
                          children: viewList
                              .map(
                                (e) => FButton(
                                  variant: e == prefs.puddingLibraryViewType
                                      ? .primary
                                      : .outline,
                                  prefix: Icon(
                                    e == vtPoster
                                        ? FLucideIcons.rectangleVertical
                                        : e == vtThumb
                                        ? FLucideIcons.rectangleHorizontal
                                        : FLucideIcons.square,
                                  ),
                                  onPress: () {
                                    controller.hide();
                                    if (libAsync.isLoading) return;

                                    libNotifier
                                      ..setViewType(e)
                                      ..updateDisplayPrefs();
                                  },
                                  child: Text(e),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        SliverPadding(
          padding: .fromLTRB(10, 0, 10, 10),
          sliver: SliverGrid.builder(
            key: ValueKey(widget.id),
            itemCount: data.items.length,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: prefs.maxImageWidth,
              childAspectRatio: prefs.aspectRatio,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              final item = data.items[index];

              return NewMediaCard(
                key: ValueKey(item.id),
                item: item,
                imageType: prefs.imageType,
              );
            },
          ),
        ),
      ],
    );
  }
}
