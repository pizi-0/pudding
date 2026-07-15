import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pudding/const/const.dart';
import 'package:pudding/screens/auth/auth_provider.dart';
import 'package:pudding/screens/auth/widgets/auth_widget.dart';
import 'package:pudding/theme/styles/card_style.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final theme = FTheme.of(context);

    if (auth.isLoading) {
      return FScaffold(
        child: Center(
          child: FCircularProgress(),
        ),
      );
    }

    if (auth.value == null) {
      return FScaffold(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400),
            child: AnimatedSize(
              alignment: .topCenter,
              duration: kDefaultAnimationDuration,
              child: FCard(
                style: cardStyle(
                  colors: theme.colors,
                  typography: theme.typography,
                  style: theme.style,
                  touch: false,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FTabs(
                    children: [
                      FTabEntry(
                        label: Text('Login'),
                        child: AuthWidget(),
                      ),
                      FTabEntry(
                        label: Text('QuickConnect'),
                        child: Text('login'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return FScaffold(child: Text('Welcome'));
  }
}
