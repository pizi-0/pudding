import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:forui_phosphor/forui_phosphor.dart';
import 'package:material_ui/material_ui.dart';
import 'package:morphnext/morphnext.dart';
import 'package:pudding/providers/userdata_registry_provider.dart';

class FavoriteButton extends ConsumerStatefulWidget {
  final JellyfinItem item;
  final FButtonSizeVariant buttonSize;

  final Future Function()? onToggleFavorite;
  const FavoriteButton({
    super.key,
    required this.item,
    this.onToggleFavorite,
    this.buttonSize = .md,
  });

  @override
  ConsumerState<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends ConsumerState<FavoriteButton> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final override = ref.watch(
      userDataRegistryProvider.select((d) => d[widget.item.id]),
    );

    final dataNotifier = ref.read(userDataRegistryProvider.notifier);

    final isFavorite = override?.isFavorite ?? widget.item.isFavorite;

    return FButton.icon(
      variant: .outline,
      size: widget.buttonSize,
      onPress: loading
          ? null
          : () async {
              loading = true;
              setState(() {});
              await dataNotifier.toggleFavorite(widget.item);

              if (widget.onToggleFavorite != null) {
                widget.onToggleFavorite;
              }

              loading = false;
              setState(() {});
            },
      child: AnimatedMorphIcon(
        icon: loading
            ? FPhosphorBoldIcons.timer
            : isFavorite
            ? FPhosphorFillIcons.heart
            : FPhosphorBoldIcons.heart,
        color: loading || !isFavorite ? null : Colors.pink,
      ),
    );
  }
}
