import 'package:flutter/material.dart';
import 'package:pensiunku/model/notification_model.dart';
import 'package:pensiunku/repository/notification_repository.dart';
import 'package:pensiunku/repository/result_model.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:pensiunku/util/widget_util.dart';
import 'package:pensiunku/widget/error_card.dart';
import 'package:pensiunku/widget/floating_bottom_navigation_bar.dart';
import 'package:pensiunku/widget/item_notification.dart';

class NotificationScreenArguments {
  final int currentIndex;

  NotificationScreenArguments({
    required this.currentIndex,
  });
}

/// Notification Screen
///
/// This screen lists user's notifications.
///
class NotificationScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/notification';

  final int currentIndex;

  const NotificationScreen({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _isBottomNavBarVisible = false;
  late Future<ResultModel<List<NotificationModel>>> _futureData;

  @override
  void initState() {
    super.initState();

    _refreshData();
    Future.delayed(Duration(milliseconds: 0), () {
      setState(() {
        _isBottomNavBarVisible = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: WidgetUtil.getNewAppBar(
        context,
        'Notifikasi',
        0,
        (_) {},
        () {
          Navigator.of(context).pop();
        },
        useNotificationIcon: false,
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () {
              return _refreshData();
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height -
                        AppBar().preferredSize.height * 1.5,
                  ),
                  FutureBuilder(
                    future: _futureData,
                    builder: (BuildContext context,
                        AsyncSnapshot<ResultModel<List<NotificationModel>>>
                            snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data?.data != null) {
                          List<NotificationModel> data = snapshot.data!.data!;
                          if (data.isEmpty) {
                            return Container(
                              height: MediaQuery.of(context).size.height -
                                  AppBar().preferredSize.height * 2,
                              child: Center(
                                child: SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 90.0,
                                      horizontal: 60.0,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 160,
                                          child: Image.asset(
                                              'assets/notification_screen/empty.png'),
                                        ),
                                        SizedBox(height: 24.0),
                                        Text(
                                          'Tidak ada notifikasi',
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.headline5
                                              ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: 8.0),
                                        Text(
                                          'Jika anda menerima notifikasi, mereka akan muncul disini',
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.bodyText1
                                              ?.copyWith(
                                            color:
                                                theme.textTheme.caption?.color,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return Column(
                              children: [
                                ...data.map(
                                  (notification) => ItemNotification(
                                    model: notification,
                                    onReadNotification: () {
                                      _markNotificationAsRead(notification);
                                    },
                                  ),
                                ),
                                SizedBox(height: 90.0),
                              ],
                            );
                          }
                        } else {
                          String errorTitle =
                              'Tidak dapat menampilkan notifikasi';
                          String? errorSubtitle = snapshot.data?.error;
                          return Column(
                            children: [
                              SizedBox(height: 16),
                              ErrorCard(
                                title: errorTitle,
                                subtitle: errorSubtitle,
                                iconData: Icons.warning_rounded,
                              ),
                            ],
                          );
                        }
                      } else {
                        return Column(
                          children: [
                            SizedBox(height: 16),
                            Center(
                              child: CircularProgressIndicator(
                                color: theme.primaryColor,
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          // FloatingBottomNavigationBar(
          //   isVisible: _isBottomNavBarVisible,
          //   currentIndex: widget.currentIndex,
          //   onTapItem: (newIndex) {
          //     Navigator.of(context).pop(newIndex);
          //   },
          // ),
        ],
      ),
    );
  }

  _refreshData() {
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    return _futureData = NotificationRepository().getAll(token!).then((value) {
      if (value.error != null) {
        WidgetUtil.showSnackbar(
          context,
          value.error.toString(),
        );
      }
      setState(() {});
      return value;
    });
  }

  void _markNotificationAsRead(NotificationModel notification) {
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    NotificationRepository()
        .readNotification(token!, notification.id)
        .then((value) {
      _refreshData();
      return value;
    });
  }
}
