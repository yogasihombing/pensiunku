import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

/// [SharedPreferences] utility class
///
class SharedPreferencesUtil {
  static const String SP_KEY_FCM_TOKEN = 'fcm_token';
  static const String SP_KEY_TOKEN = 'user_token';
  static const String SP_KEY_IS_FINISHED_WALKTHROUGH =
      'is_finished_walkthrough';
  static const String SP_KEY_NOTIFICATION_COUNTER = 'notification_counter';

  static final SharedPreferencesUtil _singleton =
      SharedPreferencesUtil._internal();

  factory SharedPreferencesUtil() {
    return _singleton;
  }

  SharedPreferencesUtil._internal();

  late SharedPreferences sharedPreferences;

  Future<void> init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  static Future<Directory> getAppDir() async {
    final appDir = await path_provider.getApplicationDocumentsDirectory();
    return appDir;
  }
}
