import 'package:flutter/material.dart';

class SliverError extends StatelessWidget {
  final String error;
  const new({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return SliverFillViewport(
      delegate: SliverChildListDelegate.fixed([
        Center(child: Text(error)),
      ]),
    );
  }
}
