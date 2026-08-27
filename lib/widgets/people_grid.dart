import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:forui_phosphor/forui_phosphor.dart';
import 'package:morphnext/morphnext.dart';
import 'package:pudding/utils/jellyfin_item_extensions.dart';
import 'package:pudding/widgets/sliver_section.dart';

import '../const/const.dart';
import '../models/jelly_people.dart';
import '../services/di.dart';

class PeopleGrid extends StatelessWidget {
  final List<JellyPeople> peoples;
  final List<JellyPeople> seasonPeoples;

  const PeopleGrid({
    super.key,
    required this.peoples,
    this.seasonPeoples = const [],
  });

  @override
  Widget build(BuildContext context) {
    return SliverGrid.builder(
      key: ValueKey(peoples.toString()),
      itemCount: peoples.length,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1 / 1.35,
        maxCrossAxisExtent: 160,
      ),
      itemBuilder: (context, index) {
        final people = peoples[index];

        return PeopleButton(people: people);
      },
    );
  }
}

class SliverPeople extends StatefulWidget {
  final JellyfinItem tv;
  final JellyfinItem? season;
  const SliverPeople({
    super.key,
    required this.tv,
    this.season,
  });

  @override
  State<SliverPeople> createState() => _SliverPeopleState();
}

class _SliverPeopleState extends State<SliverPeople> {
  bool showAll = false;
  late List<JellyPeople> selectedList = widget.tv.getPeoples();

  @override
  Widget build(BuildContext context) {
    final isSeasonList = listEquals(selectedList, widget.season?.getPeoples());

    return SliverSection(
      header: Row(
        spacing: 10,
        children: [
          Row(
            spacing: 10,
            children: [
              FButton.icon(
                variant: .outline,
                onPress: () => setState(() {
                  if (isSeasonList) {
                    selectedList = widget.tv.getPeoples();
                  } else {
                    selectedList = widget.season?.getPeoples() ?? [];
                  }
                }),
                child: Icon(FPhosphorBoldIcons.arrowsLeftRight),
              ),
              FButton(
                variant: .outline,
                onPress: () {
                  _scrollToKey(widget.key as GlobalKey);
                },

                child: Text(
                  '${isSeasonList ? widget.season?.name : 'Series'} Cast & Crew',
                ),
              ),
            ],
          ),
          if (selectedList.length > 15)
            FButton(
              variant: .ghost,
              onPress: () => setState(() => showAll = !showAll),
              suffix: AnimatedMorphIcon(
                icon: showAll
                    ? FPhosphorBoldIcons.minus
                    : FPhosphorBoldIcons.plus,
              ),
              child: showAll
                  ? Text('Show less')
                  : Text('Show all (${selectedList.length})'),
            ),
        ],
      ),
      slivers: [
        SliverPadding(
          padding: .fromLTRB(20, 0, 20, 20),
          sliver: PeopleGrid(peoples: peeps()),
        ),
      ],
    );
  }

  List<JellyPeople> peeps() {
    if (showAll) {
      return selectedList;
    } else {
      if (selectedList.length > 15) {
        return selectedList.sublist(0, 15);
      } else {
        return selectedList;
      }
    }
  }

  void _scrollToKey(GlobalKey key) {
    if (key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        alignment: 0,
        duration: kDefaultAnimationDuration,
      );
    }
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
                  child: AnimatedScale(
                    duration: kDefaultAnimationDuration,
                    scale: hover ? 1.02 : 1,
                    alignment: .bottomCenter,
                    child: CachedNetworkImage(
                      imageUrl: services<JellyfinClient>().images.url(
                        itemId: widget.people.Id,
                      ),
                      fit: .cover,
                      memCacheHeight: 400,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.black,
                        child: Icon(
                          FPhosphorBoldIcons.user,
                          size: 50,
                        ),
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
