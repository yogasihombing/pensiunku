import 'package:flutter/material.dart';

class NodataWidget extends StatelessWidget {
  final String titleText;
  final String descriptionText;
  const NodataWidget({Key? key, required this.titleText, required this.descriptionText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 90.0,
        horizontal: 60.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 160,
            child: Image.asset('assets/notification_screen/empty.png'),
          ),
          SizedBox(height: 24.0),
          Text(
            titleText,
            textAlign: TextAlign.center,
            style: theme.textTheme.headline5?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            descriptionText,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyText1?.copyWith(
              color: theme.textTheme.caption?.color,
            ),
          ),
        ],
      ),
    );
  }
}