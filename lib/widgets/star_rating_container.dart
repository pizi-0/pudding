import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:forui_phosphor/forui_phosphor.dart';

class StarRatingContainer extends StatelessWidget {
  final String rating;
  final TextStyle? style;
  const StarRatingContainer({super.key, required this.rating, this.style});

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);

    return Row(
      spacing: 4,
      children: [
        Icon(
          FPhosphorFillIcons.star,
          color: Colors.amber,
          size: theme.typography.body.sm.fontSize,
        ),
        Text(
          rating,
          style: style,
        ),
      ],
    );
  }
}
