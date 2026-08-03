import 'package:awesome_extensions/awesome_extensions_dart.dart';
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pudding/screens/home/providers/showcase_provider.dart';
import 'package:pudding/utils/jellyfin_item_extensions.dart';

class ImageSlideshow extends ConsumerStatefulWidget {
  final List<String> images;
  const ImageSlideshow({super.key, required this.images});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ImageSlideshowState();
}

class _ImageSlideshowState extends ConsumerState<ImageSlideshow>
    with SingleTickerProviderStateMixin {
  bool isAnimating = false;

  late AnimationController animationController;
  late Animation<double> opacity;
  late int currentImageIndex;
  late int nextImageIndex;

  @override
  void initState() {
    _setupImages();
    animationController = AnimationController(
      vsync: this,
      duration: 500.milliseconds,
    );
    opacity = Tween<double>(begin: 0, end: 1).animate(animationController);

    animationController.addListener(() {
      print(animationController.status);
      print(opacity.value);
      if (animationController.status == .completed) {
        setState(() {
          isAnimating = false;
          currentImageIndex = nextImageIndex;
          nextImageIndex += 1;

          animationController.reset();
        });
      }
    });

    ref.listenManual(
      showcaseProvider,
      (previous, next) {
        final prevIndex = widget.images.indexOf(previous!.getBackdrop());
        final nextIndex = widget.images.indexOf(next!.getBackdrop());

        if (nextIndex > prevIndex) {
          isAnimating = true;

          animationController.forward();
        }
      },
    );

    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void _setupImages() {
    if (widget.images.isEmpty) return;

    currentImageIndex = 0;
    nextImageIndex = 1;
  }

  @override
  Widget build(BuildContext context) {
    print(opacity.value);

    return Stack(
      fit: .expand,
      children: [
        CachedNetworkImage(
          imageUrl: widget.images[currentImageIndex],
          fit: .cover,
        ),
        if (isAnimating)
          AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              return Opacity(
                opacity: animationController.value,
                child: CachedNetworkImage(
                  imageUrl: widget.images[nextImageIndex],
                  fit: .cover,
                ),
              );
            },
          ),
      ],
    );
  }
}
