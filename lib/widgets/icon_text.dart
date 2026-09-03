import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class IconText extends StatelessWidget {
  final String text;
  final IconData icon;
  const new({super.key, required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final iconSize = theme.typography.body.sm.fontSize;

    return Row(
      spacing: 4,
      mainAxisSize: .min,
      children: [
        Icon(icon, size: iconSize),
        Text(text),
      ],
    );
  }
}
