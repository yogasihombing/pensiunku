import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:pensiunku/screen/otp/recovery_update_phone_screen.dart';

class OtpCodeRecoveryScreen extends StatefulWidget {
  final String email;
  final String phone;

  OtpCodeRecoveryScreen({required this.email, required this.phone});

  @override
  _OtpCodeRecoveryScreenState createState() => _OtpCodeRecoveryScreenState();
}

class _OtpCodeRecoveryScreenState extends State<OtpCodeRecoveryScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(5, (_) => TextEditingController());
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final List<FocusNode> _focusNodes = List.generate(5, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    // Setup listener untuk setiap field OTP
    for (int i = 0; i < 5; i++) {
      _otpControllers[i].addListener(() {
        _handleOtpChange(i);
      });
    }
  }

  @override
  void dispose() {
    // Bersihkan controllers dan focus nodes
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _handleOtpChange(int index) {
    if (_otpControllers[index].text.length == 1) {
      // Jika input sudah diisi dan bukan field terakhir, pindah ke field berikutnya
      if (index < 4) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Jika ini field terakhir, sembunyikan keyboard
        FocusScope.of(context).unfocus();
        // Opsional: Verifikasi OTP secara otomatis jika semua field terisi
        if (_areAllFieldsFilled()) {
          _verifyOtp();
        }
      }
    }
  }

  bool _areAllFieldsFilled() {
    return _otpControllers.every((controller) => controller.text.isNotEmpty);
  }

  Future<void> _verifyOtp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final otp =
          _otpControllers.map((controller) => controller.text.trim()).join();
      print('Email yang digunakan: ${widget.email}');
      print('Nomor telepon lama: ${widget.phone}');
      print('OTP yang dimasukkan: $otp');
      
      try {
        print('Mengirim permintaan verifikasi OTP ke server...');
        print('Data yang dikirim: ${jsonEncode({'email': widget.email, 'otp': otp})}');
        final response = await http.post(
          Uri.parse('https://api.pensiunku.id/new.php/cekOTP'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({'email': widget.email, 'otp': otp}),
        );

        print('Status kode: ${response.statusCode}');
        print('Respons body: ${response.body}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['text'] != null && data['text']['message'] == 'success') {
            print('OTP berhasil diverifikasi!');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => RecoveryUpdatePhoneScreen(
                  email: widget.email,
                  phone: widget.phone,
                ),
              ),
            );
          } else {
            print('OTP salah atau tidak valid.');
            _showScrollableDialog(
              title: 'Gagal',
              description: 'OTP salah atau tidak valid.',
              confirmText: 'OK',
              isError: true,
            );
          }
        } else {
          print('Terjadi kesalahan pada server.');
          _showScrollableDialog(
            title: 'Kesalahan',
            description: 'Terjadi kesalahan pada server.',
            confirmText: 'OK',
            isError: true,
          );
        }
      } catch (e) {
        print('Kesalahan: $e');
        _showScrollableDialog(
          title: 'Gagal',
          description: 'Gagal menghubungi server.',
          confirmText: 'OK',
          isError: true,
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showScrollableDialog({
    required String title,
    required String description,
    required String confirmText,
    VoidCallback? onConfirm,
    bool isError = false,
  }) {
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
                        foregroundColor: isError ? Colors.red : Color(0xFF017964),
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

  @override
  Widget build(BuildContext context) {
    // Dapatkan dimensi layar untuk responsivitas
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final safePadding = MediaQuery.of(context).padding;
    
    return Scaffold(
      resizeToAvoidBottomInset: false, // Hindari resize saat keyboard muncul
      backgroundColor: Colors.transparent,
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.white,
              Color.fromARGB(255, 170, 231, 170),
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.05), // Responsive padding
                  Image.asset(
                    'assets/register_screen/pensiunku.png',
                    height: 45.0,
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  // Menggunakan AspectRatio untuk skala gambar yang konsisten
                  AspectRatio(
                    aspectRatio: 1.5, // Sesuaikan rasio gambar jika perlu
                    child: Image.asset('assets/otp_screen/otpcode.png', fit: BoxFit.contain),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    'Verifikasi',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Masukkan kode OTP yang telah dikirim \nke email anda',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14.0),
                  ),
                  SizedBox(height: 32.0),
                  Form(
                    key: _formKey,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: SizedBox(
                            width: screenWidth * 0.12, // Responsive width
                            height: screenWidth * 0.12, // Responsive height
                            child: TextFormField(
                              controller: _otpControllers[index],
                              focusNode: _focusNodes[index],
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(color: Color(0xFFFFC950), width: 1.5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(color: Colors.grey, width: 1.5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(color: Color(0xFFFFC950), width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.zero,
                                counterText: '',
                                errorStyle: TextStyle(height: 0), // Sembunyikan pesan error
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(1),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                // Implementasi khusus untuk backspace
                                if (value.isEmpty && index > 0) {
                                  _focusNodes[index - 1].requestFocus();
                                }
                              },
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  SizedBox(height: 32.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFC950),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 32.0),
                    ),
                    onPressed: _isLoading ? null : _verifyOtp,
                    child: _isLoading 
                      ? SizedBox(
                          width: 20, 
                          height: 20, 
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          )
                        )
                      : Text(
                          'Verifikasi',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  ),
                  SizedBox(height: 32.0), // Tambahan padding bawah
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}