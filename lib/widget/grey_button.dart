import 'package:flutter/material.dart';

class GreyButton extends StatelessWidget {
  final String title;
  final void Function()? onTap;
  final double borderRadius;
  final Color color;
  final TextStyle? textStyle;

  const GreyButton({
    Key? key,
    required this.title,
    this.onTap,
    this.borderRadius = 4.0,
    this.color = const Color.fromARGB(255, 226, 226, 226),
     this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(borderRadius),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16.0,
          ),
          child: Center(
            child: Text(
              title,
              style: theme.textTheme.bodyText1?.copyWith(
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
