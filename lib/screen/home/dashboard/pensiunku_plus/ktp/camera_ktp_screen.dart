import 'dart:math' as math;
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pensiunku/model/camera_result_model.dart';
import 'package:pensiunku/repository/result_model.dart';
import 'package:pensiunku/util/widget_util.dart';
import 'package:pensiunku/widget/media_size_clipper.dart';

/// Argument untuk mengirim data ke CameraKtpScreen
class CameraKtpScreenArgs {
  final String cameraFilter;
  final Future<ResultModel<CameraResultModel>> Function(
      XFile file, CameraLensDirection cameraLensDirection) onProcessImage;
  final Future<dynamic> Function(BuildContext context, CameraResultModel result)
      onPreviewImage;
  final Widget Function(BuildContext context) buildFilter;

  CameraKtpScreenArgs({
    required this.cameraFilter,
    required this.onProcessImage,
    required this.onPreviewImage,
    required this.buildFilter,
  });
}

/// Screen untuk kamera KTP
class CameraKtpScreen extends StatefulWidget {
  final String cameraFilter;
  final Future<ResultModel<CameraResultModel>> Function(
      XFile file, CameraLensDirection cameraLensDirection) onProcessImage;
  final Future<dynamic> Function(BuildContext context, CameraResultModel result)
      onPreviewImage;
  final Widget Function(BuildContext context) buildFilter;

  static const String ROUTE_NAME = '/ktp/camera';

  const CameraKtpScreen({
    Key? key,
    required this.cameraFilter,
    required this.onProcessImage,
    required this.onPreviewImage,
    required this.buildFilter,
  }) : super(key: key);

  @override
  _CameraKtpScreenState createState() => _CameraKtpScreenState();
}

