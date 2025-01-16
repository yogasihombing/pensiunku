import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OtpCodeRecoveryScreen extends StatelessWidget {
  final String email;

  OtpCodeRecoveryScreen({required this.email});

  final List<TextEditingController> _otpControllers =
      List.generate(5, (_) => TextEditingController());
  final _formKey = GlobalKey<FormState>();

  Future<void> _verifyOtp(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final otp = _otpControllers.map((controller) => controller.text).join();

      try {
        print('Mengirim permintaan verifikasi OTP ke server...');
        final response = await http.post(
          Uri.parse('https://api.pensiunku.id/new.php/cekOTP'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'otp': otp}),
        );

        print('Status kode: ${response.statusCode}');
        print('Respons body: ${response.body}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['text'] != null && data['text']['message'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('OTP berhasil diverifikasi!')),
            );
            // TODO: Tambahkan navigasi ke halaman berikutnya jika diperlukan
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('OTP salah atau tidak valid.')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Terjadi kesalahan pada server.')),
          );
        }
      } catch (e) {
        print('Kesalahan: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghubungi server.')),
        );
      }
    }
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
                Text(
                  'Verifikasi',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Masukkan kode OTP yang telah dikirim ke email anda',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 32.0),
                Form(
                  key: _formKey,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: SizedBox(
                          width: 50.0,
                          height: 50.0,
                          child: TextFormField(
                            controller: _otpControllers[index],
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                              counterText: '',
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            onChanged: (value) {
                              if (value.length == 1 && index < 4) {
                                FocusScope.of(context).nextFocus();
                              } else if (value.isEmpty && index > 0) {
                                FocusScope.of(context).previousFocus();
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '';
                              }
                              return null;
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
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    padding:
                        EdgeInsets.symmetric(vertical: 12.0, horizontal: 32.0),
                  ),
                  onPressed: () => _verifyOtp(context),
                  child: Text(
                    'Verifikasi',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
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
