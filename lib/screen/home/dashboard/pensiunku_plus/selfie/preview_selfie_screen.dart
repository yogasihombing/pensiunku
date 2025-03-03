import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pensiunku/model/selfie_model.dart';
import 'package:pensiunku/model/submission_model.dart';
import 'package:pensiunku/model/user_model.dart';
import 'package:pensiunku/repository/result_model.dart';
import 'package:pensiunku/repository/submission_repository.dart';
import 'package:pensiunku/repository/user_repository.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/ktp/prepare_ktp_screen.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:permission_handler/permission_handler.dart';

class PreviewSelfieScreenArgs {
  final SubmissionModel submissionModel;
  final SelfieModel selfieModel;

  PreviewSelfieScreenArgs({
    required this.submissionModel,
    required this.selfieModel,
  });
}

class PreviewSelfieScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/selfie/preview';

  final SubmissionModel submissionModel;
  final SelfieModel selfieModel;

  const PreviewSelfieScreen({
    Key? key,
    required this.submissionModel,
    required this.selfieModel,
  }) : super(key: key);

  @override
  State<PreviewSelfieScreen> createState() => _PreviewSelfieScreenState();
}

class _PreviewSelfieScreenState extends State<PreviewSelfieScreen> {
  UserModel? _userModel; // Deklarasi variable UserModel
  bool _isLoading = false;
  bool _isImageLoaded = false;
  bool _isActivated = false; // Menambahkan variabel aktifasi
  late Future<ResultModel<UserModel>> _future;

  @override
  void initState() {
    super.initState();
    _checkImage();
    _refreshData();
  }

