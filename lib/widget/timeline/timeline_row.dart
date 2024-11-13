import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pensiunku/widget/timeline/timeline_indicator.dart';

class TimelineRow extends StatelessWidget {
  final DateTime timestamp;
  final String text;
  final Color color;
  final bool isFirst;
  final bool isLast;
  final double lineHeight;

  const TimelineRow({
    Key? key,
    required this.timestamp,
    required this.text,
    this.color = Colors.grey,
    this.isFirst = false,
    this.isLast = false,
    this.lineHeight = 30.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('dd MMM').format(timestamp),
                style: theme.textTheme.caption,
              ),
              Text(
                DateFormat('HH:mm').format(timestamp),
                style: theme.textTheme.caption,
              ),
            ],
          ),
          SizedBox(width: 24.0),
          TimelineIndicator(
            isLineBefore: !isFirst,
            isLineAfter: !isLast,
            color: color,
            lineHeight: lineHeight,
            lineBeforeColor: color,
            lineAfterColor: color,
          ),
          SizedBox(width: 24.0),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: lineHeight),
                Container(
                  height: lineHeight + 16.0,
                  child: Text(
                    text,
                    style: theme.textTheme.caption?.copyWith(
                      color: color,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
