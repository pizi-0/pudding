import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:pudding/services/di.dart';
import 'package:pudding/utils/num_extensions.dart';

class Showcase extends ConsumerStatefulWidget {
  final List<JellyfinItem> items;
  const Showcase({super.key, this.items = const []});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ShowcaseState();
}

class _ShowcaseState extends ConsumerState<Showcase> {
  PageController pageController = PageController();
  int currentPage = 0;
  Timer? _pageTimer;
  bool pauseSlideshow = false;

  @override
  void initState() {
    super.initState();
    _startSlideshow();
  }

  @override
  void dispose() {
    pageController.dispose();
    _pageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: .expand,
      children: [
        if (pageController.hasClients)
          ShowcaseItemBackdrop(
            key: ValueKey(widget.items[currentPage].id),
            item: widget.items[currentPage],
          ),
        ScrollConfiguration(
          behavior:
              ScrollConfiguration.of(
                context,
              ).copyWith(
                dragDevices: {.mouse, .trackpad},
              ),
          child: NotificationListener<UserScrollNotification>(
            onNotification: (notification) {
              if (notification.direction != ScrollDirection.idle) {
                pauseSlideshow = true;
              } else {
                pauseSlideshow = false;
                _startSlideshow();
              }
              setState(() {});

              return false;
            },
            child: PageView.builder(
              controller: pageController,
              allowImplicitScrolling: true,
              itemCount: widget.items.length,
              itemBuilder: (context, index) => ShowcaseItem(
                item: widget.items[index],
              ),
              onPageChanged: (v) => setState(() {
                currentPage = v;
              }),
            ),
          ),
        ),
      ],
    );
  }

  void _startSlideshow() async {
    _pageTimer?.cancel();
    _pageTimer = Timer.periodic(
      10.seconds,
      (timer) async {
        if (pauseSlideshow) return;

        if (pageController.page == widget.items.length - 1) {
          pageController.jumpTo(0);
          return;
        }
        await pageController.nextPage(
          duration: 1000.milliseconds,
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final theme = FTheme.of(context);
    final resumable = widget.item.userData?.playbackPositionTicks != 0;

    final maxwidth = size.width > theme.breakpoints.sm
        ? size.width * 0.4
        : size.width > theme.breakpoints.md
        ? size.width * 0.6
        : size.width * 0.8;

    return Align(
      alignment: .bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Column(
          spacing: 10,
          mainAxisSize: .min,
          children: [
            SizedBox(
              width: maxwidth,
              child: Opacity(
                opacity: 0.8,
                child: Image.network(
                  _getLogo(),
                  fit: .contain,
                ),
              ),
            ),
            FCard(
              style: .delta(
                decoration: .boxDelta(),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  spacing: 8,
                  mainAxisSize: .min,
                  children: [
                    FButton(
                      onPress: () {},
                      prefix: Icon(FLucideIcons.play),
                      child: Row(
                        children: [
                          Text(resumable ? 'Resume' : 'Play'),
                          Text(_playtime()),
                          Text(_endTime()),
                        ].separatedby(Icon(FLucideIcons.dot)),
                      ),
                    ),
                    if (resumable)
                      FButton.icon(
                        onPress: () {},
                        child: Icon(FLucideIcons.rotateCcw),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLogo() {
    final item = widget.item;
    return client.images.url(
      itemId: item.seriesId ?? item.id,
      type: JellyfinImagesApi.typeLogo,
    );
  }

  String _playtime() {
    return item.durationMs?.toFormattedDuration() ?? '';
  }

  String _endTime() {
    return item.durationMs?.endsAt(context) ?? '';
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
    return AnimatedBuilder(
      animation: anim,
      builder: (context, child) => Transform.scale(
        alignment: .bottomCenter,
        scale: scale.value,
        child: child,
      ),
      child: Image.network(
        _getImage(),
        errorBuilder: (context, error, stackTrace) =>
            Center(child: Text(error.toString())),
        fit: .cover,
        color: Colors.black45,
        colorBlendMode: .darken,
      ),
    ).fadeIn(duration: 1.5.seconds);
  }

  String _getImage() {
    final client = services<JellyfinClient>();

    return client.images.url(
      itemId: widget.item.seriesId ?? widget.item.id,
      type: JellyfinImagesApi.typeBackdrop,
    );
  }
}
