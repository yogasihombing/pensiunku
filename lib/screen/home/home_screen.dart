import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pensiunku/model/monitoring_pengajuan_model.dart';
import 'package:pensiunku/model/submission_model.dart';
import 'package:pensiunku/repository/user_repository.dart';
import 'package:pensiunku/screen/home/account/account_screen.dart';
import 'package:pensiunku/screen/home/dashboard/dashboard_screen.dart';
import 'package:pensiunku/screen/home/dashboard/poster/poster_dialog.dart';
import 'package:pensiunku/screen/home/dashboard/usaha/usaha_screen.dart';
import 'package:pensiunku/screen/home/submission/riwayat_pengajuan_orang_lain.dart';
import 'package:pensiunku/screen/home/update_dialog.dart';
import 'package:pensiunku/screen/notification/notification_screen.dart';
import 'package:pensiunku/screen/web_view/web_view_screen.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:pensiunku/widget/floating_bottom_navigation_bar.dart';
import 'package:new_version/new_version.dart';

class HomeScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/home';

  HomeScreen({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late CupertinoTabController _controller;
  int _currentIndex = 0;
  bool _showApplySubmissionScreen = false;
  bool _isBottomNavBarVisible = false;
  late SubmissionModel submissionModel;
  late MonitoringPengajuanModel monitoringModel;

  ScrollController _dashboardScrollController = new ScrollController();
  int? _walkthroughIndex;

  _handleApplySubmission(_) {
    print('Home Screen: Menangani pengajuan aplikasi, navigasi ke indeks 1.');
    setState(() {
      _currentIndex = 1;
      _controller.index = 1;
      _showApplySubmissionScreen = true;
    });
  }

  _handleApplySubmissionBack() {
    print(
        'Home Screen: Menangani kembali pengajuan aplikasi, mengatur _showApplySubmissionScreen ke false.');
    setState(() {
      _showApplySubmissionScreen = false;
    });
  }

  @override
  void initState() {
    super.initState();
    print('Home Screen: initState dipanggil.');

    final newVersion = NewVersion(androidId: 'com.pensiunku');

    Timer(const Duration(milliseconds: 800), () {
      print('Home Screen: Memeriksa versi baru setelah penundaan 800ms.');
      checkNewVersion(newVersion);
    });

    // TAMBAHKAN INI: Tampilkan poster dialog setelah delay
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        print('Home Screen: Menampilkan poster dialog...');
        PosterDialog.show(context);
      }
    });

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'birthday', // id
        'Birthday Notifications', // title
        description:
            'This channel is used for birthday notifications.', // description
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('happy_birthday'));

    const AndroidNotificationChannel channel_others =
        AndroidNotificationChannel(
      'another_notification', // id
      'Notifications', // title
      description: 'This channel is used for notifications.', // description
      importance: Importance.max,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    final FlutterLocalNotificationsPlugin
        flutterLocalNotificationsPluginOthers =
        FlutterLocalNotificationsPlugin();

    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel)
        .then((_) {
      print('Home Screen: Saluran notifikasi dibuat: ${channel.id}');
    });

    flutterLocalNotificationsPluginOthers
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel_others)
        .then((_) {
      print('Home Screen: Saluran notifikasi dibuat: ${channel_others.id}');
    });

    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true);

    print(
        'Home Screen: Opsi presentasi notifikasi latar depan FirebaseMessaging diatur.');

    // Ketika aplikasi diluncurkan dari keadaan terminate (ditutup sepenuhnya) melalui notifikasi
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        print(
            'Home Screen: Aplikasi diluncurkan dari keadaan terminated melalui notifikasi.');
        print('Data Pesan Awal: ${message.data}');
        dynamic data = jsonDecode(message.data["data"]);
        String finalRoute = data["route"];
        print('Rute Pesan Awal: $finalRoute');
        if (finalRoute == "birthday" ||
            finalRoute == "big_day" ||
            finalRoute == "others") {
          Navigator.of(context).pushNamed(
            NotificationScreen.ROUTE_NAME,
            arguments: NotificationScreenArguments(
              currentIndex: 0,
            ),
          );
        } else if (finalRoute == "usaha") {
          Navigator.of(context).pushNamed(
            UsahaScreen.ROUTE_NAME,
          );
        } else if (finalRoute == "article") {
          String url = data["url"];
          Navigator.of(
            context,
            rootNavigator: true,
          ).pushNamed(
            WebViewScreen.ROUTE_NAME,
            arguments: WebViewScreenArguments(
              initialUrl: url,
            ),
          );
        }
      } else {
        print('Home Screen: Aplikasi diluncurkan tanpa pesan awal.');
      }
    });

    // Ketika aplikasi dibuka dari latar belakang melalui notifikasi
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (message.data.isNotEmpty) {
        print(
            'Home Screen: Aplikasi dibuka dari latar belakang melalui notifikasi.');
        print('Data Pesan yang Dibuka: ${message.data}');
        dynamic data = jsonDecode(message.data["data"]);
        String finalRoute = data["route"];
        print(finalRoute); // Log asli dari kode Anda
        print(message.notification!.body); // Log asli dari kode Anda
        print('Rute Pesan yang Dibuka: $finalRoute');
        print(
            'Isi Notifikasi Pesan yang Dibuka: ${message.notification?.body}');
        if (finalRoute == "birthday" ||
            finalRoute == "big_day" ||
            finalRoute == "others") {
          Navigator.of(context).pushNamed(
            NotificationScreen.ROUTE_NAME,
            arguments: NotificationScreenArguments(
              currentIndex: 0,
            ),
          );
        } else if (finalRoute == "usaha") {
          Navigator.of(context).pushNamed(
            UsahaScreen.ROUTE_NAME,
          );
        } else if (finalRoute == "article") {
          String url = data["url"];
          Navigator.of(
            context,
            rootNavigator: true,
          ).pushNamed(
            WebViewScreen.ROUTE_NAME,
            arguments: WebViewScreenArguments(
              initialUrl: url,
            ),
          );
        }
      }
    });

    // Ketika aplikasi berada di latar depan dan menerima notifikasi
    FirebaseMessaging.onMessage.listen((message) {
      print('Home Screen: Menerima pesan di latar depan.');
      print('Data Pesan Latar Depan: ${message.data}');
      print(
          'Judul Notifikasi Pesan Latar Depan: ${message.notification?.title}');
      print('Isi Notifikasi Pesan Latar Depan: ${message.notification?.body}');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      // Jika `onMessage` dipicu dengan notifikasi, buat notifikasi lokal kita sendiri
      if (notification != null && android != null) {
        print('Home Screen: Menampilkan notifikasi lokal.');
        if (channel.id == 'birthday') {
          flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification.title,
              notification.body,
              NotificationDetails(
                android: AndroidNotificationDetails(channel.id, channel.name,
                    playSound: true,
                    sound:
                        RawResourceAndroidNotificationSound('happy_birthday')),
              ));
        } else if (channel_others.id == 'another_notification') {
          flutterLocalNotificationsPluginOthers.show(
              notification.hashCode,
              notification.title,
              notification.body,
              NotificationDetails(
                android: AndroidNotificationDetails(
                    channel_others.id, channel_others.name),
              ));
        }
      }
    });

    _controller = CupertinoTabController();
    Future.delayed(Duration(seconds: 0), () {
      setState(() {
        _isBottomNavBarVisible = true;
      });
      print('Home Screen: Bilah navigasi bawah diatur menjadi terlihat.');
    });
    Future.delayed(Duration(seconds: 1), () {
      bool? isFinishedWalkththrough = SharedPreferencesUtil()
          .sharedPreferences
          .getBool(SharedPreferencesUtil.SP_KEY_IS_FINISHED_WALKTHROUGH);
      if (isFinishedWalkththrough != true) {
        setState(() {
          _walkthroughIndex = 0;
        });
        print(
            'Home Screen: Walkthrough dimulai, _walkthroughIndex diatur ke 0.');
      } else {
        print('Home Screen: Walkthrough sudah selesai.');
      }
    });

    // Simpan token FCM
    _saveFcmToken();
    // Dengarkan pembaruan token FCM
    _onFcmTokenRefresh();
  }

  void checkNewVersion(NewVersion newVersion) async {
    print('Home Screen: checkNewVersion dipanggil.');
    try {
      final status = await newVersion.getVersionStatus();
      if (status != null) {
        // Log status umum versi
        print(
            'Home Screen: Status versi diterima - Lokal: ${status.localVersion}, Toko: ${status.storeVersion}, Bisa Update: ${status.canUpdate}');

        // Siapkan string deskripsi yang aman
        String releaseNotesDescription = 'Tidak ada catatan rilis tersedia.';
        if (status.releaseNotes != null && status.releaseNotes!.isNotEmpty) {
          releaseNotesDescription = status.releaseNotes!;
          print('Home Screen: Catatan rilis ditemukan dan akan digunakan.');
        } else {
          print('Home Screen: Catatan rilis kosong atau null.');
        }

        if (status.canUpdate) {
          print(
              'Home Screen: Versi baru tersedia, menampilkan dialog pembaruan.');
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return UpdateDialog(
                allowDismissal: false,
                // Gunakan releaseNotesDescription yang sudah dipersiapkan
                description: releaseNotesDescription,
                version: status.storeVersion,
                appLink: status.appStoreLink,
              );
            },
          );
        } else {
          print('Home Screen: Tidak ada versi baru yang tersedia.');
        }
      } else {
        print(
            'Home Screen: Status versi null, tidak dapat memeriksa versi baru.');
      }
    } catch (e) {
      // Log error, akan selalu muncul di konsol
      print('Home Screen: Error memeriksa versi baru: $e');
      // Penting: Di sini Anda bisa mempertimbangkan untuk menampilkan pesan error di UI
      // kepada pengguna, misalnya dengan SnackBar atau custom dialog,
      // agar mereka tahu bahwa ada masalah saat memeriksa pembaruan.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBody(),
          FloatingBottomNavigationBar(
            isVisible: _isBottomNavBarVisible,
            currentIndex: _currentIndex,
            onTapItem: (newIndex) {
              print(
                  'Home Screen: Item nav bawah diketuk, mengubah indeks dari $_currentIndex ke $newIndex.');
              setState(() {
                _currentIndex = newIndex;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return DashboardScreen(
          onApplySubmission: _handleApplySubmission,
          onChangeBottomNavIndex: (newIndex) {
            print(
                'Home Screen: Dashboard meminta perubahan indeks nav bawah ke $newIndex.');
            setState(() {
              _currentIndex = newIndex;
            });
          },
          scrollController: _dashboardScrollController,
        );
      case 1:
        return RiwayatPengajuanOrangLainScreen(
          onChangeBottomNavIndex: (newIndex) {
            print(
                'Home Screen: Riwayat Pengajuan meminta perubahan indeks nav bawah ke $newIndex.');
            setState(() {
              _currentIndex = newIndex;
            });
          },
        );

      default:
        return AccountScreen(
          onChangeBottomNavIndex: (newIndex) {
            print(
                'Home Screen: Akun meminta perubahan indeks nav bawah ke $newIndex.');
            setState(() {
              _currentIndex = newIndex;
            });
          },
        );
    }
  }

  void _saveFcmToken() {
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);
    String? fcmToken = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_FCM_TOKEN);

    print('Home Screen: Mencoba menyimpan token FCM.');
    print(
        'Home Screen: Token pengguna diambil: ${token != null ? "ada" : "null"}');
    print(
        'Home Screen: Token FCM diambil: ${fcmToken != null ? "ada" : "null"}');

    if (fcmToken != null && token != null) {
      UserRepository().saveFcmToken(token, fcmToken).then((value) {
        print(
            'Home Screen: Panggilan API penyimpanan token FCM selesai. Nilai: $value');
        return value;
      }).catchError((e) {
        print('Home Screen: Error menyimpan token FCM: $e');
      });
    } else {
      print(
          'Home Screen: Token FCM tidak disimpan, token pengguna atau token FCM null.');
    }
  }

  _onFcmTokenRefresh() {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    messaging.onTokenRefresh.listen((newFcmToken) {
      print('Home Screen: Token FCM diperbarui. Token baru: $newFcmToken');
      SharedPreferencesUtil()
          .sharedPreferences
          .setString(SharedPreferencesUtil.SP_KEY_FCM_TOKEN, newFcmToken)
          .then((success) {
        print(
            'Home Screen: Token FCM disimpan ke Shared Preferences: $success');
      }).catchError((e) {
        print(
            'Home Screen: Error menyimpan token FCM baru ke Shared Preferences: $e');
      });
      _saveFcmToken(); // Panggil untuk menyimpan token baru ke backend
    });
    print('Home Screen: Listener pembaruan token FCM terdaftar.');
  }
}

