import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

class Library extends ConsumerStatefulWidget {
  const Library({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LibraryState();
}

class _LibraryState extends ConsumerState<Library> {
  @override
  Widget build(BuildContext context) {
    return FScaffold(
      child: FButton(
        onPress: () {
          context.go('/');
        },
        child: Text('data'),
      ),
    );
  }
}
