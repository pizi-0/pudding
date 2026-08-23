import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

class PuddingScaffold extends StatefulWidget {
  final Widget child;
  final Widget? header;
  final Widget? backdrop;
  const PuddingScaffold({
    super.key,
    required this.child,
    this.header,
    this.backdrop,
  });

  @override
  State<PuddingScaffold> createState() => _PuddingScaffoldState();
}

class _PuddingScaffoldState extends State<PuddingScaffold> {
  FocusNode node = FocusNode();

  @override
  void dispose() {
    node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return TapRegion(
      onTapInside: (event) {
        final primary = FocusManager.instance.primaryFocus;

        if (primary != null) {
          primary.unfocus();
        }
      },
      child: Focus(
        focusNode: node,
        child: Listener(
          onPointerDown: (event) {
            if (event.buttons == kBackMouseButton) {
              if (context.canPop()) {
                context.pop();
              }
            }
          },
          child: FScaffold(
            childPad: false,
            child: Stack(
              children: [
                if (widget.backdrop != null)
                  Positioned.fill(
                    child: ClipRRect(
                      child: widget.backdrop,
                    ),
                  ),
                widget.child,
                if (widget.header != null)
                  FTheme(
                    data: theme.copyWith(
                      headerStyles: .delta([
                        .all(.delta(padding: .value(.all(20)))),
                      ]),
                    ),
                    child: widget.header!,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
