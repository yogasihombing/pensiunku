import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:get/get_utils/get_utils.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pensiunku/model/camera_result_model.dart';
import 'package:pensiunku/model/result_model.dart';
import 'package:pensiunku/util/widget_util.dart';
import 'package:pensiunku/widget/media_size_clipper.dart';

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
  }

  _initCamera() async {
    _cameras = await availableCameras();

    _cameraDirection = _cameras[0].lensDirection;
    _onNewCameraSelected(_cameras[0]);
  }

  void _onTakePictureButtonPressed() {
    _takePicture().then((XFile? file) async {
      if (mounted) {
        setState(() {
          _isProcessingImage = true;
        });
        var result = await widget.onProcessImage(file!, _cameraDirection!);
        setState(() {
          _isProcessingImage = false;
        });
        if (!result.isSuccess) {
          // showDialog(
          //   context: context,
          //   builder: (_) => AlertDialog(
          //         content: Text(result.error ?? 'Gagal mengajukan form',
          //             style: TextStyle(color: Colors.white)),
          //         backgroundColor: Colors.red,
          //         elevation: 24.0,
          //       ));
          WidgetUtil.showSnackbar(
            context,
            result.error ?? 'Gagal mendeteksi KTP. Mohon ulangi sekali lagi.',
          );
        } else {
          widget.onPreviewImage(context, result.data as CameraResultModel).then(
            (value) {
              if (value == true) {
                Navigator.of(context).pop(result.data);
              }
            },
          );
        }
        // if (file != null) print('Picture saved to ${file.path}');
      }
    });
  }

  Future<XFile?> _takePicture() async {
    final CameraController? cameraController = _controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      print('Error: select a camera first.');
      return null;
    }

    if (cameraController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (_) {
      // _showCameraException(e);
      return null;
    }
  }

  /// Display the control bar with buttons to take picture.
  Widget _captureControlRowWidget() {
    final CameraController? cameraController = _controller;

    return Positioned(
      bottom: 32.0,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          SizedBox(width: 36.0),
          Transform.rotate(
            angle: math.pi / 2.0, // 90 degrees
            child: Stack(
              children: [
                if (_isProcessingImage)
                  Positioned.fill(
                    child: CircularProgressIndicator(
                      strokeWidth: 8.0,
                    ),
                  ),
                InkWell(
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
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
            angle: math.pi / 2.0, // 90 degrees
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
      if (_cameraDirection == CameraLensDirection.back) {
        _cameraDirection = CameraLensDirection.front;
      } else {
        _cameraDirection = CameraLensDirection.back;
      }
    });
    CameraDescription? cameraDescription;
    for (CameraDescription camDesc in _cameras) {
      if (camDesc.lensDirection == _cameraDirection) {
        cameraDescription = camDesc;
      }
    }
    if (cameraDescription != null) {
      _onNewCameraSelected(cameraDescription);
    }
  }

  void _onNewCameraSelected(CameraDescription cameraDescription) async {
    if (_controller != null) {
      await _controller?.dispose();
    }
    _controller = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    // If the controller is updated then update the UI.
    _controller?.addListener(() {
      if (mounted) setState(() {});
      if (_controller?.value.hasError == true) {
        // showInSnackBar('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await _controller?.initialize();
      await _controller?.setFlashMode(FlashMode.off);
    } on CameraException catch (_) {
      // _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (_controller == null || _controller?.value.isInitialized != true) {
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
          ? Center(
              child: CircularProgressIndicator(),
            )
          : _buildCameraPreview(),
    );
  }

  _buildCamera() {
    final mediaSize = MediaQuery.of(context).size;
    final scale = 1 / (_controller!.value.aspectRatio * mediaSize.aspectRatio);

    return ClipRect(
      clipper: MediaSizeClipper(mediaSize),
      child: Transform.scale(
        scale: scale,
        alignment: Alignment.topCenter,
        child: CameraPreview(_controller!),
      ),
    );
  }

  _buildCameraPreview() {
    return Stack(
      children: [
        _buildCamera(),
        widget.buildFilter(context),
        _captureControlRowWidget(),
      ],
    );
  }
}

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

    final radius = 200.0;

    final Path path = Path();
    path.fillType = PathFillType.evenOdd;

    // Draw background
    path.addRect(Rect.fromLTRB(0.0, 0.0, screenSize.width, screenSize.height));

    // Draw KTP frame
    final ktpWidth = screenSize.height * 0.7;
    final ktpHeight = ktpWidth * 0.6;
    final double ktpHalfWidth = ktpWidth / 2;
    final double ktpHalfHeight = ktpHeight / 2;
    final ktpRect = Rect.fromLTRB(
      center.dx - ktpHalfHeight,
      center.dy - ktpHalfWidth,
      center.dx + ktpHalfHeight,
      center.dy + ktpHalfWidth,
    );
    path.addRRect(
      RRect.fromRectAndRadius(
        ktpRect,
        Radius.circular(radius / 10),
      ),
    );

    // Draw KTP photo
    final ktpPhotoRect = Rect.fromLTRB(
      center.dx - (ktpHeight * (0.95 / 5.5)),
      center.dy + (ktpWidth * (1.75 / 8.5)),
      center.dx + (ktpHeight * (1.55 / 5.5)),
      center.dy + (ktpWidth * (3.75 / 8.5)),
    );
    path.addRRect(
      RRect.fromRectAndRadius(
        ktpPhotoRect,
        Radius.circular(radius / 10),
      ),
    );

    // TextSpan span = new TextSpan(
    //     style: new TextStyle(color: Colors.red[600]), text: 'Yrfc');
    // TextPainter tp = new TextPainter(text: span, textAlign: TextAlign.left);
    // tp.layout();
    // tp.paint(canvas, new Offset(5.0, 5.0));

    // Draw KTP lines
    final ktpLineRect1 = Rect.fromLTRB(
      center.dx + (ktpHeight * (1.40 / 5.5)),
      center.dy - (ktpWidth * (3.75 / 8.5)),
      center.dx + (ktpHeight * (1.55 / 5.5)),
      center.dy,
    );
    final ktpLineRect2 = Rect.fromLTRB(
      center.dx + (ktpHeight * (1.05 / 5.5)),
      center.dy - (ktpWidth * (3.75 / 8.5)),
      center.dx + (ktpHeight * (1.20 / 5.5)),
      center.dy,
    );
    final ktpLineRect3 = Rect.fromLTRB(
      center.dx + (ktpHeight * (0.70 / 5.5)),
      center.dy - (ktpWidth * (3.75 / 8.5)),
      center.dx + (ktpHeight * (0.85 / 5.5)),
      center.dy - (ktpWidth * (0.5 / 8.5)),
    );
    final ktpLineRect4 = Rect.fromLTRB(
      center.dx + (ktpHeight * (0.35 / 5.5)),
      center.dy - (ktpWidth * (3.75 / 8.5)),
      center.dx + (ktpHeight * (0.50 / 5.5)),
      center.dy - (ktpWidth * (0.5 / 8.5)),
    );
    final ktpLineRect5 = Rect.fromLTRB(
      center.dx + (ktpHeight * (0.15 / 5.5)),
      center.dy - (ktpWidth * (3.75 / 8.5)),
      center.dx + (ktpHeight * (0.35 / 5.5)),
      center.dy - (ktpWidth * (0.5 / 8.5)),
    );

    path.addRRect(
      RRect.fromRectAndRadius(
        ktpLineRect1,
        Radius.circular(radius / 4),
      ),
    );
    path.addRRect(
      RRect.fromRectAndRadius(
        ktpLineRect2,
        Radius.circular(radius / 4),
      ),
    );
    path.addRRect(
      RRect.fromRectAndRadius(
        ktpLineRect3,
        Radius.circular(radius / 4),
      ),
    );
    path.addRRect(
      RRect.fromRectAndRadius(
        ktpLineRect4,
        Radius.circular(radius / 4),
      ),
    );
    // path.addRRect(
    //   RRect.fromRectAndRadius(
    //     ktpLineRect5,
    //     Radius.circular(radius / 4),
    //   ),
    // );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(KtpFramePainter oldDelegate) =>
      oldDelegate.closeWindow != closeWindow;
}

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
    final Path path = Path();
    path.fillType = PathFillType.evenOdd;

    // Draw background
    path.addRect(Rect.fromLTRB(0.0, 0.0, screenSize.width, screenSize.height));

    // Draw KTP frame
    final Offset centerKtp = size.center(
      Offset(
        0.00,
        screenSize.width * 0.2,
      ),
    );
    final ktpWidth = screenSize.width * 0.25;
    final ktpHeight = ktpWidth / 0.6;

    final double ktpHalfWidth = ktpWidth / 2;
    final double ktpHalfHeight = ktpHeight / 2;
    final ktpRect = Rect.fromLTRB(
      centerKtp.dx - ktpHalfHeight,
      centerKtp.dy - ktpHalfWidth,
      centerKtp.dx + ktpHalfHeight,
      centerKtp.dy + ktpHalfWidth,
    );
    path.addRRect(
      RRect.fromRectAndRadius(
        ktpRect,
        Radius.circular(16.0),
      ),
    );
    Paint paintBorder = Paint()
      ..color = Colors.white
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        ktpRect,
        Radius.circular(16.0),
      ),
      paintBorder,
    );

    // Draw face frame
    final radius = screenSize.width * 0.6 / 2;
    final Offset centerFace = size.center(
      Offset(
        0.0,
        -screenSize.height / 5,
      ),
    );
    path.addOval(
      Rect.fromCircle(center: centerFace, radius: radius),
    );
    canvas.drawCircle(centerFace, radius, paintBorder);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(SelfieFramePainter oldDelegate) =>
      oldDelegate.closeWindow != closeWindow;
}

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
    final Offset center = size.center(offset); //ini
    final double windowHalfWidth = windowSize.width / 2;
    final double windowHalfHeight = windowSize.height / 2;

    final Rect windowRect = Rect.fromLTRB(
      center.dx - windowHalfWidth,
      center.dy - windowHalfHeight,
      center.dx + windowHalfWidth,
      center.dy + windowHalfHeight,
    );

    final Rect left =
        Rect.fromLTRB(0, windowRect.top, windowRect.left, windowRect.bottom);
    final Rect top = Rect.fromLTRB(0, 0, size.width, windowRect.top);
    final Rect right = Rect.fromLTRB(
      windowRect.right,
      windowRect.top,
      size.width,
      windowRect.bottom,
    );
    final Rect bottom = Rect.fromLTRB(
      0,
      windowRect.bottom,
      size.width,
      size.height,
    );

    canvas.drawRect(
        windowRect,
        Paint()
          ..color = innerFrameColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = innerFrameStrokeWidth); //ini

    final Paint paint = Paint()..color = outerFrameColor;
    canvas.drawRect(left, paint); //ini
    canvas.drawRect(top, paint);
    canvas.drawRect(right, paint);
    canvas.drawRect(bottom, paint);

    if (closeWindow) {
      canvas.drawRect(windowRect, paint);
    }
