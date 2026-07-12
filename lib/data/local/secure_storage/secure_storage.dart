import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static FlutterSecureStorage storage = FlutterSecureStorage();

  static Future<void> storeSession(String session) async {
    await storage.write(key: 'saved-session', value: session);
  }

  static Future<String?> getSession() async {
    return await storage.read(key: 'saved-session');
  }
}
