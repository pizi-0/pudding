import 'dart:async';

import 'package:awesome_extensions/awesome_extensions.dart' show NumExtension;
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:forui_phosphor/forui_phosphor.dart';
import 'package:morphnext/morphnext.dart';
import 'package:pudding/widgets/detail_slivers/sliver_section.dart';

import 'hero_carousel_card.dart';

class SliverCarousel extends StatefulWidget {
  final List<JellyfinItem> items;
  const SliverCarousel({super.key, required this.items});

  @override
  State<SliverCarousel> createState() => _SliverCarouselState();
}

class _SliverCarouselState extends State<SliverCarousel> {
  CarouselController carouselController = CarouselController();
  Timer? autoPlayTimer;
  int currentIndex = 0;
  bool hover = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoPlay();
    });
  }

  @override
  void dispose() {
    carouselController.dispose();
    super.dispose();
  }

  void _autoPlay() {
    autoPlayTimer?.cancel();
    autoPlayTimer = Timer.periodic(
      5.seconds,
      (timer) {
        if (!carouselController.hasClients) return;

        currentIndex += 1;

        if (currentIndex > widget.items.length - 1) {
          currentIndex = 0;
          carouselController.animateToItem(
            currentIndex,
            duration: 500.milliseconds,
          );
        } else {
          carouselController.animateToItem(
            currentIndex,
            duration: 500.milliseconds,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final items = widget.items;

    return SliverSection(
      header: Row(
        spacing: 10,
        children: [
          FButton(
            variant: .outline,
            onPress: () {},
            child: Text('Continue watching'),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: AnimatedMorphIcon(
              icon: hover ? FPhosphorBoldIcons.pause : FPhosphorBoldIcons.play,
            ),
          ),
        ],
      ),
      slivers: [
        SliverToBoxAdapter(
          child: MouseRegion(
            onEnter: (event) {
              autoPlayTimer?.cancel();
              hover = true;
              setState(() {});
            },
            onExit: (event) {
              _autoPlay();
              hover = false;
              setState(() {});
            },
            child: SizedBox(
              height: 250,
              child: LayoutBuilder(
                builder: (context, size) {
                  final weight = _flexWeights(
                    theme.breakpoints,
                    size.maxWidth,
                  );
                  return CarouselView.weightedBuilder(
                    controller: carouselController,
                    scrollDirection: .horizontal,
                    infinite: true,
                    itemSnapping: true,
                    enableSplash: false,
                    shrinkExtent: 100,
                    itemCount: items.length,
                    flexWeights: weight,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Padding(
                        padding: const EdgeInsets.only(
                          right: 10.0,
                        ),
                        child: ClipRRect(
                          borderRadius: theme.style.borderRadius.sm,
                          child: HeroCarouselCard(
                            item: item,
                            index: index,
                            total: items.length,
                            flexWeights: weight,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<int> _flexWeights(FBreakpoints bp, double width) {
    if (width < bp.md) {
      return [3];
    } else if (width < bp.lg) {
      return [2, 3, 2];
    } else if (width < bp.xl) {
      return [2, 3, 2];
    }

    return [1, 2, 3, 2, 1];
  }
}
