import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:pudding/screens/home/home_provider.dart';
import 'package:pudding/screens/home/models/home_data_model.dart';
import 'package:pudding/screens/home/widgets/library_card.dart';
import 'package:pudding/screens/home/widgets/showcase.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  @override
  Widget build(BuildContext context) {
    final data = ref.watch(homeProvider).value ?? HomeData();
    return TapRegion(
      onTapInside: (event) => FocusScope.of(context).unfocus(),
      child: FScaffold(
        childPad: false,
        child: CustomScrollView(
          slivers: [
            SliverFillViewport(
              viewportFraction: 0.95,
              padEnds: false,
              delegate: SliverChildListDelegate([
                Showcase(),
              ]),
            ),
            SliverPadding(
              padding: .all(20),
              sliver: SliverMainAxisGroup(
                slivers: [
                  PinnedHeaderSliver(
                    child: FCard(child: Text('Libraries')),
                  ),
                  SliverPadding(padding: .all(5)),
                  SliverGrid.builder(
                    itemCount: data.libraries.length,
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 350,
                      childAspectRatio: 16 / 9,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) =>
                        LibraryCard(view: data.libraries[index]),
                  ),
                ],
              ),
            ),
            SliverMainAxisGroup(
              slivers: [
                PinnedHeaderSliver(
                  child: Text('Continue watching'),
                ),
                SliverFillViewport(
                  delegate: SliverChildListDelegate([Text('data')]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
