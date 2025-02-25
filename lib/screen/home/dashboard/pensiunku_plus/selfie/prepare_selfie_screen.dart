import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:pensiunku/model/selfie_model.dart';
import 'package:pensiunku/model/submission_model.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/ktp/camera_ktp_screen.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/selfie/preview_selfie_screen.dart';
// import 'package:pensiunku/screen/ktp/camera_ktp_screen.dart';
import 'package:pensiunku/util/firebase_vision_util.dart';
import 'package:pensiunku/util/widget_util.dart';
import 'package:permission_handler/permission_handler.dart';

class PrepareSelfieScreen extends StatefulWidget {
  // Nama rute untuk navigasi
  static const String ROUTE_NAME = '/selfie/prepare';

  // Callback ketika proses selfie berhasil
  final void Function(BuildContext context) onSuccess;
  
  // Model data submission yang diperlukan
  final SubmissionModel submissionModel;

  const PrepareSelfieScreen({
    Key? key,
    required this.onSuccess,
    required this.submissionModel,
  }) : super(key: key);

  @override
  _PrepareSelfieScreenState createState() => _PrepareSelfieScreenState();
}

class _PrepareSelfieScreenState extends State<PrepareSelfieScreen> {
  // Konstanta untuk ukuran dan padding
  static const double _logoHeight = 100.0;
  static const double _instructionImageHeight = 257.0;
  static const double _horizontalPadding = 24.0;
  
  // Status visibility bottom navigation bar
  bool _isBottomNavBarVisible = false;

  @override
  void initState() {
    super.initState();
    _initializeBottomNavBar();
  }

  // Inisialisasi bottom navigation bar
  void _initializeBottomNavBar() {
    Future.delayed(Duration.zero, () {
      setState(() => _isBottomNavBarVisible = true);
    });
  }

  // Warna untuk gradient background
  static const List<Color> _gradientColors = [
    Colors.white,
    Colors.white,
    Colors.white,
    Color.fromARGB(255, 233, 208, 127),
  ];

  // Posisi stop untuk gradient
  static const List<double> _gradientStops = [0.25, 0.5, 0.75, 1.0];

