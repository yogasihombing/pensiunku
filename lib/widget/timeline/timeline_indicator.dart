import 'package:flutter/material.dart';

class TimelineIndicator extends StatelessWidget {
  final bool isLineBefore;
  final bool isLineAfter;
  final Color color;
  final Color lineBeforeColor;
  final Color lineAfterColor;
  final double lineHeight;

  const TimelineIndicator({
    Key? key,
    this.isLineBefore = true,
    this.isLineAfter = true,
    this.color = Colors.grey,
    this.lineBeforeColor = Colors.grey,
    this.lineAfterColor = Colors.grey,
    this.lineHeight = 30.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 2,
          height: lineHeight,
          decoration: BoxDecoration(
            color: isLineBefore ? lineBeforeColor : Colors.transparent,
          ),
        ),
        Container(
          height: 16,
          width: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 2,
          height: lineHeight,
          decoration: BoxDecoration(
            color: isLineAfter ? lineAfterColor : Colors.transparent,
          ),
        ),
      ],
    );
  }
}
