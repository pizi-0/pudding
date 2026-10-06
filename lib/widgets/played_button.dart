import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:forui_phosphor/forui_phosphor.dart';
import 'package:material_ui/material_ui.dart';
import 'package:morphnext/morphnext.dart';
import 'package:pudding/providers/userdata_registry_provider.dart';
import 'package:pudding/utils/jellyfin_item_extensions.dart';

class PlayedButton extends ConsumerStatefulWidget {
  final JellyfinItem item;
  final FButtonSizeVariant buttonSize;
  final Future Function()? onTogglePlayed;
  const PlayedButton({
    super.key,
    required this.item,
    this.onTogglePlayed,
    this.buttonSize = .lg,
  });

  @override
  ConsumerState<PlayedButton> createState() => _PlayedButtonState();
}

class _PlayedButtonState extends ConsumerState<PlayedButton> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final override = ref.watch(
      userDataRegistryProvider.select((d) => d[widget.item.id]),
    );

    final dataNotifier = ref.read(userDataRegistryProvider.notifier);

    final isPlayed = override?.played ?? widget.item.isPlayed;

    return FButton.icon(
      size: widget.buttonSize,
      variant: .outline,
      onPress: loading
          ? null
          : () async {
              loading = true;
              setState(() {});
              await dataNotifier.togglePlayed(widget.item);

              if (widget.onTogglePlayed != null) {
                await widget.onTogglePlayed!();
              }

              loading = false;
              setState(() {});
            },
      child: AnimatedMorphIcon(
        icon: loading
            ? FPhosphorBoldIcons.timer
            : isPlayed
            ? FPhosphorBoldIcons.checks
            : FPhosphorBoldIcons.check,
        color: loading || !isPlayed ? null : Colors.green,
      ),
    );
  }
}
