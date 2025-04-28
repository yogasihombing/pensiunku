import 'dart:ui';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pensiunku/screen/otp/recovery_account_success_screen.dart';

class RecoveryUpdatePhoneScreen extends StatefulWidget {
  final String email;
  final String phone;

  const RecoveryUpdatePhoneScreen({
    Key? key,
    required this.email,
    required this.phone,
  }) : super(key: key);

  @override
  _RecoveryUpdatePhoneScreenState createState() =>
      _RecoveryUpdatePhoneScreenState();
}

class _RecoveryUpdatePhoneScreenState extends State<RecoveryUpdatePhoneScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _phoneController.text = '';
  }

  Future<void> _submitPhone() async {
    final phone = _phoneController.text.trim();

    // Validasi input
    if (phone.isEmpty) {
      _showDialog('Peringatan', 'Nomor telepon tidak boleh kosong.', false);
      return;
    } else if (!RegExp(r'^\d{10,15}$').hasMatch(phone)) {
      _showDialog(
        'Peringatan',
        'Nomor telepon harus berupa angka dan memiliki panjang 10-15 karakter.',
        false,
      );
      return;
    }

    if (phone == widget.phone) {
      _showDialog('Peringatan', 'Silakan masukkan nomor terbaru Anda.', false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Print before sending request
      print(
          'Submitting updateNomorTelepon request for email=${widget.email}, newPhone=$phone');

      final response = await http.post(
        Uri.parse('https://api.pensiunku.id/new.php/updateNomorTelepon'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': widget.email, 'phone': phone}),
      );

      // Print after receiving response
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      final data = jsonDecode(response.body);
      final message = data['text']?['message'];
      print('Parsed message: $message');

      if (response.statusCode == 200) {
        switch (message) {
          case 'success':
            _showDialog(
              'Berhasil',
              'Nomor telepon berhasil diperbarui.',
              false,
              onConfirm: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RecoveryAccountSuccessScreen(phone: phone),
                  ),
                );
              },
            );
            break;
          case 'Nomor telepon anda tidak berubah!':
            _showDialog(
              'Peringatan',
              'Silakan masukkan nomor telepon baru Anda.',
              false,
            );
            break;
          case 'Nomor telepon sudah terdaftar disistem!':
            _showDialog(
              'Error',
              'Nomor telepon ini sudah terdaftar. Silakan gunakan nomor lain.',
              true,
            );
            break;
          default:
            _showDialog('Error', 'Terjadi kesalahan. Silakan coba lagi.', true);
        }
      } else {
        _showDialog(
            'Error', 'Terjadi kesalahan server. Silakan coba lagi.', true);
      }
    } catch (e) {
      // Print on exception
      print('Exception occurred: $e');
      _showDialog(
          'Error', 'Gagal terhubung ke server. Silakan coba lagi.', true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showDialog(String title, String message, bool isError,
      {VoidCallback? onConfirm}) {
    final maxH = MediaQuery.of(context).size.height * 0.5;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => BackdropFilter(
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
                    message,
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
                    child: Text('OK'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.white,
              Color.fromARGB(255, 170, 231, 170),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Image.asset(
                    'assets/register_screen/pensiunku.png',
                    height: 50,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 150),
                Text(
                  'Pemulihan Akun',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Masukkan nomor telepon baru anda',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: (BorderRadius.circular(12)),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide:
                          BorderSide(color: Color(0xFFFFC950), width: 2),
                    ),
                    labelText: 'Nomor Telepon Baru',
                    labelStyle: TextStyle(color: Colors.grey[600]),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    hintText: 'Contoh: 081234567890',
                  ),
                ),
                SizedBox(height: 32),
                Center(
                  child: SizedBox(
                    width: 160,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFC950),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        elevation: 3,
                      ),
                      onPressed: _isLoading ? null : _submitPhone,
                      child: _isLoading
                          ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'SUBMIT',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
