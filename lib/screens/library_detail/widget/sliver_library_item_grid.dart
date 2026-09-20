import 'package:awesome_extensions/awesome_extensions.dart'
    show StringExtension;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:forui_phosphor/forui_phosphor.dart';
import 'package:go_router/go_router.dart';
import 'package:morphnext/morphnext.dart';
import 'package:pudding/const/const.dart';
import 'package:pudding/models/jelly_filter.dart';
import 'package:pudding/providers/settings_provider.dart';
import 'package:pudding/screens/library_detail/library_detail_provider.dart';
import 'package:pudding/utils/jellyfin_item_extensions.dart';
import 'package:pudding/widgets/detail_slivers/sliver_section.dart';
import 'package:pudding/widgets/media_card.dart';

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

    final settings = ref.watch(settingsProvider);
    final prefs = settings.value!.libraryPrefs;

    final data = libAsync.value!;
    // final prefs = PuddingDisplayPrefs.fromMap(data.displayPrefs.customPrefs);
    // final List<double> marks = List.generate(51, (index) => (index * 0.02));

    return SliverSection(
      header: Row(
        spacing: 10,
        children: [
          FButton(
            variant: .outline,
            onPress: () {},
            child: Text('All'),
          ),
          FButton.icon(
            variant: .ghost,
            onLongPress: () => libNotifier
              ..resetFilter()
              ..refresh(),
            onSecondaryPress: () => libNotifier
              ..resetFilter()
              ..refresh(),
            onPress: () {
              showFSheet(
                context: context,
                builder: (context) => FilterSheet(id: widget.id),
                side: .ltr,
              );
            },
            child: AnimatedMorphIcon(
              icon: data.filters.isEmpty
                  ? FPhosphorBoldIcons.funnel
                  : FPhosphorFillIcons.funnelX,
              color: data.filters.isEmpty ? null : theme.colors.primary,
            ),
          ),
        ],
      ),
      slivers: [
        SliverGrid.builder(
          key: ValueKey(widget.id),
          itemCount: data.items.length,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: prefs
                .itemWidth(prefs.viewType(widget.id))
                .toDouble(),
            childAspectRatio: prefs.aspectRatio(widget.id),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final item = data.items[index];

            return MediaCard(
              key: ValueKey(item.id),
              item: item,
              imageType: prefs.imageType(widget.id),
              onPressed: () {
                if (item.isSeries) {
                  context.push('/show/${item.id}');
                }

                if (item.isMovie) {
                  context.push('/movie/${item.id}');
                }

                if (item.isBoxsets) {
                  context.push('/collection/${item.id}');
                }
              },
            );
          },
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
                final filters = JellyFilter.values.map((f) => f);
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
                                  prefix: Icon(FPhosphorBoldIcons.funnelX),
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
                      filterItems: filters.map((f) => f.value).toList(),
                      customLabels: filters
                          .map((f) => f.name.capitalize)
                          .toList(),
                      // enabled: !libAsync.isLoading,
                      onChanged: (result) {
                        if (result.lastOrNull?.toString() ==
                            JellyFilter.played.value) {
                          result.remove(JellyFilter.unplayed.value);
                        } else if (result.lastOrNull?.toString() ==
                            JellyFilter.unplayed.value) {
                          result.remove(JellyFilter.played.value);
                        }

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
  final List<String>? customLabels;
  const SliverRadio({
    super.key,
    this.enabled = true,
    required this.title,
    required this.initialValues,
    required this.filterItems,
    required this.onChanged,
    this.customLabels,
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
      filterList = List<T>.from(widget.initialValues);
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
                            child: Icon(FPhosphorBoldIcons.x),
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
                    final custom = widget.customLabels?[index];

                    final label = custom ?? f.toString();

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
                          label,
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