class _CameraKtpScreenState extends State<CameraKtpScreen>
    with WidgetsBindingObserver {
  late List<CameraDescription> _cameras;
  CameraController? _controller;
  CameraLensDirection? _cameraDirection;

  bool _isProcessingImage = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      _cameraDirection = _cameras[0].lensDirection;
      _onNewCameraSelected(_cameras[0]);
    } else {
      // Tangani jika tidak ada kamera yang tersedia.
      debugPrint('No camera available');
    }
  }

  void _onTakePictureButtonPressed() {
    _takePicture().then((XFile? file) async {
      if (mounted && file != null) {
        setState(() {
          _isProcessingImage = true;
        });
        var result = await widget.onProcessImage(file, _cameraDirection!);
        setState(() {
          _isProcessingImage = false;
        });
        if (!result.isSuccess) {
          // Menampilkan pesan kesalahan (gunakan showDialog atau WidgetUtil sesuai kebutuhan)
          WidgetUtil.showSnackbar(
            context,
            result.error ?? 'Gagal mendeteksi KTP. Mohon ulangi sekali lagi.',
          );
        } else {
          widget
              .onPreviewImage(context, result.data as CameraResultModel)
              .then((value) {
            if (value == true) {
              Navigator.of(context).pop(result.data);
            }
          });
        }
      }
    });
  }

  Future<XFile?> _takePicture() async {
    final CameraController? cameraController = _controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      debugPrint('Error: select a camera first.');
      return null;
    }
    if (cameraController.value.isTakingPicture) {
      // Jika sedang mengambil gambar, jangan lakukan apa-apa.
      return null;
    }
    try {
      XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      debugPrint('CameraException: ${e.description}');
      return null;
    }
  }

  /// Widget kontrol untuk capture foto
  Widget _captureControlRowWidget() {
    final CameraController? cameraController = _controller;
    return Positioned(
      bottom: 32.0,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          const SizedBox(width: 36.0),
          Transform.rotate(
            angle: math.pi / 2.0, // 90 derajat
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_isProcessingImage)
                  const Positioned.fill(
                    child: CircularProgressIndicator(
                      strokeWidth: 8.0,
                    ),
                  ),
                InkWell(
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Colors.white70,
                      shape: BoxShape.circle,
                    ),
                  ),
                  onTap: cameraController != null &&
                          cameraController.value.isInitialized &&
                          !_isProcessingImage
                      ? _onTakePictureButtonPressed
                      : null,
                ),
              ],
            ),
          ),
          Transform.rotate(
            angle: math.pi / 2.0,
            child: IconButton(
              icon: const Icon(Icons.switch_camera),
              color: Colors.white70,
              onPressed: cameraController != null &&
                      cameraController.value.isInitialized &&
                      !_isProcessingImage
                  ? _onRotateCamera
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onRotateCamera() async {
    await _controller?.dispose();
    setState(() {
      _cameraDirection = _cameraDirection == CameraLensDirection.back
          ? CameraLensDirection.front
          : CameraLensDirection.back;
    });
    CameraDescription? cameraDescription;
    for (CameraDescription camDesc in _cameras) {
      if (camDesc.lensDirection == _cameraDirection) {
        cameraDescription = camDesc;
        break;
      }
    }
    if (cameraDescription != null) {
      _onNewCameraSelected(cameraDescription);
    }
  }

  Future<void> _onNewCameraSelected(CameraDescription cameraDescription) async {
    await _controller?.dispose();
    _controller = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    _controller?.addListener(() {
      if (mounted) setState(() {});
      if (_controller?.value.hasError == true) {
        debugPrint('Camera error: ${_controller?.value.errorDescription}');
      }
    });
    try {
      await _controller?.initialize();
      await _controller?.setFlashMode(FlashMode.off);
    } on CameraException catch (e) {
      debugPrint('CameraException during initialization: ${e.description}');
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Jika kamera belum diinisialisasi, tidak perlu menangani lifecycle
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (_controller != null) {
        _onNewCameraSelected(_controller!.description);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _controller?.value.isInitialized != true
          ? const Center(child: CircularProgressIndicator())
          : _buildCameraPreview(),
    );
  }

  Widget _buildCamera() {
    final mediaSize = MediaQuery.of(context).size;
    // Penyesuaian scale untuk menghindari distorsi preview
    final scale = 1 / (_controller!.value.aspectRatio * mediaSize.aspectRatio);

    return ClipRect(
      // Pastikan Anda sudah mendefinisikan MediaSizeClipper, atau ganti dengan clipper yang sesuai
      clipper: MediaSizeClipper(mediaSize),
      child: Transform.scale(
        scale: scale,
        alignment: Alignment.topCenter,
        child: CameraPreview(_controller!),
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Stack(
      children: [
        _buildCamera(),
        widget.buildFilter(context),
        _captureControlRowWidget(),
      ],
    );
  }
}

/// CustomPainter untuk menggambar frame KTP
class KtpFramePainter extends CustomPainter {
  KtpFramePainter({
    required this.screenSize,
    this.outerFrameColor = Colors.white54,
    this.innerFrameColor = const Color(0xFF442C2E),
    this.innerFrameStrokeWidth = 3,
    this.closeWindow = false,
  });

  final Size screenSize;
  final Color outerFrameColor;
  final Color innerFrameColor;
  final double innerFrameStrokeWidth;
  final bool closeWindow;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final Paint paint = Paint()..color = outerFrameColor;
    final double radius = 200.0;

    final Path path = Path()..fillType = PathFillType.evenOdd;

    // Gambar latar belakang
    path.addRect(Rect.fromLTWH(0, 0, screenSize.width, screenSize.height));

    // Gambar frame KTP
    final double ktpWidth = screenSize.height * 0.7;
    final double ktpHeight = ktpWidth * 0.6;
    final double ktpHalfWidth = ktpWidth / 2;
    final double ktpHalfHeight = ktpHeight / 2;
    final Rect ktpRect = Rect.fromLTRB(
      center.dx - ktpHalfWidth,
      center.dy - ktpHalfHeight,
      center.dx + ktpHalfWidth,
      center.dy + ktpHalfHeight,
    );
    path.addRRect(
      RRect.fromRectAndRadius(ktpRect, Radius.circular(radius / 10)),
    );

    // Gambar area foto KTP
    final Rect ktpPhotoRect = Rect.fromLTRB(
      center.dx - (ktpHeight * (0.95 / 5.5)),
      center.dy + (ktpWidth * (1.75 / 8.5)),
      center.dx + (ktpHeight * (1.55 / 5.5)),
      center.dy + (ktpWidth * (3.75 / 8.5)),
    );
    path.addRRect(
      RRect.fromRectAndRadius(ktpPhotoRect, Radius.circular(radius / 10)),
    );

    // Gambar beberapa garis detail pada frame KTP
    final Rect ktpLineRect1 = Rect.fromLTRB(
      center.dx + (ktpHeight * (1.40 / 5.5)),
      center.dy - (ktpWidth * (3.75 / 8.5)),
      center.dx + (ktpHeight * (1.55 / 5.5)),
      center.dy,
    );
    final Rect ktpLineRect2 = Rect.fromLTRB(
      center.dx + (ktpHeight * (1.05 / 5.5)),
      center.dy - (ktpWidth * (3.75 / 8.5)),
      center.dx + (ktpHeight * (1.20 / 5.5)),
      center.dy,
    );
    final Rect ktpLineRect3 = Rect.fromLTRB(
      center.dx + (ktpHeight * (0.70 / 5.5)),
      center.dy - (ktpWidth * (3.75 / 8.5)),
      center.dx + (ktpHeight * (0.85 / 5.5)),
      center.dy - (ktpWidth * (0.5 / 8.5)),
    );
    final Rect ktpLineRect4 = Rect.fromLTRB(
      center.dx + (ktpHeight * (0.35 / 5.5)),
      center.dy - (ktpWidth * (3.75 / 8.5)),
      center.dx + (ktpHeight * (0.50 / 5.5)),
      center.dy - (ktpWidth * (0.5 / 8.5)),
    );
    // (Jika diperlukan, baris berikut bisa diaktifkan)
    // final Rect ktpLineRect5 = Rect.fromLTRB(
    //   center.dx + (ktpHeight * (0.15 / 5.5)),
    //   center.dy - (ktpWidth * (3.75 / 8.5)),
    //   center.dx + (ktpHeight * (0.35 / 5.5)),
    //   center.dy - (ktpWidth * (0.5 / 8.5)),
    // );

    path.addRRect(
      RRect.fromRectAndRadius(ktpLineRect1, Radius.circular(radius / 4)),
    );
    path.addRRect(
      RRect.fromRectAndRadius(ktpLineRect2, Radius.circular(radius / 4)),
    );
    path.addRRect(
      RRect.fromRectAndRadius(ktpLineRect3, Radius.circular(radius / 4)),
    );
    path.addRRect(
      RRect.fromRectAndRadius(ktpLineRect4, Radius.circular(radius / 4)),
    );
    // path.addRRect(
    //   RRect.fromRectAndRadius(ktpLineRect5, Radius.circular(radius / 4)),
    // );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(KtpFramePainter oldDelegate) {
    return oldDelegate.closeWindow != closeWindow ||
        oldDelegate.outerFrameColor != outerFrameColor ||
        oldDelegate.screenSize != screenSize;
  }
}

/// CustomPainter untuk menggambar frame Selfie
class SelfieFramePainter extends CustomPainter {
  SelfieFramePainter({
    required this.screenSize,
    this.outerFrameColor = Colors.white54,
    this.innerFrameColor = const Color(0xFF442C2E),
    this.innerFrameStrokeWidth = 3,
    this.closeWindow = false,
  });

  final Size screenSize;
  final Color outerFrameColor;
  final Color innerFrameColor;
  final double innerFrameStrokeWidth;
  final bool closeWindow;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = outerFrameColor;
    final Path path = Path()..fillType = PathFillType.evenOdd;

    // Gambar latar belakang
    path.addRect(Rect.fromLTWH(0, 0, screenSize.width, screenSize.height));

    // Gambar frame KTP kecil (sebagai contoh)
    final Offset centerKtp = size.center(Offset(0, screenSize.width * 0.2));
    final double ktpWidth = screenSize.width * 0.25;
    final double ktpHeight = ktpWidth / 0.6;
    final Rect ktpRect = Rect.fromCenter(
      center: centerKtp,
      width: ktpWidth,
      height: ktpHeight,
    );
    path.addRRect(
      RRect.fromRectAndRadius(ktpRect, const Radius.circular(16.0)),
    );
    final Paint paintBorder = Paint()
      ..color = Colors.white
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
      RRect.fromRectAndRadius(ktpRect, const Radius.circular(16.0)),
      paintBorder,
    );

    // Gambar frame wajah (selfie)
    final double radius = screenSize.width * 0.6 / 2;
    final Offset centerFace = size.center(Offset(0, -screenSize.height / 5));
    path.addOval(Rect.fromCircle(center: centerFace, radius: radius));
    canvas.drawCircle(centerFace, radius, paintBorder);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(SelfieFramePainter oldDelegate) {
    return oldDelegate.closeWindow != closeWindow ||
        oldDelegate.screenSize != screenSize;
  }
}

/// CustomPainter lama untuk window (contoh)
class WindowPainterOld extends CustomPainter {
  WindowPainterOld({
    required this.windowSize,
    this.outerFrameColor = Colors.white54,
    this.innerFrameColor = const Color(0xFF442C2E),
    this.innerFrameStrokeWidth = 3,
    this.closeWindow = false,
    this.offset = Offset.zero,
  });

  final Size windowSize;
  final Color outerFrameColor;
  final Color innerFrameColor;
  final double innerFrameStrokeWidth;
  final bool closeWindow;
  final Offset offset;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(offset);
    final Paint paint = Paint()..color = outerFrameColor;

    final double radius = 200.0;
    final Path path = Path()..fillType = PathFillType.evenOdd;
    path.addRect(Rect.fromLTWH(0, 0, windowSize.width, windowSize.height));
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromCircle(center: center, radius: radius / 2),
        Radius.circular(radius / 10),
      ),
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WindowPainterOld oldDelegate) {
    return oldDelegate.closeWindow != closeWindow ||
        oldDelegate.windowSize != windowSize;
  }
}

