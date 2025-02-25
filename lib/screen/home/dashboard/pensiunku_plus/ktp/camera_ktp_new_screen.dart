// import 'package:camera_camera/camera_camera.dart';
import 'package:flutter/material.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/ktp/camera_ktp_screen.dart';


// Pastikan class Rectangle dan KtpFramePainter sudah didefinisikan atau diimpor dengan benar
// Contoh sederhana untuk Rectangle (jika belum ada)
class Rectangle {
  final double width;
  final double height;
  final Color color;

  Rectangle({required this.width, required this.height, required this.color});
}

class CameraKtpNewScreen extends StatelessWidget {
  static const String ROUTE_NAME = '/camera/new';

  @override
  Widget build(BuildContext context) {
    // Menghitung ukuran berdasarkan tinggi layar
    final screenHeight = MediaQuery.of(context).size.height;
    final citizenCardWidth = screenHeight * 0.7;
    final citizenCardHeight = citizenCardWidth * 0.6;

    // Pastikan width dan height sudah sesuai
    final validRectangle = Rectangle(
      width: citizenCardWidth,
      height: citizenCardHeight,
      color: Colors.red,
    );

    return Scaffold(
      body: Stack(
        children: [
          // Background dengan custom painter
          Container(
            constraints: const BoxConstraints.expand(),
            child: CustomPaint(
              painter: KtpFramePainter(
                screenSize: Size(validRectangle.width, validRectangle.height),
                outerFrameColor: Color(0x73442C2E),
                closeWindow: false,
                innerFrameColor: Colors.transparent,
              ),
            ),
          ),
          // Widget kamera, pastikan sudah dikonfigurasi dengan benar
          // Contoh: uncomment dan sesuaikan widget kamera sesuai kebutuhan Anda
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
// class CameraKtpNewScreen extends StatelessWidget {
//   static const String ROUTE_NAME = '/camera/new';
//   @override
//   Widget build(BuildContext context) {
//     final citizenCardWidth = MediaQuery.of(context).size.height * 0.7;
//     final citizenCardHeight = citizenCardWidth * 0.6;
//     final validRectangle = Rectangle(
//       height: citizenCardWidth,
//       width: citizenCardHeight,
//       color: Colors.red,
//     );

//     return Scaffold(
//       body: Stack(
//         children: [
//           Container(
//             constraints: const BoxConstraints.expand(),
//             child: CustomPaint(
//               painter: KtpFramePainter(
//                 screenSize: Size(validRectangle.width, validRectangle.height),
//                 outerFrameColor: Color(0x73442C2E),
//                 closeWindow: false,
//                 innerFrameColor: Colors.transparent,
//                 // innerFrameColor: _currentState == AnimationState.endSearch
//                 //     ? Colors.transparent
//                 //     : kShrineFrameBrown,
//               ),
//             ),
//           ),
//           // CameraCamera(
//           //   onFile: (File file) {
//           //     print(file.path);
//           //   },
//           //   enableAudio: false,
//           // ),
//         ],
//       ),
//     );
//   }
// }
