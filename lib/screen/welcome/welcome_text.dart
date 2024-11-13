import 'package:flutter/material.dart';

class WelcomeText extends StatelessWidget {
  final double offsetHeight;
  final String title;
  final String subtitle;
  final String text;

  const WelcomeText({
    Key? key,
    required this.offsetHeight,
    required this.title,
    required this.subtitle,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: offsetHeight),
          Text(
            title,
            style: theme.textTheme.headline5?.copyWith(
              height: 1.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            subtitle,
            style: theme.textTheme.headline5?.copyWith(
              height: 1.0,
              fontWeight: FontWeight.w600,
              color: theme.primaryColor,
            ),
          ),
          SizedBox(height: 16.0),
          Text(
            text,
            style: theme.textTheme.caption?.copyWith(),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
