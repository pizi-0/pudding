import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
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
              title: Text('All'),
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
                FButton.icon(
                  variant: prefs.isPoster ? .primary : .outline,
                  onPress: () {
                    if (libAsync.isLoading || prefs.isPoster) {
                      return;
                    }
                    libNotifier
                      ..setViewType('poster')
                      ..updateDisplayPrefs();
                  },
                  child: Icon(
                    FLucideIcons.rectangleVertical,
                  ),
                ),
                FButton.icon(
                  variant: prefs.isThumb ? .primary : .outline,
                  onPress: () {
                    if (libAsync.isLoading || prefs.isThumb) {
                      return;
                    }
                    libNotifier
                      ..setViewType('thumb')
                      ..updateDisplayPrefs();
                  },
                  child: Icon(
                    FLucideIcons.rectangleHorizontal,
                  ),
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
