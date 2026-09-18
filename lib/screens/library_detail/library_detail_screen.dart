// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:ui';

import 'package:awesome_extensions/awesome_extensions.dart'
    show StringExtension, WidgetCommonExtension;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:forui_phosphor/forui_phosphor.dart';
import 'package:go_router/go_router.dart';
import 'package:pudding/const/const.dart';
import 'package:pudding/models/settings/library/library_prefs.dart';
import 'package:pudding/models/settings/library/pudding_settings.dart';
import 'package:pudding/providers/settings_provider.dart';
import 'package:pudding/screens/library_detail/library_detail_provider.dart';
import 'package:pudding/screens/library_detail/user_views_provider.dart';
import 'package:pudding/screens/library_detail/widget/sliver_carousel.dart';
import 'package:pudding/screens/library_detail/widget/sliver_library_item_grid.dart';
import 'package:pudding/widgets/detail_scaffold.dart';
import 'package:pudding/widgets/detail_slivers/sliver_error.dart';
import 'package:pudding/widgets/detail_slivers/sliver_loader.dart';
import 'package:pudding/widgets/detail_slivers/sliver_topbar.dart';

import '../../models/settings/library/user_view_prefs.dart';

class LibraryDetail extends ConsumerStatefulWidget {
  final String? id;

  const LibraryDetail({super.key, this.id});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LibraryDetailState();
}

class _LibraryDetailState extends ConsumerState<LibraryDetail> {
  final TextEditingController widthController = TextEditingController();

