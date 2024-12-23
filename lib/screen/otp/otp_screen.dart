import 'package:flutter/material.dart';
import 'package:pensiunku/repository/user_repository.dart';
import 'package:pensiunku/screen/otp/otp_code_screen.dart';
import 'package:pensiunku/widget/elevated_button_loading.dart';

/// OTP Screen
///
/// In this screen, user inputs their phone number that will receive OTP SMS.
///
class OtpScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/otp';

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  /// Whether the screen is loading or not
  bool _isLoading = false;

  /// User phone number
  String _inputPhone = '';

  /// Is input phone number touched
  bool _inputPhoneTouched = false;

  /// Input phone number controller
  late TextEditingController _inputPhoneController;

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

  /// Send OTP to user phone number
  _sendOtp() {
    setState(() {
      _inputPhoneTouched = true;
    });

    if (_getInputPhoneError() != null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

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

  /// Get user input phone's error. Returns null if phone number is valid.
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
          // Background gradient - full layar
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white, // Hijau muda (atas)
                    Colors.white, // Kuning pucat (tengah)
                    Color.fromARGB(255, 138, 217, 165), // Hijau muda (bawah)
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
                      SizedBox(
                        height: 35,
                        child: Image.asset('assets/otp_screen/pensiunku.png'),
                      ),
                      SizedBox(height: 80.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Navigasi ke page MASUK (sementara kosong)
                            },
                            child: Text(
                              'MASUK',
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black26,
                              ),
                            ),
                          ),
                          Text(
                            ' / ',
                            style: TextStyle(
                              fontSize: 24.0,
                              color: Colors.black,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Navigasi ke page DAFTAR (sementara kosong)
                            },
                            child: Text(
                              'DAFTAR',
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 8.0),
                      Text(
                        'Masukkan nomor telepon anda',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 12.0),
                      // Input Phone Field
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

                      // Tombol Daftar
                      ElevatedButton(
                        onPressed: _isLoading ? null : _sendOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 24.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'DAFTAR',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      SizedBox(height: 120.0),

                      // Informasi Footer
                      Text(
                        'Tidak bisa mengakses nomor telepon anda?',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 2.0),

                      // Tombol Pemulihan Akun
                      TextButton(
                        onPressed: () {
                          // Pemulihan akun handler
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
