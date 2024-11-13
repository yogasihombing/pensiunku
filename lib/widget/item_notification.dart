import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pensiunku/model/notification_model.dart';

/// Notification item widget
///
class ItemNotification extends StatelessWidget {
  final NotificationModel model;
  final VoidCallback onReadNotification;

  const ItemNotification({
    Key? key,
    required this.model,
    required this.onReadNotification,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return InkWell(
      onTap: () {
        if (!model.isRead) {
          onReadNotification();
        }
        // if (model.url != null) {
        //   Navigator.of(
        //     context,
        //     rootNavigator: true,
        //   ).pushNamed(
        //     WebViewScreen.ROUTE_NAME,
        //     arguments: WebViewScreenArguments(
        //       initialUrl: model.url!,
        //     ),
        //   );
        // }
      },
      child: Container(
        color: !model.isRead ? theme.primaryColor.withOpacity(0.2) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 16.0,
          ),
          child: Row(
            children: [
              SizedBox(
                height: 36.0,
                width: 36.0,
                child: Image.asset('assets/icon/notification_icon_black.png'),
              ),
              SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.title,
                      style: theme.textTheme.subtitle2,
                    ),
                    Text(
                      model.content,
                      style: theme.textTheme.caption?.copyWith(
                        color: theme.textTheme.caption?.color,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      DateFormat('dd-MM-y HH:mm').format(model.createdAt),
                      style: theme.textTheme.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
