import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class SectionHeader extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final List<Widget> trailings;
  const SectionHeader({
    super.key,
    required this.title,
    this.trailings = const [],
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Column(
      spacing: 4,
      children: [
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: DefaultTextStyle(
                style: theme.typography.display.lg.copyWith(fontWeight: .bold),
                child: title,
              ),
            ),
            ...trailings,
          ],
        ),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: DefaultTextStyle(
              style: theme.typography.display.xs.copyWith(
                color: theme.colors.mutedForeground,
              ),
              child: subtitle!,
            ),
          ),
      ],
    );
  }
}
