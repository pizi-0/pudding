import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:forui/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pudding/services/di.dart';

class LogoShimmer extends StatefulWidget {
  final String id;
  final int width;
  const LogoShimmer({super.key, required this.id, this.width = 200});

  @override
  State<LogoShimmer> createState() => _LogoShimmerState();
}

class _LogoShimmerState extends State<LogoShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: 1.5.seconds)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (rect) => LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: const [
              Colors.white54,
              Colors.white,
              Colors.white54,
            ],
            stops: [
              _controller.value - 0.1,
              _controller.value,
              _controller.value + 0.1,
            ],
          ).createShader(rect),
          child: CachedNetworkImage(
            imageUrl: services<JellyfinClient>().images.url(
              itemId: widget.id,
              type: JellyfinImagesApi.typeLogo,
              width: widget.width,
            ),
            errorBuilder: (context, error, stackTrace) => Center(
              child: Text(
                'Pudding',
                style: GoogleFonts.flavors(
                  textStyle: theme.typography.display.xl6.copyWith(
                    fontWeight: .bold,
                    color: theme.colors.primary,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
