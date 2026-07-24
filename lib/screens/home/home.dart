import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:pudding/screens/home/widgets/showcase.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  @override
  Widget build(BuildContext context) {
    return FScaffold(
      childPad: false,
      child: CustomScrollView(
        slivers: [
          SliverFillViewport(
            delegate: SliverChildListDelegate([
              Showcase(),
            ]),
          ),
        ],
      ),
    );
  }
}
