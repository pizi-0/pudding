import 'package:flutter/material.dart';
import 'package:pudding/feat/auth/auth_screen.dart';

class Pudding extends StatelessWidget {
  const Pudding({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pudding',
      home: AuthScreen(),
    );
  }
}
