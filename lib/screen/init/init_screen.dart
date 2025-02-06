import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pensiunku/data/db/app_database.dart';
import 'package:pensiunku/screen/register/prepare_register_screen.dart';
import 'package:pensiunku/screen/welcome/welcome_screen.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Screen Inisialisasi (Splash Screen)
/// Screen ini adalah screen pertama yang dipanggil saat aplikasi dibuka.
/// Melakukan inisialisasi library yang diperlukan seperti database dan preferences,
/// kemudian mengarahkan ke welcome screen atau home screen.
class InitScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/';

  @override
  _InitScreenState createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen>
    with SingleTickerProviderStateMixin {
  // Mengontrol opacity untuk animasi fade in logo dan loading indicator
  double _opacity = 0.0;

  // Controller untuk mengatur animasi fade out saat akan pindah screen
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Mengatur UI system
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ));

    // Setup animation controller untuk fade out
    _fadeController = AnimationController(
      duration: const Duration(seconds: 1), // Durasi animasi fade out 1 detik
      vsync: this,
    );

    // Setup animation untuk fade out dari opacity 1.0 ke 0.0
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(_fadeController);

    // Delay sebelum memulai fade in logo dan loading
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0; // Trigger animasi fade in
        });
      }
    });

    // Mulai proses inisialisasi
    _initializeApp();
  }

  /// Fungsi utama untuk inisialisasi aplikasi
  Future<void> _initializeApp() async {
    try {
      if (!mounted) return;

      // Jalankan inisialisasi database dan preferences secara parallel
      await Future.wait([
        _initializeDatabase(),
        _initializePreferences(),
      ]).timeout(
          Duration(seconds: 10)); // Timeout jika inisialisasi terlalu lama

      if (!mounted) return;

      // Cek token dan setup FCM
      final token = await _handleTokenAndNavigation();

      if (!mounted) return;

      // Navigasi ke screen berikutnya berdasarkan token
      await _navigateToNextScreen(token);
    } catch (e) {
      print('Error during initialization: $e');
      _showErrorSnackbar();
    }
  }

  /// Inisialisasi database
  Future<void> _initializeDatabase() async {
    final appDatabase = AppDatabase();
    await appDatabase.init();
  }

  /// Inisialisasi shared preferences
  Future<void> _initializePreferences() async {
    await SharedPreferencesUtil().init();
  }

  /// Handle pengecekan token dan setup FCM
  Future<String?> _handleTokenAndNavigation() async {
    final prefs = SharedPreferencesUtil().sharedPreferences;
    final token = prefs.getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    // Cek FCM token
    final savedFcmToken =
        prefs.getString(SharedPreferencesUtil.SP_KEY_FCM_TOKEN);
    if (savedFcmToken == null) {
      await _setupFCMToken(prefs);
    }

    return token;
  }

  /// Setup Firebase Cloud Messaging token
  Future<void> _setupFCMToken(SharedPreferences prefs) async {
    final messaging = FirebaseMessaging.instance;
    final fcmToken = await messaging.getToken();
    if (fcmToken != null) {
      await prefs.setString(SharedPreferencesUtil.SP_KEY_FCM_TOKEN, fcmToken);
    }
  }

  /// Tampilkan snackbar jika terjadi error
  void _showErrorSnackbar() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Terjadi kesalahan saat inisialisasi aplikasi'),
      backgroundColor: Colors.red,
    ));
  }

  @override
  void dispose() {
    // Kembalikan system UI ke normal
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    // Bersihkan controller saat widget di dispose
    _fadeController.dispose();
    super.dispose();
  }

  /// Navigasi ke screen berikutnya dengan animasi fade out
  Future<void> _navigateToNextScreen(String? token) async {
    // Tunggu 2 detik sebelum mulai fade out
    await Future.delayed(Duration(seconds: 2));

    // Jalankan animasi fade out selama 1 detik
    await _fadeController.forward();

    if (!mounted) return;

    // Navigasi berdasarkan status token
    if (token != null) {
      Navigator.of(context).pushNamedAndRemoveUntil(
          PrepareRegisterScreen.ROUTE_NAME, (route) => false);
    } else {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(WelcomeScreen.ROUTE_NAME, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/background.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AnimatedOpacity(
                        opacity: _opacity,
                        duration: const Duration(milliseconds: 800),
                        child: Image.asset(
                          'assets/logo.png',
                          width: 130,
                          height: 130,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

                  // SizedBox(height: 24),
                    // Loading indicator dengan animasi fade in
                    // AnimatedOpacity(
                    //   opacity: _opacity,
                    //   duration:
                    //       Duration(milliseconds: 800), // Durasi fade in loading
                    //   child: CircularProgressIndicator(
                    //     color: Colors.white,
                    //     strokeWidth: 3,
                    //   ),
                    // ),

// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:pensiunku/data/db/app_database.dart';
// import 'package:pensiunku/screen/register/prepare_register_screen.dart';
// import 'package:pensiunku/screen/welcome/welcome_screen.dart';
// import 'package:pensiunku/util/shared_preferences_util.dart';

// /// Initialization Screen
// ///
// /// This screen is called first on the main program. It initializes all
// /// necessary libraries and then go to welcome/home screen.
// ///
// class InitScreen extends StatefulWidget {
//   static const String ROUTE_NAME = '/';

//   @override
//   _InitScreenState createState() => _InitScreenState();
// }

// class _InitScreenState extends State<InitScreen> {
//   @override
//   void initState() {
//     super.initState();

//     _initializeApp();
//   }

//   /// Initialize necessary libraries and then go to welcome/home screen.
//   Future<void> _initializeApp() async {
//     // Initialize Database
//     AppDatabase appDatabase = AppDatabase();
//     await appDatabase.init();

//     // Initialize SharedPreferences
//     await SharedPreferencesUtil().init();
//     String? token = SharedPreferencesUtil()
//         .sharedPreferences
//         .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

//     // Initialize FlutterFire
//     await Firebase.initializeApp();
//     String? savedFcmToken = SharedPreferencesUtil()
//         .sharedPreferences
//         .getString(SharedPreferencesUtil.SP_KEY_FCM_TOKEN);
//     if (savedFcmToken == null) {
//       FirebaseMessaging messaging = FirebaseMessaging.instance;
//       String? fcmToken = await messaging.getToken();
//       if (fcmToken != null) {
//         await SharedPreferencesUtil()
//             .sharedPreferences
//             .setString(SharedPreferencesUtil.SP_KEY_FCM_TOKEN, fcmToken);
//       }
//     }

//     if (token != null) {
//       Navigator.of(context)
//           .pushReplacementNamed(PrepareRegisterScreen.ROUTE_NAME);
//     } else {
//       Navigator.of(context).pushReplacementNamed(WelcomeScreen.ROUTE_NAME);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: CircularProgressIndicator(),
//       ),
//     );
//   }
// }
