import 'dart:convert';
import 'dart:ui';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:pensiunku/repository/user_repository.dart';
import 'package:pensiunku/screen/otp/account_recovery_screen.dart';
import 'package:pensiunku/screen/otp/otp_code_screen.dart';
import 'package:http/http.dart' as http;

/// OTP Screen

/// In this screen, user inputs their phone number that will receive OTP SMS.
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
      print('Mengirim permintaan ke server: $url dengan data: $body');

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(Duration(seconds: 10)); // Tambahkan timeout

      print('Status kode respons: ${response.statusCode}');
      print('Isi respons: ${response.body}');

      if (response.statusCode == 200) {
        Map<String, dynamic> data;
        try {
          data = json.decode(response.body);
        } catch (e) {
          print('Error parsing JSON: $e');
          throw Exception('Format respons tidak valid');
        }

        // Mengakses pesan dari respons
        String? message;
        try {
          message = data['text']?['message'];
        } catch (e) {
          print('Error accessing message: $e');
          message = null;
        }

        print('Message dari respons: $message');

        if (message == 'success') {
          print('Nomor terdaftar di sistem.');

          if (_isLoginMode) {
            return true; // Nomor terdaftar, langsung lanjut proses OTP
          } else {
            if (mounted) {
              // Menampilkan dialog "Nomor Sudah Terdaftar" dengan dua tombol
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext context) {
                  return BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      backgroundColor: Colors
                          .transparent, // membuat background AlertDialog transparan
                      insetPadding: EdgeInsets.symmetric(horizontal: 15),
                      content: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF017964),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Nomor Sudah Terdaftar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Nomor telepon ini sudah terdaftar. Silakan pilih menu LOGIN untuk masuk.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Color(0xFF017964),
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    setState(() => _isLoginMode = true);
                                  },
                                  child: Text('Pilih Login'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Color(0xFF017964),
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('Kembali'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
            return false;
          }
        } else {
          print('Nomor tidak terdaftar di sistem.');

          if (_isLoginMode) {
            if (mounted) {
              // Menampilkan dialog "Nomor Belum Terdaftar" dengan dua tombol
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext context) {
                  return BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      backgroundColor: Colors.transparent,
                      insetPadding: EdgeInsets.symmetric(horizontal: 15),
                      content: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF017964),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Nomor Belum Terdaftar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Nomor telepon ini belum terdaftar. Silakan pilih menu DAFTAR untuk membuat akun baru.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Color(0xFF017964),
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    setState(() => _isLoginMode = false);
                                  },
                                  child: Text('Daftar Sekarang'),
                                ),
                                SizedBox(width: 12),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Color(0xFF017964),
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('Kembali'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
            return false;
          } else {
            return true;
          }
        }
      } else {
        print('Respons tidak sukses, status kode: ${response.statusCode}');
        throw Exception('Kesalahan Server');
      }
    } catch (e) {
      print('Terjadi kesalahan: $e');
      if (mounted) {
        // Menampilkan dialog error dengan design yang sama
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                backgroundColor: Colors.transparent,
                insetPadding: EdgeInsets.symmetric(horizontal: 15),
                content: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Kesalahan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Tidak dapat terhubung ke server. Coba lagi nanti.\nDetail: ${e.toString()}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.red,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('OK'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }
      return null;
    }
  }

  Future<void> _sendOtp() async {
    try {
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

      if (!mounted) return; // Cek apakah widget masih terpasang

      setState(() {
        _isLoading = false;
      });

      if (isRegistered == null || !isRegistered) {
        // Dialog atau logika tambahan sudah diatur di `_checkPhoneNumber`
        return;
      }

      // Jika nomor valid sesuai logika, lanjut kirim OTP
      try {
        final result = await UserRepository().sendOtp(_inputPhone);

        if (!mounted) return; // Cek lagi setelah operasi asinkron

        if (result.isSuccess) {
          Navigator.of(context).pushNamed(
            OtpCodeScreen.ROUTE_NAME,
            arguments: OtpCodeScreenArgs(phone: _inputPhone),
          );
        } else {
          _showErrorDialog(result.error ?? 'Gagal mengirimkan OTP');
        }
      } catch (e) {
        print("Error sending OTP: $e");
        if (mounted) {
          _showErrorDialog(
              'Terjadi kesalahan saat mengirim OTP: ${e.toString()}');
        }
      }
    } catch (e) {
      print("Uncaught error in _sendOtp: $e");
      if (mounted) {
        _showErrorDialog('Terjadi kesalahan tidak terduga: ${e.toString()}');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Error'),
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        elevation: 24.0,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.0,
                                ),
                              )
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
                            try {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AccountRecoveryScreen(),
                                ),
                              );
                            } catch (e) {
                              print("Error navigating to recovery: $e");
                              _showErrorDialog(
                                  'Tidak dapat membuka halaman pemulihan akun: ${e.toString()}');
                            }
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
