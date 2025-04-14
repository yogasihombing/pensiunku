import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pensiunku/repository/user_repository.dart';
import 'package:pensiunku/screen/register/prepare_register_screen.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:pensiunku/widget/elevated_button_loading.dart';
import 'package:pensiunku/widget/text_button_loading.dart';
// import 'package:otp_autofill/otp_autofill.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpCodeScreenArgs {
  final String phone;

  OtpCodeScreenArgs({
    required this.phone,
  });
}

/// OTP Code Screen
///
/// In this screen, user inputs the code that they received from OTP SMS.
///
class OtpCodeScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/otp/code';
  final String phone;

  const OtpCodeScreen({
    Key? key,
    required this.phone,
  }) : super(key: key);

  @override
  _OtpCodeScreenState createState() => _OtpCodeScreenState();
}

class _OtpCodeScreenState extends State<OtpCodeScreen> {
  /// How long until user can request resend OTP in seconds
  static const int RESEND_COUNTDOWN_SECOND = 60;

  /// Whether resend OTP is loading or not
  bool _isLoadingResend = false;

  /// Whether verify OTP code is loading or not
  bool _isLoadingVerify = false;

  /// Whether user can request resed OTP or not
  bool _canResendOtp = false;

  /// Resend OTP timer
  Timer? _resendTimer;

  /// Resend OTP counter
  late int _resendCounter;

  /// Input OTP code controller
  late TextEditingController _inputOtpController;
  
