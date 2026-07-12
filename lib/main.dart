import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pudding/pudding.dart';

void main() {
  runApp(
    ProviderScope(
      child: const Pudding(),
    ),
  );
}
