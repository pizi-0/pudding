import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:pudding/models/jelly_user_policy.dart';

extension JellyUser on JellyfinUser {
  UserPolicy policy() {
    final policy = raw['Policy'] as Map<String, dynamic>;

    final map = policy.map(
      (k, v) => MapEntry(
        k.replaceFirst(k.substring(0, 1), k.substring(0, 1).toLowerCase()),
        v,
      ),
    );

    return UserPolicy.fromMap(map);
  }
}
