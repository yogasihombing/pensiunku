import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pensiunku/data/db/app_database.dart';
import 'package:pensiunku/main.dart';
import 'package:pensiunku/screen/notification/notification_screen.dart';
import 'package:pensiunku/screen/register/prepare_register_screen.dart';
import 'package:pensiunku/screen/welcome/welcome_screen.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InitScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/';

  @override
  _InitScreenState createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen>
    with SingleTickerProviderStateMixin {
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

  void _handleNotificationNavigation(RemoteMessage message) {
    // Pastikan widget masih mounted sebelum mencoba navigasi
    if (!mounted) {
      print("Widget tidak mounted, tidak bisa navigasi.");
      return;
    }

    final data = message.data;
    print("Menangani navigasi dengan data: $data");

    // Contoh logic navigasi:
    // Anda harus menyesuaikan ini dengan struktur data notifikasi Anda
    if (data.containsKey('screen')) {
      String targetScreen = data['screen'];
      switch (targetScreen) {
        case 'notification_screen':
          // Pastikan Anda memiliki argument yang sesuai jika NotificationScreen membutuhkannya
          // Misal: final currentIndex = int.tryParse(data['currentIndex'] ?? '0');
          // Navigator.of(context).pushNamed(
          //   NotificationScreen.ROUTE_NAME,
          //   arguments: NotificationScreenArguments(currentIndex: currentIndex ?? 0),
          // );
          // Untuk contoh ini, kita navigasi ke NotificationScreen tanpa argumen spesifik
          Navigator.of(context).pushNamed(NotificationScreen.ROUTE_NAME);
          break;
        case 'home_screen':
          // Contoh navigasi ke Home Screen
          // Navigator.of(context).pushNamed(HomeScreen.ROUTE_NAME);
          break;
        // Tambahkan case lain sesuai kebutuhan aplikasi Anda
        default:
          print('Target screen tidak dikenal: $targetScreen');
          break;
      }
    } else if (data.containsKey('url')) {
      // Contoh: Buka URL jika notifikasi berisi URL
      // import 'package:url_launcher/url_launcher.dart';
      // String url = data['url'];
      // launchUrl(Uri.parse(url));
      print('Notifikasi memiliki URL, bisa dibuka: ${data['url']}');
    }
    // Tambahkan logic lain berdasarkan struktur data Anda
  }

  @override
  void dispose() {
    _logoAnimationController.dispose(); // Hentikan animasi saat dispose
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
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
    final savedFcmToken =
        prefs.getString(SharedPreferencesUtil.SP_KEY_FCM_TOKEN);
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
      // --- Lakukan panggilan API ke backend Anda di sini ---
      // Contoh (pseudocode):
      // await YourApiService.sendFcmTokenToBackend(fcmToken, userId);

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
      Navigator.of(context).pushNamedAndRemoveUntil(
          PrepareRegisterScreen.ROUTE_NAME, (route) => false);
    } else {
      // Jika tidak ada token, navigasi ke WelcomeScreen (halaman default)
      Navigator.of(context)
          .pushNamedAndRemoveUntil(WelcomeScreen.ROUTE_NAME, (route) => false);
    }
  }

  /// Fungsi untuk setup Firebase Messaging (Push Notifikasi)
  /// Fungsi untuk setup Firebase Messaging (Push Notifikasi)
  Future<void> _setupFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // 1. Meminta Izin Notifikasi dari pengguna
    // Ini juga akan meminta izin untuk flutter_local_notifications di iOS
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

      // Tampilkan notifikasi visual menggunakan flutter_local_notifications
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode, // Gunakan hashCode notifikasi sebagai ID unik
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id, // Gunakan ID channel yang sudah kita buat
              channel.name,
              channelDescription: channel.description,
              icon:
                  '@mipmap/ic_launcher', // Pastikan icon ini ada di folder Android Anda
            ),
          ),
          // Tambahkan payload jika Anda ingin data dari notifikasi FCM diteruskan ke notifikasi lokal
          payload: message.data
              .toString(), // Atau JSON.encode(message.data) jika data kompleks
        );
      }
    });

    // 3. Menangani saat notifikasi ditekan (saat aplikasi di background/terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Event onMessageOpenedApp dipublikasikan!');
      print('Data pesan: ${message.data}');
      // Panggil fungsi penanganan navigasi di sini
      _handleNotificationNavigation(message);
    });

    // 4. Menangani saat aplikasi dibuka dari keadaan terminated oleh notifikasi
    RemoteMessage? initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      print(
          'Aplikasi dibuka dari keadaan terminated oleh notifikasi: ${initialMessage.data}');
      // Panggil fungsi penanganan navigasi di sini
      _handleNotificationNavigation(initialMessage);
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
