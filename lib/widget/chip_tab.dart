import 'package:flutter/material.dart';

class ChipTab extends StatelessWidget {
  final String text;
  final bool isActive;
  final VoidCallback onTap;
  final bool custom;
  final Color? backgroundColor; //

  const ChipTab({
    Key? key,
    required this.text,
    required this.isActive,
    required this.onTap,
    this.custom = false,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    // Jika backgroundColor diberikan, gunakan. Jika tidak, gunakan default.
    Color bgColor = backgroundColor ??
        (isActive
            ? custom
                ? Color.fromRGBO(0, 170, 158, 1.0)
                : Color(0xffb90d49)
            : Color.fromRGBO(247, 247, 247, 1.0));
    Color borderColor = isActive
        ? Color.fromRGBO(168, 168, 168, 1.0)
        : Color.fromRGBO(168, 168, 168, 1.0);
    Color textColor =
        isActive ? Colors.white : Color.fromRGBO(168, 168, 168, 1.0);

    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(
            color: borderColor,
            width: 1.5,
          ),
        ),
        duration: Duration(milliseconds: 300),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 4.0,
          ),
          child: Text(
            text,
            style: theme.textTheme.bodyText1?.copyWith(),
          ),
        ),
      ),
    );
  }
}
