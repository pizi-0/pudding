import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:pudding/const/const.dart';

class CardButton extends StatefulWidget {
  final Widget child;
  const CardButton({super.key, required this.child});

  @override
  State<CardButton> createState() => _CardButtonState();
}

class _CardButtonState extends State<CardButton> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);

    return FButton(
      variant: .ghost,
      style: .delta(contentStyle: .delta(padding: .value(.zero))),
      onPress: () {},
      onHoverChange: (value) {
        setState(() {
          hover = value;
        });
      },
      onFocusChange: (value) {
        setState(() {
          hover = value;
        });
      },
      child: AnimatedScale(
        duration: kDefaultAnimationDuration,
        scale: hover ? 1.025 : 1,
        child: ClipRRect(
          borderRadius:
              theme.buttonStyles.ghost.lg.decoration.base.borderRadius!,
          child: widget.child,
        ),
      ),
    );
  }
}
