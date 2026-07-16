import 'dart:async';

import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pudding/const/const.dart';
import 'package:pudding/services/di.dart';

class Showcase extends ConsumerStatefulWidget {
  final List<JellyfinItem> items;
  const Showcase({super.key, this.items = const []});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ShowcaseState();
}

class _ShowcaseState extends ConsumerState<Showcase> {
  PageController pageController = PageController();
  Timer? _pageTimer;

  @override
  void initState() {
    super.initState();
    _nextPage();
  }

  @override
  void dispose() {
    pageController.dispose();
    _pageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Column(
      children: [
        SizedBox(
          width: size.width,
          height: size.height,
          child: ScrollConfiguration(
            behavior:
                ScrollConfiguration.of(
                  context,
                ).copyWith(
                  dragDevices: {.mouse, .trackpad},
                ),
            child: PageView.builder(
              controller: pageController,
              allowImplicitScrolling: true,
              itemCount: widget.items.length,
              itemBuilder: (context, index) => ShowcaseItem(
                item: widget.items[index],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _nextPage() async {
    _pageTimer?.cancel();
    _pageTimer = Timer.periodic(
      5.seconds,
      (timer) async {
        await pageController.nextPage(
          duration: kDefaultAnimationDuration,
          curve: Curves.easeInBack,
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
  final client = services<JellyfinClient>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: .expand,
      children: [
        Image.network(
          _getImageUrl(),
          fit: .cover,
        ),
      ],
    );
  }

  String _getImageUrl() {
    final item = widget.item;

    return client.images.url(
      itemId: item.seriesId ?? item.id,
      type: JellyfinImagesApi.typeBackdrop,
    );
  }
}