  // Widget untuk background gradient
  Widget _buildBackground() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _gradientColors,
            stops: _gradientStops,
          ),
        ),
      ),
    );
  }

  // Widget untuk logo aplikasi
  Widget _buildLogo() {
    return Center(
      child: Column(
        children: [
          Image.asset(
            'assets/pensiunkuplus/pensiunku.png',
            height: _logoHeight,
          ),
          const SizedBox(height: 0),
        ],
      ),
    );
  }

  // Widget untuk gambar instruksi selfie
  Widget _buildInstructionImage() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
      child: Center(
        child: SizedBox(
          height: _instructionImageHeight,
          child: Image.asset(
            'assets/document/selfie_new.png',
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }

  // Widget untuk teks instruksi
  Widget _buildInstructions(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16.0),
          Text(
            'Mohon untuk menangkap foto sesuai frame objek yang telah ditentukan. '
            'Jangan lupa pastikan Anda memiliki cahaya dan posisi yang cukup untuk '
            'menghasilkan foto yang baik. Foto yang jelas memudahkan kami untuk '
            'melakukan verifikasi pengajuan Anda.',
            textAlign: TextAlign.justify,
            style: theme.textTheme.bodyText2,
          ),
          const SizedBox(height: 24.0),
          Text(
            '*Sebelum mengambil foto, mohon pastikan Rotation Lock/Kunci Rotasi '
            'pada Hp anda telah aktif!',
            style: theme.textTheme.bodyText1?.copyWith(color: Colors.red),
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 28.0),
          _buildTakePhotoButton(),
        ],
      ),
    );
  }

  // Widget untuk tombol ambil foto
  Widget _buildTakePhotoButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _handleCameraNavigation,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 32.0,
            vertical: 12.0,
          ),
        ),
        child: const Text('Ambil Foto'),
      ),
    );
  }

  // Method untuk menangani navigasi ke kamera
  Future<void> _handleCameraNavigation() async {
    try {
      // Cek izin kamera
      var status = await Permission.camera.status;
      if (status.isDenied) {
        status = await Permission.camera.request();
      }

      if (!mounted) return;

      if (status.isGranted) {
        // Navigasi ke layar kamera jika izin diberikan
        final result = await Navigator.of(context, rootNavigator: true).pushNamed(
          CameraKtpScreen.ROUTE_NAME,
          arguments: CameraKtpScreenArgs(
            cameraFilter: 'assets/selfie_filter.png',
            buildFilter: (context) {
              return Container(
                constraints: const BoxConstraints.expand(),
                child: CustomPaint(
                  painter: SelfieFramePainter(
                    screenSize: MediaQuery.of(context).size,
                    outerFrameColor: Color(0x73442C2E),
                    closeWindow: false,
                    innerFrameColor: Colors.transparent,
                  ),
                ),
              );
            },
            onProcessImage: (file, cameraLensDirection) =>
                FirebaseVisionUtils.getSelfieVisionDataFromImage(
              file,
              imageRotation:
                  cameraLensDirection == CameraLensDirection.back ? 0 : 0,
            ),
            onPreviewImage: (pageContext, selfieModel) {
              return Navigator.of(pageContext).pushNamed(
                PreviewSelfieScreen.ROUTE_NAME,
                arguments: PreviewSelfieScreenArgs(
                  selfieModel: selfieModel as SelfieModel,
                  submissionModel: widget.submissionModel,
                ),
              );
            },
          ),
        );

        // Panggil callback onSuccess jika berhasil
        if (result != null && mounted) {
          widget.onSuccess(context);
        }
      } else {
        // Tampilkan opsi settings jika izin ditolak
        if (mounted) {
          WidgetUtil.showSnackbar(
            context,
            'Tolong izinkan Pensiunku untuk mengakses kamera Anda.',
            snackbarAction: SnackBarAction(
              label: 'Pengaturan',
              onPressed: () {
                openAppSettings();
              },
            ),
          );
        }
      }
    } catch (e) {
      print('Error saat mengakses kamera: $e');
      if (mounted) {
        WidgetUtil.showSnackbar(
          context,
          'Terjadi kesalahan saat mengakses kamera',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  Container(height: size.height),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildLogo(),
                      _buildInstructionImage(),
                      _buildInstructions(theme),
                      const SizedBox(height: 80.0),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// class PrepareSelfieScreenArguments {
//   final void Function(BuildContext context) onSuccess;
//   final SubmissionModel submissionModel;

//   PrepareSelfieScreenArguments({
//     required this.onSuccess,
//     required this.submissionModel,
//   });
// }

// class PrepareSelfieScreen extends StatefulWidget {
//   static const String ROUTE_NAME = '/selfie/prepare';

//   final void Function(BuildContext context) onSuccess;
//   final SubmissionModel submissionModel;

//   const PrepareSelfieScreen({
//     Key? key,
//     required this.onSuccess,
//     required this.submissionModel,
//   }) : super(key: key);

//   @override
//   _PrepareSelfieScreenState createState() => _PrepareSelfieScreenState();
// }

// class _PrepareSelfieScreenState extends State<PrepareSelfieScreen> {
//   bool _isBottomNavBarVisible = false;

//   @override
//   void initState() {
//     super.initState();

//     Future.delayed(Duration(milliseconds: 0), () {
//       setState(() {
//         _isBottomNavBarVisible = true;
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     ThemeData theme = Theme.of(context);

//     return Scaffold(
//       appBar: WidgetUtil.getNewAppBar(context, 'Informasi Identitas', 1,
//           (newIndex) {
//         Navigator.of(context).pop(newIndex);
//       }, () {
//         Navigator.of(context).pop();
//       }, useNotificationIcon: false),
//       body: Stack(
//         children: [
//           SingleChildScrollView(
//             child: Stack(
//               children: [
//                 Container(
//                   height: MediaQuery.of(context).size.height -
//                       AppBar().preferredSize.height,
//                 ),
//                 Column(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                         vertical: 32.0,
//                         horizontal: 24.0,
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.stretch,
//                         children: [
//                           SizedBox(
//                             child: Image.asset(
//                               'assets/document/selfie_new.png',
//                               fit: BoxFit.fill,
//                             ),
//                             height: 200,
//                           ),
//                           SizedBox(height: 16.0),
//                           Text(
//                               'Mohon untuk menangkap foto sesuai frame objek yang telah ditentukan. Jangan lupa pastikan Anda memiliki cahaya dan posisi yang cukup untuk menghasilkan foto yang baik. Foto yang jelas memudahkan kami untuk melakukan verifikasi pengajuan Anda.'),
//                           SizedBox(height: 24.0),
//                           Text(
//                             '*Sebelum mengambil foto, mohon pastikan Rotation Lock/Kunci Rotasi pada Hp anda telah aktif!',
//                             style: theme.textTheme.headline2?.copyWith(
//                               color: Colors.red,
//                             ),
//                           ),
//                           SizedBox(height: 28.0),
//                           Align(
//                             alignment: Alignment.center,
//                             child: ElevatedButton(
//                               onPressed: () {
//                                 Navigator.of(
//                                   context,
//                                   rootNavigator: true,
//                                 )
//                                     .pushNamed(PermissionScreen.ROUTE_NAME)
//                                     .then((permissionStatus) {
//                                   switch (permissionStatus) {
//                                     case PermissionStatus.granted:
//                                       Navigator.of(
//                                         context,
//                                         rootNavigator: true,
//                                       )
//                                           .pushNamed(
//                                         CameraKtpScreen.ROUTE_NAME,
//                                         arguments: CameraKtpScreenArgs(
//                                           cameraFilter:
//                                               'assets/selfie_filter.png',
//                                           buildFilter: (context) {
//                                             return Container(
//                                               constraints:
//                                                   const BoxConstraints.expand(),
//                                               child: CustomPaint(
//                                                 painter: SelfieFramePainter(
//                                                   screenSize:
//                                                       MediaQuery.of(context)
//                                                           .size,
//                                                   outerFrameColor:
//                                                       Color(0x73442C2E),
//                                                   closeWindow: false,
//                                                   innerFrameColor:
//                                                       Colors.transparent,
//                                                   // offset: Offset(faceBoxOffsetX, 0),
//                                                 ),
//                                               ),
//                                             );
//                                           },
//                                           onProcessImage: (file,
//                                                   cameraLensDirection) =>
//                                               FirebaseVisionUtils
//                                                   .getSelfieVisionDataFromImage(
//                                             file,
//                                             imageRotation:
//                                                 cameraLensDirection ==
//                                                         CameraLensDirection.back
//                                                     ? 0
//                                                     : 0,
//                                           ),
//                                           onPreviewImage:
//                                               (pageContext, selfieModel) {
//                                             return Navigator.of(pageContext)
//                                                 .pushNamed(
//                                               PreviewSelfieScreen.ROUTE_NAME,
//                                               arguments:
//                                                   PreviewSelfieScreenArgs(
//                                                 selfieModel:
//                                                     selfieModel as SelfieModel,
//                                                 submissionModel:
//                                                     widget.submissionModel,
//                                               ),
//                                             );
//                                           },
//                                         ),
//                                       )
//                                           .then((returnValue) {
//                                         // print('returnValue: $returnValue');
//                                         if (returnValue != null) {
//                                           // User completes Selfie
//                                           widget.onSuccess(context);
//                                         }
//                                       });
//                                       break;
//                                     case PermissionStatus.limited:
//                                     case PermissionStatus.denied:
//                                     case PermissionStatus.permanentlyDenied:
//                                     case PermissionStatus.restricted:
//                                     default:
//                                       WidgetUtil.showSnackbar(
//                                         context,
//                                         'Tolong izinkan Pensiunku untuk mengakses kamera Anda.',
//                                         snackbarAction: SnackBarAction(
//                                           label: 'Pengaturan',
//                                           onPressed: () {
//                                             openAppSettings();
//                                           },
//                                         ),
//                                       );
//                                   }
//                                 });
//                               },
//                               child: Text('Ambil Foto'),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(height: 80.0),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
