import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pensiunku/repository/user_repository.dart';
import 'package:pensiunku/screen/otp/account_recovery_screen.dart';
import 'package:pensiunku/screen/otp/otp_code_screen.dart';
import 'package:http/http.dart' as http;

class OtpScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/otp';

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  bool _isLoading = false;
  String _inputPhone = '';
  bool _inputPhoneTouched = false;
  late TextEditingController _inputPhoneController;
  bool _isLoginMode = true;

  @override
  void initState() {
    super.initState();
    print('OtpScreen: initState dipanggil.');
    _inputPhoneController = TextEditingController()
      ..addListener(() {
        setState(() {
          _inputPhone = _inputPhoneController.text;
          _inputPhoneTouched = true;
        });
      });
  }

  @override
  void dispose() {
    print('OtpScreen: dispose dipanggil.');
    _inputPhoneController.dispose();
    print('OtpScreen: _inputPhoneController di-dispose.');
    super.dispose();
  }

  Future<bool?> _checkPhoneNumber() async {
    print('OtpScreen: _checkPhoneNumber dipanggil untuk nomor: $_inputPhone');
    final url = Uri.parse('https://api.pensiunku.id/new.php/cekNomorTelepon');
    final body = json.encode({'phone': _inputPhone});
    print('OtpScreen: Memulai panggilan HTTP POST ke $url dengan body: $body');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(Duration(seconds: 10)); // Batas waktu 10 detik

      print(
          'OtpScreen: Panggilan HTTP POST selesai. Status Code: ${response.statusCode}');
      print('OtpScreen: Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // --- START OF FIX ---
        // Periksa apakah respons adalah halaman HTML dari tantangan keamanan
        if (response.body.contains('One moment, please...') ||
            response.body
                .contains('Access denied by Imunify360 bot-protection') ||
            response.body.trim().startsWith('<!DOCTYPE html>')) {
          print('OtpScreen: Deteksi tantangan keamanan (HTML response).');
          if (!mounted) {
            print(
                'OtpScreen: _checkPhoneNumber (HTML response): Widget tidak mounted, berhenti.');
            return null; // Mengembalikan null karena tidak bisa diproses
          }
          _showScrollableDialog(
            title: 'Kesalahan Keamanan',
            description:
                'Sistem mendeteksi aktivitas tidak biasa. Mohon coba lagi beberapa saat.',
            confirmText: 'OK',
            isError: true,
          );
          return null; // Mengembalikan null untuk menghentikan alur
        }
        // --- END OF FIX ---

        final data = json.decode(response.body) as Map<String, dynamic>;
        final message = data['text']?['message'];
        print('OtpScreen: Server message: $message');

        if (message == 'success') {
          print('OtpScreen: Nomor sudah terdaftar.');
          if (_isLoginMode) {
            // Jika mode login dan nomor terdaftar, lanjutkan untuk mengirim OTP
            return true;
          }
          if (!mounted) {
            print(
                'OtpScreen: _checkPhoneNumber (setelah success): Widget tidak mounted, berhenti.');
            return false;
          }
          _showScrollableDialog(
            title: 'Nomor Sudah Terdaftar',
            description:
                'Nomor telepon ini sudah terdaftar. Silakan pilih menu LOGIN untuk masuk.',
            confirmText: 'Pilih Login',
            onConfirm: () => setState(() => _isLoginMode = true),
          );
          return false;
        } else {
          print('OtpScreen: Nomor belum terdaftar.');
          if (_isLoginMode) {
            if (!mounted) {
              print(
                  'OtpScreen: _checkPhoneNumber (setelah else): Widget tidak mounted, berhenti.');
              return false;
            }
            _showScrollableDialog(
              title: 'Nomor Belum Terdaftar',
              description: 'Silakan pilih menu DAFTAR untuk membuat akun baru.',
              confirmText: 'Daftar Sekarang',
              onConfirm: () => setState(() => _isLoginMode = false),
            );
            return false;
          }
          // Jika mode daftar dan nomor belum terdaftar, lanjutkan untuk mengirim OTP
          return true;
        }
      } else {
        print(
            'OtpScreen: Kesalahan Server: Status Code ${response.statusCode}');
        throw Exception('Kesalahan Server: ${response.statusCode}');
      }
    } on TimeoutException catch (e) {
      print(
          'OtpScreen: TimeoutException di _checkPhoneNumber: ${e.toString()}');
      if (!mounted) return null;
      _showScrollableDialog(
        title: 'Koneksi Lambat',
        description: 'Permintaan memakan waktu terlalu lama. Coba lagi.',
        confirmText: 'OK',
        isError: true,
      );
      return null;
    } catch (e) {
      print('OtpScreen: Catch block di _checkPhoneNumber: ${e.toString()}');
      if (!mounted) {
        print(
            'OtpScreen: _checkPhoneNumber (catch): Widget tidak mounted, berhenti.');
        return null;
      }
      _showScrollableDialog(
        title: 'Kesalahan',
        description:
            'Tidak dapat terhubung ke server. Coba lagi nanti.\nDetail: ${e.toString()}',
        confirmText: 'OK',
        isError: true,
      );
      return null;
    }
  }

  Future<void> _sendOtp() async {
    print('OtpScreen: _sendOtp dipanggil.');
    setState(() => _inputPhoneTouched = true);
    if (_getInputPhoneError() != null) {
      print(
          'OtpScreen: Validasi nomor telepon gagal: ${_getInputPhoneError()}');
      return;
    }
    print('OtpScreen: Nomor telepon valid.');

    setState(() => _isLoading = true);
    print('OtpScreen: _isLoading = true.');

    final isRegistered = await _checkPhoneNumber();
    if (!mounted) {
      print(
          'OtpScreen: _sendOtp (setelah _checkPhoneNumber): Widget tidak mounted, berhenti.');
      return;
    }
    setState(() => _isLoading = false);
    print('OtpScreen: _isLoading = false.');

    // Hanya lanjutkan jika isRegistered adalah true (untuk mode login)
    // atau jika isRegistered adalah true (untuk mode daftar, setelah dialog konfirmasi)
    if (isRegistered == true) {
      try {
        print('OtpScreen: Memulai panggilan UserRepository().sendOtp...');
        final result = await UserRepository().sendOtp(_inputPhone);
        print('OtpScreen: Panggilan UserRepository().sendOtp selesai.');

        if (!mounted) {
          print(
              'OtpScreen: _sendOtp (setelah sendOtp): Widget tidak mounted, berhenti.');
          return;
        }
        if (result.isSuccess) {
          print(
              'OtpScreen: Pengiriman OTP berhasil, navigasi ke OtpCodeScreen.');
          Navigator.of(context).pushNamed(
            OtpCodeScreen.ROUTE_NAME,
            arguments: OtpCodeScreenArgs(phone: _inputPhone),
          );
        } else {
          print('OtpScreen: Pengiriman OTP gagal. Error: ${result.error}');
          _showScrollableDialog(
            title: 'Error',
            description: result.error ?? 'Gagal mengirimkan OTP',
            confirmText: 'OK',
            isError: true,
          );
        }
      } catch (e) {
        print(
            'OtpScreen: Catch block di _sendOtp (UserRepository().sendOtp): ${e.toString()}');
        if (!mounted) return;
        _showScrollableDialog(
          title: 'Error',
          description: 'Terjadi kesalahan saat mengirim OTP: ${e.toString()}',
          confirmText: 'OK',
          isError: true,
        );
      }
    } else {
      print(
          'OtpScreen: Nomor tidak terdaftar atau _checkPhoneNumber mengembalikan null/false (setelah dialog konfirmasi).');
    }
  }

  void _showScrollableDialog({
    required String title,
    required String description,
    required String confirmText,
    VoidCallback? onConfirm,
    bool isError = false,
  }) {
    print('OtpScreen: Menampilkan dialog: $title - $description');
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        final maxH = MediaQuery.of(context).size.height * 0.5;
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(horizontal: 15),
            content: Container(
              constraints: BoxConstraints(maxHeight: maxH),
              decoration: BoxDecoration(
                color: isError ? Colors.red : Color(0xFF017964),
                borderRadius: BorderRadius.circular(15),
              ),
              padding: EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      description,
                      style: TextStyle(fontSize: 14, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            isError ? Colors.red : Color(0xFF017964),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        if (onConfirm != null) onConfirm();
                      },
                      child: Text(confirmText),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String? _getInputPhoneError() {
    if (!_inputPhoneTouched) return null;
    if (_inputPhone.isEmpty) return "Nomor telepon harus diisi";
    if (!_inputPhone.trim().startsWith('0'))
      return "Nomor telepon harus mulai dari angka 0";
    if (_inputPhone.trim().length < 8)
      return "Nomor telepon harus terdiri dari min. 8 karakter";
    if (_inputPhone.trim().length > 13)
      return "Nomor telepon harus terdiri dari max. 13 karakter";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topSpace = size.height * 0.08;
    final midSpace = size.height * 0.10;
    final bottomSpace = size.height * 0.20;
    String? inputError = _getInputPhoneError();

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient - full layar
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, // Gradient mulai dari kiri
                  end: Alignment.bottomCenter, // Gradient berakhir di kanan
                  colors: [
                    Color.fromARGB(255, 255, 255, 255),
                    Color.fromARGB(255, 255, 255, 255),
                    Color.fromARGB(255, 255, 255, 255),
                    Color.fromARGB(
                        255, 170, 231, 170), // Hijau muda (pinggir kanan)
                  ],
                  stops: [
                    0.0,
                    0.25,
                    0.5,
                    1.0
                  ], // Titik berhenti warna di gradient
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: size.height),
                child: Column(
                  children: [
                    SizedBox(height: topSpace),
                    Image.asset(
                      'assets/otp_screen/pensiunku.png',
                      height: size.height * 0.05,
                    ),
                    SizedBox(height: bottomSpace),
                    _buildModeToggle(),
                    SizedBox(height: 8),
                    Text(
                      'Masukkan nomor telepon anda',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 12),

                    // TextField proporsional
                    FractionallySizedBox(
                      widthFactor: 0.8,
                      child: TextField(
                        controller: _inputPhoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Nomor Telepon',
                          errorText: inputError,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),

                    // Button proporsional
                    Center(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _sendOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          // pastikan tidak ada minimum width default
                          minimumSize: Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _isLoginMode ? 'Masuk' : 'Daftar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    SizedBox(height: bottomSpace),

                    if (_isLoginMode) ...[
                      Text(
                        'Tidak bisa mengakses nomor telepon anda?',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 2),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AccountRecoveryScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Pemulihan Akun',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => setState(() => _isLoginMode = true),
          child: Text('Masuk', style: _getModeStyle(_isLoginMode)),
        ),
        Text(' / '),
        GestureDetector(
          onTap: () => setState(() => _isLoginMode = false),
          child: Text('Daftar', style: _getModeStyle(!_isLoginMode)),
        ),
      ],
    );
  }

  TextStyle _getModeStyle(bool isActive) {
    return TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: isActive ? Colors.black : Colors.black26,
    );
  }
}
