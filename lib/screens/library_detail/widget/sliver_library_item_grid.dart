import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:morphnext/morphnext.dart';
import 'package:pudding/const/const.dart';
import 'package:pudding/models/jelly_filter.dart';
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
            padding: .fromLTRB(20, 0, 20, 0),
            child: SectionHeader(
              title: Row(
                spacing: 4,
                children: [
                  Text('All'),
                  FButton.icon(
                    variant: .ghost,
                    onPress: () {
                      showFSheet(
                        context: context,
                        builder: (context) => FilterSheet(id: widget.id),
                        side: .ltr,
                      );
                    },
                    onSecondaryPress: () {
                      libNotifier
                        ..resetFilter()
                        ..refresh();
                    },
                    child: Icon(
                      data.filters.isEmpty
                          ? FLucideIcons.filter
                          : FLucideIcons.filterX,
                    ),
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
                  if (!data.filters.isEmpty) Text('[Filtered]'),
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
          padding: .fromLTRB(20, 0, 20, 20),
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

class FilterSheet extends ConsumerStatefulWidget {
  final String id;
  const FilterSheet({super.key, required this.id});

  @override
  ConsumerState<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<FilterSheet> {
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    final libAsync = ref.watch(libraryProvider(widget.id));
    final libNotifier = ref.read(libraryProvider(widget.id).notifier);
    final filAsync = ref.watch(filterProvider(widget.id));

    return FResizable(
      axis: .horizontal,
      children: [
        FResizableRegion.fixed(
          extent: 500,
          minExtent: 200,
          builder: (context, value, child) => child!,
          child: Container(
            decoration: BoxDecoration(
              color: theme.colors.background,
            ),
            child: filAsync.when(
              loading: () => Center(child: FCircularProgress()),
              error: (error, stackTrace) =>
                  Center(child: Text(error.toString())),
              data: (data) {
                final filters = JellyFilter.values.map((f) => f.name);
                final genres = data.genres;
                final rating = data.parentalRating;
                final years = data.years;
                final tags = data.tags;

                return CustomScrollView(
                  slivers: [
                    PinnedHeaderSliver(
                      child: Container(
                        height: 76,
                        decoration: BoxDecoration(
                          color: theme.colors.background,
                          border: Border(
                            bottom: BorderSide(color: theme.colors.border),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 20,
                          ),
                          child: Row(
                            spacing: 10,
                            children: [
                              Text('Result: ${libAsync.value?.count}'),
                              if (libAsync.isLoading) FCircularProgress(),
                              Spacer(),
                              if (!(libAsync.value?.filters.isEmpty ?? false))
                                FButton(
                                  variant: .destructive,
                                  onPress: () {
                                    libNotifier
                                      ..resetFilter()
                                      ..refresh();
                                  },
                                  prefix: Icon(FLucideIcons.filterX),
                                  child: Text('Clear all'),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SliverRadio<String>(
                      title: Text('Filters'),
                      initialValues: libAsync.value?.filters.filters ?? [],
                      filterItems: filters.toList(),
                      // enabled: !libAsync.isLoading,
                      onChanged: (result) {
                        libNotifier
                          ..applyFilter(filters: result)
                          ..refresh();
                      },
                    ),
                    if (genres.isNotEmpty)
                      SliverRadio<String>(
                        title: Text('Genres'),
                        // enabled: !libAsync.isLoading,
                        initialValues: libAsync.value?.filters.genres ?? [],
                        filterItems: genres.toList(),
                        onChanged: (result) {
                          libNotifier
                            ..applyFilter(genres: result)
                            ..refresh();
                        },
                      ),
                    if (rating.isNotEmpty)
                      SliverRadio<String>(
                        title: Text('Parental rating'),
                        // enabled: !libAsync.isLoading,
                        initialValues:
                            libAsync.value?.filters.parentalRating ?? [],
                        filterItems: rating.toList(),
                        onChanged: (result) {
                          libNotifier
                            ..applyFilter(parentalRating: result)
                            ..refresh();
                        },
                      ),
                    if (years.isNotEmpty)
                      SliverRadio<int>(
                        title: Text('Years'),
                        // enabled: !libAsync.isLoading,
                        initialValues: libAsync.value?.filters.years ?? [],
                        filterItems: years.toList(),
                        onChanged: (result) {
                          libNotifier
                            ..applyFilter(years: result)
                            ..refresh();
                        },
                      ),
                    if (tags.isNotEmpty)
                      SliverRadio<String>(
                        title: Text('Tags'),
                        // enabled: !libAsync.isLoading,
                        initialValues: libAsync.value?.filters.tags ?? [],
                        filterItems: tags.toList(),
                        onChanged: (result) {
                          libNotifier
                            ..applyFilter(tags: result)
                            ..refresh();
                        },
                      ),
                    SliverPadding(padding: .only(bottom: 20)),
                  ],
                );
              },
            ),
          ),
        ),
        FResizableRegion.flex(
          builder: (context, value, child) => SizedBox(),
        ),
      ],
    );
  }
}

class SliverRadio<T> extends StatefulWidget {
  final Widget title;
  final List<T> filterItems;
  final List<T> initialValues;
  final bool enabled;
  final Function(List<T> result) onChanged;
  const SliverRadio({
    super.key,
    this.enabled = true,
    required this.title,
    required this.initialValues,
    required this.filterItems,
    required this.onChanged,
  });

  @override
  State<SliverRadio<T>> createState() => SliverRadioState();
}

class SliverRadioState<T> extends State<SliverRadio<T>> {
  late List<T> filterList = List<T>.from(widget.initialValues);
  bool expand = true;

  @override
  void didUpdateWidget(covariant SliverRadio<T> oldWidget) {
    if (!listEquals(oldWidget.initialValues, widget.initialValues)) {
      filterList = widget.initialValues;
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return SliverPadding(
      padding: .fromLTRB(20, 10, 20, 0),
      sliver: SliverMainAxisGroup(
        slivers: [
          PinnedHeaderSliver(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Align(
                alignment: .centerLeft,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colors.background,
                    borderRadius: theme.style.borderRadius.md,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: .min,
                      spacing: 10,
                      children: [
                        DefaultTextStyle(
                          style: theme.typography.body.sm.copyWith(
                            fontWeight: .bold,
                          ),
                          child: widget.title,
                        ),
                        if (filterList.isNotEmpty)
                          FButton.icon(
                            size: .xs,
                            variant: .destructive,
                            onPress: () {
                              filterList.clear();

                              widget.onChanged(filterList);
                            },
                            child: Icon(FLucideIcons.x),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: AnimatedSize(
              duration: kDefaultAnimationDuration,
              alignment: .topCenter,
              child: SizedBox(
                height: expand ? null : 0,
                child: GridView.builder(
                  shrinkWrap: true,
                  primary: false,
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    mainAxisExtent: 36,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: widget.filterItems.length,
                  itemBuilder: (context, index) {
                    final f = widget.filterItems[index];
                    final selected = filterList.contains(f);

                    return FButton(
                      variant: selected ? .primary : .outline,
                      onPress: !widget.enabled
                          ? null
                          : () {
                              if (filterList.contains(f)) {
                                filterList.remove(f);
                              } else {
                                filterList.add(f);
                              }

                              widget.onChanged(filterList.toSet().toList());
                            },
                      child: Expanded(
                        child: Text(
                          f.toString(),
                          maxLines: 1,
                          textAlign: .center,
                          overflow: .ellipsis,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