//ini
    final radius = 200.0;

    final Path path = Path();
    path.fillType = PathFillType.evenOdd;
    path.addRect(Rect.fromLTRB(0.0, 0.0, windowSize.width, windowSize.height));
    // path.addOval(Rect.fromCircle(center: center, radius: radius));
    path.addRRect(RRect.fromRectAndRadius(
        Rect.fromCircle(center: center, radius: radius / 2),
        Radius.circular(radius / 10)));
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(KtpFramePainter oldDelegate) =>
      oldDelegate.closeWindow != closeWindow;
}

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
    Color color;
    if (t > .5) {
      color = Color.lerp(begin.color, end.color, (t - .5) / .25)!;
    } else {
      color = begin.color;
    }

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
//       onPreviewImage;
//   final Widget Function(
//       BuildContext context, CameraResultModel? detectionResult) buildFilter;

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
//       onPreviewImage;
//   final Widget Function(
//       BuildContext context, CameraResultModel? detectionResult) buildFilter;

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

//   // Tambahkan deklarasi ini
//   List<Rect> _detectedTextBoxes = [];

//   // UPDATED: Tambahkan state untuk menyimpan hasil deteksi
//   CameraResultModel? _detectionResult;

//   @override
//   void initState() {
//     super.initState();
//     _initCamera();
//     WidgetsBinding.instance.addObserver(this);
//   }

//   Future<void> _initCamera() async {
//     _cameras = await availableCameras();
//     if (_cameras.isNotEmpty) {
//       _cameraDirection = _cameras[0].lensDirection;
//       _onNewCameraSelected(_cameras[0]);
//     } else {
//       // Tangani jika tidak ada kamera yang tersedia.
//       debugPrint('No camera available');
//     }
//   }

//   void _onTakePictureButtonPressed() {
//     _takePicture().then((XFile? file) async {
//       if (mounted && file != null) {
//         setState(() {
//           _isProcessingImage = true;
//         });
//         var result = await widget.onProcessImage(file, _cameraDirection!);
//         setState(() {
//           _isProcessingImage = false;
//         });
//         if (!result.isSuccess) {
//           // Menampilkan pesan kesalahan (gunakan showDialog atau WidgetUtil sesuai kebutuhan)
//           WidgetUtil.showSnackbar(
//             context,
//             result.error ?? 'Gagal mendeteksi KTP. Mohon ulangi sekali lagi.',
//           );
//         } else {
//           widget
//               .onPreviewImage(context, result.data as CameraResultModel)
//               .then((value) {
//             if (value == true) {
//               Navigator.of(context).pop(result.data);
//             }
//           });
//         }
//       }
//     });
//   }

//   Future<CameraResultModel> getKtpVisionDataFromImage(XFile file) async {
//     final result = CameraResultModel(imagePath: file.path, textBoxes: []);
//     final textBlocks = <String>[];

//     try {
//       // 1. Proses awal gambar
//       final originalImage = img.decodeImage(await file.readAsBytes());
//       if (originalImage == null) throw Exception('Gagal memproses gambar');

//       final rotatedImage = rotateImageIfNeeded(originalImage);
//       final croppedImage = cropImage(rotatedImage, 192, 91, 896, 537);
//       final processedFile = await saveProcessedImage(croppedImage);

//       // 2. Deteksi teks dengan ML Kit
//       final inputImage = InputImage.fromFilePath(processedFile.path);
//       final textRecognizer =
//           TextRecognizer(script: TextRecognitionScript.latin);
//       final visionText = await textRecognizer.processImage(inputImage);
//       await textRecognizer.close();

//       // Simpan semua teks untuk analisis lengkap
//       final completeText = visionText.text;
//       print('Teks lengkap terdeteksi: $completeText');

//       // 3. Kumpulkan semua blok teks dan simpan ke array untuk pencocokan pola
//       final allTextLines = <String>[];
//       for (final block in visionText.blocks) {
//         for (final line in block.lines) {
//           final correctedText = correctSpelling(line.text.trim());
//           if (correctedText.isNotEmpty) {
//             allTextLines.add(correctedText);
//             textBlocks.add(correctedText);
//           }
//         }
//       }

//       // 4. Parsing data dengan pendekatan berbasis pola
//       _extractDataFromTextLines(allTextLines, result);

//       // 5. Validasi dan pembersihan data
//       _postProcessData(result);

