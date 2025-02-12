// import 'package:camera_camera/camera_camera.dart';
import 'package:flutter/material.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/ktp/camera_ktp_screen.dart';


class CameraKtpNewScreen extends StatelessWidget {
  static const String ROUTE_NAME = '/camera/new';
  @override
  Widget build(BuildContext context) {
    final citizenCardWidth = MediaQuery.of(context).size.height * 0.7;
    final citizenCardHeight = citizenCardWidth * 0.6;
    final validRectangle = Rectangle(
      height: citizenCardWidth,
      width: citizenCardHeight,
      color: Colors.red,
    );

    return Scaffold(
      body: Stack(
        children: [
          Container(
            constraints: const BoxConstraints.expand(),
            child: CustomPaint(
              painter: KtpFramePainter(
                screenSize: Size(validRectangle.width, validRectangle.height),
                outerFrameColor: Color(0x73442C2E),
                closeWindow: false,
                innerFrameColor: Colors.transparent,
                // innerFrameColor: _currentState == AnimationState.endSearch
                //     ? Colors.transparent
                //     : kShrineFrameBrown,
              ),
            ),
          ),
          // CameraCamera(
          //   onFile: (File file) {
          //     print(file.path);
          //   },
          //   enableAudio: false,
          // ),
        ],
      ),
    );
  }
}
