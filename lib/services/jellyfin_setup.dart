import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:pudding/const/const.dart';
import 'package:pudding/services/di.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class JellyUtils {
  static Future<JellyfinCredentials> setupCredentials() async {
    final deviceId = await _getDeviceId();
    final device = await _getDeviceName();

    debugPrint('Device-ID: $deviceId');
    debugPrint('Device name: $device');

    return JellyfinCredentials(
      client: kAppName,
      device: device,
      deviceId: deviceId,
      version: kAppVersion,
    );
  }

  static Future<String> _getDeviceId() async {
    final deviceId = services<SharedPreferences>().getString('device-id');

    if (deviceId != null) return deviceId;

    final newId = Uuid().v1();
    await services<SharedPreferences>().setString('device-id', newId);

    return newId;
  }

  static Future<String> _getDeviceName() async {
    final DeviceInfoPlugin infoPlugin = DeviceInfoPlugin();

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return (await infoPlugin.androidInfo).model;
      case TargetPlatform.iOS:
        return (await infoPlugin.iosInfo).modelName;
      case TargetPlatform.linux:
        return (await infoPlugin.linuxInfo).name;
      case TargetPlatform.windows:
        return (await infoPlugin.windowsInfo).computerName;
      case TargetPlatform.macOS:
        return (await infoPlugin.macOsInfo).modelName;
      default:
        return 'unknown';
    }
  }
}
