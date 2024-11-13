import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:pensiunku/data/db/app_database.dart';
import 'package:pensiunku/screen/register/prepare_register_screen.dart';
import 'package:pensiunku/screen/welcome/welcome_screen.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';

/// Initialization Screen
///
/// This screen is called first on the main program. It initializes all
/// necessary libraries and then go to welcome/home screen.
///
class InitScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/';

  @override
  _InitScreenState createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  @override
  void initState() {
    super.initState();

    _initializeApp();
  }

  /// Initialize necessary libraries and then go to welcome/home screen.
  Future<void> _initializeApp() async {
    // Initialize Database
    AppDatabase appDatabase = AppDatabase();
    await appDatabase.init();

    // Initialize SharedPreferences
    await SharedPreferencesUtil().init();
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    // Initialize FlutterFire
    await Firebase.initializeApp();
    String? savedFcmToken = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_FCM_TOKEN);
    if (savedFcmToken == null) {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      String? fcmToken = await messaging.getToken();
      if (fcmToken != null) {
        await SharedPreferencesUtil()
            .sharedPreferences
            .setString(SharedPreferencesUtil.SP_KEY_FCM_TOKEN, fcmToken);
      }
    }

    if (token != null) {
      Navigator.of(context)
          .pushReplacementNamed(PrepareRegisterScreen.ROUTE_NAME);
    } else {
      Navigator.of(context).pushReplacementNamed(WelcomeScreen.ROUTE_NAME);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
