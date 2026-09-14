// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:ui';

import 'package:awesome_extensions/awesome_extensions.dart'
    show WidgetCommonExtension, StringExtension;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:forui_phosphor/forui_phosphor.dart';
import 'package:go_router/go_router.dart';
import 'package:pudding/const/const.dart';
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
          LibraryPrefsButton(id: widget.id!),
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

    // return PuddingScaffold(
    //   child: Stack(
    //     children: [
    //       ScrollConfiguration(
    //         behavior: ScrollBehavior().copyWith(
    //           dragDevices: {...PointerDeviceKind.values},
    //         ),
    //         child: SilkyCustomScrollView(
    //           scrollSpeed: 2,
    //           controller: scrollController,
    //           slivers: [
    //             PinnedHeaderSliver(
    //               child: Bar(
    //                 padding: .all(20),
    //                 child: Row(
    //                   children: [
    //                     FButton.icon(
    //                       onPress: context.pop,
    //                       child: Icon(FPhosphorBoldIcons.caretLeft),
    //                     ),
    //                     Expanded(
    //                       child: SingleChildScrollView(
    //                         scrollDirection: .horizontal,
    //                         child: Row(
    //                           spacing: 10,
    //                           children: [
    //                             if (userviewAsync.hasValue)
    //                               ...userviewAsync.value!.values.map((v) {
    //                                 return FButton(
    //                                   variant: widget.id == v.id
    //                                       ? .primary
    //                                       : .outline,
    //                                   onPress: () => context.pushReplacement(
    //                                     '/library/${v.id}',
    //                                   ),
    //                                   prefix: v.getButtonIcon(),
    //                                   child: Text(v.name),
    //                                 );
    //                               }),
    //                           ],
    //                         ),
    //                       ),
    //                     ),
    //                     FButton.icon(
    //                       onPress: _manualRefresh,
    //                       child: libAsync.isLoading && manualRefresh
    //                           ? FCircularProgress()
    //                           : Icon(FPhosphorBoldIcons.arrowClockwise),
    //                     ),
    //                   ].separatedBy(Icon(FPhosphorBoldIcons.dot)),
    //                 ),
    //               ),
    //             ),
    //             libAsync.when(
    //               skipLoadingOnReload: true,
    //               loading: () => SliverPadding(
    //                 padding: .fromLTRB(10, 0, 10, 10),
    //                 sliver: SliverGrid.builder(
    //                   key: ValueKey(widget.id),
    //                   itemCount: 10,
    //                   gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
    //                     maxCrossAxisExtent: 200,
    //                     childAspectRatio: 10 / 16,
    //                     mainAxisSpacing: 10,
    //                     crossAxisSpacing: 10,
    //                   ),
    //                   itemBuilder: (context, index) {
    //                     return Container(
    //                       decoration: BoxDecoration(
    //                         border: .all(
    //                           color: theme.colors.background,
    //                           width: 2,
    //                         ),
    //                         color: theme.colors.foreground,
    //                         borderRadius: theme.style.borderRadius.sm,
    //                       ),
    //                     ).applyShimmer(
    //                       baseColor: theme.colors.background,
    //                       highlightColor: theme.colors.muted,
    //                     );
    //                   },
    //                 ),
    //               ),
    //               error: (error, stackTrace) => SliverFillRemaining(
    //                 child: Center(
    //                   child: Text(error.toString()),
    //                 ),
    //               ),
    //               data: (data) {
    //                 final libs = data.items;
    //                 all = libs.length == data.count;
    //                 retried = false;

    //                 WidgetsBinding.instance.addPostFrameCallback((_) {
    //                   manualRefresh = false;

    //                   if (!all &&
    //                       scrollController.position.maxScrollExtent == 0) {
    //                     ref
    //                         .read(libraryProvider(widget.id!).notifier)
    //                         .getMore();
    //                   }
    //                 });

    //                 return SliverMainAxisGroup(
    //                   slivers: [
    //                     if (data.next.isNotEmpty)
    //                       SliverCarousel(items: data.next),
    //                     SliverLibraryItemGrid(id: widget.id!),

    //                     SliverToBoxAdapter(
    //                       child: Center(
    //                         child: Padding(
    //                           padding: .only(bottom: 20),
    //                           child: Row(
    //                             spacing: 10,
    //                             mainAxisAlignment: .center,
    //                             children: [
    //                               if (libAsync.isLoading) FCircularProgress(),
    //                               Text(
    //                                 'Showing ${libs.length} of ${data.count}',
    //                               ),
    //                             ],
    //                           ),
    //                         ),
    //                       ),
    //                     ),
    //                   ],
    //                 );
    //               },
    //             ),
    //           ],
    //         ),
    //       ),
    //     ],
    //   ),
    // );
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
  const new({super.key, required this.id});

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
    final settings = ref.watch(settingsProvider).value ?? PuddingSettings();
    final prefs = settings.libraryPrefs;
    final settNotifier = ref.read(settingsProvider.notifier);

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
      childAnchor: .bottomLeft,
      popoverAnchor: .topLeft,
      cutoutBuilder: FModalBarrier.defaultCutoutBuilder,
      constraints: FPortalConstraints(maxWidth: 300),
      popoverBuilder: (context, controller) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          spacing: 10,
          children: [
            FSlider(
              control: .managedContinuous(
                controller: sliderController,
                onChange: (value) {
                  final newWidth = lerpDouble(
                    sliderMin,
                    sliderMax,
                    value.max,
                  )!.round();

                  settNotifier.setSettings(
                    (current) => current.copyWith(
                      libraryPrefs: current.libraryPrefs.updateItemSize(
                        current.libraryPrefs.viewType(widget.id),
                        newWidth,
                      ),
                    ),
                  );

                  widthTextController.text = newWidth.toString();
                },
              ),
              tooltipControls: FSliderTooltipControls.disabled(),
              label: Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Text('Item width'),
                  SizedBox(
                    width: 100,
                    height: 33,
                    child: FTextField(
                      keyboardType: .number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      control: .managed(controller: widthTextController),
                      onSubmit: (width) => _setSlider(
                        width,
                        prefs.itemWidth(prefs.viewType(widget.id)),
                      ),
                      textAlign: .center,
                      style: .delta(constraints: .new(maxHeight: 33)),
                    ),
                  ),
                ],
              ),
            ),
            FSelect<ViewType>.rich(
              label: Text('View type'),
              control: .managed(
                initial: prefs.viewType(widget.id),
                onChange: (type) async {
                  if (type != null) {
                    final sett = await settNotifier.setSettings(
                      (current) => current.copyWith(
                        libraryPrefs: current.libraryPrefs.updateViewType(
                          widget.id,
                          type,
                        ),
                      ),
                    );
                    _setSlider(
                      sett.libraryPrefs.itemWidth(type).toString(),
                      prefs.itemWidth(type),
                    );
                  }
                },
              ),
              format: (value) => value.name.capitalize,
              children: ViewType.values
                  .map(
                    (t) =>
                        FSelectItem(title: Text(t.name.capitalize), value: t),
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

  void _setSlider(String width, int current) {
    final extent = sliderController.value.pixelConstraints.max;

    int w = (int.tryParse(width) ?? current).clamp(
      sliderMin,
      sliderMax,
    );

    final to = ((w - sliderMin) / (sliderMax - sliderMin)) * extent;

    sliderController.tap(to);
  }
}
