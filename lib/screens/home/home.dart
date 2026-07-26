import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:pudding/screens/home/home_provider.dart';
import 'package:pudding/screens/home/models/home_data_model.dart';
import 'package:pudding/screens/home/widgets/library_card.dart';
import 'package:pudding/screens/home/widgets/showcase.dart';
import 'package:pudding/widgets/media_card.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final data = ref.watch(homeProvider).value ?? HomeData();
    return TapRegion(
      onTapInside: (event) => FocusScope.of(context).unfocus(),
      child: CustomScrollView(
        slivers: [
          SliverFillViewport(
            viewportFraction: 1,
            padEnds: false,
            delegate: SliverChildListDelegate([
              Showcase(),
            ]),
          ),
          SliverPadding(
            padding: .symmetric(vertical: 20, horizontal: 30),
            sliver: SliverMainAxisGroup(
              slivers: [
                PinnedHeaderSliver(
                  child: Text(
                    'Libraries',
                    style: theme.typography.display.xl3.copyWith(
                      fontWeight: .bold,
                      height: 1.5,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: FDivider(
                    style: .delta(
                      padding: .value(.only(bottom: 8)),
                    ),
                  ),
                ),
                SliverGrid.builder(
                  itemCount: data.libraries.length,
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 350,
                    childAspectRatio: 16 / 9,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) => LibraryCard(
                    view: data.libraries[index],
                    onPress: () {},
                  ),
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: .symmetric(vertical: 20, horizontal: 30),
            sliver: SliverMainAxisGroup(
              slivers: [
                PinnedHeaderSliver(
                  child: Text(
                    'Continue watching',
                    style: theme.typography.display.xl3.copyWith(
                      fontWeight: .bold,
                      height: 1.5,
                    ),
                  ),
                ),
                SliverPadding(padding: .all(5)),
                SliverGrid.builder(
                  itemCount: data.continueWatching.length,
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 350,
                    childAspectRatio: 350 / 250,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) =>
                      MediaCard(item: data.continueWatching[index]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
