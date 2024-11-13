import 'package:flutter/material.dart';

class ErrorCard extends StatelessWidget {
  final String title;
  final IconData iconData;
  final String? subtitle;

  const ErrorCard({
    Key? key,
    required this.title,
    required this.iconData,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              iconData,
              color: theme.errorColor,
              size: 60,
            ),
            SizedBox(height: 16.0),
            Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
              ),
            ),
            if (subtitle != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 8.0),
                  Center(
                    child: Text(
                      subtitle!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.caption,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
