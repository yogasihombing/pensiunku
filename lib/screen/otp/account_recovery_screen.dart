import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:pensiunku/screen/otp/otp_code_recovery_screen.dart';

import 'dart:ui';

class AccountRecoveryScreen extends StatefulWidget {
  @override
  _AccountRecoveryScreenState createState() => _AccountRecoveryScreenState();
}

class _AccountRecoveryScreenState extends State<AccountRecoveryScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitEmail() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showScrollableDialog(
        title: "Peringatan",
        description: "Email tidak boleh kosong.",
        confirmText: "OK",
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print("Mengirim permintaan ke server...");
      final response = await http.post(
        Uri.parse('https://api.pensiunku.id/new.php/cekEmail'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      print("Status kode: ${response.statusCode}");
      print("Respons body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['text'] != null && data['text']['message'] == 'success') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OtpCodeRecoveryScreen(
                      email: email,
                      phone: 'phone',
                    )),
          );
        } else {
          _showScrollableDialog(
            title: "Kesalahan",
            description: 'Email tidak terdaftar.',
            confirmText: "OK",
            isError: true,
          );
        }
      } else {
        _showScrollableDialog(
          title: "Kesalahan",
          description: "Terjadi kesalahan, silakan coba lagi.",
          confirmText: "OK",
          isError: true,
        );
      }
    } catch (e) {
      print("Kesalahan: $e");
      _showScrollableDialog(
        title: "Kesalahan",
        description: "Gagal terhubung ke server. Silakan coba lagi.",
        confirmText: "OK",
        isError: true,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
      print("Permintaan selesai.");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
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
        // Menggunakan Stack untuk memposisikan logo di bagian atas dan formulir di tengah
        child: Stack(
          children: [
            // Logo di bagian atas
            Positioned(
              top: 80.0,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  'assets/register_screen/pensiunku.png',
                  height: 45.0,
                ),
              ),
            ),

            // Bagian tengah konten (dari "Pemulihan Akun" hingga tombol Submit)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Pemulihan Akun',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'Masukkan email yang pernah didaftarkan',
                      style: TextStyle(fontSize: 12.0),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24.0),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        labelText: 'Email',
                      ),
                    ),
                    SizedBox(height: 24.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFC950),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                        padding: EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 32.0),
                      ),
                      onPressed: _isLoading ? null : _submitEmail,
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Submit',
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
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
