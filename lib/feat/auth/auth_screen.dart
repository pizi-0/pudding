import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pudding/feat/auth/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

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
            constraints: BoxConstraints(maxWidth: 400, maxHeight: 400),
            child: FCard(
              child: FTabs(
                children: [
                  FTabEntry(label: Text('Login'), child: _buildLoginForm()),
                  FTabEntry(label: Text('QuickConnect'), child: Text('login')),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return FScaffold(child: Text('Welcome'));
  }

  Widget _buildLoginForm() {
    return Column(
      spacing: 4,
      children: [
        FTextFormField(
          label: Text('Server addresss'),
          onSubmit: (value) async {},
        ),
        FTextFormField(
          label: Text('Username'),
        ),
        FTextFormField.password(),

        Row(
          spacing: 4,
          children: [
            Expanded(
              flex: 2,
              child: FButton(
                child: Text('Login'),
                onPress: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }
}
