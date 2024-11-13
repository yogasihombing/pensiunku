import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';

class NotificationCounter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    int? notificationCounter = SharedPreferencesUtil()
        .sharedPreferences
        .getInt(SharedPreferencesUtil.SP_KEY_NOTIFICATION_COUNTER);

    Widget? icon;
    if (notificationCounter != null) {
      if (notificationCounter > 0) {
        icon = Badge(
          badgeContent: Text(
            '$notificationCounter',
            style: theme.textTheme.bodyText1?.copyWith(
              color: Colors.white,
            ),
          ),
          position: BadgePosition.topEnd(
            top: -4,
            end: -4,
          ),
          child: SizedBox(
            height: 36.0,
            child: Image.asset('assets/icon/notification_icon.png'),
          ),
        );
      }
    }
    if (icon == null) {
      icon = SizedBox(
        height: 36.0,
        child: Image.asset('assets/icon/notification_icon.png'),
      );
    }
    return icon;
  }
}
