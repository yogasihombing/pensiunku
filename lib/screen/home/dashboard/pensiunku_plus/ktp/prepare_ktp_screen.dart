import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pensiunku/model/camera_result_model.dart';
import 'package:pensiunku/model/ktp_model.dart';
import 'package:pensiunku/model/submission_model.dart';
import 'package:pensiunku/repository/result_model.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/ktp/camera_ktp_screen.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/ktp/confirm_ktp_screen.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/ktp/preview_ktp_screen.dart';
import 'package:pensiunku/screen/permission/permission_screen.dart';
import 'package:pensiunku/util/firebase_vision_util.dart';
import 'package:pensiunku/util/widget_util.dart';
import 'package:permission_handler/permission_handler.dart';

final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: const Color(0xFF16826E),
  padding: const EdgeInsets.all(10.0),
  disabledForegroundColor: const Color(0xFFF29724).withOpacity(0.38),
  disabledBackgroundColor: const Color(0xFFF29724).withOpacity(0.12),
  textStyle: const TextStyle(color: Colors.white),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
  ),
);

class PrepareKtpScreenArguments {
  final SubmissionModel submissionModel;
  final void Function(BuildContext context) onSuccess;

  PrepareKtpScreenArguments({
    required this.submissionModel,
    required this.onSuccess,
  });
}

class PrepareKtpScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/ktp/prepare';

  final SubmissionModel submissionModel;
  final void Function(BuildContext context) onSuccess;

  const PrepareKtpScreen({
    Key? key,
    required this.submissionModel,
    required this.onSuccess,
  }) : super(key: key);

  @override
  _PrepareKtpScreenState createState() => _PrepareKtpScreenState();
}

class _PrepareKtpScreenState extends State<PrepareKtpScreen> {
  // Variabel ini dapat digunakan jika nanti ingin mengatur tampilan bottom navigation bar
  bool _isBottomNavBarVisible = false;
  bool _isLoadingOverlay = false;


  // Constants
  static const double _logoHeight = 50.0;
  static const double _instructionImageHeight = 150.0;
  static const List<Color> _gradientColors = [
    Colors.white,
    Colors.white,
    Colors.white,
    Color.fromARGB(255, 233, 208, 127),
  ];
  static const List<double> _gradientStops = [0.25, 0.5, 0.75, 1.0];

  @override
  void initState() {
    super.initState();
    // Tampilkan bottom nav bar (jika diperlukan) setelah build awal
    Future.delayed(Duration.zero, () {
      setState(() => _isBottomNavBarVisible = true);
    });
  }