/// Kelas Rectangle untuk perhitungan ukuran
class Rectangle {
  const Rectangle({
    required this.width,
    required this.height,
    required this.color,
  });

  final double width;
  final double height;
  final Color color;

  static Rectangle lerp(Rectangle begin, Rectangle end, double t) {
    final Color color = t > 0.5
        ? Color.lerp(begin.color, end.color, (t - 0.5) / 0.25)!
        : begin.color;
    return Rectangle(
      width: lerpDouble(begin.width, end.width, t)!,
      height: lerpDouble(begin.height, end.height, t)!,
      color: color,
    );
  }
}

// class CameraKtpScreenArgs {
//   final String cameraFilter;
//   final Future<ResultModel<CameraResultModel>> Function(
//       XFile file, CameraLensDirection cameraLensDirection) onProcessImage;
//   final Future<dynamic> Function(BuildContext context, CameraResultModel result)
//   onPreviewImage;
//   final Widget Function(BuildContext context) buildFilter;

//   CameraKtpScreenArgs({
//     required this.cameraFilter,
//     required this.onProcessImage,
//     required this.onPreviewImage,
//     required this.buildFilter,
//   });
// }

// class CameraKtpScreen extends StatefulWidget {
//   final String cameraFilter;
//   final Future<ResultModel<CameraResultModel>> Function(
//       XFile file, CameraLensDirection cameraLensDirection) onProcessImage;
//   final Future<dynamic> Function(BuildContext context, CameraResultModel result)
//   onPreviewImage;
//   final Widget Function(BuildContext context) buildFilter;

