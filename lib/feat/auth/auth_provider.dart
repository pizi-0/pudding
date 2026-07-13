import 'dart:async';

import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pudding/data/local/secure_storage/secure_storage.dart';
import 'package:pudding/services/di.dart';

class AuthNotifier extends AsyncNotifier<JellyfinUser?> {
  @override
  Future<JellyfinUser?> build() async {
    return await getUser();
  }

  Future<JellyfinUser?> getUser() async {
    final savedSession = await SecureStorage.getSession();
    final client = services<JellyfinClient>();

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
}

final authProvider = AsyncNotifierProvider<AuthNotifier, JellyfinUser?>(
  () => AuthNotifier(),
);
