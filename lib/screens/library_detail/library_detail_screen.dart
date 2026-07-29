import 'package:awesome_extensions/awesome_extensions_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

class LibraryDetail extends ConsumerStatefulWidget {
  final String? id;
  const LibraryDetail({super.key, this.id});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LibraryDetailState();
}

class _LibraryDetailState extends ConsumerState<LibraryDetail> {
  @override
  Widget build(BuildContext context) {
    return FButton(
      onPress: context.pop,
      child: Text('data'),
    );
  }
}