  // Widget builder untuk header yang berisi tombol back dan progress indicator
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF006C4E)),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: 0.5,
              backgroundColor: Colors.grey[300],
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF006C4E)),
            ),
          ),
        ],
      ),
    );
  }

  // Widget builder untuk background gradient
  Widget _buildBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _gradientColors,
          stops: _gradientStops,
        ),
      ),
    );
  }

  // Widget builder untuk logo
  Widget _buildLogo({
    double? height,
    Alignment alignment = Alignment.center,
    EdgeInsetsGeometry? padding,
  }) {
    double effectiveHeight = height ?? _logoHeight;
    return Padding(
      padding: padding ?? const EdgeInsets.only(top: 8.0),
      child: Align(
        alignment: alignment,
        child: SizedBox(
          height: effectiveHeight,
          child: Image.asset(
            'assets/pensiunkuplus/pensiunku.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  // Widget builder untuk instruksi tampilan
  Widget _buildInstructionImage() {
    return Padding(
      padding: const EdgeInsets.only(top: 0.0, bottom: 5.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/pensiunkuplus/uploadktp.png', // Gunakan asset untuk foto KTP
              height: _instructionImageHeight,
              // fit: BoxFit.fill,
            ),
            const Text(
              'Ambil foto KTP',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method untuk membuka gallery (jika diperlukan)
  void _openGallery() async {
    var picture = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picture != null) {
      setState(() {});
    }
    Navigator.pop(context);
  }

  // Dialog yang menjelaskan cara pengambilan foto KTP yang tepat
  Future<void> _showDescriptionDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Cara Pengambilan Foto KTP Yang Tepat',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('\u2022 Pencahayaan terang'),
                const SizedBox(height: 5),
                const Text(
                    '\u2022 Posisikan KTP sesuaikan informasi KTP sejajar dengan tanda garis'),
                const SizedBox(height: 5),
                const Text(
                    '\u2022 Letakkan foto sejajar atau letakkan tepat masuk dalam kotak'),
                const SizedBox(height: 5),
                const Text(
                    '\u2022 Gunakan KTP yang jelas tidak Blur sehingga data dapat terbaca oleh sistem'),
                const SizedBox(height: 5),
                ElevatedButton(
                  style: raisedButtonStyle,
                  onPressed: () => _handleCameraPermission(context),
                  child: const Text('Open Camera'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Menangani pengecekan izin akses kamera.
  void _handleCameraPermission(BuildContext context) {
    Navigator.of(context, rootNavigator: true)
        .pushNamed(PermissionScreen.ROUTE_NAME)
        .then((permissionStatus) {
      switch (permissionStatus) {
        case PermissionStatus.granted:
          _openKtpCamera(context);
          break;
        case PermissionStatus.limited:
        case PermissionStatus.denied:
        case PermissionStatus.permanentlyDenied:
        case PermissionStatus.restricted:
        default:
          WidgetUtil.showSnackbar(
            context,
            'Tolong izinkan pensiunku untuk mengakses kamera Anda.',
            snackbarAction: SnackBarAction(
              label: 'Pengaturan',
              onPressed: () => openAppSettings(),
            ),
          );
      }
    });
  }

  /// Membuka halaman kamera untuk mengambil foto KTP.
  void _openKtpCamera(BuildContext context) {
    Navigator.of(context, rootNavigator: true)
        .pushNamed(
          CameraKtpScreen.ROUTE_NAME,
          arguments: CameraKtpScreenArgs(
            cameraFilter: 'assets/ktp_filter.png',
            buildFilter: (context) {
              return Container(
                constraints: const BoxConstraints.expand(),
                child: CustomPaint(
                  painter: KtpFramePainter(
                    screenSize: MediaQuery.of(context).size,
                    outerFrameColor: Color(0x73442C2E),
                    innerFrameColor: Colors.transparent,
                  ),
                ),
              );
            },
            onProcessImage: (file, _) => _processKtpImage(file),
            onPreviewImage: (pageContext, ktpModel) =>
                _previewKtpImage(pageContext, ktpModel as KtpModel),
          ),
        )
        .then((value) => _handleCameraResult(context, value));
  }

  // Widget builder untuk filter KTP yang ditampilkan di kamera
  Widget _buildKtpFilter(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      child: CustomPaint(
        painter: KtpFramePainter(
          screenSize: MediaQuery.of(context).size,
          outerFrameColor: const Color(0x73442C2E),
          innerFrameColor: Colors.transparent,
        ),
      ),
    );
  }

  /// Memproses gambar KTP menggunakan Firebase Vision.
  Future<ResultModel<KtpModel>> _processKtpImage(dynamic file) async{
    setState(() {
    _isLoadingOverlay = true; // Tampilkan loading overlay
  });
    var result = await FirebaseVisionUtils.getKtpVisionDataFromImage(
      file,
      isDrawSearchingArea: false,
      isDrawExtractedArea: true,
    );
    setState(() {
    _isLoadingOverlay = false; // Sembunyikan loading overlay setelah selesai
  });
  return result;
  }

  /// Menampilkan preview dari foto KTP yang telah diambil.
  Future<void> _previewKtpImage(BuildContext context, KtpModel ktpModel) {
    return Navigator.of(context).pushNamed(
      PreviewKtpScreen.ROUTE_NAME,
      arguments: PreviewKtpScreenArgs(ktpModel: ktpModel),
    );
  }

  /// Menangani hasil yang dikembalikan dari halaman kamera.
  void _handleCameraResult(BuildContext context, dynamic value) {
    if (value != null) {
      KtpModel ktpModel = value as KtpModel;
      _navigateToConfirmScreen(context, ktpModel);
    }
  }

  /// Navigasi ke layar konfirmasi setelah berhasil mengambil foto KTP.
  void _navigateToConfirmScreen(BuildContext context, KtpModel ktpModel) {
    Navigator.of(context)
        .pushNamed(
          ConfirmKtpScreen.ROUTE_NAME,
          arguments: ConfirmKtpScreenArgs(
            submissionModel: widget.submissionModel,
            ktpModel: ktpModel,
            onSuccess: (_) => widget.onSuccess(context),
          ),
        )
        .then((returnValue) => _handleConfirmResult(context, returnValue));
  }

  /// Menangani hasil konfirmasi KTP.
  void _handleConfirmResult(BuildContext context, dynamic returnValue) {
    if (returnValue is int) {
      // Jika user memilih item BottomNavBar
      Navigator.of(context).pop(returnValue);
    } else if (returnValue == true) {
      // Jika user menyelesaikan proses KTP
      widget.onSuccess(context);
    }
  }

// Menampilkan pesan jika permission kamera ditolak
  void _showPermissionDeniedMessage() {
    print('Permission kamera ditolak...');
    WidgetUtil.showSnackbar(
      context,
      'Tolong izinkan Pensiunku untuk mengakses kamera Anda.',
      snackbarAction: SnackBarAction(
        label: 'Pengaturan',
        onPressed: openAppSettings,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        // Atur tinggi toolbar agar cukup untuk konten di flexibleSpace
        toolbarHeight: 120.0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(''),
        centerTitle: true,
        automaticallyImplyLeading: false, // Hilangkan back button default
        flexibleSpace: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          // Gunakan mainAxisSize.min agar Column tidak memaksa tinggi penuh
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context),
                _buildLogo(
                  height:
                      _logoHeight, // atau bisa dihilangkan jika ingin menggunakan nilai default
                  alignment: Alignment.center,
                )
              ],
            ),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          _buildBackground(), // Background gradient
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 32.0,
                  horizontal: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Gunakan widget _buildInstructionImage() untuk tampilan instruksi
                    _buildInstructionImage(),
                    const SizedBox(height: 15.0),
                    const Text(
                      'Arahkan kamera Anda tepat sesuai frame yang telah kami tentukan. '
                      'Setelah foto, mohon untuk melakukan verifikasi data KTP anda!',
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 32.0),
                    Center(
                      child: ElevatedButton(
                        style: raisedButtonStyle,
                        onPressed: () {
                          _showDescriptionDialog(context);
                        },
                        child: const Text('Ambil Foto'),
                      ),
                    ),
                    const SizedBox(height: 80.0),
                  ],
                ),
              ),
            ),
          ),
          // Tampilkan loading overlay bila _isLoadingOverlay true
        if (_isLoadingOverlay)
          Stack(
            children: [
              Positioned.fill(
                child: ModalBarrier(
                  color: Colors.black.withOpacity(0.5),
                  dismissible: false,
                ),
              ),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF017964)),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Mohon tunggu...',
                        style: TextStyle(
                          color: Color(0xFF017964),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


// final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
//   backgroundColor: const Color(0xFF16826E),
//   padding: const EdgeInsets.all(10.0),
//   disabledForegroundColor: const Color(0xFFF29724).withOpacity(0.38),
//   disabledBackgroundColor: const Color(0xFFF29724).withOpacity(0.12),
//   textStyle: const TextStyle(color: Colors.white),
//   shape: const RoundedRectangleBorder(
//     borderRadius: BorderRadius.all(Radius.circular(10.0)),
//   ),
// );

// // Arguments class untuk PrepareKtpScreen
// class PrepareKtpScreenArguments {
//   final SubmissionModel submissionModel;
//   final void Function(BuildContext context) onSuccess;

//   PrepareKtpScreenArguments({
//     required this.submissionModel,
//     required this.onSuccess,
//   });
// }

// class PrepareKtpScreen extends StatefulWidget {
//   static const String ROUTE_NAME = '/ktp/prepare';

//   final SubmissionModel submissionModel;
//   final void Function(BuildContext context) onSuccess;

//   const PrepareKtpScreen({
//     Key? key,
//     required this.submissionModel,
//     required this.onSuccess,
//   }) : super(key: key);

//   @override
//   _PrepareKtpScreenState createState() => _PrepareKtpScreenState();
// }

// class _PrepareKtpScreenState extends State<PrepareKtpScreen> {
//   // Variabel ini dapat digunakan jika nanti ingin mengatur tampilan bottom navigation bar
//   bool _isBottomNavBarVisible = false;

//   // Constants
//   static const double _logoHeight = 50.0;
//   static const double _instructionImageHeight = 150.0;
//   static const List<Color> _gradientColors = [
//     Colors.white,
//     Colors.white,
//     Colors.white,
//     Color.fromARGB(255, 233, 208, 127),
//   ];
//   static const List<double> _gradientStops = [0.25, 0.5, 0.75, 1.0];

//   @override
//   void initState() {
//     super.initState();
//     // Tampilkan bottom nav bar (jika diperlukan) setelah build awal
//     Future.delayed(Duration.zero, () {
//       setState(() => _isBottomNavBarVisible = true);
//     });
//   }

//   // Widget builder untuk header yang berisi tombol back dan progress indicator
//   Widget _buildHeader(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//       child: Row(
//         children: [
//           IconButton(
//             icon: const Icon(Icons.arrow_back, color: Color(0xFF006C4E)),
//             onPressed: () => Navigator.pop(context),
//           ),
//           Expanded(
//             child: LinearProgressIndicator(
//               value: 0.5,
//               backgroundColor: Colors.grey[300],
//               valueColor:
//                   const AlwaysStoppedAnimation<Color>(Color(0xFF006C4E)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Widget builder untuk background gradient
//   Widget _buildBackground() {
//     return Container(
//       width: double.infinity,
//       height: double.infinity,
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: _gradientColors,
//           stops: _gradientStops,
//         ),
//       ),
//     );
//   }

//   // Widget builder untuk logo
//   Widget _buildLogo({
//     double? height,
//     Alignment alignment = Alignment.center,
//     EdgeInsetsGeometry? padding,
//   }) {
//     double effectiveHeight = height ?? _logoHeight;
//     return Padding(
//       padding: padding ?? const EdgeInsets.only(top: 8.0),
//       child: Align(
//         alignment: alignment,
//         child: SizedBox(
//           height: effectiveHeight,
//           child: Image.asset(
//             'assets/pensiunkuplus/pensiunku.png',
//             fit: BoxFit.contain,
//           ),
//         ),
//       ),
//     );
//   }

//   // Widget builder untuk instruksi tampilan
//   Widget _buildInstructionImage() {
//     return Padding(
//       padding: const EdgeInsets.only(top: 0.0, bottom: 5.0),
//       child: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Image.asset(
//               'assets/pensiunkuplus/uploadktp.png', // Gunakan asset untuk foto KTP
//               height: _instructionImageHeight,
//               // fit: BoxFit.fill,
//             ),
//             const Text(
//               'Ambil foto KTP',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Method untuk membuka gallery (jika diperlukan)
//   void _openGallery() async {
//     var picture = await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (picture != null) {
//       setState(() {});
//     }
//     Navigator.pop(context);
//   }

//   // Dialog yang menjelaskan cara pengambilan foto KTP yang tepat
//   Future<void> _showDescriptionDialog(BuildContext context) {
//     return showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text(
//             'Cara Pengambilan Foto KTP Yang Tepat',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: Colors.black,
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           content: SingleChildScrollView(
//             child: ListBody(
//               children: <Widget>[
//                 const Text('\u2022 Pencahayaan terang'),
//                 const SizedBox(height: 5),
//                 const Text(
//                     '\u2022 Posisikan KTP sesuaikan informasi KTP sejajar dengan tanda garis'),
//                 const SizedBox(height: 5),
//                 const Text(
//                     '\u2022 Letakkan foto sejajar atau letakkan tepat masuk dalam kotak'),
//                 const SizedBox(height: 5),
//                 const Text(
//                     '\u2022 Gunakan KTP yang jelas tidak Blur sehingga data dapat terbaca oleh sistem'),
//                 const SizedBox(height: 5),
//                 ElevatedButton(
//                   style: raisedButtonStyle,
//                   onPressed: () => _handleCameraPermission(),
//                   child: const Text('Open Camera'),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // Menangani permission kamera dan membuka kamera KTP jika diizinkan
//   void _handleCameraPermission() {
//     Navigator.of(context, rootNavigator: true)
//         .pushNamed(PermissionScreen.ROUTE_NAME)
//         .then((permissionStatus) {
//       if (permissionStatus == PermissionStatus.granted) {
//         _openKtpCamera();
//       } else {
//         _showPermissionDeniedMessage();
//       }
//     });
//   }

//   // Membuka kamera KTP dengan filter dan callback yang telah didefinisikan
//   void _openKtpCamera() {
//   Navigator.of(context, rootNavigator: true)
//       .pushNamed(
//         CameraKtpScreen.ROUTE_NAME,
//         arguments: CameraKtpScreenArgs(
//           cameraFilter: 'assets/ktp_filter.png',
//           buildFilter: (BuildContext context, CameraResultModel? detectionResult) {
//             // Jika mode selfie, nonaktifkan filter (ubah logika jika perlu)
//             if ('assets/ktp_filter.png' == 'selfie') {
//               return Container();
//             } else {
//               // Untuk mode KTP, tampilkan overlay filter KTP dengan bounding box OCR
//               return Positioned.fill(
//                 child: Container(
//                   color: Colors.transparent,
//                   child: CustomPaint(
//                     painter: KtpFramePainter(
//                       screenSize: MediaQuery.of(context).size,
//                       detectedTextBoxes: detectionResult?.textBoxes, // kirim data OCR
//                     ),
//                   ),
//                 ),
//               );
//             }
//           },
//           onProcessImage: _processKtpImage,
//           onPreviewImage: _previewKtpImage,
//         ),
//       )
//       .then(_handleCameraResult);
// }


//   // Widget builder untuk filter KTP yang ditampilkan di kamera
//   Widget _buildKtpFilter(BuildContext context) {
//     return Container(
//       constraints: const BoxConstraints.expand(),
//       child: CustomPaint(
//         painter: KtpFramePainter(
//           screenSize: MediaQuery.of(context).size,
//           outerFrameColor: const Color(0x73442C2E),
//           innerFrameColor: Colors.transparent,
//         ),
//       ),
//     );
//   }

//   // Proses gambar KTP menggunakan Firebase Vision
//   Future<ResultModel<CameraResultModel>> _processKtpImage(
//       XFile file, CameraLensDirection lensDirection) async {
//     try {
//       print('Memproses gambar KTP...');
//       // Langsung gunakan objek file (XFile) tanpa konversi ke File
//       ResultModel<KtpModel> ktpData =
//           await FirebaseVisionUtils.getKtpVisionDataFromImage(
//         file,
//         isDrawSearchingArea: false,
//         isDrawExtractedArea: true,
//       );

//       if (!ktpData.isSuccess || ktpData.data == null) {
//         return ResultModel<CameraResultModel>(
//           isSuccess: false,
//           data: null,
//           message: ktpData.message ?? 'Gagal memproses KTP',
//         );
//       }

// // Convert KtpModel to CameraResultModel
//       final cameraResult = CameraResultModel(
//         imagePath: file.path,
//         ktpData: ktpData.data,
//         textBoxes: [],
//       );
//       print('Berhasil memproses gambar KTP');
//       return ResultModel<CameraResultModel>(
//         isSuccess: true,
//         data: cameraResult,
//         message: 'Berhasil mengambil data KTP',
//       );
//     } catch (e) {
//       print('Gagal memproses gambar KTP: ${e.toString()}');
//       return ResultModel<CameraResultModel>(
//         isSuccess: false,
//         data: null,
//         message: 'Gagal memproses KTP: ${e.toString()}',
//       );
//     }
//   }

// // Menampilkan preview gambar KTP yang telah diambil
//   Future<dynamic> _previewKtpImage(
//       BuildContext pageContext, dynamic resultModel) {
//     print('Menampilkan preview gambar KTP...');
//     print(22222);
//     if (resultModel is CameraResultModel) {
//       if (resultModel.ktpData != null) {
//         return Navigator.of(pageContext).pushNamed(
//           PreviewKtpScreen.ROUTE_NAME,
//           arguments: PreviewKtpScreenArgs(
//             ktpModel:
//                 resultModel.ktpData!, // Akses ktpData dari CameraResultModel
//           ),
//         );
//       } else {
//         // Tangani kasus di mana ktpData adalah null
//         throw Exception('KtpData is null');
//       }
//     } else if (resultModel is KtpModel) {
//       return Navigator.of(pageContext).pushNamed(
//         PreviewKtpScreen.ROUTE_NAME,
//         arguments: PreviewKtpScreenArgs(
//           ktpModel: resultModel,
//         ),
//       );
//     } else {
//       throw Exception('Invalid result model type');
//     }
//   }

// // Menangani hasil dari kamera
//   void _handleCameraResult(dynamic value) {
//     print('Menangani hasil dari kamera...');
//     if (value != null) {
//       if (value is ResultModel<CameraResultModel> &&
//           value.isSuccess &&
//           value.data != null) {
//         CameraResultModel cameraResult = value.data!;
//         if (cameraResult.ktpData != null) {
//           _navigateToConfirmScreen(cameraResult.ktpData!);
//         } else {
//           // Handle the case where ktpData is null
//           // You might want to show an error message or take some other action
//         }
//       } else if (value is KtpModel) {
//         // Jika masih menggunakan format lama
//         _navigateToConfirmScreen(value);
//       }
//     }
//   }

// // Navigasi ke halaman konfirmasi KTP
//   void _navigateToConfirmScreen(KtpModel ktpModel) {
//     print('Navigasi ke halaman konfirmasi KTP...');
//     Navigator.of(context)
//         .pushNamed(
//           ConfirmKtpScreen.ROUTE_NAME,
//           arguments: ConfirmKtpScreenArgs(
//             submissionModel: widget.submissionModel,
//             ktpModel: ktpModel,
//             onSuccess: (_) => widget.onSuccess(context),
//           ),
//         )
//         .then(_handleConfirmResult);
//   }

// // Menangani hasil dari halaman konfirmasi
//   void _handleConfirmResult(dynamic returnValue) {
//     print('Menangani hasil dari halaman konfirmasi...');
//     if (returnValue is int) {
//       Navigator.of(context).pop(returnValue);
//     } else if (returnValue == true) {
//       widget.onSuccess(context);
//     }
//   }

// // Menampilkan pesan jika permission kamera ditolak
//   void _showPermissionDeniedMessage() {
//     print('Permission kamera ditolak...');
//     WidgetUtil.showSnackbar(
//       context,
//       'Tolong izinkan Pensiunku untuk mengakses kamera Anda.',
//       snackbarAction: SnackBarAction(
//         label: 'Pengaturan',
//         onPressed: openAppSettings,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     ThemeData theme = Theme.of(context);

//     return Scaffold(
//       appBar: AppBar(
//         // Atur tinggi toolbar agar cukup untuk konten di flexibleSpace
//         toolbarHeight: 120.0,
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: const Text(''),
//         centerTitle: true,
//         automaticallyImplyLeading: false, // Hilangkan back button default
//         flexibleSpace: Container(
//           padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
//           // Gunakan mainAxisSize.min agar Column tidak memaksa tinggi penuh
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 _buildHeader(context),
//                 _buildLogo(
//                   height:
//                       _logoHeight, // atau bisa dihilangkan jika ingin menggunakan nilai default
//                   alignment: Alignment.center,
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//       extendBodyBehindAppBar: true,
//       body: Stack(
//         children: [
//           _buildBackground(), // Background gradient
//           SafeArea(
//             child: SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(
//                   vertical: 32.0,
//                   horizontal: 24.0,
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     // Gunakan widget _buildInstructionImage() untuk tampilan instruksi
//                     _buildInstructionImage(),
//                     const SizedBox(height: 15.0),
//                     const Text(
//                       'Arahkan kamera Anda tepat sesuai frame yang telah kami tentukan. '
//                       'Setelah foto, mohon untuk melakukan verifikasi data KTP anda!',
//                       textAlign: TextAlign.justify,
//                     ),
//                     const SizedBox(height: 32.0),
//                     Center(
//                       child: ElevatedButton(
//                         style: raisedButtonStyle,
//                         onPressed: () {
//                           _showDescriptionDialog(context);
//                         },
//                         child: const Text('Ambil Foto'),
//                       ),
//                     ),
//                     const SizedBox(height: 80.0),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



// final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
//   backgroundColor: const Color(0xFF16826E),
//   padding: const EdgeInsets.all(10.0),
//   disabledForegroundColor: const Color(0xFFF29724).withOpacity(0.38),
//   disabledBackgroundColor: const Color(0xFFF29724).withOpacity(0.12),
//   textStyle: const TextStyle(color: Colors.white),
//   shape: const RoundedRectangleBorder(
//     borderRadius: BorderRadius.all(Radius.circular(10.0)),
//   ),
// );

// // Arguments class untuk PrepareKtpScreen
// class PrepareKtpScreenArguments {
//   final SubmissionModel submissionModel;
//   final void Function(BuildContext context) onSuccess;

//   PrepareKtpScreenArguments({
//     required this.submissionModel,
//     required this.onSuccess,
//   });
// }

// class PrepareKtpScreen extends StatefulWidget {
//   static const String ROUTE_NAME = '/ktp/prepare';

//   final SubmissionModel submissionModel;
//   final void Function(BuildContext context) onSuccess;

//   const PrepareKtpScreen({
//     Key? key,
//     required this.submissionModel,
//     required this.onSuccess,
//   }) : super(key: key);

//   @override
//   _PrepareKtpScreenState createState() => _PrepareKtpScreenState();
// }

// class _PrepareKtpScreenState extends State<PrepareKtpScreen> {
//   // Variabel ini dapat digunakan jika nanti ingin mengatur tampilan bottom navigation bar
//   bool _isBottomNavBarVisible = false;

//   // Constants
//   static const double _logoHeight = 80.0;
//   static const double _instructionImageHeight = 257.0;
//   static const List<Color> _gradientColors = [
//     Colors.white,
//     Colors.white,
//     Colors.white,
//     Color.fromARGB(255, 233, 208, 127),
//   ];
//   static const List<double> _gradientStops = [0.25, 0.5, 0.75, 1.0];

//   @override
//   void initState() {
//     super.initState();
//     // Tampilkan bottom nav bar (jika diperlukan) setelah build awal
//     Future.delayed(Duration.zero, () {
//       setState(() => _isBottomNavBarVisible = true);
//     });
//   }

//   // Widget builder untuk header yang berisi tombol back dan progress indicator
//   Widget _buildHeader(BuildContext context) {
//     return Row(
//       children: [
//         IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         Expanded(
//           child: LinearProgressIndicator(
//             value: 0.5,
//             backgroundColor: Colors.grey[300],
//             valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF006C4E)),
//           ),
//         ),
//       ],
//     );
//   }

//   // Widget builder untuk background gradient
//   Widget _buildBackground() {
//     return Container(
//       width: double.infinity,
//       height: double.infinity,
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: _gradientColors,
//           stops: _gradientStops,
//         ),
//       ),
//     );
//   }

//   // Widget builder untuk logo
//   Widget _buildLogo({
//     double? height,
//     double? width,
//     Alignment alignment = Alignment.center,
//     EdgeInsetsGeometry? padding,
//   }) {
//     return Padding(
//       padding: padding ?? const EdgeInsets.only(top: 20.0),
//       child: Align(
//         alignment: alignment,
//         child: Image.asset(
//           'assets/pensiunkuplus/pensiunku.png',
//           height: height ?? _logoHeight,
//           width: width,
//           fit: BoxFit.contain,
//         ),
//       ),
//     );
//   }

//   // Widget builder untuk instruksi tampilan
//   Widget _buildInstructionImage() {
//     return Padding(
//       padding: const EdgeInsets.only(top: 0.0, bottom: 10.0),
//       child: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             SizedBox(
//               height: _instructionImageHeight,
//               child: Image.asset(
//                 'assets/pensiunkuplus/uploadktp.png', // Gunakan asset untuk foto KTP
//                 height: 150,
//                 // fit: BoxFit.fill,
//               ),
//             ),
//             const Text(
//               'Ambil foto KTP',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Method untuk membuka gallery (jika diperlukan)
//   void _openGallery() async {
//     var picture = await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (picture != null) {
//       setState(() {});
//     }
//     Navigator.pop(context);
//   }

//   // Dialog yang menjelaskan cara pengambilan foto KTP yang tepat
//   Future<void> _showDescriptionDialog(BuildContext context) {
//     return showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text(
//             'Cara Pengambilan Foto KTP Yang Tepat',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: Colors.black,
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           content: SingleChildScrollView(
//             child: ListBody(
//               children: <Widget>[
//                 const Text('\u2022 Pencahayaan terang'),
//                 const SizedBox(height: 5),
//                 const Text(
//                     '\u2022 Posisikan KTP sesuaikan informasi KTP sejajar dengan tanda garis'),
//                 const SizedBox(height: 5),
//                 const Text(
//                     '\u2022 Letakkan foto sejajar atau letakkan tepat masuk dalam kotak'),
//                 const SizedBox(height: 5),
//                 const Text(
//                     '\u2022 Gunakan KTP yang jelas tidak Blur sehingga data dapat terbaca oleh sistem'),
//                 const SizedBox(height: 5),
//                 ElevatedButton(
//                   style: raisedButtonStyle,
//                   onPressed: () => _handleCameraPermission(),
//                   child: const Text('Open Camera'),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // Menangani permission kamera dan membuka kamera KTP jika diizinkan
//   void _handleCameraPermission() {
//     Navigator.of(context, rootNavigator: true)
//         .pushNamed(PermissionScreen.ROUTE_NAME)
//         .then((permissionStatus) {
//       if (permissionStatus == PermissionStatus.granted) {
//         _openKtpCamera();
//       } else {
//         _showPermissionDeniedMessage();
//       }
//     });
//   }

//   // Membuka kamera KTP dengan filter dan callback yang telah didefinisikan
//   void _openKtpCamera() {
//     Navigator.of(context, rootNavigator: true)
//         .pushNamed(
//           CameraKtpScreen.ROUTE_NAME,
//           arguments: CameraKtpScreenArgs(
//             cameraFilter: 'assets/ktp_filter.png',
//             buildFilter: _buildKtpFilter,
//             onProcessImage: _processKtpImage,
//             onPreviewImage: _previewKtpImage,
//           ),
//         )
//         .then(_handleCameraResult);
//   }

//   // Widget builder untuk filter KTP yang ditampilkan di kamera
//   Widget _buildKtpFilter(BuildContext context) {
//     return Container(
//       constraints: const BoxConstraints.expand(),
//       child: CustomPaint(
//         painter: KtpFramePainter(
//           screenSize: MediaQuery.of(context).size,
//           outerFrameColor: const Color(0x73442C2E),
//           innerFrameColor: Colors.transparent,
//         ),
//       ),
//     );
//   }

//   // Proses gambar KTP menggunakan Firebase Vision
//   Future<ResultModel<KtpModel>> _processKtpImage(
//       XFile file, CameraLensDirection lensDirection) async {
//     try {
//       // Langsung gunakan objek file (XFile) tanpa konversi ke File
//       ResultModel<KtpModel> ktpData =
//           await FirebaseVisionUtils.getKtpVisionDataFromImage(
//         file,
//         isDrawSearchingArea: false,
//         isDrawExtractedArea: true,
//       );

//       return ResultModel<KtpModel>(
//         isSuccess: true,
//         data: ktpData.data!, // Pastikan data tidak null jika isSuccess true
//         message: 'Berhasil mengambil data KTP',
//       );
//     } catch (e) {
//       return ResultModel<KtpModel>(
//         isSuccess: false,
//         data: null,
//         message: 'Gagal memproses KTP: ${e.toString()}',
//       );
//     }
//   }

//   // Menampilkan preview gambar KTP yang telah diambil
//   Future<dynamic> _previewKtpImage(BuildContext pageContext, dynamic ktpModel) {
//     return Navigator.of(pageContext).pushNamed(
//       PreviewKtpScreen.ROUTE_NAME,
//       arguments: PreviewKtpScreenArgs(
//         ktpModel: ktpModel as KtpModel,
//       ),
//     );
//   }

//   // Menangani hasil dari kamera
//   void _handleCameraResult(dynamic value) {
//     if (value != null) {
//       if (value is ResultModel<KtpModel> &&
//           value.isSuccess &&
//           value.data != null) {
//         KtpModel ktpModel = value.data!; // Perbaiki di sini
//         _navigateToConfirmScreen(ktpModel);
//       } else if (value is KtpModel) {
//         // Jika masih menggunakan format lama
//         _navigateToConfirmScreen(value);
//       }
//     }
//   }

//   // Navigasi ke halaman konfirmasi KTP
//   void _navigateToConfirmScreen(KtpModel ktpModel) {
//     Navigator.of(context)
//         .pushNamed(
//           ConfirmKtpScreen.ROUTE_NAME,
//           arguments: ConfirmKtpScreenArgs(
//             submissionModel: widget.submissionModel,
//             ktpModel: ktpModel,
//             onSuccess: (_) => widget.onSuccess(context),
//           ),
//         )
//         .then(_handleConfirmResult);
//   }

//   // Menangani hasil dari halaman konfirmasi
//   void _handleConfirmResult(dynamic returnValue) {
//     if (returnValue is int) {
//       Navigator.of(context).pop(returnValue);
//     } else if (returnValue == true) {
//       widget.onSuccess(context);
//     }
//   }

//   // Menampilkan pesan jika permission kamera ditolak
//   void _showPermissionDeniedMessage() {
//     WidgetUtil.showSnackbar(
//       context,
//       'Tolong izinkan Pensiunku untuk mengakses kamera Anda.',
//       snackbarAction: SnackBarAction(
//         label: 'Pengaturan',
//         onPressed: openAppSettings,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     ThemeData theme = Theme.of(context);

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: const Text(''),
//         centerTitle: true,
//         automaticallyImplyLeading: false, // Hilangkan back button default
//         flexibleSpace: Container(
//           padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
//           child: Column(
//             children: [
//               _buildHeader(context),
//               _buildLogo(
//                 height: _logoHeight / 1.9,
//                 alignment: Alignment.center,
//               ),
//             ],
//           ),
//         ),
//       ),
//       extendBodyBehindAppBar: true,
//       body: Stack(
//         children: [
//           _buildBackground(), // Background gradient
//           SafeArea(
//             child: SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(
//                   vertical: 32.0,
//                   horizontal: 24.0,
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     // Ganti tampilan instruksi dengan widget _buildInstructionImage()
//                     _buildInstructionImage(),
//                     const SizedBox(height: 8.0),
//                     const Text(
//                       'Arahkan kamera Anda tepat sesuai frame yang telah kami tentukan. '
//                       'Setelah foto, mohon untuk melakukan verifikasi data KTP anda!',
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 32.0),
//                     Center(
//                       child: ElevatedButton(
//                         style: raisedButtonStyle,
//                         onPressed: () {
//                           _showDescriptionDialog(context);
//                         },
//                         child: const Text('Ambil Foto'),
//                       ),
//                     ),
//                     const SizedBox(height: 80.0),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
