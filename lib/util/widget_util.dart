import 'package:flutter/material.dart';
import 'package:pensiunku/screen/notification/notification_screen.dart';
import 'package:pensiunku/widget/notification_icon.dart';

class WidgetUtil {
  static void showSnackbar(
    BuildContext context,
    String message, {
    SnackBarAction? snackbarAction,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        // behavior: SnackBarBehavior.floating,
        // margin: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 100.0),
        action: snackbarAction,
      ),
    );
  }

  static BottomNavigationBarItem getCustomBottomNavigationBarItem({
    required String title,
    required String icon,
    required String iconActive,
    bool isActive = false,
  }) {
    return BottomNavigationBarItem(
      label: title,
      icon: SizedBox(
        height: 36.0,
        child: Image.asset(isActive ? iconActive : icon),
      ),
    );
  }

  static AppBar getNewAppBar(
    BuildContext context,
    String titleText,
    int currentIndex,
    void Function(int index) onChangeBottomNavIndex,
    VoidCallback onPressedBack, {
    bool useNotificationIcon = true,
  }) {
    ThemeData theme = Theme.of(context);

    return AppBar(
      elevation: 0.0,
      leading: IconButton(
        onPressed: onPressedBack,
        icon: Icon(Icons.arrow_back_ios),
      ),
      title: Text(
        titleText,
        style: theme.textTheme.headline6?.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      actions: [
        if (useNotificationIcon)
          IconButton(
            tooltip: 'Notifikasi',
            onPressed: () {
              Navigator.of(context)
                  .pushNamed(
                NotificationScreen.ROUTE_NAME,
                arguments: NotificationScreenArguments(
                  currentIndex: currentIndex,
                ),
              )
                  .then((newIndex) {
                if (newIndex is int) {
                  onChangeBottomNavIndex(newIndex);
                }
              });
            },
            icon: NotificationCounter(),
          ),
      ],
    );
  }
}
