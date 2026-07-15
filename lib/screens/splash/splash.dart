import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      child: Center(
        child: FCircularProgress(),
      ),
    );
  }
}
