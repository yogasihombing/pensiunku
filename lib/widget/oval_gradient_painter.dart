import 'package:flutter/material.dart';

class OvalGradientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Offset circleOffset = Offset(
      size.width / 2,
      0.0,
    );
    double height = size.height * 2;
    double width = height * 0.9;
    Rect rect =
        Rect.fromCenter(center: circleOffset, width: width, height: height);
    var paint1 = Paint()
      ..shader = LinearGradient(
        colors: [
          Color.fromARGB(255, 255, 221, 123),
          Color.fromARGB(255, 31, 157, 159),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [
          0.5,
          1.0,
        ],
      ).createShader(rect);
    canvas.drawOval(
      rect,
      paint1,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
