import 'package:flutter/material.dart';
import 'package:pudding/widgets/logo_shimmer.dart';

class SliverLoader extends StatelessWidget {
  final String id;
  const new({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(right: 56.0),
        child: SizedBox(
          height: size.height - 76 - 76,
          child: Center(child: LogoShimmer(id: id)),
        ),
      ),
    );
  }
}
