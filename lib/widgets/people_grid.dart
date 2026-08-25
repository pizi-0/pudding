import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../const/const.dart';
import '../models/jelly_people.dart';
import '../services/di.dart';

class PeopleGrid extends StatelessWidget {
  final List<JellyPeople> peoples;

  const PeopleGrid({
    super.key,
    required this.peoples,
  });

  @override
  Widget build(BuildContext context) {
    return SliverGrid.builder(
      key: ValueKey(peoples.toString()),
      itemCount: peoples.length,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1 / 1.35,
        maxCrossAxisExtent: 180,
      ),
      itemBuilder: (context, index) {
        final people = peoples[index];

        return PeopleButton(people: people);
      },
    );
  }
}

class PeopleButton extends StatefulWidget {
  const PeopleButton({super.key, required this.people});

  final JellyPeople people;

  @override
  State<PeopleButton> createState() => _PeopleButtonState();
}

class _PeopleButtonState extends State<PeopleButton> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final style = theme.style;

    return FButton.raw(
      variant: .outline,
      onPress: () {},
      onHoverChange: (value) => setState(() => hover = !hover),
      onFocusChange: (value) => setState(() => hover = !hover),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: ClipRRect(
          borderRadius: style.borderRadius.sm,
          child: Stack(
            fit: .expand,
            children: [
              Positioned.fill(
                child: ShaderMask(
                  shaderCallback: (rect) => LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black,
                    ],
                    stops: [0.4, 1],
                    begin: .topCenter,
                    end: .bottomCenter,
                  ).createShader(rect),
                  blendMode: .darken,
                  child: CachedNetworkImage(
                    imageUrl: services<JellyfinClient>().images.url(
                      itemId: widget.people.Id,
                    ),
                    fit: .cover,
                    height: 50,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.black,
                      child: Icon(
                        FLucideIcons.user,
                        size: 50,
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: .bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AnimatedSize(
                    duration: kDefaultAnimationDuration,
                    alignment: .topCenter,
                    child: Column(
                      mainAxisSize: .min,
                      children: [
                        Text(
                          widget.people.Name,
                          maxLines: hover ? null : 1,
                          overflow: hover ? null : .ellipsis,
                          textAlign: .center,
                          style: theme.typography.body.sm,
                        ).bold(),
                        Text(
                          'as ${widget.people.Role}',
                          maxLines: hover ? null : 1,
                          overflow: hover ? null : .ellipsis,
                          textAlign: .center,
                          style: theme.typography.body.xs,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