//   static const String ROUTE_NAME = '/ktp/camera';

//   const CameraKtpScreen({
//     Key? key,
//     required this.cameraFilter,
//     required this.onProcessImage,
//     required this.onPreviewImage,
//     required this.buildFilter,
//   }) : super(key: key);

//   @override
//   _CameraKtpScreenState createState() => _CameraKtpScreenState();
// }

// class _CameraKtpScreenState extends State<CameraKtpScreen>
//     with WidgetsBindingObserver {
//   late List<CameraDescription> _cameras;
//   CameraController? _controller;
//   CameraLensDirection? _cameraDirection;

//   bool _isProcessingImage = false;

//   @override
//   void initState() {
//     super.initState();

//     _initCamera();
//   }

//   _initCamera() async {
//     _cameras = await availableCameras();

//     _cameraDirection = _cameras[0].lensDirection;
//     _onNewCameraSelected(_cameras[0]);
//   }

//   void _onTakePictureButtonPressed() {
//     _takePicture().then((XFile? file) async {
//       if (mounted) {
//         setState(() {
//           _isProcessingImage = true;
//         });
//         var result = await widget.onProcessImage(file!, _cameraDirection!);
//         setState(() {
//           _isProcessingImage = false;
//         });
//         if (!result.isSuccess) {
//           // showDialog(
//           //   context: context,
//           //   builder: (_) => AlertDialog(
//           //         content: Text(result.error ?? 'Gagal mengajukan form',
//           //             style: TextStyle(color: Colors.white)),
//           //         backgroundColor: Colors.red,
//           //         elevation: 24.0,
//           //       ));
//           WidgetUtil.showSnackbar(
//             context,
//             result.error ?? 'Gagal mendeteksi KTP. Mohon ulangi sekali lagi.',
//           );
//         } else {
//           widget.onPreviewImage(context, result.data as CameraResultModel).then(
//                 (value) {
//               if (value == true) {
//                 Navigator.of(context).pop(result.data);
//               }
//             },
//           );
//         }
//         // if (file != null) print('Picture saved to ${file.path}');
//       }
//     });
//   }

