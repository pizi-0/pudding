import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:media_kit/media_kit.dart';
import 'package:pudding/pudding.dart';
import 'package:pudding/services/di.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  await initializeDateFormatting();

  await Di.init();

  runApp(
    ProviderScope(
      child: const Pudding(),
    ),
  );
}
