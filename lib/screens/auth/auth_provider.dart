import 'dart:async';

import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pudding/data/local/secure_storage/secure_storage.dart';
import 'package:pudding/services/di.dart';

class AuthNotifier extends AsyncNotifier<JellyfinUser?> {
  final client = services<JellyfinClient>();
  @override
  Future<JellyfinUser?> build() async {
    return await getUser();
  }

  Future<JellyfinUser?> getUser() async {
    final savedSession = await SecureStorage.getSession();

    if (savedSession != null) {
      client.setSession(
        token: savedSession.token,
        userId: savedSession.userId,
      );

      client.connect(savedSession.serverAddresss);

      return await client.user.currentUser();
    }

    return null;
  }

  Future<void> signInWithCredential(String user, String password) async {
    try {
      final auth = await client.user.authenticateByName(
        username: user,
        password: password,
      );

      client.setSession(token: auth.accessToken, userId: auth.user.id);

      state = AsyncData(auth.user);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signInWithQuickConnect(String secret) async {
    try {
      final auth = await client.user.authenticateWithQuickConnect(
        secret: secret,
      );

      client.setSession(token: auth.accessToken, userId: auth.user.id);

      state = AsyncData(auth.user);
    } catch (e) {
      rethrow;
    }
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, JellyfinUser?>(
  () => AuthNotifier(),
);

final authStateProvider = Provider<AuthState>((ref) {
  final user = ref.watch(authProvider);

  if (user.value == null) {
    return .unauthd;
  } else if (user.value != null) {
    return .authd;
  } else {
    return .init;
  }
});

enum AuthState { init, authd, unauthd }