// live chat dinonaktifkan
          // Positioned(
          //   bottom: 100,
          //   right: 20,
          //   child: GestureDetector(
          //     onTap: () {
          //       Navigator.push(context,
          //           MaterialPageRoute(builder: (context) => LiveChat()));
          //     },
          //     child: Image.asset(
          //       'assets/icon/live_chat.png',
          //       width: 60,
          //       height: 60,
          //     ),
          //   ),
          // ),
          // live chat dinonaktifkan
          // if (_walkthroughIndex != null)
          //   GestureDetector(
          //     onTap: () {
          //       if (_walkthroughIndex == 0) {
          //         _dashboardScrollController.animateTo(
          //           (67 + 12) * 6, // the average height of the simulation form
          //           duration: Duration(seconds: 1),
          //           curve: Curves.easeIn,
          //         );
          //         Future.delayed(Duration(seconds: 1), () {
          //           setState(() {
          //             _walkthroughIndex = _walkthroughIndex! + 1;
          //           });
          //         });
          //       } else if (_walkthroughIndex == 3) {
          //         SharedPreferencesUtil().sharedPreferences.setBool(
          //               SharedPreferencesUtil.SP_KEY_IS_FINISHED_WALKTHROUGH,
          //               true,
          //             );
          //         setState(() {
          //           _walkthroughIndex = null;
          //         });
          //         _dashboardScrollController.animateTo(
          //           0,
          //           duration: Duration(seconds: 1),
          //           curve: Curves.easeIn,
          //         );
          //         // Restart.restartApp(webOrigin: '[your main route]');
          //       } else {
          //         setState(() {
          //           _walkthroughIndex = _walkthroughIndex! + 1;
          //         });
          //       }
          //     },
          //     child: Container(
          //       color: Colors.transparent,
          //     ),
          //   ),

          // if (_walkthroughIndex != null)
          //   AnimatedContainer(
          //     color: isWalkthroughStep2 || isWalkthroughStep3
          //         ? Colors.black.withOpacity(0.35)
          //         : Colors.transparent,
          //     duration: Duration(milliseconds: 300),
          //   ),
          // if (_walkthroughIndex != null)
          //   FloatingTooltip(
          //     text: 'Menu aplikasi untuk melihat pilihan produk',
          //     width: 200,
          //     isVisible: isWalkthroughStep2,
          //     bottom: 86.0,
          //     left: MediaQuery.of(context).size.width * 0.24,
          //   ),
          // if (_walkthroughIndex != null)
          //   FloatingTooltip(
          //     text: 'Pantau proses pengajuan anda kapan saja',
          //     width: 180,
          //     isVisible: isWalkthroughStep3,
          //     bottom: 86.0,
          //     right: 48.0,
          //   ),