import 'package:flutter/material.dart';
import 'package:pudding/widgets/logo_shimmer.dart';

class SliverLoader extends StatelessWidget {
  final String id;
  const new({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return SliverFillViewport(
      delegate: SliverChildListDelegate.fixed([
        Center(child: LogoShimmer(id: id)),
      ]),
    );
  }
}
