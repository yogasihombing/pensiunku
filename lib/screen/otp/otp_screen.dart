import 'dart:convert';
import 'dart:ui';

import 'package:awesome_dialog/awesome_dialog.dart';
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
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final message = data['text']?['message'];

        if (message == 'success') {
          if (_isLoginMode) return true;
          if (!mounted) return false;
          _showScrollableDialog(
            title: 'Nomor Sudah Terdaftar',
            description:
                'Nomor telepon ini sudah terdaftar. Silakan pilih menu LOGIN untuk masuk.',
            confirmText: 'Pilih Login',
            onConfirm: () => setState(() => _isLoginMode = true),
          );
          return false;
        } else {
          if (_isLoginMode) {
            if (!mounted) return false;
            _showScrollableDialog(
              title: 'Nomor Belum Terdaftar',
              description: 'Silakan pilih menu DAFTAR untuk membuat akun baru.',
              confirmText: 'Daftar Sekarang',
              onConfirm: () => setState(() => _isLoginMode = false),
            );
            return false;
          }
          return true;
        }
      } else {
        throw Exception('Kesalahan Server: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return null;
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
    setState(() => _inputPhoneTouched = true);
    if (_getInputPhoneError() != null) return;

    setState(() => _isLoading = true);
    final isRegistered = await _checkPhoneNumber();
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (isRegistered == true) {
      try {
        final result = await UserRepository().sendOtp(_inputPhone);
        if (!mounted) return;
        if (result.isSuccess) {
          Navigator.of(context).pushNamed(
            OtpCodeScreen.ROUTE_NAME,
            arguments: OtpCodeScreenArgs(phone: _inputPhone),
          );
        } else {
          _showScrollableDialog(
            title: 'Error',
            description: result.error ?? 'Gagal mengirimkan OTP',
            confirmText: 'OK',
            isError: true,
          );
        }
      } catch (e) {
        if (!mounted) return;
        _showScrollableDialog(
          title: 'Error',
          description: 'Terjadi kesalahan saat mengirim OTP: ${e.toString()}',
          confirmText: 'OK',
          isError: true,
        );
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
                    Color.fromARGB(255, 170, 231, 170), // Hijau muda (pinggir kanan)
                  ],
                  stops: [0.0, 0.25, 0.5, 1.0], // Titik berhenti warna di gradient
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


// /// OTP Screen

// /// In this screen, user inputs their phone number that will receive OTP SMS.
// class OtpScreen extends StatefulWidget {
//   static const String ROUTE_NAME = '/otp';

//   @override
//   _OtpScreenState createState() => _OtpScreenState();
// }

// class _OtpScreenState extends State<OtpScreen> {
//   bool _isLoading = false;
//   String _inputPhone = '';
//   bool _inputPhoneTouched = false;
//   late TextEditingController _inputPhoneController;
//   bool _isLoginMode = true;

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

//   Future<bool?> _checkPhoneNumber() async {
//     final url = Uri.parse('https://api.pensiunku.id/new.php/cekNomorTelepon');
//     final body = json.encode({'phone': _inputPhone});

//     try {
//       print('Mengirim permintaan ke server: $url dengan data: $body');

//       final response = await http
//           .post(
//             url,
//             headers: {'Content-Type': 'application/json'},
//             body: body,
//           )
//           .timeout(Duration(seconds: 10)); // Tambahkan timeout

//       print('Status kode respons: ${response.statusCode}');
//       print('Isi respons: ${response.body}');

//       if (response.statusCode == 200) {
//         Map<String, dynamic> data;
//         try {
//           data = json.decode(response.body);
//         } catch (e) {
//           print('Error parsing JSON: $e');
//           throw Exception('Format respons tidak valid');
//         }

//         // Mengakses pesan dari respons
//         String? message;
//         try {
//           message = data['text']?['message'];
//         } catch (e) {
//           print('Error accessing message: $e');
//           message = null;
//         }

//         print('Message dari respons: $message');

//         if (message == 'success') {
//           print('Nomor terdaftar di sistem.');

//           if (_isLoginMode) {
//             return true; // Nomor terdaftar, langsung lanjut proses OTP
//           } else {
//             if (mounted) {
//               // Menampilkan dialog "Nomor Sudah Terdaftar" dengan dua tombol
//               showDialog(
//                 context: context,
//                 barrierDismissible: true,
//                 builder: (BuildContext context) {
//                   return BackdropFilter(
//                     filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
//                     child: AlertDialog(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                       backgroundColor: Colors
//                           .transparent, // membuat background AlertDialog transparan
//                       insetPadding: EdgeInsets.symmetric(horizontal: 15),
//                       content: Container(
//                         decoration: BoxDecoration(
//                           color: Color(0xFF017964),
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                         padding: EdgeInsets.all(16),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Text(
//                               'Nomor Sudah Terdaftar',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                             SizedBox(height: 10),
//                             Text(
//                               'Nomor telepon ini sudah terdaftar. Silakan pilih menu LOGIN untuk masuk.',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.white,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                             SizedBox(height: 20),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                               children: [
//                                 ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                     foregroundColor: Color(0xFF017964),
//                                     backgroundColor: Colors.white,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                   ),
//                                   onPressed: () {
//                                     Navigator.pop(context);
//                                     setState(() => _isLoginMode = true);
//                                   },
//                                   child: Text('Pilih Login'),
//                                 ),
//                                 ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                     foregroundColor: Color(0xFF017964),
//                                     backgroundColor: Colors.white,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                   ),
//                                   onPressed: () {
//                                     Navigator.pop(context);
//                                   },
//                                   child: Text('Kembali'),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               );
//             }
//             return false;
//           }
//         } else {
//           print('Nomor tidak terdaftar di sistem.');

//           if (_isLoginMode) {
//             if (mounted) {
//               // Menampilkan dialog "Nomor Belum Terdaftar" dengan dua tombol
//               showDialog(
//                 context: context,
//                 barrierDismissible: true,
//                 builder: (BuildContext context) {
//                   return BackdropFilter(
//                     filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
//                     child: AlertDialog(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                       backgroundColor: Colors.transparent,
//                       insetPadding: EdgeInsets.symmetric(horizontal: 15),
//                       content: Container(
//                         decoration: BoxDecoration(
//                           color: Color(0xFF017964),
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                         padding: EdgeInsets.all(16),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Text(
//                               'Nomor Belum Terdaftar',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                             SizedBox(height: 10),
//                             Text(
//                               'Silakan pilih menu DAFTAR untuk membuat akun baru.',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.white,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                             SizedBox(height: 20),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                               children: [
//                                 ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                     foregroundColor: Color(0xFF017964),
//                                     backgroundColor: Colors.white,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                   ),
//                                   onPressed: () {
//                                     Navigator.pop(context);
//                                     setState(() => _isLoginMode = false);
//                                   },
//                                   child: Text('Daftar Sekarang'),
//                                 ),
//                                 SizedBox(width: 12),
//                                 ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                     foregroundColor: Color(0xFF017964),
//                                     backgroundColor: Colors.white,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                   ),
//                                   onPressed: () {
//                                     Navigator.pop(context);
//                                   },
//                                   child: Text('Kembali'),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               );
//             }
//             return false;
//           } else {
//             return true;
//           }
//         }
//       } else {
//         print('Respons tidak sukses, status kode: ${response.statusCode}');
//         throw Exception('Kesalahan Server');
//       }
//     } catch (e) {
//       print('Terjadi kesalahan: $e');
//       if (mounted) {
//         // Menampilkan dialog error dengan design yang sama
//         showDialog(
//           context: context,
//           barrierDismissible: true,
//           builder: (BuildContext context) {
//             return BackdropFilter(
//               filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
//               child: AlertDialog(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 backgroundColor: Colors.transparent,
//                 insetPadding: EdgeInsets.symmetric(horizontal: 15),
//                 content: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.red,
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   padding: EdgeInsets.all(16),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         'Kesalahan',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                       SizedBox(height: 10),
//                       Text(
//                         'Tidak dapat terhubung ke server. Coba lagi nanti.\nDetail: ${e.toString()}',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.white,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                       SizedBox(height: 20),
//                       ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           foregroundColor: Colors.red,
//                           backgroundColor: Colors.white,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                         onPressed: () {
//                           Navigator.pop(context);
//                         },
//                         child: Text('OK'),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       }
//       return null;
//     }
//   }

//   Future<void> _sendOtp() async {
//     try {
//       setState(() {
//         _inputPhoneTouched = true;
//       });

//       if (_getInputPhoneError() != null) {
//         return;
//       }

//       setState(() {
//         _isLoading = true;
//       });

//       final isRegistered = await _checkPhoneNumber();

//       if (!mounted) return; // Cek apakah widget masih terpasang

//       setState(() {
//         _isLoading = false;
//       });

//       if (isRegistered == null || !isRegistered) {
//         // Dialog atau logika tambahan sudah diatur di `_checkPhoneNumber`
//         return;
//       }

//       // Jika nomor valid sesuai logika, lanjut kirim OTP
//       try {
//         final result = await UserRepository().sendOtp(_inputPhone);

//         if (!mounted) return; // Cek lagi setelah operasi asinkron

//         if (result.isSuccess) {
//           Navigator.of(context).pushNamed(
//             OtpCodeScreen.ROUTE_NAME,
//             arguments: OtpCodeScreenArgs(phone: _inputPhone),
//           );
//         } else {
//           _showErrorDialog(result.error ?? 'Gagal mengirimkan OTP');
//         }
//       } catch (e) {
//         print("Error sending OTP: $e");
//         if (mounted) {
//           _showErrorDialog(
//               'Terjadi kesalahan saat mengirim OTP: ${e.toString()}');
//         }
//       }
//     } catch (e) {
//       print("Uncaught error in _sendOtp: $e");
//       if (mounted) {
//         _showErrorDialog('Terjadi kesalahan tidak terduga: ${e.toString()}');
//       }
//     }
//   }

//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text('Error'),
//         content: Text(
//           message,
//           style: TextStyle(color: Colors.white),
//         ),
//         backgroundColor: Colors.red,
//         elevation: 24.0,
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: Text('OK', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   String? _getInputPhoneError() {
//     if (!_inputPhoneTouched) return null;

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
//     String? inputPhoneError = _getInputPhoneError();

//     return Scaffold(
//       body: Stack(
//         children: [
//           // Background gradient
//           Positioned.fill(
//             child: Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     Colors.white,
//                     Colors.white,
//                     Color.fromARGB(255, 138, 217, 165),
//                   ],
//                   stops: [0.0, 0.5, 1.0],
//                 ),
//               ),
//             ),
//           ),

//           // Konten utama
//           SafeArea(
//             child: SingleChildScrollView(
//               physics: BouncingScrollPhysics(),
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(
//                   minHeight: MediaQuery.of(context).size.height,
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 36.0,
//                     vertical: 40.0,
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       SizedBox(height: 60.0),
//                       Image.asset('assets/otp_screen/pensiunku.png',
//                           height: 35),
//                       SizedBox(height: 80.0),
//                       _buildModeToggle(),

//                       SizedBox(height: 8.0),
//                       Text(
//                         'Masukkan nomor telepon anda',
//                         style: TextStyle(
//                           fontSize: 16.0,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                       SizedBox(height: 12.0),

//                       TextField(
//                         controller: _inputPhoneController,
//                         keyboardType: TextInputType.phone,
//                         decoration: InputDecoration(
//                           labelText: 'Nomor Telepon',
//                           errorText: inputPhoneError,
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8.0),
//                           ),
//                         ),
//                       ),

//                       SizedBox(height: 12.0),

//                       ElevatedButton(
//                         onPressed: _isLoading ? null : _sendOtp,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.orange,
//                           foregroundColor: Colors.white,
//                           padding: EdgeInsets.symmetric(
//                             vertical: 12.0,
//                             horizontal: 24.0,
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(24.0),
//                           ),
//                         ),
//                         child: _isLoading
//                             ? SizedBox(
//                                 width: 20,
//                                 height: 20,
//                                 child: CircularProgressIndicator(
//                                   color: Colors.white,
//                                   strokeWidth: 2.0,
//                                 ),
//                               )
//                             : Text(
//                                 _isLoginMode ? 'MASUK' : 'DAFTAR',
//                                 style: TextStyle(
//                                   fontSize: 16.0,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                       ),
//                       SizedBox(height: 120.0),

//                       // Informasi Footer
//                       if (_isLoginMode)
//                         Column(
//                           children: [
//                             Text(
//                               'Tidak bisa mengakses nomor telepon anda?',
//                               style: TextStyle(
//                                 color: Colors.grey,
//                                 fontSize: 12.0,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                             SizedBox(height: 2.0),
//                           ],
//                         ),

//                       SizedBox(height: 2.0),

//                       // Tombol Pemulihan Akun
//                       if (_isLoginMode)
//                         TextButton(
//                           onPressed: () {
//                             try {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => AccountRecoveryScreen(),
//                                 ),
//                               );
//                             } catch (e) {
//                               print("Error navigating to recovery: $e");
//                               _showErrorDialog(
//                                   'Tidak dapat membuka halaman pemulihan akun: ${e.toString()}');
//                             }
//                           },
//                           child: Text(
//                             'PEMULIHAN AKUN',
//                             style: TextStyle(
//                               color: Colors.orange,
//                               fontSize: 14.0,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),

//                       SizedBox(height: 24.0),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildModeToggle() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         GestureDetector(
//           onTap: () => setState(() => _isLoginMode = true),
//           child: Text('MASUK', style: _getModeStyle(_isLoginMode)),
//         ),
//         Text(' / '),
//         GestureDetector(
//           onTap: () => setState(() => _isLoginMode = false),
//           child: Text('DAFTAR', style: _getModeStyle(!_isLoginMode)),
//         ),
//       ],
//     );
//   }

//   TextStyle _getModeStyle(bool isActive) {
//     return TextStyle(
//       fontSize: 24.0,
//       fontWeight: FontWeight.bold,
//       color: isActive ? Colors.black : Colors.black26,
//     );
//   }
// }