//       // Debug output
//       print('NIK: ${result.nik}');
//       print('Nama: ${result.name}');
//       print('Tempat Lahir: ${result.tempatLahir}');
//       print('Tanggal Lahir: ${result.tanggalLahir}');
//       print('Alamat: ${result.alamat}');
//       print('RT/RW: ${result.rtRw}');
//       print('Kelurahan: ${result.kelurahan}');
//       print('Kecamatan: ${result.kecamatan}');
//       print('Agama: ${result.agama}');
//       print('Status Perkawinan: ${result.statusPerkawinan}');
//       print('Pekerjaan: ${result.pekerjaan}');
//       print('Kewarganegaraan: ${result.kewarganegaraan}');

//       if (result.nik == null ||
//           (result.nik != null && result.nik!.length != 16)) {
//         // Coba ekstrak NIK dengan pendekatan alternatif
//         _extractNikFromTextLinesAlt(allTextLines, result);
//       }

//       return result;
//     } catch (e) {
//       print('Error processing KTP: $e');
//       throw Exception(
//           'Gagal membaca data KTP. Pastikan foto jelas dan dalam bingkai');
//     }
//   }

//   void _extractDataFromTextLines(
//       List<String> textLines, CameraResultModel result) {
//     // State tracking untuk analisis konteks
//     bool inAddressSection = false;
//     String pendingAddress = '';

//     for (int i = 0; i < textLines.length; i++) {
//       final line = textLines[i].trim();

//       // NIK extraction - look for patterns like "NIK: 1234567890123456" or standalone 16-digit number
//       if (line.contains('NIK') || RegExp(r'\bNIK\b').hasMatch(line)) {
//         final nikPattern = RegExp(r'(\d{16})');
//         final match = nikPattern.firstMatch(line);
//         if (match != null) {
//           result.nik = match.group(1);
//         } else if (i + 1 < textLines.length) {
//           // Check next line for NIK
//           final nextLine = textLines[i + 1].trim();
//           final nextMatch = nikPattern.firstMatch(nextLine);
//           if (nextMatch != null) {
//             result.nik = nextMatch.group(1);
//           }
//         }
//       } else if (RegExp(r'^\d{16}$').hasMatch(line)) {
//         // Standalone 16-digit number is likely a NIK
//         result.nik = line;
//       }

//       // Nama extraction
//       if (line.contains('Nama') ||
//           RegExp(r'\bNama\b', caseSensitive: false).hasMatch(line)) {
//         if (line.contains(':')) {
//           result.nama = line.split(':').last.trim();
//         } else if (i + 1 < textLines.length && _isAllCaps(textLines[i + 1])) {
//           result.nama = textLines[i + 1].trim();
//         }
//       } else if (_isAllCaps(line) &&
//           !line.contains('PROVINSI') &&
//           !line.contains('REPUBLIK') &&
//           !line.contains('KARTU') &&
//           !line.contains('TANDA') &&
//           !line.contains('PENDUDUK')) {
//         // Look for all caps name not containing common KTP header text
//         if (result.nama == null || result.nama!.isEmpty) {
//           result.nama = line;
//         }
//       }

//       // Tempat/Tanggal Lahir extraction
//       if (line.contains('Tempat') && line.contains('Lahir')) {
//         String birthInfo = line;
//         if (line.contains(':')) {
//           birthInfo = line.split(':').last.trim();
//         } else if (i + 1 < textLines.length) {
//           // Check next line for birth info
//           birthInfo = textLines[i + 1].trim();
//         }

//         if (birthInfo.contains(',')) {
//           final parts = birthInfo.split(',');
//           result.tempatLahir = parts[0].trim();
//           if (parts.length > 1) {
//             result.tanggalLahir = _parseDate(parts[1].trim());
//           }
//         }
//       }

//       // Jenis Kelamin
//       if (line.contains('Kelamin')) {
//         if (i + 1 < textLines.length) {
//           final nextLine = textLines[i + 1].trim();
//           if (nextLine.contains('LAKI-LAKI') ||
//               nextLine.contains('LAKI LAKI')) {
//             result.jenisKelamin = 'LAKI-LAKI';
//           } else if (nextLine.contains('PEREMPUAN')) {
//             result.jenisKelamin = 'PEREMPUAN';
//           }
//         }
//       } else if (line == 'LAKI-LAKI' || line == 'LAKI LAKI') {
//         result.jenisKelamin = 'LAKI-LAKI';
//       } else if (line == 'PEREMPUAN') {
//         result.jenisKelamin = 'PEREMPUAN';
//       }

//       // Alamat processing - need to handle multi-line addresses
//       if (line.contains('Alamat') ||
//           RegExp(r'\bAlamat\b', caseSensitive: false).hasMatch(line)) {
//         inAddressSection = true;
//         if (line.contains(':')) {
//           pendingAddress = line.split(':').last.trim();
//         } else if (i + 1 < textLines.length) {
//           // Next line is likely address
//           pendingAddress = textLines[i + 1].trim();
//           i++; // Skip the next line since we've used it
//         }
//       } else if (inAddressSection &&
//           !line.contains('RT') &&
//           !line.contains('Kel') &&
//           !line.contains('Kecamatan') &&
//           !line.contains('Agama')) {
//         // Continue appending to address until we hit another section
//         if (pendingAddress.isNotEmpty) {
//           pendingAddress += ' ' + line;
//         } else {
//           pendingAddress = line;
//         }
//       } else if (inAddressSection) {
//         // Hit a new section, finalize address
//         inAddressSection = false;
//         result.alamat = pendingAddress;
//       }

//       // RT/RW extraction
//       if (line.contains('RT') && line.contains('RW')) {
//         final rtRwPattern = RegExp(r'(\d{3})[/\s]*(\d{3})');
//         final match = rtRwPattern.firstMatch(line);
//         if (match != null) {
//           result.rtRw = '${match.group(1)}/${match.group(2)}';
//         } else if (i + 1 < textLines.length) {
//           // Check next line
//           final nextLine = textLines[i + 1].trim();
//           final nextMatch = rtRwPattern.firstMatch(nextLine);
//           if (nextMatch != null) {
//             result.rtRw = '${nextMatch.group(1)}/${nextMatch.group(2)}';
//           } else if (RegExp(r'^\d+\/\d+$').hasMatch(nextLine)) {
//             // Format like "007/008"
//             result.rtRw = nextLine;
//           }
//         }
//       } else if (RegExp(r'^(\d{3})[/\s]*(\d{3})$').hasMatch(line) ||
//           RegExp(r'^(\d+)\/(\d+)$').hasMatch(line)) {
//         result.rtRw = line;
//       }

//       // Kel/Desa extraction
//       if (line.contains('Kel') || line.contains('Desa')) {
//         if (line.contains(':')) {
//           result.kelurahan = line.split(':').last.trim();
//         } else if (i + 1 < textLines.length) {
//           result.kelurahan = textLines[i + 1].trim();
//         }
//       }

//       // Kecamatan extraction
//       if (line.contains('Kecamatan')) {
//         if (line.contains(':')) {
//           result.kecamatan = line.split(':').last.trim();
//         } else if (i + 1 < textLines.length) {
//           result.kecamatan = textLines[i + 1].trim();
//         }
//       }

//       // Agama extraction
//       if (line.contains('Agama')) {
//         if (line.contains(':')) {
//           result.agama = line.split(':').last.trim();
//         } else if (i + 1 < textLines.length) {
//           result.agama = textLines[i + 1].trim();
//         }
//       } else if (line == 'ISLAM' ||
//           line == 'KRISTEN' ||
//           line == 'KATOLIK' ||
//           line == 'HINDU' ||
//           line == 'BUDHA' ||
//           line == 'KONGHUCU') {
//         result.agama = line;
//       }

