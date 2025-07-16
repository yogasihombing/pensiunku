import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pensiunku/model/ktp_model.dart';
import 'package:pensiunku/model/user_model.dart';
import 'package:pensiunku/repository/user_repository.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/daftarkan_pin_screen.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreviewKtpScreenArgs {
  final KtpModel ktpModel;

  // Konstruktor untuk kelas PreviewKtpScreenArgs yang menerima objek KtpModel.
  PreviewKtpScreenArgs({
    required this.ktpModel,
  });
}

class PreviewKtpScreen extends StatefulWidget {
  static const String ROUTE_NAME =
      '/ktp/preview'; // Mendefinisikan nama rute untuk layar ini.

  final KtpModel ktpModel;

  // Konstruktor untuk kelas PreviewKtpScreen yang menerima objek KtpModel.
  const PreviewKtpScreen({
    Key? key,
    required this.ktpModel,
  }) : super(key: key);

  @override
  _PreviewKtpScreenState createState() => _PreviewKtpScreenState();
}

class _PreviewKtpScreenState extends State<PreviewKtpScreen> {
  UserModel? _userModel;
  bool _isLoadingOverlay = false;
  bool _isImageLoaded = false;
  bool _isActivated = false;
  final Dio dio = Dio();
  List<Rect> _detectedTextBoxes = [];

  @override
  void initState() {
    super.initState();
    _checkImage();
    _refreshData();
  }

  // Fungsi untuk memeriksa apakah file gambar KTP tersedia.
  Future<void> _checkImage() async {
    final file = File(widget.ktpModel.image.path);
    if (await file.exists()) {
      setState(() {
        _isImageLoaded = true;
      });
    }
  }

