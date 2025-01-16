import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:pensiunku/screen/otp/otp_code_recovery_screen.dart';

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
      _showAwesomeDialog("Email tidak boleh kosong.", DialogType.warning);
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
                      email: 'email',
                    )),
          );
        } else {
          _showAwesomeDialog('Email tidak terdaftar.', DialogType.error);
        }
      } else {
        _showAwesomeDialog(
            "Terjadi kesalahan, silakan coba lagi.", DialogType.error);
      }
    } catch (e) {
      print("Kesalahan: $e");
      _showAwesomeDialog(
          "Gagal terhubung ke server. Silakan coba lagi.", DialogType.error);
    } finally {
      setState(() {
        _isLoading = false;
      });
      print("Permintaan selesai.");
    }
  }

  void _showAwesomeDialog(String message, DialogType dialogType) {
    print("Menampilkan dialog: $message");
    AwesomeDialog(
      context: context,
      dialogType: dialogType,
      animType: AnimType.scale,
      title: dialogType == DialogType.success ? 'Berhasil' : 'Kesalahan',
      desc: message,
      btnOkOnPress: () {},
    )..show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.white,
              Color.fromARGB(255, 219, 218, 145), // Warna gradasi hijau muda
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/register_screen/pensiunku.png',
                  height: 45.0, // Sesuaikan tinggi logo
                ),
                SizedBox(height: 70.0),
                Text(
                  'Pemulihan Akun',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Masukkan email yang pernah didaftarkan',
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 16.0),
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
                SizedBox(height: 16.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    padding:
                        EdgeInsets.symmetric(vertical: 12.0, horizontal: 32.0),
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
      ),
    );
  }
}
