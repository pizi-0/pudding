import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pudding/screens/home/providers/showcase_provider.dart';
import 'package:pudding/utils/jellyfin_item_extensions.dart';

class ShowcaseItemBackdrop extends ConsumerStatefulWidget {
  const ShowcaseItemBackdrop({super.key});

  @override
  ConsumerState<ShowcaseItemBackdrop> createState() =>
      _ShowcaseItemBackdropState();
}

class _ShowcaseItemBackdropState extends ConsumerState<ShowcaseItemBackdrop>
    with TickerProviderStateMixin {
  late AnimationController anim;
  late Animation<double> scale;
  late AnimationController _fadeController;

  JellyfinItem? _prevItem;
  JellyfinItem? _currentItem;
  bool _newImageLoaded = false;
  double _prevScale = 1.0;

  @override
  void initState() {
    super.initState();
    anim = AnimationController(vsync: this, duration: 15.seconds);
    scale = Tween<double>(begin: 1, end: 1.05).animate(anim);
    _fadeController = AnimationController(
      vsync: this,
      duration: 500.milliseconds,
    );
  }

  @override
  void dispose() {
    anim.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final item = ref.watch(showcaseProvider);

    if (item == null) {
      return Container(
        color: Colors.transparent,
        height: size.height,
        width: size.width,
      );
    }

    if (item != _currentItem) {
      _prevItem = _currentItem;
      _currentItem = item;
      _newImageLoaded = false;
      _fadeController.reset();

      if (_prevItem == null) {
        _fadeController.value = 1.0;
        _newImageLoaded = true;
        anim.forward(from: 0.0);
      }
    }

    return Container(
      clipBehavior: .hardEdge,
      decoration: const BoxDecoration(color: Colors.transparent),
      height: size.height,
      width: size.width,
      margin: .only(bottom: 5),
      child: AnimatedBuilder(
        animation: Listenable.merge([anim, _fadeController]),
        builder: (context, _) {
          final showPrev = _prevItem != null && _fadeController.value < 1.0;

          return Stack(
            fit: StackFit.expand,
            children: [
              if (showPrev)
                CachedNetworkImage(
                  imageUrl: _prevItem!.getImage(
                    type: JellyfinImagesApi.typeBackdrop,
                  ),
                  imageBuilder: (context, imageProvider) {
                    final prevImageScale = _newImageLoaded
                        ? _prevScale
                        : scale.value;
                    return Transform.scale(
                      scale: prevImageScale,
                      child: Image(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                  fit: BoxFit.cover,
                  color: Colors.black38,
                  colorBlendMode: BlendMode.darken,
                ),
              Opacity(
                opacity: _fadeController.value,
                child: CachedNetworkImage(
                  imageUrl: _currentItem!.getImage(
                    type: JellyfinImagesApi.typeBackdrop,
                  ),
                  errorBuilder: (context, error, stackTrace) =>
                      Center(child: Text(error.toString())),
                  imageBuilder: (context, imageProvider) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!_newImageLoaded && mounted) {
                        _prevScale = scale.value;
                        _newImageLoaded = true;
                        _fadeController.forward();
                        anim.forward(from: 0.0);
                      }
                    });

                    return Transform.scale(
                      scale: scale.value,
                      child: Image(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                  fit: BoxFit.cover,
                  color: Colors.black38,
                  colorBlendMode: BlendMode.darken,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