  // Fungsi uploadKtpImage menggunakan format JSON (Base64) agar sesuai dengan API.
  Future<Response?> uploadKtpImage(
      String token, String ktpFilePath, String idUser) async {
    print('=== Mulai upload KTP ke API ===');
    print('URL: https://api.pensiunku.id/new.php/uploadKTP');
    print('User ID: $idUser');

    final file = File(ktpFilePath);
    if (!await file.exists()) {
      print('File tidak ditemukan: $ktpFilePath');
      throw Exception('File KTP tidak ditemukan');
    }

    print('File ditemukan: $ktpFilePath');
    print('Ukuran file: ${await file.length()} bytes');

    // Baca file dan ubah ke format Base64
    List<int> imageBytes = await file.readAsBytes();
    String base64Image = base64Encode(imageBytes);

    // Siapkan data JSON yang akan dikirim
    Map<String, dynamic> formData = {
      "foto_ktp": base64Image,
      "nama_foto_ktp": path.basename(ktpFilePath),
      "id_user": idUser
    };

    print('Mengirim JSON ke API (foto dan nama file)');

    try {
      Response response = await dio.post(
        'https://api.pensiunku.id/new.php/uploadKTP',
        data: jsonEncode(formData),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'X-User-ID': idUser,
          },
          responseType: ResponseType.json,
        ),
      );
      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');
      return response;
    } catch (e) {
      print('Error saat mengunggah foto KTP: $e');
      return null;
    }
  }

  // Fungsi untuk mengulangi pengambilan foto.
  void _retakePhoto(BuildContext context) {
    print('Mengulangi pengambilan foto KTP...');
    Navigator.of(context).pop(false);
  }

  // Fungsi untuk merefresh data user.
  Future<void> _refreshData() async {
    print('Memulai refresh data user...');
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);
    print('Token dari SharedPreferences: $token');

    if (token != null && token.isNotEmpty) {
      try {
        print('Memanggil UserRepository().getOne dengan token');
        final result = await UserRepository().getOne(token);
        if (result.error == null) {
          setState(() {
            _userModel = result.data;
            _isActivated = _userModel?.isActivated ?? false;
            print('Data user berhasil dimuat:');
            print('User ID: ${_userModel?.id}');
            print('Is Activated: $_isActivated');
          });
        } else {
          print('Error memuat data user: ${result.error}');
          _showErrorDialog(context, 'Gagal memuat data user: ${result.error}');
        }
      } catch (error) {
        print('Exception saat memuat data user: $error');
        _showErrorDialog(context, 'Terjadi kesalahan saat memuat data user');
      }
    } else {
      print('Token tidak ditemukan atau kosong');
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        token = prefs.getString('SP_KEY_TOKEN');
        print('Token dari SharedPreferences langsung: $token');
        if (token != null && token.isNotEmpty) {
          final result = await UserRepository().getOne(token);
          // Lanjutkan proses jika diperlukan
        } else {
          _showErrorDialog(
              context, 'Sesi telah berakhir. Silakan login kembali.');
        }
      } catch (e) {
        print('Error saat mencoba cara alternatif: $e');
        _showErrorDialog(context, 'Terjadi kesalahan saat mengambil token.');
      }
    }
  }

  // Fungsi untuk mengonfirmasi foto KTP dan mengunggahnya ke server.
  Future<void> _confirmPhoto(BuildContext context) async {
    print('1. Memulai proses confirm photo');
    if (!mounted) return;

    if (_userModel == null) {
      print('Error: User data belum dimuat');
      await _refreshData();

      if (_userModel == null) {
        _showErrorDialog(
            context, 'Data user tidak tersedia. Silakan login ulang.');
        return;
      }
    }

    final file = File(widget.ktpModel.image.path);
    if (!await file.exists()) {
      print('Error: File KTP tidak ditemukan!');
      _showErrorDialog(context, 'File KTP tidak ditemukan. Silakan ulangi.');
      return;
    }

    setState(() {
      _isLoadingOverlay = true;
      print('2. Set loading state ke true');
    });
    try {
      print('Mengunggah foto KTP...');
      // Mengambil token dari SharedPreferences
      String? token = SharedPreferencesUtil()
          .sharedPreferences
          .getString(SharedPreferencesUtil.SP_KEY_TOKEN);
      if (token == null || token.isEmpty) {
        _showErrorDialog(
            context, 'Token tidak ditemukan. Silakan login kembali.');
        setState(() {
          _isLoadingOverlay = false;
        });
        return;
      }
      Response? response = await uploadKtpImage(
        token,
        widget.ktpModel.image.path,
        _userModel!.id.toString(),
      );
      if (!mounted) return;
      setState(() {
        _isLoadingOverlay = false;
      });
      if (response == null || response.data == null) {
        _showErrorDialog(context, 'Terjadi kesalahan saat mengunggah foto KTP');
        return;
      }
      String responseBody = jsonEncode(response.data);
      if (responseBody.contains('"message":"Foto KTP belum diupload!"')) {
        print('Pengunggahan gagal: Foto KTP belum diupload!');
        _showErrorDialog(
            context, 'Pengunggahan gagal: Foto KTP belum diupload!');
      } else {
        print('Pengunggahan selesai');
        _showCustomDialog(context, 'Foto KTP berhasil diupload');
        Future.delayed(Duration(seconds: 3), () {
          Navigator.of(context)
              .pushNamed(DaftarkanPinPensiunkuPlusScreen.ROUTE_NAME);
        });
      }
    } catch (e) {
      print('Error saat mengonfirmasi foto KTP: $e');
      setState(() {
        _isLoadingOverlay = false;
      });
      _showErrorDialog(context, 'Terjadi kesalahan: ${e.toString()}');
    }
  }

  void _showCustomDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Future.delayed(Duration(seconds: 2), () {
          Navigator.of(context).pop(true);
        });
        return AlertDialog(
          content: Text(
            message,
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.green,
          contentTextStyle: TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        );
      },
    );
  }

  // Fungsi untuk menampilkan dialog kesalahan.
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print('Membangun widget PreviewKtpScreen...');
    ThemeData theme =
        Theme.of(context); // Mendapatkan tema saat ini dari konteks.

    return Scaffold(
      backgroundColor:
          Color(0xfff2f2f2), // Mengatur warna latar belakang layar.
      appBar: AppBar(
        title: Text(
          'Preview KTP',
          style: TextStyle(color: Color(0xFF017964)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF017964)), // Warna tombol back
      ),
      body: Stack(
        children: [
          if (!_isImageLoaded)
            Center(
              child: CircularProgressIndicator(),
            ),
          if (_isImageLoaded)
            Positioned(
              top: 0.0,
              bottom: 80.0,
              left: 16.0,
              right: 16.0,
              child: Center(
                child: Container(
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
                    child: Stack(
                      children: [
                        Image.file(
                          File(widget.ktpModel.image.path),
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 32.0,
            left: 16.0,
            right: 16.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        _isLoadingOverlay ? null : () => _retakePhoto(context),
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
                    onPressed:
                        _isLoadingOverlay ? null : () => _confirmPhoto(context),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: theme.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: _isLoadingOverlay
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text('Lanjutkan'),
                  ),
                ),
              ],
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
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF017964)),
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