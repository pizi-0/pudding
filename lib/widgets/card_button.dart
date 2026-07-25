import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:pudding/const/const.dart';

class CardButton extends StatefulWidget {
  final Widget child;
  final Function()? onPress;
  const CardButton({super.key, required this.child, this.onPress});

  @override
  State<CardButton> createState() => _CardButtonState();
}

class _CardButtonState extends State<CardButton> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);

    return FButton.raw(
      variant: .ghost,
      onPress: widget.onPress,
      onHoverChange: (h) => setState(() => hover = h),
      onFocusChange: (f) => setState(() => hover = f),
      child: AnimatedScale(
        duration: kDefaultAnimationDuration,
        scale: hover ? 1.02 : 1,
        child: ClipRRect(
          borderRadius:
              theme.buttonStyles.ghost.lg.decoration.base.borderRadius!,
          child: widget.child,
        ),
      ),
    );
  }
}