  /// Flag to track if initialization has completed
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    // Bungkus dengan try-catch untuk menangkap error inisialisasi
    try {
      _inputOtpController = TextEditingController();
      _startResendTimer();
      _isInitialized = true;
    } catch (e) {
      print('Error initializing OTP screen: $e');
      // Tampilkan pesan error jika terjadi masalah saat inisialisasi
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showErrorDialog('Terjadi kesalahan saat memuat layar OTP: ${e.toString()}');
        }
      });
    }
  }

  @override
  void dispose() {
    // Pastikan controller dibersihkan
    _inputOtpController.dispose();
    
    // Pastikan timer dibatalkan untuk menghindari memory leak
    _resendTimer?.cancel();
    super.dispose();
  }

  /// Start resend OTP timer with improved error handling
  void _startResendTimer() {
    try {
      setState(() {
        _resendCounter = RESEND_COUNTDOWN_SECOND;
        _canResendOtp = false;
      });
      
      _resendTimer?.cancel(); // Cancel any existing timer
      _resendTimer = Timer.periodic(
        Duration(seconds: 1),
        (Timer timer) {
          if (mounted) {
            if (_resendCounter == 0) {
              setState(() {
                timer.cancel();
                _canResendOtp = true;
              });
            } else {
              setState(() {
                _resendCounter--;
              });
            }
          } else {
            // Stop timer if widget is no longer mounted
            timer.cancel();
          }
        },
      );
    } catch (e) {
      print('Error starting resend timer: $e');
    }
  }

  /// Verify user OTP code with improved error handling
  Future<void> _verify() async {
    try {
      if (!_validateInputCode(_inputOtpController.text)) {
        _showErrorDialog('Kode OTP harus 5 digit');
        return;
      }
      
      if (!mounted) return;
      
      setState(() {
        _isLoadingVerify = true;
      });
      
      try {
        final result = await UserRepository().verifyOtp(
          widget.phone, 
          _inputOtpController.text
        );
        
        if (!mounted) return;
        
        setState(() {
          _isLoadingVerify = false;
        });
        
        if (result.isSuccess && result.data != null) {
          // Save token
          try {
            final prefs = await SharedPreferencesUtil().sharedPreferences;
            await prefs.setString(SharedPreferencesUtil.SP_KEY_TOKEN, result.data!);
            
            if (!mounted) return;
            
            _resendTimer?.cancel();
            
            // Navigasi dengan safe call
            try {
              Navigator.of(context).pushNamedAndRemoveUntil(
                PrepareRegisterScreen.ROUTE_NAME,
                (route) => false,
              );
            } catch (e) {
              print('Navigation error: $e');
              if (mounted) {
                _showErrorDialog('Terjadi kesalahan saat membuka halaman selanjutnya. Silakan coba lagi.');
              }
            }
          } catch (e) {
            print('Error saving token: $e');
            if (mounted) {
              _showErrorDialog('Gagal menyimpan token: ${e.toString()}');
            }
          }
        } else {
          if (mounted) {
            _showErrorDialog(result.error ?? 'Gagal memverifikasi OTP. Pastikan kode yang dimasukkan benar.');
          }
        }
      } catch (e) {
        print('Error verifying OTP: $e');
        if (mounted) {
          setState(() {
            _isLoadingVerify = false;
          });
          _showErrorDialog('Terjadi kesalahan saat verifikasi OTP: ${e.toString()}');
        }
      }
    } catch (e) {
      print('Uncaught error in _verify: $e');
      if (mounted) {
        setState(() {
          _isLoadingVerify = false;
        });
        _showErrorDialog('Terjadi kesalahan tidak terduga: ${e.toString()}');
      }
    }
  }

  /// Validate user OTP code. Returns true if code is valid.
  bool _validateInputCode(String? inputCode) {
    if (inputCode == null) {
      return false;
    }
    if (inputCode.isNotEmpty && inputCode.trim().length == 5) {
      // Pastikan hanya berisi angka
      if (RegExp(r'^\d{5}$').hasMatch(inputCode.trim())) {
        return true;
      }
    }
    return false;
  }

  /// Resend OTP code with improved error handling
  Future<void> _resendOtp() async {
    try {
      if (!mounted) return;
      
      setState(() {
        _isLoadingResend = true;
      });
      
      try {
        final result = await UserRepository().sendOtp(widget.phone);
        
        if (!mounted) return;
        
        setState(() {
          _isLoadingResend = false;
        });
        
        if (result.isSuccess) {
          if (mounted) {
            _showSuccessDialog('OTP sudah berhasil dikirim ulang!');
            _startResendTimer();
          }
        } else {
          if (mounted) {
            _showErrorDialog(result.error ?? 'Gagal mengirim ulang OTP');
          }
        }
      } catch (e) {
        print('Error resending OTP: $e');
        if (mounted) {
          setState(() {
            _isLoadingResend = false;
          });
          _showErrorDialog('Terjadi kesalahan saat mengirim ulang OTP: ${e.toString()}');
        }
      }
    } catch (e) {
      print('Uncaught error in _resendOtp: $e');
      if (mounted) {
        setState(() {
          _isLoadingResend = false;
        });
        _showErrorDialog('Terjadi kesalahan tidak terduga: ${e.toString()}');
      }
    }
  }

  /// Show error dialog with improved UI
  void _showErrorDialog(String message) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Error', style: TextStyle(color: Colors.white)),
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

  /// Show success dialog
  void _showSuccessDialog(String message) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
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

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    bool _isLoading = _isLoadingVerify || _isLoadingResend;

    // Jika belum diinisialisasi, tampilkan loading
    if (!_isInitialized) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: WillPopScope(
        // Tangani tombol back untuk menghindari crash
        onWillPop: () async {
          // Batalkan timer jika ada
          _resendTimer?.cancel();
          // Izinkan navigasi kembali
          return true;
        },
        child: Stack(
          children: [
            // Background Gradient - full layar
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      Colors.white,
                      Color.fromARGB(225, 138, 217, 165), // Hijau Muda
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),

            // Konten Utama
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
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
                              height: 220,
                              child: Image.asset('assets/otp_screen/otpcode.png'),
                            ),
                            SizedBox(height: 24.0),
                            Text(
                              'VERIFIKASI',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headline6?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'Masukkan 5 digit kode OTP yang telah dikirim ke nomor ${widget.phone}',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyText2,
                            ),
                            SizedBox(height: 24.0),
                            PinCodeTextField(
                              enabled: !_isLoading,
                              length: 5,
                              animationType: AnimationType.fade,
                              keyboardType: TextInputType.number,
                              cursorColor: theme.primaryColor,
                              pinTheme: PinTheme(
                                shape: PinCodeFieldShape.box,
                                borderRadius: BorderRadius.circular(5),
                                fieldHeight: 50,
                                fieldWidth: 50,
                                selectedColor:
                                    theme.primaryColor.withOpacity(0.6),
                                selectedFillColor:
                                    theme.primaryColor.withOpacity(0.6),
                                inactiveColor: Colors.grey[300],
                                inactiveFillColor: Colors.white,
                                activeFillColor:
                                    theme.primaryColor.withOpacity(0.4),
                                activeColor: theme.primaryColor.withOpacity(0.4),
                              ),
                              animationDuration: Duration(milliseconds: 300),
                              enableActiveFill: true,
                              controller: _inputOtpController,
                              appContext: context,
                              onChanged: (value) {},
                              beforeTextPaste: (text) {
                                // Validasi teks yang akan di-paste
                                if (text != null && RegExp(r'^\d+$').hasMatch(text)) {
                                  return true;
                                }
                                return false;
                              },
                            ),
                            SizedBox(height: 16.0),
                            ElevatedButtonLoading(
                              text: 'VERIFIKASI OTP',
                              onTap: _verify,
                              isLoading: _isLoadingVerify,
                              disabled: _isLoading,
                            ),
                            SizedBox(height: 16.0),
                            _canResendOtp
                                ? TextButtonLoading(
                                    text: 'Kirim Ulang OTP',
                                    onTap: _resendOtp,
                                    isLoading: _isLoadingResend,
                                    disabled: _isLoading,
                                  )
                                : Column(
                                    children: [
                                      SizedBox(height: 16.0),
                                      Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Kirim ulang OTP dalam $_resendCounter detik',
                                        ),
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class OtpCodeScreenArgs {
//   final String phone;

//   OtpCodeScreenArgs({
//     required this.phone,
//   });
// }

// /// OTP Code Screen
// ///
// /// In this screen, user inputs the code that they received from OTP SMS.
// ///
// class OtpCodeScreen extends StatefulWidget {
//   static const String ROUTE_NAME = '/otp/code';
//   final String phone;

//   const OtpCodeScreen({
//     Key? key,
//     required this.phone,
//   }) : super(key: key);

//   @override
//   _OtpCodeScreenState createState() => _OtpCodeScreenState();
// }

// class _OtpCodeScreenState extends State<OtpCodeScreen> {
//   /// How long until user can request resend OTP in seconds
//   static const int RESEND_COUNTDOWN_SECOND = 60;

//   /// Whether resend OTP is loading or not
//   bool _isLoadingResend = false;

//   /// Whether verify OTP code is loading or not
//   bool _isLoadingVerify = false;

//   /// Whether user can request resed OTP or not
//   bool _canResendOtp = false;

//   /// Resend OTP timer
//   Timer? _resendTimer;

//   /// Resend OTP counter
//   late int _resendCounter;

//   /// Input OTP code controller
//   late OTPTextEditController _inputOtpController;
  
//   /// Flag to track if initialization has completed
//   bool _isInitialized = false;

//   @override
//   void initState() {
//     super.initState();

//     // Bungkus dengan try-catch untuk menangkap error inisialisasi
//     try {
//       _initOtpAutofill();
//       _startResendTimer();
//       _isInitialized = true;
//     } catch (e) {
//       print('Error initializing OTP screen: $e');
//       // Tampilkan pesan error jika terjadi masalah saat inisialisasi
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted) {
//           _showErrorDialog('Terjadi kesalahan saat memuat layar OTP: ${e.toString()}');
//         }
//       });
//     }
//   }

//   @override
//   void dispose() {
//     try {
//       // Gunakan try-catch untuk menangkap error dispose controller
//       if (_isInitialized) {
//         _inputOtpController.stopListen();
//         _inputOtpController.dispose();
//       }
//     } catch (e) {
//       print('Error disposing OTP controller: $e');
//     }
    
//     // Pastikan timer dibatalkan untuk menghindari memory leak
//     _resendTimer?.cancel();
//     super.dispose();
//   }

//   /// Initialize OTP autofill dengan penanganan error
//   void _initOtpAutofill() {
//     try {
//       final otpInteractor = OTPInteractor();
//       otpInteractor.getAppSignature().then((value) {
//         print('signature - $value');
//       }).catchError((error) {
//         print('Error getting app signature: $error');
//       });
      
//       _inputOtpController = OTPTextEditController(
//         codeLength: 5,
//         onCodeReceive: (code) {
//           // Tangani kode yang diterima secara aman
//           if (mounted && code != null && code.length == 5) {
//             // Verifikasi otomatis hanya jika kode lengkap
//             // _verify(); // Dikomentar untuk menghindari verifikasi otomatis
//           }
//         },
//       );
      
//       // Bungkus dengan try-catch untuk menangkap error saat memulai listen
//       try {
//         _inputOtpController.startListenUserConsent(
//           (code) {
//             final exp = RegExp(r'(\d{5})');
//             return exp.stringMatch(code ?? '') ?? '';
//           },
//           strategies: [
//             // SampleStrategy(),
//           ],
//         );
//       } catch (e) {
//         print('Error starting OTP listener: $e');
//         // Jika terjadi error, tetap lanjutkan tanpa autofill
//       }
//     } catch (e) {
//       print('Error in _initOtpAutofill: $e');
//       throw e; // Re-throw untuk ditangkap di initState
//     }
//   }

//   /// Start resend OTP timer with improved error handling
//   void _startResendTimer() {
//     try {
//       setState(() {
//         _resendCounter = RESEND_COUNTDOWN_SECOND;
//         _canResendOtp = false;
//       });
      
//       _resendTimer?.cancel(); // Cancel any existing timer
//       _resendTimer = Timer.periodic(
//         Duration(seconds: 1),
//         (Timer timer) {
//           if (mounted) {
//             if (_resendCounter == 0) {
//               setState(() {
//                 timer.cancel();
//                 _canResendOtp = true;
//               });
//             } else {
//               setState(() {
//                 _resendCounter--;
//               });
//             }
//           } else {
//             // Stop timer if widget is no longer mounted
//             timer.cancel();
//           }
//         },
//       );
//     } catch (e) {
//       print('Error starting resend timer: $e');
//     }
//   }

//   /// Verify user OTP code with improved error handling
//   Future<void> _verify() async {
//     try {
//       if (!_validateInputCode(_inputOtpController.text)) {
//         _showErrorDialog('Kode OTP harus 5 digit');
//         return;
//       }
      
//       if (!mounted) return;
      
//       setState(() {
//         _isLoadingVerify = true;
//       });
      
//       try {
//         final result = await UserRepository().verifyOtp(
//           widget.phone, 
//           _inputOtpController.text
//         );
        
//         if (!mounted) return;
        
//         setState(() {
//           _isLoadingVerify = false;
//         });
        
//         if (result.isSuccess && result.data != null) {
//           // Save token
//           try {
//             final prefs = await SharedPreferencesUtil().sharedPreferences;
//             await prefs.setString(SharedPreferencesUtil.SP_KEY_TOKEN, result.data!);
            
//             if (!mounted) return;
            
//             _resendTimer?.cancel();
            
//             // Navigasi dengan safe call
//             try {
//               Navigator.of(context).pushNamedAndRemoveUntil(
//                 PrepareRegisterScreen.ROUTE_NAME,
//                 (route) => false,
//               );
//             } catch (e) {
//               print('Navigation error: $e');
//               if (mounted) {
//                 _showErrorDialog('Terjadi kesalahan saat membuka halaman selanjutnya. Silakan coba lagi.');
//               }
//             }
//           } catch (e) {
//             print('Error saving token: $e');
//             if (mounted) {
//               _showErrorDialog('Gagal menyimpan token: ${e.toString()}');
//             }
//           }
//         } else {
//           if (mounted) {
//             _showErrorDialog(result.error ?? 'Gagal memverifikasi OTP. Pastikan kode yang dimasukkan benar.');
//           }
//         }
//       } catch (e) {
//         print('Error verifying OTP: $e');
//         if (mounted) {
//           setState(() {
//             _isLoadingVerify = false;
//           });
//           _showErrorDialog('Terjadi kesalahan saat verifikasi OTP: ${e.toString()}');
//         }
//       }
//     } catch (e) {
//       print('Uncaught error in _verify: $e');
//       if (mounted) {
//         setState(() {
//           _isLoadingVerify = false;
//         });
//         _showErrorDialog('Terjadi kesalahan tidak terduga: ${e.toString()}');
//       }
//     }
//   }

//   /// Validate user OTP code. Returns true if code is valid.
//   bool _validateInputCode(String? inputCode) {
//     if (inputCode == null) {
//       return false;
//     }
//     if (inputCode.isNotEmpty && inputCode.trim().length == 5) {
//       // Pastikan hanya berisi angka
//       if (RegExp(r'^\d{5}$').hasMatch(inputCode.trim())) {
//         return true;
//       }
//     }
//     return false;
//   }

//   /// Resend OTP code with improved error handling
//   Future<void> _resendOtp() async {
//     try {
//       if (!mounted) return;
      
//       setState(() {
//         _isLoadingResend = true;
//       });
      
//       try {
//         final result = await UserRepository().sendOtp(widget.phone);
        
//         if (!mounted) return;
        
//         setState(() {
//           _isLoadingResend = false;
//         });
        
//         if (result.isSuccess) {
//           if (mounted) {
//             _showSuccessDialog('OTP sudah berhasil dikirim ulang!');
//             _startResendTimer();
//           }
//         } else {
//           if (mounted) {
//             _showErrorDialog(result.error ?? 'Gagal mengirim ulang OTP');
//           }
//         }
//       } catch (e) {
//         print('Error resending OTP: $e');
//         if (mounted) {
//           setState(() {
//             _isLoadingResend = false;
//           });
//           _showErrorDialog('Terjadi kesalahan saat mengirim ulang OTP: ${e.toString()}');
//         }
//       }
//     } catch (e) {
//       print('Uncaught error in _resendOtp: $e');
//       if (mounted) {
//         setState(() {
//           _isLoadingResend = false;
//         });
//         _showErrorDialog('Terjadi kesalahan tidak terduga: ${e.toString()}');
//       }
//     }
//   }

//   /// Show error dialog with improved UI
//   void _showErrorDialog(String message) {
//     if (!mounted) return;
    
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text('Error', style: TextStyle(color: Colors.white)),
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

//   /// Show success dialog
//   void _showSuccessDialog(String message) {
//     if (!mounted) return;
    
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         content: Text(
//           message,
//           style: TextStyle(color: Colors.white),
//         ),
//         backgroundColor: Colors.green,
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

//   @override
//   Widget build(BuildContext context) {
//     ThemeData theme = Theme.of(context);
//     bool _isLoading = _isLoadingVerify || _isLoadingResend;

//     // Jika belum diinisialisasi, tampilkan loading
//     if (!_isInitialized) {
//       return Scaffold(
//         body: Center(
//           child: CircularProgressIndicator(),
//         ),
//       );
//     }

//     return Scaffold(
//       body: WillPopScope(
//         // Tangani tombol back untuk menghindari crash
//         onWillPop: () async {
//           // Batalkan timer jika ada
//           _resendTimer?.cancel();
//           // Izinkan navigasi kembali
//           return true;
//         },
//         child: Stack(
//           children: [
//             // Background Gradient - full layar
//             Positioned.fill(
//               child: Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [
//                       Colors.white,
//                       Colors.white,
//                       Color.fromARGB(225, 138, 217, 165), // Hijau Muda
//                     ],
//                     stops: [0.0, 0.5, 1.0],
//                   ),
//                 ),
//               ),
//             ),

//             // Konten Utama
//             SafeArea(
//               child: Column(
//                 children: [
//                   Expanded(
//                     child: SingleChildScrollView(
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 36.0,
//                           vertical: 40.0,
//                         ),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             SizedBox(height: 60.0),
//                             SizedBox(
//                               height: 220,
//                               child: Image.asset('assets/otp_screen/otpcode.png'),
//                             ),
//                             SizedBox(height: 24.0),
//                             Text(
//                               'VERIFIKASI',
//                               textAlign: TextAlign.center,
//                               style: theme.textTheme.headline6?.copyWith(
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                             SizedBox(height: 8.0),
//                             Text(
//                               'Masukkan 5 digit kode OTP yang telah dikirim ke nomor ${widget.phone}',
//                               textAlign: TextAlign.center,
//                               style: theme.textTheme.bodyText2,
//                             ),
//                             SizedBox(height: 24.0),
//                             PinCodeTextField(
//                               enabled: !_isLoading,
//                               length: 5,
//                               animationType: AnimationType.fade,
//                               keyboardType: TextInputType.number,
//                               cursorColor: theme.primaryColor,
//                               pinTheme: PinTheme(
//                                 shape: PinCodeFieldShape.box,
//                                 borderRadius: BorderRadius.circular(5),
//                                 fieldHeight: 50,
//                                 fieldWidth: 50,
//                                 selectedColor:
//                                     theme.primaryColor.withOpacity(0.6),
//                                 selectedFillColor:
//                                     theme.primaryColor.withOpacity(0.6),
//                                 inactiveColor: Colors.grey[300],
//                                 inactiveFillColor: Colors.white,
//                                 activeFillColor:
//                                     theme.primaryColor.withOpacity(0.4),
//                                 activeColor: theme.primaryColor.withOpacity(0.4),
//                               ),
//                               animationDuration: Duration(milliseconds: 300),
//                               enableActiveFill: true,
//                               controller: _inputOtpController,
//                               appContext: context,
//                               onChanged: (value) {},
//                               beforeTextPaste: (text) {
//                                 // Validasi teks yang akan di-paste
//                                 if (text != null && RegExp(r'^\d+$').hasMatch(text)) {
//                                   return true;
//                                 }
//                                 return false;
//                               },
//                             ),
//                             SizedBox(height: 16.0),
//                             ElevatedButtonLoading(
//                               text: 'VERIFIKASI OTP',
//                               onTap: _verify,
//                               isLoading: _isLoadingVerify,
//                               disabled: _isLoading,
//                             ),
//                             SizedBox(height: 16.0),
//                             _canResendOtp
//                                 ? TextButtonLoading(
//                                     text: 'Kirim Ulang OTP',
//                                     onTap: _resendOtp,
//                                     isLoading: _isLoadingResend,
//                                     disabled: _isLoading,
//                                   )
//                                 : Column(
//                                     children: [
//                                       SizedBox(height: 16.0),
//                                       Align(
//                                         alignment: Alignment.center,
//                                         child: Text(
//                                           'Kirim ulang OTP dalam $_resendCounter detik',
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// class OtpCodeScreenArgs {
//   final String phone;

//   OtpCodeScreenArgs({
//     required this.phone,
//   });
// }

// /// OTP Code Screen
// ///
// /// In this screen, user inputs the code that they received from OTP SMS.
// ///
// class OtpCodeScreen extends StatefulWidget {
//   static const String ROUTE_NAME = '/otp/code';
//   final String phone;

//   const OtpCodeScreen({
//     Key? key,
//     required this.phone,
//   }) : super(key: key);

//   @override
//   _OtpCodeScreenState createState() => _OtpCodeScreenState();
// }

// class _OtpCodeScreenState extends State<OtpCodeScreen> {
//   /// How long until user can request resend OTP in seconds
//   static const int RESEND_COUNTDOWN_SECOND = 60;

//   /// Whether resend OTP is loading or not
//   bool _isLoadingResend = false;

//   /// Whether verify OTP code is loading or not
//   bool _isLoadingVerify = false;

//   /// Whether user can request resed OTP or not
//   bool _canResendOtp = false;

//   /// Resend OTP timer
//   Timer? _resendTimer;

//   /// Resend OTP counter
//   late int _resendCounter;

//   /// Input OTP code controller
//   late OTPTextEditController _inputOtpController;

//   @override
//   void initState() {
//     super.initState();

//     _initOtpAutofill();
//     _startResendTimer();
//   }

//   @override
//   void dispose() {
//     // Somehow the controller throw error when you try to dispose it
//     // _inputOtpController.dispose();
//     _resendTimer?.cancel();
//     super.dispose();
//   }

//   /// Initialize OTP autofill
//   void _initOtpAutofill() {
//     final otpInteractor = OTPInteractor();
//     otpInteractor.getAppSignature().then((value) {
//       print('signature - $value');
//     });
//     _inputOtpController = OTPTextEditController(
//       codeLength: 5,
//       onCodeReceive: (code) {
//         // print('onCodeReceive: $code');
//         // _verify();
//       },
//     )..startListenUserConsent(
//         (code) {
//           final exp = RegExp(r'(\d{5})');
//           return exp.stringMatch(code ?? '') ?? '';
//         },
//         strategies: [
//           // SampleStrategy(),
//         ],
//       );
//   }

//   /// Start resend OTP timer
//   void _startResendTimer() {
//     setState(() {
//       _resendCounter = RESEND_COUNTDOWN_SECOND;
//       _canResendOtp = false;
//     });
//     _resendTimer = new Timer.periodic(
//       Duration(seconds: 1),
//       (Timer timer) {
//         if (mounted) {
//           if (_resendCounter == 0) {
//             setState(() {
//               timer.cancel();
//               _canResendOtp = true;
//             });
//           } else {
//             setState(() {
//               _resendCounter--;
//             });
//           }
//         }
//       },
//     );
//   }

//   /// Verify user OTP code
//   _verify() {
//     if (!_validateInputCode(_inputOtpController.text)) {
//       return;
//     }
//     setState(() {
//       _isLoadingVerify = true;
//     });
//     UserRepository()
//         .verifyOtp(widget.phone, _inputOtpController.text)
//         .then((result) async {
//       setState(() {
//         _isLoadingVerify = false;
//       });
//       if (result.isSuccess && result.data != null) {
//         // Save token
//         await SharedPreferencesUtil()
//             .sharedPreferences
//             .setString(SharedPreferencesUtil.SP_KEY_TOKEN, result.data!);
//         _resendTimer?.cancel();
//         Navigator.of(context).pushNamedAndRemoveUntil(
//           PrepareRegisterScreen.ROUTE_NAME,
//           (route) => false,
//         );
//       } else {
//         // WidgetUtil.showSnackbar(
//         //   context,
//         //   result.error ?? 'Gagal memverifikasi OTP',
//         // );
//         showDialog(
//             context: context,
//             builder: (_) => AlertDialog(
//                   content: Text(result.error ?? 'Gagal memverifikasi OTP',
//                       style: TextStyle(color: Colors.white)),
//                   backgroundColor: Colors.red,
//                   elevation: 24.0,
//                 ));
//       }
//     });
//   }

//   /// Validate user OTP code. Returns true if code is valid.
//   bool _validateInputCode(String? inputPhone) {
//     if (inputPhone == null) {
//       return false;
//     }
//     if (inputPhone.isNotEmpty && inputPhone.trim().length == 5) {
//       return true;
//     }
//     return false;
//   }

//   /// Resend OTP code
//   _resendOtp() {
//     setState(() {
//       _isLoadingResend = true;
//     });
//     UserRepository().sendOtp(widget.phone).then((result) {
//       setState(() {
//         _isLoadingResend = false;
//       });
//       if (result.isSuccess) {
//         showDialog(
//             context: context,
//             builder: (_) => AlertDialog(
//                   content: Text('OTP sudah berhasil dikirim ulang!',
//                       style: TextStyle(color: Colors.white)),
//                   backgroundColor: Colors.green,
//                   elevation: 24.0,
//                 ));
//         // WidgetUtil.showSnackbar(
//         //   context,
//         //   'OTP sudah berhasil dikirim ulang!',
//         // );
//         _startResendTimer();
//       } else {
//         showDialog(
//             context: context,
//             builder: (_) => AlertDialog(
//                   content: Text(result.error ?? 'Gagal mengirim ulang OTP',
//                       style: TextStyle(color: Colors.white)),
//                   backgroundColor: Colors.red,
//                   elevation: 24.0,
//                 ));
//         // WidgetUtil.showSnackbar(
//         //   context,
//         //   result.error ?? 'Gagal mengirim ulang OTP',
//         // );
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     ThemeData theme = Theme.of(context);
//     bool _isLoading = _isLoadingVerify || _isLoadingResend;

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
//                   child: Image.asset('assets/otp_screen/mail.png'),
//                 ),
//                 SizedBox(height: 24.0),
//                 Text(
//                   'Verifikasi',
//                   textAlign: TextAlign.center,
//                   style: theme.textTheme.headline6?.copyWith(
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 SizedBox(height: 8.0),
//                 Text(
//                   'Masukkan kode OTP yang telah dikirimkan ke nomor Anda',
//                   textAlign: TextAlign.center,
//                   style: theme.textTheme.bodyText2,
//                 ),
//                 SizedBox(height: 24.0),
//                 PinCodeTextField(
//                   enabled: !_isLoading,
//                   length: 5,
//                   animationType: AnimationType.fade,
//                   keyboardType: TextInputType.number,
//                   cursorColor: theme.primaryColor,
//                   pinTheme: PinTheme(
//                     shape: PinCodeFieldShape.box,
//                     borderRadius: BorderRadius.circular(5),
//                     fieldHeight: 50,
//                     fieldWidth: 50,
//                     selectedColor: theme.primaryColor.withOpacity(0.6),
//                     selectedFillColor: theme.primaryColor.withOpacity(0.6),
//                     inactiveColor: Colors.grey[300],
//                     inactiveFillColor: Colors.grey[300],
//                     activeFillColor: theme.primaryColor.withOpacity(0.4),
//                     activeColor: theme.primaryColor.withOpacity(0.4),
//                   ),
//                   animationDuration: Duration(milliseconds: 300),
//                   enableActiveFill: true,
//                   controller: _inputOtpController,
//                   appContext: context,
//                   onChanged: (value) {},
//                 ),
//                 SizedBox(height: 16.0),
//                 ElevatedButtonLoading(
//                   text: 'Verifikasi',
//                   onTap: _verify,
//                   isLoading: _isLoadingVerify,
//                   disabled: _isLoading,
//                 ),
//                 SizedBox(height: 16.0),
//                 _canResendOtp
//                     ? TextButtonLoading(
//                         text: 'Kirim Ulang OTP',
//                         onTap: _resendOtp,
//                         isLoading: _isLoadingResend,
//                         disabled: _isLoading,
//                       )
//                     : Column(
//                         children: [
//                           SizedBox(height: 16.0),
//                           Align(
//                             alignment: Alignment.center,
//                             child: Text(
//                               'Kirim ulang OTP dalam $_resendCounter detik',
//                             ),
//                           ),
//                         ],
//                       ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
