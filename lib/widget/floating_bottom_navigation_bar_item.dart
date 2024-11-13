import 'package:flutter/material.dart';

class FloatingBottomNavigationBarItem extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final String assetNameInactive;
  final String assetNameActive;
  final bool isActive;

  const FloatingBottomNavigationBarItem({
    Key? key,
    required this.onTap,
    required this.text,
    required this.assetNameInactive,
    required this.assetNameActive,
    required this.isActive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    final Size txtSize = _textSize(
      text,
      theme.textTheme.caption?.copyWith(
        color: theme.primaryColor,
        fontWeight: FontWeight.w700,
      ),
    );
    double iconSize = 36.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(36.0),
        child: AnimatedContainer(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36.0),
            color: isActive
                ? theme.primaryColor.withOpacity(0.28)
                : Colors.transparent,
          ),
          duration: Duration(milliseconds: 100),
          height: iconSize + 12.0,
          width: isActive
              ? txtSize.width + iconSize + 16.0 + 16.0
              : iconSize + 16.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 6.0,
            ),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                SizedBox(
                  height: iconSize,
                  width: iconSize,
                  child: Image.asset(
                      isActive ? assetNameActive : assetNameInactive),
                ),
                SizedBox(width: 4.0),
                Center(
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.caption?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Size _textSize(String text, TextStyle? style) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: 1,
        textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }
}
