import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:pensiunku/repository/user_repository.dart';
import 'package:pensiunku/screen/otp/account_recovery_screen.dart';
import 'package:pensiunku/screen/otp/otp_code_screen.dart';
import 'package:http/http.dart' as http;

/// OTP Screen
///
/// In this screen, user inputs their phone number that will receive OTP SMS.
///
class OtpScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/otp';
  final String phone;

  OtpScreen({required this.phone});

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
    _inputPhoneController.dispose();
    super.dispose();
  }

  Future<bool?> _checkPhoneNumber() async {
    final url = Uri.parse('https://api.pensiunku.id/new.php/cekNomorTelepon');
    final body = json.encode({'phone': _inputPhone});

    try {
      print(
          'Mengirim permintaan ke server: $url dengan data: $body'); // Debug log

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('Status kode respons: ${response.statusCode}');
      print('Isi respons: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Data yang diterima: $data'); // Debug log

        final message = data['text']?['message'];
        print('Message dari respons: $message');

        if (message == 'success') {
          print('Nomor terdaftar di sistem.');

          if (_isLoginMode) {
            // Jika mode LOGIN, langsung kirim OTP
            return true; // Nomor terdaftar
          } else {
            // Jika mode DAFTAR, tampilkan dialog bahwa nomor sudah terdaftar
            AwesomeDialog(
              context: context,
              dialogType: DialogType.info,
              animType: AnimType.scale,
              title: 'Nomor Sudah Terdaftar',
              desc:
                  'Nomor telepon ini sudah terdaftar. Silakan pilih menu LOGIN untuk masuk.',
              btnOkOnPress: () {
                setState(() => _isLoginMode = true); // Alihkan ke mode LOGIN
              },
              btnOkText: 'Pilih Login',
              btnCancelOnPress: () {},
              btnCancelText: 'Kembali',
            ).show();
            return false; // Jangan lanjut ke _sendOtp
          }
        } else {
          print('Nomor tidak terdaftar di sistem.');

          if (_isLoginMode) {
            // Jika mode LOGIN, tampilkan dialog bahwa nomor belum terdaftar
            AwesomeDialog(
              context: context,
              dialogType: DialogType.info,
              animType: AnimType.scale,
              title: 'Nomor Belum Terdaftar',
              desc:
                  'Nomor telepon ini belum terdaftar. Silakan pilih menu DAFTAR untuk membuat akun baru.',
              btnOkOnPress: () {
                setState(() => _isLoginMode = false); // Alihkan ke mode DAFTAR
              },
              btnOkText: 'Daftar Sekarang',
              btnCancelOnPress: () {},
              btnCancelText: 'Kembali',
            ).show();
            return false; // Jangan lanjut ke _sendOtp
          } else {
            // Jika mode DAFTAR, lanjut ke _sendOtp
            return true;
          }
        }
      } else {
        print('Respons tidak sukses, status kode: ${response.statusCode}');
        throw Exception('Kesalahan Server');
      }
    } catch (e) {
      print('Terjadi kesalahan: $e'); // Debug log
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.scale,
        title: 'Kesalahan',
        desc: 'Tidak dapat terhubung ke server. Coba lagi nanti.',
        btnOkOnPress: () {},
      ).show();
      return null; // Kesalahan jaringan
    }
  }

  void _sendOtp() async {
    setState(() {
      _inputPhoneTouched = true;
    });

    if (_getInputPhoneError() != null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final isRegistered = await _checkPhoneNumber();

    if (isRegistered == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (!isRegistered) {
      // Dialog atau logika tambahan sudah diatur di `_checkPhoneNumber`
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Jika nomor valid sesuai logika, lanjut kirim OTP
    UserRepository().sendOtp(_inputPhone).then((result) {
      setState(() {
        _isLoading = false;
      });
      if (result.isSuccess) {
        Navigator.of(context).pushNamed(
          OtpCodeScreen.ROUTE_NAME,
          arguments: OtpCodeScreenArgs(phone: _inputPhone),
        );
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            content: Text(
              result.error ?? 'Gagal mengirimkan OTP',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            elevation: 24.0,
          ),
        );
      }
    });
  }

  String? _getInputPhoneError() {
    if (!_inputPhoneTouched) return null;

    if (_inputPhone.isEmpty) {
      return "Nomor telepon harus diisi";
    } else if (!_inputPhone.trim().startsWith('0')) {
      return "Nomor telepon harus mulai dari angka 0";
    } else if (_inputPhone.trim().length < 8) {
      return "Nomor telepon harus terdiri dari min. 8 karakter";
    } else if (_inputPhone.trim().length > 13) {
      return "Nomor telepon harus terdiri dari max. 13 karakter";
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    String? inputPhoneError = _getInputPhoneError();

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Colors.white,
                    Color.fromARGB(255, 138, 217, 165),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Konten utama
          SafeArea(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 36.0,
                    vertical: 40.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 60.0),
                      Image.asset('assets/otp_screen/pensiunku.png',
                          height: 35),
                      SizedBox(height: 80.0),
                      _buildModeToggle(),

                      SizedBox(height: 8.0),
                      Text(
                        'Masukkan nomor telepon anda',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 12.0),

                      TextField(
                        controller: _inputPhoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Nomor Telepon',
                          errorText: inputPhoneError,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),

                      SizedBox(height: 12.0),

                      ElevatedButton(
                        onPressed: _isLoading ? null : _sendOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 24.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                _isLoginMode ? 'MASUK' : 'DAFTAR',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      SizedBox(height: 120.0),

                      // Informasi Footer
                      if (_isLoginMode)
                        Column(
                          children: [
                            Text(
                              'Tidak bisa mengakses nomor telepon anda?',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 2.0),
                          ],
                        ),

                      SizedBox(height: 2.0),

                      // Tombol Pemulihan Akun
                      if (_isLoginMode)
                        TextButton(
                          onPressed: () {
                            // Pemulihan akun handler
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AccountRecoveryScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'PEMULIHAN AKUN',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      SizedBox(height: 24.0),
                    ],
                  ),
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
          child: Text('MASUK', style: _getModeStyle(_isLoginMode)),
        ),
        Text(' / '),
        GestureDetector(
          onTap: () => setState(() => _isLoginMode = false),
          child: Text('DAFTAR', style: _getModeStyle(!_isLoginMode)),
        ),
      ],
    );
  }

  TextStyle _getModeStyle(bool isActive) {
    return TextStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
      color: isActive ? Colors.black : Colors.black26,
    );
  }
}


