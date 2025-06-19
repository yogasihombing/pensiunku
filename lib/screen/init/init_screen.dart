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

class _InitScreenState extends State<InitScreen> with SingleTickerProviderStateMixin {
  bool _isLoadingOverlay = true;

  late final AnimationController _logoAnimationController;

  @override
  void initState() {
    super.initState();

    // Setup animasi logo
    _logoAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(); // Muter terus

    // Mengatur UI system
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ));

    // Mulai proses inisialisasi library inti
    _initializeApp();

    // Mulai setup Firebase Messaging (Notifikasi)
    _setupFirebaseMessaging();
  }

  @override
  void dispose() {
    _logoAnimationController.dispose(); // Hentikan animasi saat dispose
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  /// Fungsi utama untuk inisialisasi aplikasi (database, preferences)
  Future<void> _initializeApp() async {
    try {
      if (!mounted) return;

      // Jalankan inisialisasi database dan preferences secara paralel
      await Future.wait([
        _initializeDatabase(),
        _initializePreferences(),
      ]).timeout(Duration(seconds: 10)); // Batas waktu 10 detik

      if (!mounted) return;

      // Cek token pengguna dan setup FCM (token FCM juga dihandle di sini)
      final token = await _handleTokenAndNavigation();

      // Navigasi ke screen berikutnya berdasarkan keberadaan token
      await _navigateToNextScreen(token);
    } catch (e) {
      print('Error during initialization: $e');
      _showErrorSnackbar();
    } finally {
      if (mounted) {
        setState(() => _isLoadingOverlay = false);
      }
    }
  }

  /// Fungsi untuk inisialisasi database
  Future<void> _initializeDatabase() async {
    final appDatabase = AppDatabase();
    await appDatabase.init();
  }

  /// Fungsi untuk inisialisasi shared preferences
  Future<void> _initializePreferences() async {
    await SharedPreferencesUtil().init();
  }

  /// Fungsi untuk menangani token pengguna dan FCM
  Future<String?> _handleTokenAndNavigation() async {
    final prefs = SharedPreferencesUtil().sharedPreferences;
    final token = prefs.getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    // Cek FCM token dan perbarui jika diperlukan
    final savedFcmToken = prefs.getString(SharedPreferencesUtil.SP_KEY_FCM_TOKEN);
    if (savedFcmToken == null) {
      await _setupFCMToken(prefs);
    }

    return token;
  }

  /// Fungsi untuk mendapatkan dan menyimpan FCM token
  Future<void> _setupFCMToken(SharedPreferences prefs) async {
    final messaging = FirebaseMessaging.instance;
    final fcmToken = await messaging.getToken();
    if (fcmToken != null) {
      await prefs.setString(SharedPreferencesUtil.SP_KEY_FCM_TOKEN, fcmToken);
      print('FCM Token baru: $fcmToken');
      // Anda mungkin ingin mengirim token ini ke backend Anda di sini
    }
  }

  /// Fungsi untuk menampilkan Snackbar error
  void _showErrorSnackbar() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Terjadi kesalahan saat inisialisasi aplikasi'),
      backgroundColor: Colors.red,
    ));
  }

  /// Fungsi untuk navigasi ke screen berikutnya setelah delay
  Future<void> _navigateToNextScreen(String? token) async {
    await Future.delayed(Duration(seconds: 2)); // Delay 2 detik
    if (!mounted) return;

    if (token != null) {
      // Jika ada token, navigasi ke PrepareRegisterScreen
      Navigator.of(context).pushNamedAndRemoveUntil(PrepareRegisterScreen.ROUTE_NAME, (route) => false);
    } else {
      // Jika tidak ada token, navigasi ke WelcomeScreen (halaman default)
      Navigator.of(context).pushNamedAndRemoveUntil(WelcomeScreen.ROUTE_NAME, (route) => false);
    }
  }

  /// Fungsi untuk setup Firebase Messaging (Push Notifikasi)
  Future<void> _setupFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // 1. Meminta Izin Notifikasi dari pengguna
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('Izin notifikasi diberikan: ${settings.authorizationStatus}');

    // 2. Mendengarkan pesan saat aplikasi di foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Menerima pesan saat aplikasi di foreground!');
      print('Data pesan: ${message.data}');

      if (message.notification != null) {
        print('Pesan juga berisi notifikasi: ${message.notification?.title} / ${message.notification?.body}');
      
      }
    });

    // 3. Menangani saat notifikasi ditekan (saat aplikasi di background/terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Event onMessageOpenedApp dipublikasikan!');
      print('Data pesan: ${message.data}');
    
    });

    // 4. Menangani saat aplikasi dibuka dari keadaan terminated oleh notifikasi
    RemoteMessage? initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      print('Aplikasi dibuka dari keadaan terminated oleh notifikasi: ${initialMessage.data}');
   
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
        child: Stack(
          children: [
            // Background
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/background.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: Image.asset(
                  'assets/logo.png',
                  width: 130,
                  height: 130,
                ),
              ),
            ),
            // Loading Overlay
            if (_isLoadingOverlay)
              Positioned.fill(
                child: ModalBarrier(
                  color: Colors.black.withOpacity(0.5),
                  dismissible: false,
                ),
              ),
            if (_isLoadingOverlay)
              Center(
                child: RotationTransition(
                  turns: _logoAnimationController,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(20),
                    child: Image.asset('assets/logo.png'), // Logo yang muter
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
// class InitScreen extends StatefulWidget {
//   static const String ROUTE_NAME = '/';

//   @override
//   _InitScreenState createState() => _InitScreenState();
// }

// class _InitScreenState extends State<InitScreen>
//     with SingleTickerProviderStateMixin {
//   // Variabel untuk mengatur tampilan loading overlay
//   bool _isLoadingOverlay = true;

//   @override
//   void initState() {
//     super.initState();

//     // Mengatur UI system
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
//     SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent,
//       systemNavigationBarColor: Colors.transparent,
//     ));
//     // Mulai proses inisialisasi
//     _initializeApp();
//   }

//   /// Fungsi utama untuk inisialisasi aplikasi
//   Future<void> _initializeApp() async {
//     try {
//       if (!mounted) return;

//       // Jalankan inisialisasi database dan preferences secara parallel
//       await Future.wait([
//         _initializeDatabase(),
//         _initializePreferences(),
//       ]).timeout(
//           Duration(seconds: 10)); // Timeout jika inisialisasi terlalu lama

//       if (!mounted) return;

//       // Cek token dan setup FCM
//       final token = await _handleTokenAndNavigation();
//       // Navigasi ke screen berikutnya berdasarkan token
//       await _navigateToNextScreen(token);
//     } catch (e) {
//       print('Error during initialization: $e');
//       _showErrorSnackbar();
//     } finally {
//       if (mounted) {
//         setState(() => _isLoadingOverlay = false);
//       }
//     }
//   }

//   /// Inisialisasi database
//   Future<void> _initializeDatabase() async {
//     final appDatabase = AppDatabase();
//     await appDatabase.init();
//   }

//   /// Inisialisasi shared preferences
//   Future<void> _initializePreferences() async {
//     await SharedPreferencesUtil().init();
//   }

//   /// Handle pengecekan token dan setup FCM
//   Future<String?> _handleTokenAndNavigation() async {
//     final prefs = SharedPreferencesUtil().sharedPreferences;
//     final token = prefs.getString(SharedPreferencesUtil.SP_KEY_TOKEN);

//     // Cek FCM token
//     final savedFcmToken =
//         prefs.getString(SharedPreferencesUtil.SP_KEY_FCM_TOKEN);
//     if (savedFcmToken == null) {
//       await _setupFCMToken(prefs);
//     }

//     return token;
//   }

//   /// Setup Firebase Cloud Messaging token
//   Future<void> _setupFCMToken(SharedPreferences prefs) async {
//     final messaging = FirebaseMessaging.instance;
//     final fcmToken = await messaging.getToken();
//     if (fcmToken != null) {
//       await prefs.setString(SharedPreferencesUtil.SP_KEY_FCM_TOKEN, fcmToken);
//     }
//   }

//   /// Tampilkan snackbar jika terjadi error
//   void _showErrorSnackbar() {
//     if (!mounted) return;

//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Text('Terjadi kesalahan saat inisialisasi aplikasi'),
//       backgroundColor: Colors.red,
//     ));
//   }

//   /// Navigasi ke screen berikutnya dengan animasi fade out
//   Future<void> _navigateToNextScreen(String? token) async {
//     // Tunggu 2 detik sebelum mulai fade out
//     await Future.delayed(Duration(seconds: 2));

//     if (!mounted) return;

//     // Navigasi berdasarkan status token
//     if (token != null) {
//       Navigator.of(context).pushNamedAndRemoveUntil(
//           PrepareRegisterScreen.ROUTE_NAME, (route) => false);
//     } else {
//       Navigator.of(context)
//           .pushNamedAndRemoveUntil(WelcomeScreen.ROUTE_NAME, (route) => false);
//     }
//   }

//   @override
//   void dispose() {
//     // Kembalikan UI system ke mode normal
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
//         overlays: SystemUiOverlay.values);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: AnnotatedRegion<SystemUiOverlayStyle>(
//         value: const SystemUiOverlayStyle(
//           statusBarColor: Colors.transparent,
//           systemNavigationBarColor: Colors.transparent,
//           statusBarIconBrightness: Brightness.dark,
//           systemNavigationBarIconBrightness: Brightness.dark,
//         ),
//         child: Stack(
//           children: [
//             Container(
//               decoration: const BoxDecoration(
//                 image: DecorationImage(
//                   image: AssetImage("assets/background.png"),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               child: Center(
//                 child: Image.asset(
//                   'assets/logo.png',
//                   width: 130,
//                   height: 130,
//                 ),
//               ),
//             ),
//             // Loading overlay yang muncul ketika _isLoadingOverlay true
//             if (_isLoadingOverlay)
//               Positioned.fill(
//                 child: ModalBarrier(
//                   color: Colors.black.withOpacity(0.5),
//                   dismissible: false, // Hindari interaksi selama loading
//                 ),
//               ),
//             if (_isLoadingOverlay)
//               Center(
//                 child: Container(
//                   padding: EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       CircularProgressIndicator(
//                         valueColor:
//                             AlwaysStoppedAnimation<Color>(Color(0xFF017964)),
//                       ),
//                       SizedBox(height: 16),
//                       Text(
//                         'Mohon tunggu...',
//                         style: TextStyle(
//                           color: Color(0xFF017964),
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

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
