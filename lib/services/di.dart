import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:pudding/services/jellyfin_setup.dart';
import 'package:shared_preferences/shared_preferences.dart';

final services = GetIt.instance;

class Di {
  static Future<void> init() async {
    final secStorage = _initSecureStorage();
    final prefs = await _initSharedPrefs();

    services.registerSingleton<FlutterSecureStorage>(secStorage);
    services.registerSingleton<SharedPreferences>(prefs);

    final jellyClient = await _initJellyfin();
    services.registerSingleton<JellyfinClient>(jellyClient);
  }

  static Future<SharedPreferences> _initSharedPrefs() async {
    return await SharedPreferences.getInstance();
  }

  static FlutterSecureStorage _initSecureStorage() {
    return FlutterSecureStorage();
  }

  static Future<JellyfinClient> _initJellyfin() async {
    final credentials = await JellyUtils.setupCredentials();

    return JellyfinClient(credentials: credentials);
  }
}