//       // Status Perkawinan
//       if (line.contains('Status') || line.contains('Perkawinan')) {
//         if (i + 1 < textLines.length) {
//           final nextLine = textLines[i + 1].trim();
//           if (nextLine == 'KAWIN' ||
//               nextLine == 'BELUM KAWIN' ||
//               nextLine == 'CERAI HIDUP' ||
//               nextLine == 'CERAI MATI') {
//             result.statusPerkawinan = nextLine;
//           }
//         }
//       } else if (line == 'KAWIN' ||
//           line == 'BELUM KAWIN' ||
//           line == 'CERAI HIDUP' ||
//           line == 'CERAI MATI') {
//         result.statusPerkawinan = line;
//       }

//       // Pekerjaan extraction
//       if (line.contains('Pekerjaan')) {
//         if (line.contains(':')) {
//           result.pekerjaan = line.split(':').last.trim();
//         } else if (i + 1 < textLines.length) {
//           result.pekerjaan = textLines[i + 1].trim();
//         }
//       }

//       // Kewarganegaraan extraction
//       if (line.contains('Kewarganegaraan')) {
//         if (line.contains(':')) {
//           result.kewarganegaraan = line.split(':').last.trim();
//         } else if (i + 1 < textLines.length) {
//           result.kewarganegaraan = textLines[i + 1].trim();
//         }
//       } else if (line == 'WNI' || line == 'WNA') {
//         result.kewarganegaraan = line;
//       }
//     }

//     // Finalize address if still pending
//     if (inAddressSection && pendingAddress.isNotEmpty) {
//       result.alamat = pendingAddress;
//     }
//   }

// // Alternatif ekstraksi NIK jika metode utama gagal
//   void _extractNikFromTextLinesAlt(
//       List<String> textLines, CameraResultModel result) {
//     for (final line in textLines) {
//       // Coba temukan pola digit 16 angka di tengah text
//       final matches = RegExp(r'\D*(\d{16})\D*').allMatches(line);
//       for (final match in matches) {
//         final candidate = match.group(1);
//         if (candidate != null && candidate.length == 16) {
//           result.nik = candidate;
//           return;
//         }
//       }
//     }
//   }

// // ===== PARSING FUNCTIONS =====
//   void _parseNikField(String text, CameraResultModel result) {
//     // Pattern 1: "NIK 1234567890123456"
//     if (text.contains('NIK')) {
//       result.nik = text.replaceAll('NIK', '').replaceAll(':', '').trim();
//     }
//     // Pattern 2: 16 digit langsung
//     else if (RegExp(r'^\d{16}$').hasMatch(text)) {
//       result.nik = text;
//     }
//   }

//   void _parseNameField(String text, CameraResultModel result) {
//     if (text.contains('Nama')) {
//       result.nama = text.replaceAll('Nama', '').replaceAll(':', '').trim();
//     }
//     // Jika nama terdeteksi di line berikutnya setelah label
//     else if (result.nama == null && _isAllCaps(text)) {
//       result.nama = text.trim();
//     }
//   }

//   void _parseBirthInfo(String text, CameraResultModel result) {
//     if (text.contains('Tempat/Tgl Lahir')) {
//       final cleanedText =
//           text.replaceAll('Tempat/Tgl Lahir', '').replaceAll(':', '').trim();

//       // Split tempat dan tanggal lahir
//       final parts = cleanedText.split(',');
//       if (parts.length >= 2) {
//         result.tempatLahir = parts[0].trim();
//         result.tanggalLahir = _parseDate(parts[1].trim());
//       }
//     }
//   }

//   void _parseAddressInfo(String text, CameraResultModel result) {
//     final addressKeywords = ['Alamat', 'RT/RW', 'Kel/Desa', 'Kecamatan'];

//     if (text.contains('Alamat')) {
//       result.alamat = text.replaceAll('Alamat', '').replaceAll(':', '').trim();
//     } else if (text.contains('RT/RW')) {
//       result.rtRw = text.replaceAll('RT/RW', '').replaceAll(':', '').trim();
//     } else if (text.contains('Kel/Desa')) {
//       result.kelurahan =
//           text.replaceAll('Kel/Desa', '').replaceAll(':', '').trim();
//     } else if (text.contains('Kecamatan')) {
//       result.kecamatan =
//           text.replaceAll('Kecamatan', '').replaceAll(':', '').trim();
//     }
//     // Jika alamat multi-line
//     else if (result.alamat != null && !addressKeywords.any(text.contains)) {
//       result.alamat = ' $text';
//     }
//   }

//   void _parseMaritalStatus(String text, CameraResultModel result) {
//     const statuses = ['BELUM KAWIN', 'KAWIN', 'CERAI HIDUP', 'CERAI MATI'];
//     final matchedStatus = statuses.firstWhereOrNull((s) => text.contains(s));
//     if (matchedStatus != null) {
//       result.statusPerkawinan = matchedStatus;
//     }
//   }

//   void _parseCitizenship(String text, CameraResultModel result) {
//     if (text.contains('Kewarganegaraan')) {
//       result.kewarganegaraan =
//           text.replaceAll('Kewarganegaraan', '').replaceAll(':', '').trim();
//     } else if (text.contains('WNI') || text.contains('WNA')) {
//       result.kewarganegaraan = text;
//     }
//   }

//   void _postProcessData(CameraResultModel result) {
//     // Bersihkan data nama - hapus karakter khusus
//     if (result.nama != null) {
//       result.nama = result.nama!
//           .replaceAll(
//               RegExp(r'[^a-zA-Z\s]'), ' ') // Ganti karakter khusus dengan spasi
//           .replaceAll(RegExp(r'\s+'), ' ') // Gabungkan multiple spasi
//           .trim()
//           .toUpperCase();
//     }

//     // Bersihkan NIK - hanya angka
//     if (result.nik != null) {
//       result.nik = result.nik!.replaceAll(RegExp(r'[^0-9]'), '');
//       // Validasi panjang NIK
//       if (result.nik!.length != 16) {
//         print('WARNING: NIK length is not 16 digits: ${result.nik!.length}');
//       }
//     }

//     // Format alamat
//     if (result.alamat != null) {
//       result.alamat = result.alamat!
//           .replaceAll(RegExp(r'\s+'), ' ') // Gabungkan multiple spasi
//           .trim();
//     }

//     // Format RT/RW jika perlu
//     if (result.rtRw != null) {
//       // Jika belum dalam format x/y
//       if (!result.rtRw!.contains('/')) {
//         result.rtRw = result.rtRw!.replaceAllMapped(
//           RegExp(r'(\d+)\s*(\d+)'),
//           (match) => '${match[1]}/${match[2]}',
//         );
//       }
//     }
//   }

//   DateTime? _parseDate(String dateString) {
//     try {
//       // Bersihkan string tanggal
//       dateString = dateString.trim().replaceAll(RegExp(r'\s+'), ' ');

//       // Format yang mungkin: dd-mm-yyyy, dd/mm/yyyy, dd mm yyyy, dd.mm.yyyy
//       final List<String> formats = [
//         'dd-MM-yyyy',
//         'dd/MM/yyyy',
//         'dd MM yyyy',
//         'dd.MM.yyyy',
//         'd-MM-yyyy',
//         'd/MM/yyyy',
//         'd MM yyyy',
//         'd.MM.yyyy',
//         'dd-M-yyyy',
//         'dd/M/yyyy',
//         'dd M yyyy',
//         'dd.M.yyyy',
//         'd-M-yyyy',
//         'd/M/yyyy',
//         'd M yyyy',
//         'd.M.yyyy'
//       ];

//       // Coba dengan semua format
//       for (final format in formats) {
//         try {
//           return DateFormat(format).parse(dateString);
//         } catch (_) {
//           // Lanjut ke format berikutnya jika gagal
//         }
//       }

