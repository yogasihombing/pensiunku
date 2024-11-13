import 'package:flutter/material.dart';

class CustomTab extends StatelessWidget {
  final String text;
  final bool isActive;
  final VoidCallback onTap;

  const CustomTab({
    Key? key,
    required this.text,
    required this.isActive,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                text,
                style: theme.textTheme.bodyText1?.copyWith(
                  color: isActive ? theme.primaryColor : null,
                ),
              ),
            ),
            Container(
              color: isActive ? theme.primaryColor : Colors.transparent,
              height: 2.0,
            ),
          ],
        ),
      ),
    );
  }
}
