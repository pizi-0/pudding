import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:pudding/const/const.dart';
import 'package:pudding/feat/auth/auth_provider.dart';
import 'package:pudding/services/di.dart';

class AuthWidget extends ConsumerStatefulWidget {
  const AuthWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AuthWidgetState();
}

class _AuthWidgetState extends ConsumerState<AuthWidget> {
  final formKey = GlobalKey<FormState>();

  String? serverErrorMessage;
  String? loginErrorMessage;
  JellyfinSystemInfo? info;

  bool loading = false;

  FAutocompleteController serverField = FAutocompleteController();
  TextEditingController userField = TextEditingController();
  TextEditingController passField = TextEditingController();

  final jelly = services<JellyfinClient>();

  @override
  void dispose() {
    serverField.dispose();
    userField.dispose();
    passField.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final showCredentialFields = info != null;

    return Column(
      mainAxisAlignment: .start,
      children: [
        FAutocomplete.text(
          items: ['http://localhost:8096', 'http://192.168.0.69:8096'],
          control: .managed(controller: serverField),
          label: Text('Server address'),
          hint: 'http://localhost:8096',
          onSubmit: (v) => _getServerInfo(),
          readOnly: info != null,
          forceErrorText: serverErrorMessage,
          errorBuilder: (context, message) => Text(message),
          suffixBuilder: (context, style, variants) {
            if (serverField.text.isNotEmpty) {
              return Padding(
                padding: const .only(right: 2),
                child: FButton.icon(
                  size: .sm,
                  variant: .ghost,
                  onPress: () {
                    serverField.clear();
                    serverErrorMessage = null;
                    info = null;
                    setState(() {});
                  },
                  child: Icon(FLucideIcons.x),
                ),
              );
            }
            return SizedBox.shrink();
          },
        ),

        SizedBox(height: 8),
        SizedBox(
          height: showCredentialFields ? null : 0,
          child: Column(
            crossAxisAlignment: .start,
            spacing: 8,
            children: [
              Row(
                spacing: 8,
                children: [
                  Expanded(child: FDivider()),
                  Text(
                    '${info?.serverName ?? '{serverName}'} (${info?.version})',
                    style: theme.typography.body.sm.copyWith(
                      fontWeight: .w600,
                    ),
                  ),
                  Expanded(child: FDivider()),
                ],
              ),
              Form(
                key: formKey,
                child: Column(
                  spacing: 8,
                  children: [
                    FTextFormField(
                      control: .managed(controller: userField),
                      label: Text('Username'),
                      validator: (value) {
                        if (value?.isEmpty ?? false) {
                          return 'Username cannot be empty';
                        }
                        return null;
                      },
                    ),
                    FTextFormField.password(
                      control: .managed(controller: passField),
                      label: Text('Password'),
                      validator: (value) {
                        if (value?.isEmpty ?? false) {
                          return 'Password cannot be empty';
                        }
                        return null;
                      },
                      onSubmit: (v) => _signInWithCredentials(),
                    ),
                  ],
                ),
              ),
              AnimatedSize(
                duration: kDefaultAnimationDuration,
                alignment: AlignmentGeometry.topLeft,
                child: SizedBox(
                  height: loginErrorMessage == null ? 0 : null,
                  child: Text(
                    loginErrorMessage ??
                        'There should be an error message here',
                    style: theme.typography.body.sm.copyWith(
                      color: theme.colors.error,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        AnimatedSwitcher(
          duration: kDefaultAnimationDuration,
          child: showCredentialFields
              ? FButton(
                  onPress: _signInWithCredentials,
                  child: loading ? FCircularProgress() : Text('Sign in'),
                )
              : FButton(
                  onPress: _getServerInfo,
                  child: loading ? FCircularProgress() : Text('Test'),
                ),
        ),
      ],
    );
  }

  Future<void> _getServerInfo() async {
    if (loading) return;
    String address = 'http://localhost:8096';

    if (serverField.text.isEmpty) {
      serverField.text = address;
    } else {
      address = serverField.text;
    }

    loading = true;
    info = null;
    serverErrorMessage = null;
    setState(() {});
    try {
      jelly.connect(address);
      info = await jelly.system.publicInfo();
      setState(() {});
    } on JellyfinException catch (e) {
      debugPrint(e.type.toString());
      serverErrorMessage = 'Unable to connect to $address. ${e.type}';
    } on Exception catch (e) {
      serverErrorMessage = 'Unable to connect to $address. $e';
    } finally {
      loading = false;
      setState(() {});
    }
  }

  Future<void> _signInWithCredentials() async {
    if (loading) return;

    loading = true;
    loginErrorMessage = null;
    setState(() {});
    try {
      if (formKey.currentState?.validate() ?? false) {
        await ref
            .read(authProvider.notifier)
            .signInWithCredential(userField.text.trim(), passField.text.trim());
      }
    } on JellyfinException catch (e) {
      loginErrorMessage = 'Sign in error (${e.statusCode})';
      debugPrint(e.toString());
    } catch (e) {
      loginErrorMessage = e.toString();
    } finally {
      loading = false;
      setState(() {});
    }
  }
}
