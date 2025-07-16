import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:pensiunku/model/camera_result_model.dart';
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
  bool _isBottomNavBarVisible = false;
  bool _isLoadingOverlay = false;

  @override
  void initState() {
    super.initState();
    _initializeBottomNavBar();
  }

  void _initializeBottomNavBar() {
    Future.delayed(Duration.zero, () {
      setState(() => _isBottomNavBarVisible = true);
    });
  }

  // Background gradient
  Widget _buildBackground() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: const [
              Colors.white,
              Colors.white,
              Colors.white,
              Color.fromARGB(255, 233, 208, 127),
            ],
            stops: const [0.25, 0.5, 0.75, 1.0],
          ),
        ),
      ),
    );
  }

  // Back button dan progress bar
  Widget _buildBackButtonAndProgress() {
    final screenHeight = MediaQuery.of(context).size.height; // ← diubah
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenHeight * 0.02, // ← diubah dari 16.0
        vertical: screenHeight * 0.01, // ← diubah dari 8.0
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF006C4E)),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: 0.25,
              backgroundColor: Colors.grey[300],
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF006C4E)),
            ),
          ),
        ],
      ),
    );
  }

  // Logo aplikasi
  Widget _buildLogo() {
    final screenHeight = MediaQuery.of(context).size.height; // ← diubah
    return Center(
      child: Column(
        children: [
          Image.asset(
            'assets/pensiunkuplus/pensiunku.png',
            height: screenHeight * 0.06, // ← diubah dari 50.0
          ),
          SizedBox(height: screenHeight * 0.0),
        ],
      ),
    );
  }

  // Gambar instruksi selfie
  Widget _buildInstructionImage() {
    final screenHeight = MediaQuery.of(context).size.height; // ← diubah
    return Padding(
      padding: EdgeInsets.only(
        top: screenHeight * 0.0,
        bottom: screenHeight * 0.025, // ← diubah dari 10.0
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: screenHeight * 0.25, // ← diubah dari 257.0
              child: Image.asset(
                'assets/pensiunkuplus/uploadfotowajah.png',
                // height attribute removed to let SizedBox control
              ),
            ),
            SizedBox(height: screenHeight * 0.030),
            const Text(
              'Upload foto wajah',
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

  // Instruksi teks
  Widget _buildInstructions(ThemeData theme) {
    final screenHeight = MediaQuery.of(context).size.height; // ← diubah
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenHeight * 0.03, // ← diubah dari _horizontalPadding
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Mohon untuk menangkap foto sesuai frame objek yang telah ditentukan. '
            'Jangan lupa pastikan Anda memiliki cahaya dan posisi yang cukup untuk '
            'menghasilkan foto yang baik. Foto yang jelas memudahkan kami untuk '
            'melakukan verifikasi pengajuan Anda.',
            textAlign: TextAlign.justify,
            style: theme.textTheme.bodySmall,
          ),
          SizedBox(height: screenHeight * 0.02), // ← diubah dari 24.0
          _buildTakePhotoButton(),
        ],
      ),
    );
  }

  // Tombol ambil foto
  Widget _buildTakePhotoButton() {
    final screenHeight = MediaQuery.of(context).size.height; // ← diubah
    return Center(
      child: ElevatedButton(
        onPressed: _handleCameraNavigation,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: screenHeight * 0.030, // ← diubah dari 32.0
            vertical: screenHeight * 0.015, // ← diubah dari 12.0
          ),
        ),
        child: Text(
          'Ambil Foto',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  // Navigasi ke kamera dan proses verifikasi
  Future<void> _handleCameraNavigation() async {
    try {
      setState(() => _isLoadingOverlay = true);
      var status = await Permission.camera.status;
      if (status.isDenied) status = await Permission.camera.request();

      if (!mounted) return;
      if (status.isGranted) {
        final result =
            await Navigator.of(context, rootNavigator: true).pushNamed(
          CameraKtpScreen.ROUTE_NAME,
          arguments: CameraKtpScreenArgs(
            cameraFilter: 'assets/selfie_filter.png',
            buildFilter: (ctx) {
              return Container(
                constraints: const BoxConstraints.expand(),
                child: CustomPaint(
                  painter: SelfieFramePainter(
                    screenSize: MediaQuery.of(ctx).size,
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
        setState(() => _isLoadingOverlay = false);
        if (result != null && mounted) widget.onSuccess(context);
      } else {
        setState(() => _isLoadingOverlay = false);
        if (mounted) {
          WidgetUtil.showSnackbar(
            context,
            'Tolong izinkan Pensiunku untuk mengakses kamera Anda.',
            snackbarAction: SnackBarAction(
              label: 'Pengaturan',
              onPressed: () => openAppSettings(),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoadingOverlay = false);
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
    final screenHeight = size.height; // ← diubah
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  Container(height: screenHeight), // ← diubah from size.height
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildBackButtonAndProgress(),
                      _buildLogo(),
                      SizedBox(height: screenHeight * 0.05),
                      _buildInstructionImage(),
                      SizedBox(height: screenHeight * 0.00),
                      _buildInstructions(theme),
                      SizedBox(
                          height: screenHeight * 0.08), // ← diubah from 60.0
                    ],
                  ),
                ],
              ),
            ),
          ),
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
                    padding: EdgeInsets.all(
                        screenHeight * 0.025), // ← diubah from 20
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF017964)),
                        ),
                        SizedBox(
                            height: screenHeight * 0.02), // ← diubah from 16
                        const Text(
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