//       // Coba deteksi dengan RegExp untuk format tanggal Indonesia
//       final regexMatch = RegExp(r'(\d{1,2})[-./\s](\d{1,2})[-./\s](\d{4})')
//           .firstMatch(dateString);
//       if (regexMatch != null) {
//         final day = int.parse(regexMatch.group(1)!);
//         final month = int.parse(regexMatch.group(2)!);
//         final year = int.parse(regexMatch.group(3)!);
//         return DateTime(year, month, day);
//       }
//     } catch (e) {
//       print('Gagal parsing tanggal: $e');
//     }
//     return null;
//   }

//   bool _isAllCaps(String text) {
//     return text == text.toUpperCase() && text.contains(RegExp(r'[A-Z]'));
//   }

//   img.Image rotateImageIfNeeded(img.Image image) {
//     // Implementasikan logika rotasi gambar jika diperlukan
//     // Contoh sederhana: rotasi 90 derajat
//     return img.copyRotate(image, 90);
//   }

//   img.Image cropImage(img.Image image, int x, int y, int width, int height) {
//     return img.copyCrop(image, x, y, width, height);
//   }

//   Future<File> saveProcessedImage(img.Image image) async {
//     final directory = await getTemporaryDirectory();
//     final path = '${directory.path}/processed_image.png';
//     final file = File(path);
//     await file.writeAsBytes(img.encodePng(image));
//     return file;
//   }

//   Future<List<TextBlock>> detectText(InputImage inputImage) async {
//     // Inisialisasi TextRecognizer dari package yang benar
//     final textRecognizer = TextRecognizer();

//     // Proses gambar
//     final visionText = await textRecognizer.processImage(inputImage);

//     // Tutup recognizer setelah selesai
//     await textRecognizer.close();

//     return visionText.blocks;
//   }

//   String correctSpelling(String text) {
//     // Implementasikan logika koreksi ejaan di sini
//     // Contoh sederhana:
//     text = text.replaceAll('Tenpat', 'Tempat');
//     text = text.replaceAll('Kelain', 'Kelamin');
//     text = text.replaceAll('Tenpat', 'Tempat');
//     text = text.replaceAll('Nama', 'Nama');
//     text = text.replaceAll('NIK', 'NIK');
//     text = text.replaceAll('Alamat', 'Alamat');
//     text = text.replaceAll('RTRW', 'RT/RW');
//     text = text.replaceAll('KelDesa', 'Kel/Desa');
//     text = text.replaceAll('Kecamatan', 'Kecamatan');
//     text = text.replaceAll('Agama', 'Agama');
//     text = text.replaceAll('Status Perkawinan', 'Status Perkawinan');
//     text = text.replaceAll('Pekeraan', 'Pekerjaan');
//     text = text.replaceAll('Kewarganegaraan', 'Kewarganegaraan');
//     text = text.replaceAll('Berlaku Hingga', 'Berlaku Hingga');
//     text = text.replaceAll('Gol Darah', 'Golongan Darah');
//     text = text.replaceAll('Jenis Kelamin', 'Jenis Kelamin');
//     text = text.replaceAll('Tempat/Tgl Lahir', 'Tempat/Tanggal Lahir');
//     text = text.replaceAll('LahiL', 'Lahir');
//     return text;
//   }

//   Future<XFile?> _takePicture() async {
//     final CameraController? cameraController = _controller;
//     if (cameraController == null || !cameraController.value.isInitialized) {
//       debugPrint('Error: select a camera first.');
//       return null;
//     }
//     if (cameraController.value.isTakingPicture) {
//       // Jika sedang mengambil gambar, jangan lakukan apa-apa.
//       return null;
//     }
//     try {
//       XFile file = await cameraController.takePicture();
//       return file;
//     } on CameraException catch (e) {
//       debugPrint('CameraException: ${e.description}');
//       return null;
//     }
//   }

//   /// Widget kontrol untuk capture foto
//   Widget _captureControlRowWidget() {
//     final CameraController? cameraController = _controller;
//     return Positioned(
//       bottom: 32.0,
//       left: 0,
//       right: 0,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: <Widget>[
//           const SizedBox(width: 36.0),
//           Transform.rotate(
//             angle: math.pi / 2.0, // 90 derajat
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 if (_isProcessingImage)
//                   const Positioned.fill(
//                     child: CircularProgressIndicator(
//                       strokeWidth: 8.0,
//                     ),
//                   ),
//                 InkWell(
//                   child: Container(
//                     width: 50,
//                     height: 50,
//                     decoration: const BoxDecoration(
//                       color: Colors.white70,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                   onTap: cameraController != null &&
//                           cameraController.value.isInitialized &&
//                           !_isProcessingImage
//                       ? _onTakePictureButtonPressed
//                       : null,
//                 ),
//               ],
//             ),
//           ),
//           Transform.rotate(
//             angle: math.pi / 2.0,
//             child: IconButton(
//               icon: const Icon(Icons.switch_camera),
//               color: Colors.white70,
//               onPressed: cameraController != null &&
//                       cameraController.value.isInitialized &&
//                       !_isProcessingImage
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
//       _cameraDirection = _cameraDirection == CameraLensDirection.back
//           ? CameraLensDirection.front
//           : CameraLensDirection.back;
//     });
//     CameraDescription? cameraDescription;
//     for (CameraDescription camDesc in _cameras) {
//       if (camDesc.lensDirection == _cameraDirection) {
//         cameraDescription = camDesc;
//         break;
//       }
//     }
//     if (cameraDescription != null) {
//       _onNewCameraSelected(cameraDescription);
//     }
//   }

//   Future<void> _onNewCameraSelected(CameraDescription cameraDescription) async {
//     await _controller?.dispose();
//     _controller = CameraController(
//       cameraDescription,
//       ResolutionPreset.medium,
//       enableAudio: false,
//     );
//     _controller?.addListener(() {
//       if (mounted) setState(() {});
//       if (_controller?.value.hasError == true) {
//         debugPrint('Camera error: ${_controller?.value.errorDescription}');
//       }
//     });
//     try {
//       await _controller?.initialize();
//       await _controller?.setFlashMode(FlashMode.off);
//     } on CameraException catch (e) {
//       debugPrint('CameraException during initialization: ${e.description}');
//     }
//     if (mounted) {
//       setState(() {});
//     }
//   }

//   @override
//   void dispose() {
//     _controller?.dispose();
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     // Jika kamera belum diinisialisasi, tidak perlu menangani lifecycle
//     if (_controller == null || !_controller!.value.isInitialized) {
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
//               child: CircularProgressIndicator(),
//             )
//           : _buildCameraPreview(),
//     );
//   }

//   Widget _buildCamera() {
//     final mediaSize = MediaQuery.of(context).size;
//     // Penyesuaian scale untuk menghindari distorsi preview
//     final scale = 1 / (_controller!.value.aspectRatio * mediaSize.aspectRatio);

//     return ClipRect(
//       // Pastikan Anda sudah mendefinisikan MediaSizeClipper, atau ganti dengan clipper yang sesuai
//       clipper: MediaSizeClipper(mediaSize),
//       child: Transform.scale(
//         scale: scale,
//         alignment: Alignment.topCenter,
//         child: CameraPreview(_controller!),
//       ),
//     );
//   }

//   /// UPDATED: Panggil buildFilter dengan mengoper _detectionResult
//   _buildCameraPreview() {
//     final size = MediaQuery.of(context).size;
//     return SizedBox.expand(
//       child: Stack(
//         children: [
//           _buildCamera(),
//           widget.buildFilter(context, _detectionResult),
//           _captureControlRowWidget(),
//         ],
//       ),
//     );
//   }

