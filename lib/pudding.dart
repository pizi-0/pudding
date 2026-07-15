import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:pudding/providers/route_provider.dart';
import 'package:pudding/theme/theme.dart';

class Pudding extends ConsumerWidget {
  const Pudding({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routeProvider);

    return MaterialApp.router(
      title: 'Pudding',
      routerConfig: router,
      builder: (context, child) => FTheme(
        data: FThemeData(
          colors: darkCustom(primary: Colors.pink),
          touch: false,
        ),
        child: child!,
      ),
    );
  }
}