//   Future<XFile?> _takePicture() async {
//     final CameraController? cameraController = _controller;
//     if (cameraController == null || !cameraController.value.isInitialized) {
//       print('Error: select a camera first.');
//       return null;
//     }

//     if (cameraController.value.isTakingPicture) {
//       // A capture is already pending, do nothing.
//       return null;
//     }

//     try {
//       XFile file = await cameraController.takePicture();
//       return file;
//     } on CameraException catch (_) {
//       // _showCameraException(e);
//       return null;
//     }
//   }

//   /// Display the control bar with buttons to take picture.
//   Widget _captureControlRowWidget() {
//     final CameraController? cameraController = _controller;

//     return Positioned(
//       bottom: 32.0,
//       left: 0,
//       right: 0,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         mainAxisSize: MainAxisSize.max,
//         children: <Widget>[
//           SizedBox(width: 36.0),
//           Transform.rotate(
//             angle: math.pi / 2.0, // 90 degrees
//             child: Stack(
//               children: [
//                 if (_isProcessingImage)
//                   Positioned.fill(
//                     child: CircularProgressIndicator(
//                       strokeWidth: 8.0,
//                     ),
//                   ),
//                 InkWell(
//                   child: Container(
//                     width: 50,
//                     height: 50,
//                     decoration: BoxDecoration(
//                       color: Colors.white70,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                   onTap: cameraController != null &&
//                       cameraController.value.isInitialized &&
//                       !_isProcessingImage
//                       ? _onTakePictureButtonPressed
//                       : null,
//                 ),
//               ],
//             ),
//           ),
//           Transform.rotate(
//             angle: math.pi / 2.0, // 90 degrees
//             child: IconButton(
//               icon: const Icon(Icons.switch_camera),
//               color: Colors.white70,
//               onPressed: cameraController != null &&
//                   cameraController.value.isInitialized &&
//                   !_isProcessingImage
//                   ? _onRotateCamera
//                   : null,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _onRotateCamera() async {
//     await _controller?.dispose();
//     setState(() {
//       if (_cameraDirection == CameraLensDirection.back) {
//         _cameraDirection = CameraLensDirection.front;
//       } else {
//         _cameraDirection = CameraLensDirection.back;
//       }
//     });
//     CameraDescription? cameraDescription;
//     for (CameraDescription camDesc in _cameras) {
//       if (camDesc.lensDirection == _cameraDirection) {
//         cameraDescription = camDesc;
//       }
//     }
//     if (cameraDescription != null) {
//       _onNewCameraSelected(cameraDescription);
//     }
//   }

//   void _onNewCameraSelected(CameraDescription cameraDescription) async {
//     if (_controller != null) {
//       await _controller?.dispose();
//     }
//     _controller = CameraController(
//       cameraDescription,
//       ResolutionPreset.medium,
//       enableAudio: false,
//     );

//     // If the controller is updated then update the UI.
//     _controller?.addListener(() {
//       if (mounted) setState(() {});
//       if (_controller?.value.hasError == true) {
//         // showInSnackBar('Camera error ${controller.value.errorDescription}');
//       }
//     });