//   Widget buildFilter(BuildContext context) {
//     final mediaSize = MediaQuery.of(context).size;
//     final isSelfie = widget.cameraFilter ==
//         'selfie'; // Sesuaikan dengan kondisi filter selfie

//     return CustomPaint(
//       painter: SelfieFramePainter(
//         screenSize: mediaSize,
//         showKtpFrame: !isSelfie, // Tampilkan kotak KTP hanya jika bukan selfie
//       ),
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
//     this.detectedTextBoxes, // Parameter baru untuk bounding box OCR
//   });

//   final Size screenSize;
//   final Color outerFrameColor;
//   final Color innerFrameColor;
//   final double innerFrameStrokeWidth;
//   final bool closeWindow;
//   final List<Rect>? detectedTextBoxes; // Bounding box OCR

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

//     canvas.drawPath(path, paint);

//     // Jika ada bounding box hasil OCR, gambar overlay kotak di setiap area
//     if (detectedTextBoxes != null) {
//       final boxPaint = Paint()
//         ..color = Colors.redAccent
//         ..strokeWidth = 2.0
//         ..style = PaintingStyle.stroke;
//       for (Rect rect in detectedTextBoxes!) {
//         canvas.drawRect(rect, boxPaint);
//       }
//     }
//   }

//   @override
//   bool shouldRepaint(KtpFramePainter oldDelegate) =>
//       oldDelegate.closeWindow != closeWindow ||
//       oldDelegate.detectedTextBoxes != detectedTextBoxes;
// }

// class SelfieFramePainter extends CustomPainter {
//   SelfieFramePainter(
//       {required this.screenSize,
//       this.outerFrameColor = Colors.white54,
//       this.innerFrameColor = const Color(0xFF442C2E),
//       this.innerFrameStrokeWidth = 3,
//       this.closeWindow = false,
//       this.showKtpFrame =
//           false // Parameter baru untuk mengontrol tampilan KTP frame
//       });

//   final Size screenSize;
//   final Color outerFrameColor;
//   final Color innerFrameColor;
//   final double innerFrameStrokeWidth;
//   final bool closeWindow;
//   final bool showKtpFrame;

//   @override
//   void paint(Canvas canvas, Size size) {
//     final Paint paint = Paint()..color = outerFrameColor;
//     final Path path = Path();
//     path.fillType = PathFillType.evenOdd;

//     // Draw background
//     path.addRect(Rect.fromLTRB(0.0, 0.0, screenSize.width, screenSize.height));

//     // Draw KTP frame (hanya jika showKtpFrame = true)
//     if (showKtpFrame) {
//       final Offset centerKtp = size.center(
//         Offset(
//           0.00,
//           screenSize.width * 0.2,
//         ),
//       );
//       final ktpWidth = screenSize.width * 0.25;
//       final ktpHeight = ktpWidth / 0.6;

//       final double ktpHalfWidth = ktpWidth / 2;
//       final double ktpHalfHeight = ktpHeight / 2;
//       final ktpRect = Rect.fromLTRB(
//         centerKtp.dx - ktpHalfHeight,
//         centerKtp.dy - ktpHalfWidth,
//         centerKtp.dx + ktpHalfHeight,
//         centerKtp.dy + ktpHalfWidth,
//       );
//       path.addRRect(
//         RRect.fromRectAndRadius(
//           ktpRect,
//           Radius.circular(16.0),
//         ),
//       );
//       Paint paintBorder = Paint()
//         ..color = Colors.white
//         ..strokeWidth = 4.0
//         ..style = PaintingStyle.stroke;
//       canvas.drawRRect(
//         RRect.fromRectAndRadius(
//           ktpRect,
//           Radius.circular(16.0),
//         ),
//         paintBorder,
//       );
//     }
//     // Draw face frame
//     final radius = screenSize.width * 0.6 / 2;
//     final Offset centerFace = size.center(
//       Offset(
//         0.0,
//         -screenSize.height / 5,
//       ),
//     );
//     path.addOval(
//       Rect.fromCircle(center: centerFace, radius: radius),
//     );
//     Paint paintBorder = Paint()
//       ..color = Colors.white
//       ..strokeWidth = 4.0
//       ..style = PaintingStyle.stroke;
//     canvas.drawCircle(centerFace, radius, paintBorder);

//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(SelfieFramePainter oldDelegate) =>
//       oldDelegate.closeWindow != closeWindow ||
//       oldDelegate.showKtpFrame !=
//           showKtpFrame; // Tambahkan showKtpFrame ke shouldRepaint
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

//     final Paint paint = Paint()..color = outerFrameColor;

//     final radius = 200.0;

//     final Path path = Path();
//     path.fillType = PathFillType.evenOdd;
//     path.addRect(Rect.fromLTRB(0.0, 0.0, windowSize.width, windowSize.height));

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


// class CameraKtpScreenArgs {
//   final String cameraFilter;
//   final Future<ResultModel<CameraResultModel>> Function(
//       XFile file, CameraLensDirection cameraLensDirection) onProcessImage;
//   final Future<dynamic> Function(BuildContext context, CameraResultModel result)
//       onPreviewImage;
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
//       onPreviewImage;
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
//     if (_isProcessingImage) return; // Mencegah tap berulang

//     setState(() {
//       _isProcessingImage = true;
//     });

//     _takePicture().then((XFile? file) async {
//       if (!mounted || file == null) {
//         setState(() {
//           _isProcessingImage = false;
//         });
//         return;
//       }

//       try {
//         print('Processing image from path: ${file.path}');

//         // Validasi file ada dan dapat dibaca
//         if (!await File(file.path).exists()) {
//           throw Exception('File tidak ditemukan');
//         }

//         // Proses gambar
//         final result = await widget.onProcessImage(file, _cameraDirection!);

//         if (!mounted) return;

//         setState(() {
//           _isProcessingImage = false;
//         });

//         // Penanganan error yang lebih baik
//         if (!result.isSuccess || result.data == null) {
//           String errorMessage = result.error ?? 'Gagal mendeteksi KTP';
//           print('Image processing failed: $errorMessage');

//           // Pesan error yang lebih spesifik berdasarkan jenis error
//           if (errorMessage.contains('Null check operator')) {
//             errorMessage =
//                 'Beberapa data KTP tidak terbaca dengan jelas. Coba ambil ulang dengan pencahayaan yang lebih baik.';
//           }

//           WidgetUtil.showSnackbar(
//             context,
//             'Pastikan KTP berada dalam bingkai dan pencahayaan cukup. $errorMessage',
//           );
//           return;
//         }

//         // Penanganan sukses dengan pemeriksaan tipe data
//         if (result.data is CameraResultModel) {
//           final previewResult = await widget.onPreviewImage(
//               context, result.data as CameraResultModel);

//           if (previewResult == true) {
//             Navigator.of(context).pop(result.data);
//           }
//         } else {
//           throw Exception('Tipe data hasil tidak sesuai');
//         }
//       } catch (e) {
//         print('Error during image processing: $e');

//         if (mounted) {
//           setState(() {
//             _isProcessingImage = false;
//           });

//           WidgetUtil.showSnackbar(
//             context,
//             'Terjadi kesalahan: ${e.toString()}',
//           );
//         }
//       }
//     }).catchError((error) {
//       print('Error taking picture: $error');

//       if (mounted) {
//         setState(() {
//           _isProcessingImage = false;
//         });

//         WidgetUtil.showSnackbar(
//           context,
//           'Gagal mengambil gambar: ${error.toString()}',
//         );
//       }
//     });
//   }

//   Future<XFile?> _takePicture() async {
//     if (_controller == null || !_controller!.value.isInitialized) {
//       print('Error: Camera not initialized');
//       return null;
//     }

