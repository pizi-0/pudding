import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pudding/const/const.dart';
import 'package:pudding/screens/auth/widgets/auth_widget.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    return FScaffold(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 400),
          child: AnimatedSize(
            alignment: .topCenter,
            duration: kDefaultAnimationDuration,
            child: AuthWidget(),
          ),
        ),
      ),
    );
  }
}
