import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences prefs;

class SharedPrefs {
  static Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }
}
