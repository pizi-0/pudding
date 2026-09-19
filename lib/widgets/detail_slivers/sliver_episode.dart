import 'package:awesome_extensions/awesome_extensions.dart'
    show WidgetCommonExtension;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:pudding/providers/settings_provider.dart';
import 'package:pudding/screens/detail_screens/widgets/season_selector.dart';
import 'package:pudding/screens/tvshow_detail/provider/tvshow_state_provider.dart';
import 'package:pudding/utils/jellyfin_item_extensions.dart';
import 'package:pudding/utils/scroll_to_key_extension.dart';
import 'package:pudding/widgets/media_card.dart';
import 'package:pudding/widgets/detail_slivers/sliver_section.dart';

class SliverEpisodes extends ConsumerWidget {
  final String id;
  final Function()? onSeasonChanged;
  const new({super.key, required this.id, this.onSeasonChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final tvAsync = ref.watch(tvshowStateProvider(id));
    final prefs = ref.watch(
      settingsProvider.select((s) => s.value!.libraryPrefs),
    );

    return SliverSection(
      header: SeasonSelector(
        seriesId: id,
        onSeasonChanged: () {
          if (key is GlobalKey) {
            (key as GlobalKey).scrollToKey();
          }
        },
      ),
      slivers: [
        tvAsync.when(
          skipLoadingOnReload:
              tvAsync.isReloading && tvAsync.value?.episodes != null,
          loading: () => SliverToBoxAdapter(
            child: FCircularProgress(),
          ),
          error: (error, stackTrace) => SliverToBoxAdapter(
            child: Text(error.toString()),
          ),
          data: (data) {
            if (data.episodes.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text('No episodes found'),
                ),
              );
            }

            return SliverGrid.builder(
              itemCount: data.episodes.length,
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: prefs.itemWidth(.thumb).toDouble(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 16 / 14,
              ),
              itemBuilder: (context, index) {
                final tv = data.episodes[index];

                return NewMediaCard(
                  item: tv,
                  dimPlayed: tv.userData?.played ?? false,
                  bottom: AspectRatio(
                    aspectRatio: 16 / 4,
                    child:
                        LayoutBuilder(
                          builder: (context, size) {
                            final ov = tv.getOverview() ?? 'No overview';
                            final style = theme.typography.body.sm.copyWith(
                              color: theme.colors.mutedForeground,
                            );

                            final textPainter = TextPainter(
                              text: TextSpan(text: ov, style: style),
                              textDirection: .ltr,
                            );

                            final lineheight = textPainter.preferredLineHeight;
                            final maxlines =
                                ((size.maxHeight - 16) / lineheight).floor();

                            return Container(
                              padding: .all(8),
                              child: Text(
                                tv.getOverview() ?? 'No overview',
                                maxLines: maxlines > 0 ? maxlines : 1,
                                overflow: .ellipsis,
                                style: style,
                              ),
                            );
                          },
                        ).showIf(
                          (tv.userData?.played ?? false) ||
                              ((tv.id == data.nextup?.id) || index == 0) &&
                                  !tv.isMissing,
                        ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
