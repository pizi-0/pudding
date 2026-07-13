import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pudding/models/jf_saved_session.dart';
import 'package:pudding/services/di.dart';

class SecureStorage {
  static Future<void> storeSession(JfSavedSession session) async {
    await services<FlutterSecureStorage>().write(
      key: 'saved-session',
      value: session.toJson(),
    );
  }

  static Future<JfSavedSession?> getSession() async {
    final data = await services<FlutterSecureStorage>().read(
      key: 'saved-session',
    );

    if (data == null) return null;

    final session = JfSavedSession.fromJson(data);
    return session;
  }
}
