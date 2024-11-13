import 'package:flutter/material.dart';
import 'package:pensiunku/widget/triangle_painter.dart';

class FloatingTooltip extends StatelessWidget {
  final String text;
  final bool isVisible;
  final Duration duration;
  final double width;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  const FloatingTooltip({
    Key? key,
    required this.text,
    required this.isVisible,
    this.width = 150,
    this.bottom,
    this.top,
    this.left,
    this.right,
    this.duration = const Duration(milliseconds: 200),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    double? finalBottom;
    if (bottom != null) {
      finalBottom = isVisible ? bottom : bottom! - 8.0;
    }
    double? finalTop;
    if (top != null) {
      finalTop = isVisible ? top : top! + 8.0;
    }

    return AnimatedPositioned(
      top: finalTop,
      bottom: finalBottom,
      left: left,
      right: right,
      duration: duration,
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: duration,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              width: width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                text,
                style: theme.textTheme.caption?.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            CustomPaint(
              painter: TrianglePainter(
                strokeColor: Colors.white,
                strokeWidth: 10,
                paintingStyle: PaintingStyle.fill,
              ),
              child: Container(
                height: 20,
                width: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
