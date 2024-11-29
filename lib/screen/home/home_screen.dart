import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pensiunku/data/api/riwayat_ajukan_api.dart';
import 'package:pensiunku/model/monitoring_pengajuan_model.dart';
import 'package:pensiunku/model/submission_model.dart';
import 'package:pensiunku/repository/monitoring_repository.dart';
import 'package:pensiunku/repository/user_repository.dart';
import 'package:pensiunku/screen/home/account/account_screen.dart';
import 'package:pensiunku/screen/home/dashboard/dashboard_screen.dart';
import 'package:pensiunku/screen/home/dashboard/usaha_screen.dart';
import 'package:pensiunku/screen/home/submission/riwayat_pengajuan.dart';
import 'package:pensiunku/screen/home/test.dart';
import 'package:pensiunku/screen/home/update_dialog.dart';
import 'package:pensiunku/screen/notification/notification_screen.dart';
import 'package:pensiunku/screen/web_view/web_view_screen.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:pensiunku/widget/floating_bottom_navigation_bar.dart';
import 'package:new_version/new_version.dart';

/// Home Screen
///
/// This screen is the main screen of the app.
///
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
    setState(() {
      _currentIndex = 1;
      _controller.index = 1;
      _showApplySubmissionScreen = true;
    });
  }

  _handleApplySubmissionBack() {
    setState(() {
      _showApplySubmissionScreen = false;
    });
  }

  @override
  void initState() {
    final newVersion = NewVersion(androidId: 'com.kreditpensiun');

    Timer(const Duration(milliseconds: 800), () {
      checkNewVersion(newVersion);
    });

    super.initState();

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
        ?.createNotificationChannel(channel);

    flutterLocalNotificationsPluginOthers
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel_others);

    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true);

    //On Terminated
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        dynamic data = jsonDecode(message.data["data"]);
        String finalRoute = data["route"];
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

    //Backgroung App
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (message.data.isNotEmpty) {
        dynamic data = jsonDecode(message.data["data"]);
        String finalRoute = data["route"];
        print(finalRoute);
        print(message.notification!.body);
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

    //Foreground App
    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      // If `onMessage` is triggered with a notification, construct our own
      // local notification to show to users using the created channel.
      if (notification != null && android != null) {
        if (channel.id == 'birthday') {
          flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification.title,
              notification.body,
              NotificationDetails(
                android: AndroidNotificationDetails(channel.id, channel.name,
                    playSound: true,
                    sound: RawResourceAndroidNotificationSound('happy_birthday')
                    // other properties...
                    ),
              ));
        } else if (channel_others.id == 'another_notification') {
          flutterLocalNotificationsPluginOthers.show(
              notification.hashCode,
              notification.title,
              notification.body,
              NotificationDetails(
                android: AndroidNotificationDetails(
                    channel_others.id, channel_others.name
                    // other properties...
                    ),
              ));
        }
      }
    });

    _controller = CupertinoTabController();
    Future.delayed(Duration(seconds: 0), () {
      setState(() {
        _isBottomNavBarVisible = true;
      });
    });
    Future.delayed(Duration(seconds: 1), () {
      bool? isFinishedWalkththrough = SharedPreferencesUtil()
          .sharedPreferences
          .getBool(SharedPreferencesUtil.SP_KEY_IS_FINISHED_WALKTHROUGH);
      if (isFinishedWalkththrough != true) {
        setState(() {
          _walkthroughIndex = 0;
        });
      }
    });

    // Save FCM token
    _saveFcmToken();
    // Listen on new FCM token
    _onFcmTokenRefresh();
  }

  void checkNewVersion(NewVersion newVersion) async {
    final status = await newVersion.getVersionStatus();
    if (status != null) {
      if (status.canUpdate) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return UpdateDialog(
              allowDismissal: false,
              description: status.releaseNotes!,
              version: status.storeVersion,
              appLink: status.appStoreLink,
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // bool isWalkthroughStep2 = _walkthroughIndex == 2;
    // bool isWalkthroughStep3 = _walkthroughIndex == 3;

    return Scaffold(
      body: Stack(
        children: [
          _buildBody(),
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
          FloatingBottomNavigationBar(
            isVisible: _isBottomNavBarVisible,
            currentIndex: _currentIndex,
            onTapItem: (newIndex) {
              setState(() {
                _currentIndex = newIndex;
              });
            },
          ),
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
            setState(() {
              _currentIndex = newIndex;
            });
          },
          walkthroughIndex: _walkthroughIndex,
          scrollController: _dashboardScrollController,
        );
      case 1:
        return RiwayatPengajuanPage(
          onChangeBottomNavIndex: (newIndex) {
            setState(() {
              _currentIndex = newIndex;
            });
          },
        );

      default:
        return AccountScreen(
          onChangeBottomNavIndex: (newIndex) {
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

    if (fcmToken != null) {
      UserRepository().saveFcmToken(token!, fcmToken).then((value) {
        return value;
      });
    }
  }

  _onFcmTokenRefresh() {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    messaging.onTokenRefresh.listen((newFcmToken) {
      SharedPreferencesUtil()
          .sharedPreferences
          .setString(SharedPreferencesUtil.SP_KEY_FCM_TOKEN, newFcmToken);
      _saveFcmToken();
    });
  }
}
