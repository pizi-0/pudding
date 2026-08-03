import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class StarRatingContainer extends StatelessWidget {
  final String rating;
  const StarRatingContainer({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);

    return Row(
      spacing: 4,
      children: [
        Icon(
          FLucideIcons.star,
          color: Colors.amber,
          size: theme.typography.body.sm.fontSize,
        ),
        Text(rating),
      ],
    );
  }
}