//     if (_controller!.value.isTakingPicture) {
//       print('Error: Already taking picture');
//       return null;
//     }

//     try {
//       // Ensure camera is focused before taking picture
//       await _controller!.setFocusMode(FocusMode.auto);
//       await Future.delayed(Duration(milliseconds: 500));

//       final XFile file = await _controller!.takePicture();
//       return file;
//     } catch (e) {
//       print('Error taking picture: $e');
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
//                           cameraController.value.isInitialized &&
//                           !_isProcessingImage
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
//                       cameraController.value.isInitialized &&
//                       !_isProcessingImage
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

//   Future<void> _onNewCameraSelected(CameraDescription cameraDescription) async {
//     if (_controller != null) {
//       await _controller!.dispose();
//     }

//     try {
//       final CameraController controller = CameraController(
//         cameraDescription,
//         ResolutionPreset.high,
//         enableAudio: false,
//         imageFormatGroup: ImageFormatGroup.jpeg,
//       );

//       _controller = controller;

//       await controller.initialize();

//       // Set optimal camera settings
//       await controller.setFlashMode(FlashMode.off);
//       await controller.setExposureMode(ExposureMode.auto);
//       await controller.setFocusMode(FocusMode.auto);

//       if (mounted) {
//         setState(() {});
//       }
//     } catch (e) {
//       print('Error initializing camera: $e');
//       WidgetUtil.showSnackbar(
//         context,
//         'Gagal menginisialisasi kamera: ${e.toString()}',
//       );
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
//               child: CircularProgressIndicator(),
//             )
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
//         -screenSize.height / 5,
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

//     final Paint paint = Paint()..color = outerFrameColor;

//     final radius = 200.0;

//     final Path path = Path();
//     path.fillType = PathFillType.evenOdd;
//     path.addRect(Rect.fromLTRB(0.0, 0.0, windowSize.width, windowSize.height));

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


// ORIGNINAL

// /// Argument untuk mengirim data ke CameraKtpScreen
// class CameraKtpScreenArgs {
//   final String cameraFilter;
//   final Future<ResultModel<CameraResultModel>> Function(
//       XFile file, CameraLensDirection cameraLensDirection) onProcessImage;
//   final Future<dynamic> Function(BuildContext context, CameraResultModel result)
//       onPreviewImage;

//   final Widget Function(BuildContext context) buildFilter;

//   CameraKtpScreenArgs({
//     required this.cameraFilter,
//     required this.onProcessImage,
//     required this.onPreviewImage,
//     required this.buildFilter,
//   });
// }

// /// Screen untuk kamera KTP
// class CameraKtpScreen extends StatefulWidget {
//   final String cameraFilter;
//   final Future<ResultModel<CameraResultModel>> Function(
//       XFile file, CameraLensDirection cameraLensDirection) onProcessImage;
//   final Future<dynamic> Function(BuildContext context, CameraResultModel result)
//       onPreviewImage;
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
//     WidgetsBinding.instance.addObserver(this);
//   }

//   Future<void> _initCamera() async {
//     _cameras = await availableCameras();
//     if (_cameras.isNotEmpty) {
//       _cameraDirection = _cameras[0].lensDirection;
//       _onNewCameraSelected(_cameras[0]);
//     } else {
//       // Tangani jika tidak ada kamera yang tersedia.
//       debugPrint('No camera available');
//     }
//   }

//   void _onTakePictureButtonPressed() {
//     _takePicture().then((XFile? file) async {
//       if (mounted && file != null) {
//         setState(() {
//           _isProcessingImage = true;
//         });
//         var result = await widget.onProcessImage(file, _cameraDirection!);
//         setState(() {
//           _isProcessingImage = false;
//         });
//         if (!result.isSuccess) {
//           // Menampilkan pesan kesalahan (gunakan showDialog atau WidgetUtil sesuai kebutuhan)
//           WidgetUtil.showSnackbar(
//             context,
//             result.error ?? 'Gagal mendeteksi KTP. Mohon ulangi sekali lagi.',
//           );
//         } else {
//           widget
//               .onPreviewImage(context, result.data as CameraResultModel)
//               .then((value) {
//             if (value == true) {
//               Navigator.of(context).pop(result.data);
//             }
//           });
//         }
//       }
//     });
//   }

//   Future<XFile?> _takePicture() async {
//     final CameraController? cameraController = _controller;
//     if (cameraController == null || !cameraController.value.isInitialized) {
//       debugPrint('Error: select a camera first.');
//       return null;
//     }
//     if (cameraController.value.isTakingPicture) {
//       // Jika sedang mengambil gambar, jangan lakukan apa-apa.
//       return null;
//     }
//     try {
//       XFile file = await cameraController.takePicture();
//       return file;
//     } on CameraException catch (e) {
//       debugPrint('CameraException: ${e.description}');
//       return null;
//     }
//   }

//   /// Widget kontrol untuk capture foto
//   Widget _captureControlRowWidget() {
//     final CameraController? cameraController = _controller;
//     return Positioned(
//       bottom: 32.0,
//       left: 0,
//       right: 0,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: <Widget>[
//           const SizedBox(width: 36.0),
//           Transform.rotate(
//             angle: math.pi / 2.0, // 90 derajat
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 if (_isProcessingImage)
//                   const Positioned.fill(
//                     child: CircularProgressIndicator(
//                       strokeWidth: 8.0,
//                     ),
//                   ),
//                 InkWell(
//                   child: Container(
//                     width: 50,
//                     height: 50,
//                     decoration: const BoxDecoration(
//                       color: Colors.white70,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                   onTap: cameraController != null &&
//                           cameraController.value.isInitialized &&
//                           !_isProcessingImage
//                       ? _onTakePictureButtonPressed
//                       : null,
//                 ),
//               ],
//             ),
//           ),
//           Transform.rotate(
//             angle: math.pi / 2.0,
//             child: IconButton(
//               icon: const Icon(Icons.switch_camera),
//               color: Colors.white70,
//               onPressed: cameraController != null &&
//                       cameraController.value.isInitialized &&
//                       !_isProcessingImage
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
//       _cameraDirection = _cameraDirection == CameraLensDirection.back
//           ? CameraLensDirection.front
//           : CameraLensDirection.back;
//     });
//     CameraDescription? cameraDescription;
//     for (CameraDescription camDesc in _cameras) {
//       if (camDesc.lensDirection == _cameraDirection) {
//         cameraDescription = camDesc;
//         break;
//       }
//     }
//     if (cameraDescription != null) {
//       _onNewCameraSelected(cameraDescription);
//     }
//   }

//   Future<void> _onNewCameraSelected(CameraDescription cameraDescription) async {
//     await _controller?.dispose();
//     _controller = CameraController(
//       cameraDescription,
//       ResolutionPreset.medium,
//       enableAudio: false,
//     );
//     _controller?.addListener(() {
//       if (mounted) setState(() {});
//       if (_controller?.value.hasError == true) {
//         debugPrint('Camera error: ${_controller?.value.errorDescription}');
//       }
//     });
//     try {
//       await _controller?.initialize();
//       await _controller?.setFlashMode(FlashMode.off);
//     } on CameraException catch (e) {
//       debugPrint('CameraException during initialization: ${e.description}');
//     }
//     if (mounted) {
//       setState(() {});
//     }
//   }

//   @override
//   void dispose() {
//     _controller?.dispose();
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     // Jika kamera belum diinisialisasi, tidak perlu menangani lifecycle
//     if (_controller == null || !_controller!.value.isInitialized) {
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
//           ? const Center(child: CircularProgressIndicator())
//           : _buildCameraPreview(),
//     );
//   }

