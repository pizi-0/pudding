import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:pudding/const/const.dart';
import 'package:pudding/screens/home/home_provider.dart';
import 'package:pudding/services/di.dart';
import 'package:pudding/utils/jellyfin_item_extensions.dart';

class Showcase extends ConsumerStatefulWidget {
  const Showcase({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ShowcaseState();
}

class _ShowcaseState extends ConsumerState<Showcase> {
  late PageController pageController;
  int currentPage = 0;
  Timer? _pageTimer;
  bool pauseSlideshow = false;

  @override
  void initState() {
    pageController = PageController();
    final data = ref.read(homeProvider).value ?? HomeData();
    super.initState();
    _startSlideshow(data.showcaseItem);
  }

  @override
  void dispose() {
    pageController.dispose();
    _pageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = (ref.watch(homeProvider).value ?? HomeData()).showcaseItem;
    return Stack(
      fit: .expand,
      children: [
        if (items.isNotEmpty)
          ShowcaseItemBackdrop(
            key: ValueKey(items[currentPage].id),
            item: items[currentPage],
          ),
        ScrollConfiguration(
          behavior:
              ScrollConfiguration.of(
                context,
              ).copyWith(
                dragDevices: {...PointerDeviceKind.values},
              ),
          child: NotificationListener<UserScrollNotification>(
            onNotification: (notification) {
              if (notification.direction != ScrollDirection.idle) {
                pauseSlideshow = true;
              } else {
                pauseSlideshow = false;
                _startSlideshow(items);
              }
              setState(() {});

              return false;
            },
            child: PageView.builder(
              controller: pageController,
              itemCount: items.length,
              itemBuilder: (context, index) => ShowcaseItem(
                item: items[index],
                key: ValueKey(items[index].id),
              ),
              onPageChanged: (value) => setState(() {
                currentPage = value;
              }),
            ),
          ),
        ),
        Align(
          alignment: .topRight,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisSize: .min,
              children: [
                FButton.icon(
                  variant: .ghost,
                  onPress: () => ref.refresh(homeProvider),
                  child: ref.read(homeProvider).isLoading
                      ? FCircularProgress()
                      : Icon(FLucideIcons.rotateCcw),
                ),
                Row(
                  mainAxisSize: .min,
                  spacing: 8,
                  children: [
                    AnimatedSwitcher(
                      duration: kDefaultAnimationDuration,
                      child: FButton.icon(
                        variant: .ghost,
                        size: .lg,
                        onPress: currentPage == 0
                            ? null
                            : () => _previousPage(items),
                        child: Icon(FLucideIcons.chevronLeft),
                      ),
                    ),
                    SizedBox(
                      width: 35,
                      child: AnimatedSwitcher(
                        duration: kDefaultAnimationDuration,
                        child: FittedBox(
                          child: Text(
                            '${currentPage + 1}/${items.length}',
                            textAlign: .center,
                          ),
                        ),
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: kDefaultAnimationDuration,
                      child: FButton.icon(
                        variant: .ghost,
                        size: .lg,
                        onPress: () => _nextPage(items),
                        child: Icon(FLucideIcons.chevronRight),
                      ),
                    ),
                  ],
                ),
              ].separatedby(Icon(FLucideIcons.dot)),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _previousPage(List<JellyfinItem> items) async {
    _pageTimer?.cancel();
    await pageController.previousPage(
      duration: 500.milliseconds,
      curve: Curves.easeInOut,
    );

    _startSlideshow(items);
  }

  Future<void> _nextPage(List<JellyfinItem> items) async {
    _pageTimer?.cancel();

    if (pageController.page == items.length - 1) {
      pageController.jumpTo(0);
      _startSlideshow(items);
      return;
    }
    await pageController.nextPage(
      duration: 500.milliseconds,
      curve: Curves.easeInOut,
    );

    _startSlideshow(items);
  }

  void _startSlideshow(List<JellyfinItem> items) async {
    _pageTimer?.cancel();
    _pageTimer = Timer.periodic(
      10.seconds,
      (timer) async {
        if (pauseSlideshow) return;

        if (pageController.page == items.length - 1) {
          pageController.jumpTo(0);
          return;
        }
        await pageController.nextPage(
          duration: 500.milliseconds,
          curve: Curves.easeInOut,
        );
      },
    );
  }
}

class ShowcaseItem extends ConsumerStatefulWidget {
  final JellyfinItem item;
  const ShowcaseItem({super.key, required this.item});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ShowcaseItemState();
}

class _ShowcaseItemState extends ConsumerState<ShowcaseItem> {
  late final item = widget.item;
  final client = services<JellyfinClient>();
  late final resumable = widget.item.userData?.playbackPositionTicks != 0;
  late final isEpisode = widget.item.type == JellyfinItemKind.episode;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final theme = FTheme.of(context);
    final sm = size.width < theme.breakpoints.sm;

    return Align(
      alignment: .bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: AnimatedSwitcher(
          duration: kDefaultAnimationDuration,
          child: sm
              ? ItemSm(item: item)
              : ItemLg(
                  item: item,
                  key: ValueKey(item.id),
                ),
        ),
      ),
    );
  }
}

class ItemLg extends ConsumerWidget {
  final JellyfinItem item;
  const ItemLg({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = FTheme.of(context);

    return SizedBox(
      height: 220,
      child: Row(
        spacing: 20,
        crossAxisAlignment: .stretch,
        children: [
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: .circular(10),
              child: CachedNetworkImage(
                imageUrl: item.getLogo(),
                height: 200,
                errorBuilder: (context, error, stackTrace) =>
                    CachedNetworkImage(
                      imageUrl: item.getPrimary(),
                      errorBuilder: (context, error, stackTrace) =>
                          Text(error.toString()),
                      height: 150,
                      width: 200,
                    ),
              ),
            ),
          ),
          FDivider(
            axis: .vertical,
            style: .delta(color: theme.colors.primary, padding: .value(.zero)),
          ),
          Expanded(
            flex: 7,
            child: Column(
              spacing: 8,
              crossAxisAlignment: .stretch,
              mainAxisAlignment: .center,
              children: [
                Column(
                  spacing: 8,
                  children: [
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.getTitle(),
                                style: theme.typography.body.xl3.copyWith(
                                  fontWeight: .bold,
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: .ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(item.productionYear?.toString() ?? ''),
                            if (item.getOfficialRating() != null)
                              Container(
                                height: theme.typography.body.lg.fontSize,
                                decoration: BoxDecoration(
                                  border: .all(
                                    color: theme.colors.foreground,
                                  ),
                                  borderRadius: .circular(4),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 1.5,
                                    horizontal: 3,
                                  ),
                                  child: FittedBox(
                                    child: Text(
                                      item.getOfficialRating()!,
                                    ),
                                  ),
                                ),
                              ),
                            if (item.showRuntime) Text(item.getRuntime() ?? ''),

                            if (item.isSeries)
                              Text('${item.getSeasons()} season'),
                          ].separatedby(Icon(FLucideIcons.dot)),
                        ),
                      ],
                    ),
                    FDeterminateProgress(value: item.getPlayProgress()),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.getOverview() ?? '',
                            maxLines: 3,
                            overflow: .ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  spacing: 8,
                  children: [
                    FButton.icon(
                      onPress: () {},
                      child: Icon(FLucideIcons.info),
                    ),
                    FButton.icon(
                      onPress: () {},
                      child: Icon(FLucideIcons.heart),
                    ),
                    FButton.icon(
                      onPress: () {},
                      child: Icon(FLucideIcons.check),
                    ),
                    Icon(FLucideIcons.dot),
                    FButton(
                      onPress: () {},
                      prefix: Icon(FLucideIcons.play),
                      child: Row(
                        children: [
                          Text('Play'),
                          if (item.showRuntime)
                            Text('Ends at ${item.getEndsAt(context)}'),
                        ].separatedby(Icon(FLucideIcons.dot)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ItemSm extends ConsumerWidget {
  final JellyfinItem item;
  const ItemSm({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container();
  }
}

class ShowcaseItemBackdrop extends StatefulWidget {
  final JellyfinItem item;
  const ShowcaseItemBackdrop({super.key, required this.item});

  @override
  State<ShowcaseItemBackdrop> createState() => _ShowcaseItemBackdropState();
}

class _ShowcaseItemBackdropState extends State<ShowcaseItemBackdrop>
    with TickerProviderStateMixin {
  late JellyfinItem item = widget.item;
  late AnimationController anim;
  late Animation<double> scale;

  @override
  void initState() {
    super.initState();
    anim = AnimationController(vsync: this, duration: 15.seconds);
    scale = Tween<double>(begin: 1, end: 1.05).animate(anim);
    anim.forward();
  }

  @override
  void dispose() {
    anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Container(
      clipBehavior: .hardEdge,
      decoration: BoxDecoration(color: Colors.transparent),
      height: size.height,
      width: size.width,
      child: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          begin: .topCenter,
          end: .bottomCenter,
          stops: [0.6, 1],
          colors: [Colors.black12, Colors.black],
        ).createShader(bounds),
        blendMode: .dstOut,
        child: CachedNetworkImage(
          imageUrl: item.getBackdrop(),
          errorBuilder: (context, error, stackTrace) =>
              Center(child: Text(error.toString())),
          imageBuilder: (context, imageProvider) => AnimatedBuilder(
            animation: anim,
            builder: (context, _) {
              return Transform.scale(
                scale: scale.value,
                child: Image(
                  image: imageProvider,
                  fit: .cover,
                ),
              );
            },
          ),
          fit: .cover,
          color: Colors.black38,
          colorBlendMode: .darken,
        ).fadeIn(duration: 1000.milliseconds, curve: Curves.easeInOut),
      ),
    );
  }
}