//     try {
//       await _controller?.initialize();
//       await _controller?.setFlashMode(FlashMode.off);
//     } on CameraException catch (_) {
//       // _showCameraException(e);
//     }

//     if (mounted) {
//       setState(() {});
//     }
//   }

//   @override
//   void dispose() {
//     _controller?.dispose();
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     // App state changed before we got the chance to initialize.
//     if (_controller == null || _controller?.value.isInitialized != true) {
//       return;
//     }
//     if (state == AppLifecycleState.inactive) {
//       _controller?.dispose();
//     } else if (state == AppLifecycleState.resumed) {
//       if (_controller != null) {
//         _onNewCameraSelected(_controller!.description);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _controller?.value.isInitialized != true
//           ? Center(
//         child: CircularProgressIndicator(),
//       )
//           : _buildCameraPreview(),
//     );
//   }

//   _buildCamera() {
//     final mediaSize = MediaQuery.of(context).size;
//     final scale = 1 / (_controller!.value.aspectRatio * mediaSize.aspectRatio);

//     return ClipRect(
//       clipper: MediaSizeClipper(mediaSize),
//       child: Transform.scale(
//         scale: scale,
//         alignment: Alignment.topCenter,
//         child: CameraPreview(_controller!),
//       ),
//     );
//   }

//   _buildCameraPreview() {
//     return Stack(
//       children: [
//         _buildCamera(),
//         widget.buildFilter(context),
//         _captureControlRowWidget(),
//       ],
//     );
//   }
// }

// class KtpFramePainter extends CustomPainter {
//   KtpFramePainter({
//     required this.screenSize,
//     this.outerFrameColor = Colors.white54,
//     this.innerFrameColor = const Color(0xFF442C2E),
//     this.innerFrameStrokeWidth = 3,
//     this.closeWindow = false,
//   });

//   final Size screenSize;
//   final Color outerFrameColor;
//   final Color innerFrameColor;
//   final double innerFrameStrokeWidth;
//   final bool closeWindow;

//   @override
//   void paint(Canvas canvas, Size size) {
//     final Offset center = size.center(Offset.zero);

//     final Paint paint = Paint()..color = outerFrameColor;

//     final radius = 200.0;

//     final Path path = Path();
//     path.fillType = PathFillType.evenOdd;

//     // Draw background
//     path.addRect(Rect.fromLTRB(0.0, 0.0, screenSize.width, screenSize.height));

//     // Draw KTP frame
//     final ktpWidth = screenSize.height * 0.7;
//     final ktpHeight = ktpWidth * 0.6;
//     final double ktpHalfWidth = ktpWidth / 2;
//     final double ktpHalfHeight = ktpHeight / 2;
//     final ktpRect = Rect.fromLTRB(
//       center.dx - ktpHalfHeight,
//       center.dy - ktpHalfWidth,
//       center.dx + ktpHalfHeight,
//       center.dy + ktpHalfWidth,
//     );
//     path.addRRect(
//       RRect.fromRectAndRadius(
//         ktpRect,
//         Radius.circular(radius / 10),
//       ),
//     );

//     // Draw KTP photo
//     final ktpPhotoRect = Rect.fromLTRB(
//       center.dx - (ktpHeight * (0.95 / 5.5)),
//       center.dy + (ktpWidth * (1.75 / 8.5)),
//       center.dx + (ktpHeight * (1.55 / 5.5)),
//       center.dy + (ktpWidth * (3.75 / 8.5)),
//     );
//     path.addRRect(
//       RRect.fromRectAndRadius(
//         ktpPhotoRect,
//         Radius.circular(radius / 10),
//       ),
//     );

//     // TextSpan span = new TextSpan(
//     //     style: new TextStyle(color: Colors.red[600]), text: 'Yrfc');
//     // TextPainter tp = new TextPainter(text: span, textAlign: TextAlign.left);
//     // tp.layout();
//     // tp.paint(canvas, new Offset(5.0, 5.0));