//   Widget _buildCamera() {
//     final mediaSize = MediaQuery.of(context).size;
//     // Penyesuaian scale untuk menghindari distorsi preview
//     final scale = 1 / (_controller!.value.aspectRatio * mediaSize.aspectRatio);

//     return ClipRect(
//       // Pastikan Anda sudah mendefinisikan MediaSizeClipper, atau ganti dengan clipper yang sesuai
//       clipper: MediaSizeClipper(mediaSize),
//       child: Transform.scale(
//         scale: scale,
//         alignment: Alignment.topCenter,
//         child: CameraPreview(_controller!),
//       ),
//     );
//   }

//   Widget _buildCameraPreview() {
//     return Stack(
//       children: [
//         _buildCamera(),
//         widget.buildFilter(context),
//         _captureControlRowWidget(),
//       ],
//     );
//   }
// }

// /// CustomPainter untuk menggambar frame KTP
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
//     final double radius = 200.0;

//     final Path path = Path()..fillType = PathFillType.evenOdd;

//     // Gambar latar belakang
//     path.addRect(Rect.fromLTWH(0, 0, screenSize.width, screenSize.height));

//     // Gambar frame KTP
//     final double ktpWidth = screenSize.height * 0.7;
//     final double ktpHeight = ktpWidth * 0.6;
//     final double ktpHalfWidth = ktpWidth / 2;
//     final double ktpHalfHeight = ktpHeight / 2;
//     final Rect ktpRect = Rect.fromLTRB(
//       center.dx - ktpHalfWidth,
//       center.dy - ktpHalfHeight,
//       center.dx + ktpHalfWidth,
//       center.dy + ktpHalfHeight,
//     );
//     path.addRRect(
//       RRect.fromRectAndRadius(ktpRect, Radius.circular(radius / 10)),
//     );

//     // Gambar area foto KTP
//     final Rect ktpPhotoRect = Rect.fromLTRB(
//       center.dx - (ktpHeight * (0.95 / 5.5)),
//       center.dy + (ktpWidth * (1.75 / 8.5)),
//       center.dx + (ktpHeight * (1.55 / 5.5)),
//       center.dy + (ktpWidth * (3.75 / 8.5)),
//     );
//     path.addRRect(
//       RRect.fromRectAndRadius(ktpPhotoRect, Radius.circular(radius / 10)),
//     );

//     // Gambar beberapa garis detail pada frame KTP
//     final Rect ktpLineRect1 = Rect.fromLTRB(
//       center.dx + (ktpHeight * (1.40 / 5.5)),
//       center.dy - (ktpWidth * (3.75 / 8.5)),
//       center.dx + (ktpHeight * (1.55 / 5.5)),
//       center.dy,
//     );
//     final Rect ktpLineRect2 = Rect.fromLTRB(
//       center.dx + (ktpHeight * (1.05 / 5.5)),
//       center.dy - (ktpWidth * (3.75 / 8.5)),
//       center.dx + (ktpHeight * (1.20 / 5.5)),
//       center.dy,
//     );
//     final Rect ktpLineRect3 = Rect.fromLTRB(
//       center.dx + (ktpHeight * (0.70 / 5.5)),
//       center.dy - (ktpWidth * (3.75 / 8.5)),
//       center.dx + (ktpHeight * (0.85 / 5.5)),
//       center.dy - (ktpWidth * (0.5 / 8.5)),
//     );
//     final Rect ktpLineRect4 = Rect.fromLTRB(
//       center.dx + (ktpHeight * (0.35 / 5.5)),
//       center.dy - (ktpWidth * (3.75 / 8.5)),
//       center.dx + (ktpHeight * (0.50 / 5.5)),
//       center.dy - (ktpWidth * (0.5 / 8.5)),
//     );
//     // (Jika diperlukan, baris berikut bisa diaktifkan)
//     // final Rect ktpLineRect5 = Rect.fromLTRB(
//     //   center.dx + (ktpHeight * (0.15 / 5.5)),
//     //   center.dy - (ktpWidth * (3.75 / 8.5)),
//     //   center.dx + (ktpHeight * (0.35 / 5.5)),
//     //   center.dy - (ktpWidth * (0.5 / 8.5)),
//     // );

//     path.addRRect(
//       RRect.fromRectAndRadius(ktpLineRect1, Radius.circular(radius / 4)),
//     );
//     path.addRRect(
//       RRect.fromRectAndRadius(ktpLineRect2, Radius.circular(radius / 4)),
//     );
//     path.addRRect(
//       RRect.fromRectAndRadius(ktpLineRect3, Radius.circular(radius / 4)),
//     );
//     path.addRRect(
//       RRect.fromRectAndRadius(ktpLineRect4, Radius.circular(radius / 4)),
//     );
//     // path.addRRect(
//     //   RRect.fromRectAndRadius(ktpLineRect5, Radius.circular(radius / 4)),
//     // );

//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(KtpFramePainter oldDelegate) {
//     return oldDelegate.closeWindow != closeWindow ||
//         oldDelegate.outerFrameColor != outerFrameColor ||
//         oldDelegate.screenSize != screenSize;
//   }
// }

// /// CustomPainter untuk menggambar frame Selfie
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
//     final Path path = Path()..fillType = PathFillType.evenOdd;

//     // Gambar latar belakang
//     path.addRect(Rect.fromLTWH(0, 0, screenSize.width, screenSize.height));

//     // Gambar frame KTP kecil (sebagai contoh)
//     final Offset centerKtp = size.center(Offset(0, screenSize.width * 0.2));
//     final double ktpWidth = screenSize.width * 0.25;
//     final double ktpHeight = ktpWidth / 0.6;
//     final Rect ktpRect = Rect.fromCenter(
//       center: centerKtp,
//       width: ktpWidth,
//       height: ktpHeight,
//     );
//     path.addRRect(
//       RRect.fromRectAndRadius(ktpRect, const Radius.circular(16.0)),
//     );
//     final Paint paintBorder = Paint()
//       ..color = Colors.white
//       ..strokeWidth = 4.0
//       ..style = PaintingStyle.stroke;
//     canvas.drawRRect(
//       RRect.fromRectAndRadius(ktpRect, const Radius.circular(16.0)),
//       paintBorder,
//     );

//     // Gambar frame wajah (selfie)
//     final double radius = screenSize.width * 0.6 / 2;
//     final Offset centerFace = size.center(Offset(0, -screenSize.height / 5));
//     path.addOval(Rect.fromCircle(center: centerFace, radius: radius));
//     canvas.drawCircle(centerFace, radius, paintBorder);

//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(SelfieFramePainter oldDelegate) {
//     return oldDelegate.closeWindow != closeWindow ||
//         oldDelegate.screenSize != screenSize;
//   }
// }

// /// CustomPainter lama untuk window (contoh)
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
//     final Paint paint = Paint()..color = outerFrameColor;

//     final double radius = 200.0;
//     final Path path = Path()..fillType = PathFillType.evenOdd;
//     path.addRect(Rect.fromLTWH(0, 0, windowSize.width, windowSize.height));
//     path.addRRect(
//       RRect.fromRectAndRadius(
//         Rect.fromCircle(center: center, radius: radius / 2),
//         Radius.circular(radius / 10),
//       ),
//     );
//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(WindowPainterOld oldDelegate) {
//     return oldDelegate.closeWindow != closeWindow ||
//         oldDelegate.windowSize != windowSize;
//   }
// }

// /// Kelas Rectangle untuk perhitungan ukuran
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
//     final Color color = t > 0.5
//         ? Color.lerp(begin.color, end.color, (t - 0.5) / 0.25)!
//         : begin.color;
//     return Rectangle(
//       width: lerpDouble(begin.width, end.width, t)!,
//       height: lerpDouble(begin.height, end.height, t)!,
//       color: color,
//     );
//   }
// }

