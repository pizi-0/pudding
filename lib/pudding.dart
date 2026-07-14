import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:pudding/feat/auth/auth_screen.dart';

class Pudding extends StatelessWidget {
  const Pudding({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pudding',
      home: Material(
        child: FTheme(data: FThemes.violet.dark.desktop, child: AuthScreen()),
      ),
    );
  }
}