//     // Draw KTP lines
//     final ktpLineRect1 = Rect.fromLTRB(
//       center.dx + (ktpHeight * (1.40 / 5.5)),
//       center.dy - (ktpWidth * (3.75 / 8.5)),
//       center.dx + (ktpHeight * (1.55 / 5.5)),
//       center.dy,
//     );
//     final ktpLineRect2 = Rect.fromLTRB(
//       center.dx + (ktpHeight * (1.05 / 5.5)),
//       center.dy - (ktpWidth * (3.75 / 8.5)),
//       center.dx + (ktpHeight * (1.20 / 5.5)),
//       center.dy,
//     );
//     final ktpLineRect3 = Rect.fromLTRB(
//       center.dx + (ktpHeight * (0.70 / 5.5)),
//       center.dy - (ktpWidth * (3.75 / 8.5)),
//       center.dx + (ktpHeight * (0.85 / 5.5)),
//       center.dy - (ktpWidth * (0.5 / 8.5)),
//     );
//     final ktpLineRect4 = Rect.fromLTRB(
//       center.dx + (ktpHeight * (0.35 / 5.5)),
//       center.dy - (ktpWidth * (3.75 / 8.5)),
//       center.dx + (ktpHeight * (0.50 / 5.5)),
//       center.dy - (ktpWidth * (0.5 / 8.5)),
//     );
//     final ktpLineRect5 = Rect.fromLTRB(
//       center.dx + (ktpHeight * (0.15 / 5.5)),
//       center.dy - (ktpWidth * (3.75 / 8.5)),
//       center.dx + (ktpHeight * (0.35 / 5.5)),
//       center.dy - (ktpWidth * (0.5 / 8.5)),
//     );

//     path.addRRect(
//       RRect.fromRectAndRadius(
//         ktpLineRect1,
//         Radius.circular(radius / 4),
//       ),
//     );
//     path.addRRect(
//       RRect.fromRectAndRadius(
//         ktpLineRect2,
//         Radius.circular(radius / 4),
//       ),
//     );
//     path.addRRect(
//       RRect.fromRectAndRadius(
//         ktpLineRect3,
//         Radius.circular(radius / 4),
//       ),
//     );
//     path.addRRect(
//       RRect.fromRectAndRadius(
//         ktpLineRect4,
//         Radius.circular(radius / 4),
//       ),
//     );
//     // path.addRRect(
//     //   RRect.fromRectAndRadius(
//     //     ktpLineRect5,
//     //     Radius.circular(radius / 4),
//     //   ),
//     // );

//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(KtpFramePainter oldDelegate) =>
//       oldDelegate.closeWindow != closeWindow;
// }

// class SelfieFramePainter extends CustomPainter {
//   SelfieFramePainter({
//     required this.screenSize,
//     this.outerFrameColor = Colors.white54,
//     this.innerFrameColor = const Color(0xFF442C2E),
//     this.innerFrameStrokeWidth = 3,
//     this.closeWindow = false,
//   });

//   final Size screenSize;
//   final Color outerFrameColor;
//   final Color innerFrameColor;
//   final double innerFrameStrokeWidth;
//   final bool closeWindow;

//   @override
//   void paint(Canvas canvas, Size size) {
//     final Paint paint = Paint()..color = outerFrameColor;
//     final Path path = Path();
//     path.fillType = PathFillType.evenOdd;

//     // Draw background
//     path.addRect(Rect.fromLTRB(0.0, 0.0, screenSize.width, screenSize.height));

//     // Draw KTP frame
//     final Offset centerKtp = size.center(
//       Offset(
//         0.00,
//         screenSize.width * 0.2,
//       ),
//     );
//     final ktpWidth = screenSize.width * 0.25;
//     final ktpHeight = ktpWidth / 0.6;

//     final double ktpHalfWidth = ktpWidth / 2;
//     final double ktpHalfHeight = ktpHeight / 2;
//     final ktpRect = Rect.fromLTRB(
//       centerKtp.dx - ktpHalfHeight,
//       centerKtp.dy - ktpHalfWidth,
//       centerKtp.dx + ktpHalfHeight,
//       centerKtp.dy + ktpHalfWidth,
//     );
//     path.addRRect(
//       RRect.fromRectAndRadius(
//         ktpRect,
//         Radius.circular(16.0),
//       ),
//     );
//     Paint paintBorder = Paint()
//       ..color = Colors.white
//       ..strokeWidth = 4.0
//       ..style = PaintingStyle.stroke;
//     canvas.drawRRect(
//       RRect.fromRectAndRadius(
//         ktpRect,
//         Radius.circular(16.0),
//       ),
//       paintBorder,
//     );

