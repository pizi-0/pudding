import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class RatingContainer extends StatelessWidget {
  final String rating;
  const RatingContainer({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    return Container(
      height: theme.typography.body.lg.fontSize,
      decoration: BoxDecoration(
        border: .all(
          color: theme.colors.foreground,
        ),
        borderRadius: .circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 1.5,
          horizontal: 3,
        ),
        child: FittedBox(
          child: Text(rating),
        ),
      ),
    );
  }
}
