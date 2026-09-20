import 'package:awesome_extensions/awesome_extensions.dart' show StyledText;
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:pudding/const/const.dart';
import 'package:pudding/utils/jellyfin_item_extensions.dart';

class NewNewMediaCard extends StatefulWidget {
  final JellyfinItem item;
  final String imageType;
  final int width;
  const new({
    super.key,
    required this.item,
    this.imageType = JellyfinImagesApi.typePrimary,
    this.width = 350,
  });

  @override
  State<NewNewMediaCard> createState() => _NewNewMediaCardState();
}

class _NewNewMediaCardState extends State<NewNewMediaCard>
    with AutomaticKeepAliveClientMixin {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = context.theme;
    final item = widget.item;
    final imgType = widget.imageType;
    final imgWidth = widget.width;

    return FButton.raw(
      style: .delta(
        decoration: .delta([.all(.boxDelta(color: theme.colors.background))]),
      ),
      variant: .ghost,
      onPress: () {},
      onHoverChange: (b) => setState(() {
        hover = b;
      }),
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: .all(color: theme.colors.border, width: 2),
                    borderRadius: theme.style.borderRadius.sm,
                  ),
                  child: SizedBox.expand(
                    child: ClipRRect(
                      borderRadius: theme.style.borderRadius.sm,
                      child: CachedNetworkImage(
                        memCacheWidth: imgWidth,
                        disablePlaceholderOnCacheHit: false,
                        imageUrl: item.getImage(type: imgType),
                        fit: .cover,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 52),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: .only(
                bottomLeft: theme.style.borderRadius.sm.bottomLeft,
                bottomRight: theme.style.borderRadius.sm.bottomRight,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colors.background,
                  borderRadius: .only(
                    bottomLeft: theme.style.borderRadius.sm.bottomLeft,
                    bottomRight: theme.style.borderRadius.sm.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: AnimatedSize(
                              duration: kDefaultAnimationDuration,
                              alignment: .bottomCenter,
                              child: Text(
                                item.getTitle(),
                                overflow: .ellipsis,
                                maxLines: hover ? 5 : 1,
                              ).bold(),
                            ),
                          ),
                        ],
                      ),
                      DefaultTextStyle(
                        style: theme.typography.body.sm.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                        child: Row(
                          children: [
                            Text(item.getYear().toString()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