//     // Draw face frame
//     final radius = screenSize.width * 0.6 / 2;
//     final Offset centerFace = size.center(
//       Offset(
//         0.0,
//         -screenSize.height / 5 ,
//       ),
//     );
//     path.addOval(
//       Rect.fromCircle(center: centerFace, radius: radius),
//     );
//     canvas.drawCircle(centerFace, radius, paintBorder);

//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(SelfieFramePainter oldDelegate) =>
//       oldDelegate.closeWindow != closeWindow;
// }

// class WindowPainterOld extends CustomPainter {
//   WindowPainterOld({
//     required this.windowSize,
//     this.outerFrameColor = Colors.white54,
//     this.innerFrameColor = const Color(0xFF442C2E),
//     this.innerFrameStrokeWidth = 3,
//     this.closeWindow = false,
//     this.offset = Offset.zero,
//   });

//   final Size windowSize;
//   final Color outerFrameColor;
//   final Color innerFrameColor;
//   final double innerFrameStrokeWidth;
//   final bool closeWindow;
//   final Offset offset;

//   @override
//   void paint(Canvas canvas, Size size) {
//     final Offset center = size.center(offset);
//     // final double windowHalfWidth = windowSize.width / 2;
//     // final double windowHalfHeight = windowSize.height / 2;

//     // final Rect windowRect = Rect.fromLTRB(
//     //   center.dx - windowHalfWidth,
//     //   center.dy - windowHalfHeight,
//     //   center.dx + windowHalfWidth,
//     //   center.dy + windowHalfHeight,
//     // );

//     // final Rect left =
//     //     Rect.fromLTRB(0, windowRect.top, windowRect.left, windowRect.bottom);
//     // final Rect top = Rect.fromLTRB(0, 0, size.width, windowRect.top);
//     // final Rect right = Rect.fromLTRB(
//     //   windowRect.right,
//     //   windowRect.top,
//     //   size.width,
//     //   windowRect.bottom,
//     // );
//     // final Rect bottom = Rect.fromLTRB(
//     //   0,
//     //   windowRect.bottom,
//     //   size.width,
//     //   size.height,
//     // );

//     // canvas.drawRect(
//     //     windowRect,
//     //     Paint()
//     //       ..color = innerFrameColor
//     //       ..style = PaintingStyle.stroke
//     //       ..strokeWidth = innerFrameStrokeWidth);

//     final Paint paint = Paint()..color = outerFrameColor;
//     // canvas.drawRect(left, paint);
//     // canvas.drawRect(top, paint);
//     // canvas.drawRect(right, paint);
//     // canvas.drawRect(bottom, paint);

//     // if (closeWindow) {
//     //   canvas.drawRect(windowRect, paint);
//     // }

//     final radius = 200.0;

//     final Path path = Path();
//     path.fillType = PathFillType.evenOdd;
//     path.addRect(Rect.fromLTRB(0.0, 0.0, windowSize.width, windowSize.height));
//     // path.addOval(Rect.fromCircle(center: center, radius: radius));
//     path.addRRect(RRect.fromRectAndRadius(
//         Rect.fromCircle(center: center, radius: radius / 2),
//         Radius.circular(radius / 10)));
//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(KtpFramePainter oldDelegate) =>
//       oldDelegate.closeWindow != closeWindow;
// }

// class Rectangle {
//   const Rectangle({
//     required this.width,
//     required this.height,
//     required this.color,
//   });

//   final double width;
//   final double height;
//   final Color color;

//   static Rectangle lerp(Rectangle begin, Rectangle end, double t) {
//     Color color;
//     if (t > .5) {
//       color = Color.lerp(begin.color, end.color, (t - .5) / .25)!;
//     } else {
//       color = begin.color;
//     }

//     return Rectangle(
//       width: lerpDouble(begin.width, end.width, t)!,
//       height: lerpDouble(begin.height, end.height, t)!,
//       color: color,
//     );
//   }
// }
