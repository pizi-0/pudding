import 'package:awesome_extensions/awesome_extensions.dart' show StyledText;
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:forui_phosphor/forui_phosphor.dart';
import 'package:morphnext/morphnext.dart';
import 'package:pudding/const/const.dart';
import 'package:pudding/models/jelly_people.dart';
import 'package:pudding/utils/jellyfin_item_extensions.dart';
import 'package:pudding/widgets/people_grid.dart';
import 'package:pudding/widgets/detail_slivers/sliver_section.dart';

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
        peeps().isEmpty
            ? SliverToBoxAdapter(child: Text('Hello, there.').italic())
            : PeopleGrid(peoples: peeps()),
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
