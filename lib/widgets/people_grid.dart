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
  final JellyfinItem media;
  final JellyfinItem? altMedia;
  const SliverPeople({
    super.key,
    required this.media,
    this.altMedia,
  });

  @override
  State<SliverPeople> createState() => _SliverPeopleState();
}

class _SliverPeopleState extends State<SliverPeople> {
  bool showAll = false;
  late List<JellyPeople> selectedList = widget.media.getPeoples();

  @override
  Widget build(BuildContext context) {
    final isAltList = listEquals(selectedList, widget.altMedia?.getPeoples());

    final isSeries = widget.media.isSeries;

    return SliverSection(
      header: Row(
        spacing: 10,
        children: [
          Row(
            spacing: 10,
            children: [
              if (widget.altMedia != null)
                FButton.icon(
                  variant: .outline,
                  onPress: () => setState(() {
                    if (isAltList) {
                      selectedList = widget.media.getPeoples();
                    } else {
                      selectedList = widget.altMedia?.getPeoples() ?? [];
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
                  isSeries
                      ? '${isAltList ? widget.altMedia?.name : 'Series'} Cast & Crew'
                      : 'Cast & Crew',
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
          padding: .fromSTEB(28, 0, 20, 20),
          sliver: peeps().isEmpty
              ? SliverToBoxAdapter(child: Text('Hello, there.').italic())
              : PeopleGrid(peoples: peeps()),
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

    return RepaintBoundary(
      child: FButton.raw(
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
                Positioned.fill(
                  top: -1,
                  left: -1,
                  right: -1,
                  bottom: -1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, theme.colors.background],
                        begin: .center,
                        end: .bottomCenter,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: .end,
                        children: [
                          AnimatedSize(
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
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