  Future<void> requestCameraPermission() async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      print("Izin kamera diberikan");
    } else {
      print("Izin kamera ditolak");
    }
  }

  Future<void> _checkImage() async {
    final file = File(widget.selfieModel.image.path);
    if (await file.exists()) {
      setState(() {
        _isImageLoaded = true;
      });
    }
  }

  Future<void> _retakePhoto(BuildContext context) async {
    Navigator.of(context).pop(false);
  }

  Future<void> _refreshData() async {
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    if (token != null) {
      try {
        final result = await UserRepository().getOne(token);
        if (result.error == null) {
          setState(() {
            _userModel = result.data;
            _isActivated = _userModel?.isActivated ?? false;
            print('User data loaded successfully:');
            print('User ID: ${_userModel?.id}');
            print('Is Activated: $_isActivated');
          });
        } else {
          print('Error loading user data: ${result.error}');
          _showErrorDialog('Gagal memuat data user: ${result.error}');
        }
      } catch (error) {
        print('Exception while loading user data: $error');
        _showErrorDialog('Terjadi kesalahan saat memuat data user');
      }
    } else {
      print('Token tidak ditemukan');
      _showErrorDialog('Sesi telah berakhir. Silakan login kembali.');
    }
  }

  Future<void> _confirmPhoto(BuildContext context) async {
    print('1. Memulai proses confirm photo');
    if (!mounted) return;

    // Cek apakah user data sudah dimuat
    if (_userModel == null) {
      print('Error: User data belum dimuat');
      await _refreshData(); // Coba muat ulang data user

      if (_userModel == null) {
        _showErrorDialog('Data user tidak tersedia. Silakan login ulang.');
        return;
      }
    }

    final file = File(widget.selfieModel.image.path);
    if (!await file.exists()) {
      print('Error: File selfie tidak ditemukan!');
      _showErrorDialog('File selfie tidak ditemukan. Silakan ulangi.');
      return;
    }

    setState(() {
      _isLoading = true;
      print('2. Set loading state ke true');
    });

    try {
      final token = SharedPreferencesUtil()
          .sharedPreferences
          .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

      if (token == null) {
        throw Exception('Token not found');
      }

      print('Token: $token');
      print('Image path: ${widget.selfieModel.image.path}');
      print('User ID: ${_userModel?.id}');

      // Teruskan user ID ke metode repository
      final result = await SubmissionRepository().uploadSelfie(
        token,
        widget.submissionModel,
        widget.selfieModel.image.path,
        idUser: _userModel?.id.toString() ?? '', // Tambahkan parameter ini
      );

      if (!mounted) return;

      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Foto selfie ${_userModel?.username} berhasil diupload'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.of(context).pushReplacementNamed(
          PrepareKtpScreen.ROUTE_NAME,
          arguments: PrepareKtpScreenArguments(
            submissionModel: widget.submissionModel,
            onSuccess: (BuildContext ctx) {
              print('KTP berhasil diupload dan diproses');
            },
          ),
        );
      } else {
        _showErrorDialog(result.error ?? 'Gagal mengirimkan foto selfie');
      }
    } catch (e) {
      print('Terjadi exception: $e');
      _showErrorDialog('Terjadi kesalahan: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color(0xfff2f2f2),
      appBar: AppBar(
        title: Text('Preview Foto'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            if (!_isImageLoaded)
              Center(
                child: CircularProgressIndicator(),
              ),
            if (_isImageLoaded)
              Positioned(
                top: 0.0,
                bottom: 80.0, // Give space for buttons
                left: 16.0,
                right: 16.0,
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: size.height * 0.7,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(widget.selfieModel.image.path),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 32.0,
              left: 0.0,
              right: 0.0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            _isLoading ? null : () => _retakePhoto(context),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: theme.colorScheme.secondary,
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text('Ulangi'),
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                print('=== Tombol Lanjutkan ditekan ===');
                                _confirmPhoto(context);
                              },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: theme.primaryColor,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text('Lanjutkan'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class PreviewSelfieScreenArgs {
//   final SubmissionModel submissionModel;
//   final SelfieModel selfieModel;

//   PreviewSelfieScreenArgs({
//     required this.submissionModel,
//     required this.selfieModel,
//   });
// }

// class PreviewSelfieScreen extends StatefulWidget {
//   static const String ROUTE_NAME = '/selfie/preview';

//   final SubmissionModel submissionModel;
//   final SelfieModel selfieModel;

//   const PreviewSelfieScreen({
//     Key? key,
//     required this.submissionModel,
//     required this.selfieModel,
//   }) : super(key: key);

//   @override
//   State<PreviewSelfieScreen> createState() => _PreviewSelfieScreenState();
// }

// class _PreviewSelfieScreenState extends State<PreviewSelfieScreen> {
//   bool _isLoading = false;

//   _retakePhoto(BuildContext context) {
//     Navigator.of(context).pop(false);
//   }

//   // _confirmPhoto(BuildContext context) {
//   //   setState(() {
//   //     _isLoading = true;
//   //   });

//   //   String? token = SharedPreferencesUtil()
//   //       .sharedPreferences
//   //       .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

//   //   SubmissionRepository()
//   //       .uploadSelfie(
//   //     token!,
//   //     widget.submissionModel,
//   //     widget.selfieModel.image.path,
//   //   )
//   //       .then((result) {
//   //     setState(() {
//   //       _isLoading = false;
//   //     });
//   //     if (result.isSuccess) {
//   //       setState(() {
//   //         _isLoading = false;
//   //       });
//   //       Navigator.of(context).pop(true);
//   //     } else {
//   //       showDialog(
//   //           context: context,
//   //           builder: (_) => AlertDialog(
//   //                 content: Text(result.error ?? 'Gagal mengirimkan foto selfie',
//   //                     style: TextStyle(color: Colors.white)),
//   //                 backgroundColor: Colors.red,
//   //                 elevation: 24.0,
//   //               ));
//   //       // WidgetUtil.showSnackbar(
//   //       //     context, result.error ?? 'Gagal mengirimkan foto selfie');
//   //     }
//   //   });
//   // }

//   @override
//   Widget build(BuildContext context) {
//     ThemeData theme = Theme.of(context);

//     return Scaffold(
//       backgroundColor: Color(0xfff2f2f2),
//       body: Stack(
//         children: [
//           Positioned(
//             top: 0.0,
//             bottom: 0.0,
//             left: 16.0,
//             right: 16.0,
//             child: Center(
//               child: SizedBox(
//                 child: Image.file(
//                   File(widget.selfieModel.image.path),
//                 ),
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: 32.0,
//             left: 0.0,
//             right: 0.0,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 !_isLoading
//                     ? ElevatedButton(
//                         onPressed: () => _retakePhoto(context),
//                         child: Text('Ulangi'),
//                         style: ElevatedButton.styleFrom(
//                           primary: Colors.white,
//                           onPrimary: theme.colorScheme.secondary,
//                         ),
//                       )
//                     : TextButton(
//                         onPressed: null,
//                         child: Text('Ulangi'),
//                       ),
//                 SizedBox(width: 32.0),
//                 // ElevatedButtonLoading(
//                 //   text: 'Lanjutkan',
//                 //   onTap: () => _confirmPhoto(context),
//                 //   isLoading: _isLoading,
//                 //   disabled: _isLoading,
//                 // ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
