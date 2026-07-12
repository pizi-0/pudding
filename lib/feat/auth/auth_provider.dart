import 'dart:async';

import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pudding/data/local/secure_storage/secure_storage.dart';

class AuthNotifier extends AsyncNotifier<JellyfinUser?> {
  @override
  Future<JellyfinUser?> build() async {
    return await getUser();
  }

  Future<JellyfinUser?> getUser() async {
    final previousSession = await SecureStorage.getSession();

    if (previousSession != null) {}
  }
}

final authProvider = AsyncNotifierProvider(
  () => AuthNotifier(),
);