// /// OTP Screen
// ///
// /// In this screen, user inputs their phone number that will receive OTP SMS.
// ///
// class OtpScreen extends StatefulWidget {
//   static const String ROUTE_NAME = '/otp';

//   @override
//   _OtpScreenState createState() => _OtpScreenState();
// }

// class _OtpScreenState extends State<OtpScreen> {
//   /// Whether the screen is loading or not
//   bool _isLoading = false;

//   /// User phone number
//   String _inputPhone = '';

//   /// Is input phone number touched
//   bool _inputPhoneTouched = false;

//   /// Input phone number controller
//   late TextEditingController _inputPhoneController;

//   @override
//   void initState() {
//     super.initState();

//     _inputPhoneController = TextEditingController()
//       ..addListener(() {
//         setState(() {
//           _inputPhone = _inputPhoneController.text;
//           _inputPhoneTouched = true;
//         });
//       });
//   }

//   @override
//   void dispose() {
//     _inputPhoneController.dispose();

//     super.dispose();
//   }

//   /// Send OTP to user phone number
//   _sendOtp() {
//     setState(() {
//       _inputPhoneTouched = true;
//     });
//     if (_getInputPhoneError() != null) {
//       return;
//     }
//     setState(() {
//       _isLoading = true;
//     });

//     UserRepository().sendOtp(_inputPhone).then((result) {
//       setState(() {
//         _isLoading = false;
//       });
//       if (result.isSuccess) {
//         Navigator.of(context).pushNamed(
//           OtpCodeScreen.ROUTE_NAME,
//           arguments: OtpCodeScreenArgs(
//             phone: _inputPhone,
//           ),
//         );
//       } else {
//         showDialog(
//             context: context,
//             builder: (_) => AlertDialog(
//                   content: Text(result.error ?? 'Gagal mengirimkan OTP',
//                       style: TextStyle(color: Colors.white)),
//                   backgroundColor: Colors.red,
//                   elevation: 24.0,
//                 ));
//         // WidgetUtil.showSnackbar(
//         //   context,
//         //   result.error ?? 'Gagal mengirimkan OTP',
//         // );
//       }
//     });
//   }

//   /// Get user input phone's error. Returns null if phone number is valid.
//   String? _getInputPhoneError() {
//     if (!_inputPhoneTouched) {
//       return null;
//     }

//     if (_inputPhone.isEmpty) {
//       return "Nomor telepon harus diisi";
//     } else if (!_inputPhone.trim().startsWith('0')) {
//       return "Nomor telepon harus mulai dari angka 0";
//     } else if (_inputPhone.trim().length < 8) {
//       return "Nomor telepon harus terdiri dari min. 8 karakter";
//     } else if (_inputPhone.trim().length > 13) {
//       return "Nomor telepon harus terdiri dari max. 13 karakter";
//     }
//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     ThemeData theme = Theme.of(context);
//     String? inputPhoneError = _getInputPhoneError();

//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 36.0,
//               vertical: 40.0,
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 SizedBox(height: 60.0),
//                 SizedBox(
//                   height: 120,
//                   child: Image.asset('assets/otp_screen/phone.png'),
//                 ),
//                 SizedBox(height: 24.0),
//                 Text(
//                   'Login dengan Nomor Telepon',
//                   textAlign: TextAlign.center,
//                   style: theme.textTheme.headline6?.copyWith(
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 SizedBox(height: 8.0),
//                 Text(
//                   'Masukkan nomor telepon Anda, kami akan mengirimkan OTP untuk memverifikasi',
//                   textAlign: TextAlign.center,
//                   style: theme.textTheme.bodyText2,
//                 ),
//                 SizedBox(height: 24.0),
//                 TextFormField(
//                   controller: _inputPhoneController,
//                   enabled: !_isLoading,
//                   keyboardType: TextInputType.phone,
//                   textAlign: TextAlign.center,
//                   decoration: InputDecoration(
//                     // labelText: 'Nomor Telepon',
//                     errorText: inputPhoneError,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(36.0),
//                     ),
//                     suffixIcon: inputPhoneError != null
//                         ? Icon(
//                             Icons.error,
//                           )
//                         : null,
//                   ),
//                 ),
//                 SizedBox(height: 16.0),
//                 ElevatedButtonLoading(
//                   text: 'Verifikasi OTP',
//                   onTap: _sendOtp,
//                   isLoading: _isLoading,
//                   disabled: _isLoading,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
