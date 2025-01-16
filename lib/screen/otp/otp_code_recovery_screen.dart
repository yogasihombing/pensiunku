import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:pensiunku/screen/otp/recovery_update_phone_screen.dart';

class OtpCodeRecoveryScreen extends StatelessWidget {
  final String email;
  final String phone; // Tambahkan parameter untuk nomor telepon lama


  OtpCodeRecoveryScreen({required this.email, required this.phone});

  final List<TextEditingController> _otpControllers =
      List.generate(5, (_) => TextEditingController());
  final _formKey = GlobalKey<FormState>();

  Future<void> _verifyOtp(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final otp =
          _otpControllers.map((controller) => controller.text.trim()).join();
      print('Email yang digunakan: $email');
      print('Nomor telepon lama: $phone');
      print('OTP yang dimasukkan: $otp');
      try {
        print('Mengirim permintaan verifikasi OTP ke server...');
        print('Data yang dikirim: ${jsonEncode({'email': email, 'otp': otp})}');
        final response = await http.post(
          Uri.parse('https://api.pensiunku.id/new.php/cekOTP'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json', // Jika server membutuhkan header ini
          },
          body: jsonEncode({'email': email, 'otp': otp}),
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
                  email: email,
                  phone: phone, //kirim nomor telepon lama
                ),
              ),
            );
          } else {
            print('OTP salah atau tidak valid.');
            AwesomeDialog(
              context: context,
              dialogType: DialogType.error,
              animType: AnimType.bottomSlide,
              title: 'Gagal',
              desc: 'OTP salah atau tidak valid.',
              btnOkOnPress: () {},
            ).show();
          }
        } else {
          print('Terjadi kesalahan pada server.');
          AwesomeDialog(
            context: context,
            dialogType: DialogType.warning,
            animType: AnimType.bottomSlide,
            title: 'Kesalahan',
            desc: 'Terjadi kesalahan pada server.',
            btnOkOnPress: () {},
          ).show();
        }
      } catch (e) {
        print('Kesalahan: $e');
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.bottomSlide,
          title: 'Gagal',
          desc: 'Gagal menghubungi server.',
          btnOkOnPress: () {},
        ).show();
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
                  'Masukkan kode OTP yang telah dikirim \nke email anda',
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
                    backgroundColor: Color(0xFFFFC950),
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
