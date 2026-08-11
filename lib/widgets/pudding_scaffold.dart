import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

class PuddingScaffold extends StatefulWidget {
  final Widget child;
  const PuddingScaffold({super.key, required this.child});

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
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