  bool all = false;
  bool manualRefresh = false;
  bool retried = false;
  String hId = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(libraryProvider(widget.id!).notifier).refresh();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _fetchMore(ScrollUpdateNotification noti) {
    final max = noti.metrics.maxScrollExtent;
    final current = noti.metrics.pixels;

    if (!all) {
      if ((current / max > 0.6) || max == 0) {
        ref.read(libraryProvider(widget.id!).notifier).getMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final libAsync = ref.watch(libraryProvider(widget.id!));
    final userviewAsync = ref.watch(userviewsProvider).value ?? {};

    return DetailScaffold(
      headerSliver: SliverTopbar(
        extent: 76,
        suffix: PDetailRefreshButton(
          onPress: _manualRefresh,
        ),
        children: [
          if (libAsync.hasValue)
            FButton(
              variant: .outline,
              mainAxisSize: .min,
              onPress: () {},
              suffix: FCircularProgress().showIf(libAsync.isLoading),
              child: Flexible(
                fit: .loose,
                child: Text('${libAsync.value?.name}'),
              ),
            ),
          LibraryPrefsButton(
            id: widget.id!,
            name: libAsync.value?.name,
          ),
        ],
      ),
      sideChick: Column(
        crossAxisAlignment: .start,
        spacing: 10,
        children: userviewAsync.values
            .map(
              (v) => AnimatedSize(
                duration: kDefaultAnimationDuration,
                alignment: .topLeft,
                child: FButton(
                  onHoverChange: (h) {
                    if (h) {
                      hId = v.id;
                    } else {
                      hId = '';
                    }

                    setState(() {});
                  },
                  variant: v.id == widget.id ? .primary : .outline,
                  onPress: () => context.pushReplacement(
                    '/library/${v.id}',
                  ),
                  child: Text(
                    v.name.substring(0, hId == v.id ? v.name.length : 1),
                  ),
                ),
              ),
            )
            .toList(),
      ),
      onscroll: (ScrollUpdateNotification n) {
        _fetchMore(n);

        return true;
      },
      sliverBuilder: (context, controller) => libAsync.when(
        skipLoadingOnReload: true,
        loading: () => [SliverLoader(id: widget.id!)],
        error: (error, stackTrace) => [SliverError(error: error.toString())],
        data: (data) {
          final libs = data.items;
          all = libs.length == data.count;
          retried = false;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            manualRefresh = false;

            if (!all && controller.position.maxScrollExtent == 0) {
              ref.read(libraryProvider(widget.id!).notifier).getMore();
            }
          });

          return [
            if (data.next.isNotEmpty) SliverCarousel(items: data.next),
            SliverLibraryItemGrid(id: widget.id!),

            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: .only(bottom: 20),
                  child: Row(
                    spacing: 10,
                    mainAxisAlignment: .center,
                    children: [
                      if (libAsync.isLoading) FCircularProgress(),
                      Text(
                        'Showing ${libs.length} of ${data.count}',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
      ),
    );
  }

  Future<void> _manualRefresh() async {
    manualRefresh = true;
    setState(() {});
    final userviews = await ref.read(userviewsProvider.notifier).getUserviews();

    if (!userviews.containsKey(widget.id)) {
      if (mounted) {
        if (userviews.isEmpty) {
          context.pop();
        }

        context.pushReplacement(
          '/library/${userviews.values.first.id}',
        );
      }
    }

    ref.invalidate(libraryProvider(widget.id!));
  }
}

class LibraryPrefsButton extends ConsumerStatefulWidget {
  final String id;
  final String? name;
  const new({super.key, required this.id, this.name});

  @override
  ConsumerState<LibraryPrefsButton> createState() => _LibraryPrefsButtonState();
}

class _LibraryPrefsButtonState extends ConsumerState<LibraryPrefsButton> {
  final int sliderMin = 150;
  final int sliderMax = 600;

  late final TextEditingController widthTextController;
  late final FContinuousSliderController sliderController;

  @override
  void initState() {
    final settings = ref.watch(settingsProvider).value ?? PuddingSettings();
    final prefs = settings.libraryPrefs;

    final width = prefs.itemWidth(prefs.viewType(widget.id));

    widthTextController = TextEditingController(text: width.toString());
    sliderController = FContinuousSliderController(
      value: FSliderValue(max: (width - sliderMin) / (sliderMax - sliderMin)),
    );

    super.initState();
  }

  @override
  void dispose() {
    widthTextController.dispose();
    sliderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final prefs = ref.watch(
      settingsProvider.select((s) => s.value!.libraryPrefs),
    );

    final settNotifier = ref.watch(settingsProvider.notifier);

    return FPopover(
      style: .delta(
        decoration: .boxDelta(color: theme.colors.background),
        barrierFilter: (context, anim) => ImageFilter.compose(
          outer: ImageFilter.blur(sigmaX: anim * 5, sigmaY: anim * 5),
          inner: ColorFilter.mode(
            Color.lerp(Colors.transparent, theme.colors.barrier, anim)!,
            .srcOver,
          ),
        ),
      ),
      cutoutBuilder: FModalBarrier.defaultCutoutBuilder,
      constraints: FPortalConstraints(maxWidth: 400),
      popoverBuilder: (context, controller) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          spacing: 10,
          children: [
            FTileGroup(
              label: Text(widget.name ?? 'View'),
              children: [
                FTile(
                  title: Row(
                    children: [
                      Expanded(child: Text('View type')),
                      SizedBox(
                        width: 150,
                        child: Row(
                          spacing: 10,
                          mainAxisAlignment: .spaceAround,
                          children: ViewType.values
                              .map(
                                (t) => FButton.icon(
                                  variant: prefs.viewType(widget.id) == t
                                      ? .primary
                                      : .outline,
                                  onPress: () => settNotifier.setLibraryPrefs(
                                    (current) =>
                                        current.updateViewType(widget.id, t),
                                  ),
                                  child: _icon(t),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            FTileGroup(
              label: Column(
                crossAxisAlignment: .start,
                spacing: 10,
                children: [
                  Text('Item size'),
                  Text(
                    'All libraries, include [Detail Screen]',
                    style: theme.typography.body.xs.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                ],
              ),
              children: ViewType.values
                  .map(
                    (t) => FTile.raw(
                      child: ItemSizeTile(type: t),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
      builder: (context, controller, child) => FButton.icon(
        variant: .ghost,
        onPress: controller.toggle,
        child: Icon(FPhosphorBoldIcons.gear),
      ),
    );
  }

  Icon _icon(ViewType type) {
    switch (type) {
      case .poster:
        return Icon(FLucideIcons.rectangleVertical);
      case .thumb:
        return Icon(FLucideIcons.rectangleHorizontal);
      case .square:
        return Icon(FLucideIcons.square);
    }
  }
}

class ItemSizeTile extends ConsumerStatefulWidget {
  final ViewType type;
  const new({super.key, required this.type});

  @override
  ConsumerState<ItemSizeTile> createState() => _ItemSizeTileState();
}

class _ItemSizeTileState extends ConsumerState<ItemSizeTile> {
  final int sliderMin = 100;
  final int sliderMax = 1000;

  late TextEditingController textController;
  late FContinuousSliderController sliderController;

  @override
  void initState() {
    final prefs = ref.watch(
      settingsProvider.select((s) => s.value!.libraryPrefs),
    );

    final width = prefs.itemWidth(widget.type);

    textController = TextEditingController(text: width.toString());
    sliderController = FContinuousSliderController(
      value: FSliderValue(max: (width - sliderMin) / (sliderMax - sliderMin)),
    );
    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
    sliderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(
      settingsProvider.select((s) => s.value!.libraryPrefs),
    );

    final settNotifier = ref.read(settingsProvider.notifier);

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Text(widget.type.name.capitalize)),
            SizedBox(
              width: 150,
              child: FTextField(
                control: .managed(controller: textController),
                onSubmit: (w) => _onSubmit(w, prefs, settNotifier),
              ),
            ),
          ],
        ),
        FSlider(
          tooltipControls: .disabled(),
          control: .managedContinuous(
            controller: sliderController,
            onChange: (w) => _onSlide(w, settNotifier),
          ),
        ),
      ],
    );
  }

  void _onSubmit(String val, LibraryPrefs prefs, SettingsNotifier notifier) {
    final width =
        int.tryParse(val) ??
        prefs.itemWidth(widget.type).clamp(sliderMin, sliderMax);
    final sliderExtent = sliderController.value.pixelConstraints.extent;

    notifier.setLibraryPrefs(
      (current) => current.updateItemSize(widget.type, width),
    );

    sliderController.tap(
      ((width - sliderMin) / (sliderMax - sliderMin)) * sliderExtent,
    );
  }

  void _onSlide(FSliderValue val, SettingsNotifier notifier) {
    final width = sliderMin + (val.max * ((sliderMax - sliderMin))).round();

    notifier.setLibraryPrefs(
      (current) => current.updateItemSize(widget.type, width),
    );

    textController.value = TextEditingValue(text: width.toString());
  }
}
