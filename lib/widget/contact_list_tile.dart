import 'package:flutter/material.dart';

class ContactListTile extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final String subtitle;
  final Widget leading;

  const ContactListTile({
    Key? key,
    required this.onTap,
    required this.title,
    required this.subtitle,
    required this.leading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(36.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.primaryColor,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(36.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 16.0,
          ),
          child: Row(
            children: [
              leading,
              SizedBox(width: 24.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.subtitle1,
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.caption,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
