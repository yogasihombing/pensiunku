import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pensiunku/repository/user_repository.dart';
import 'package:pensiunku/screen/home/home_screen.dart';
import 'package:pensiunku/screen/register/register_controller.dart';
import 'package:pensiunku/screen/register/register_success_screen.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:pensiunku/widget/custom_text_field.dart';
import 'package:pensiunku/widget/elevated_button_loading.dart';

class RegisterScreen extends StatefulWidget {
  static const String ROUTE_NAME =
      '/register'; // Mendefenisikan rute statis untuk navigasi ke halaman ini.

  @override
  _RegisterScreenState createState() =>
      _RegisterScreenState(); // Menghubungkan widget dengan state-nya.
}

class _RegisterScreenState extends State<RegisterScreen> {
  // AccountModel _accountModel = AccountModel();
  RegisterController _controller =
      RegisterController(); // Membuat instance dari RegisterController untuk validasi.
  bool _isLoading =
      false; // state untuk mengontrol apakah proses sedang berlangsung.

// Variabel dan controller untuk input nama.
  String _inputName = '';
  bool _inputNameTouched = false;
  late TextEditingController _inputNameController;

  // Variabel dan controller untuk input Email
  String _inputEmail = '';
  bool _inputEmailTouched = false;
  late TextEditingController _inputEmailController;

// Variabel untuk menyimpan input kode referal (jika ada).
  // String _inputReferral = '';
  // // late TextEditingController _inputReferralController;

  @override
  void initState() {
    super
        .initState(); // Fungsi yang dijalankan pertama kali saat widget dibuat.

    // Menginisialisasi controller nama dengan listener untuk mengupdate state.
    _inputNameController = TextEditingController()
      ..addListener(() {
        setState(() {
          _inputName = _inputNameController.text;
          _inputNameTouched = true;
        });
      });

    //Menginisialisasi controller Email listener untuk mengupdate state.
    _inputEmailController = TextEditingController()
      ..addListener(() {
        setState(() {
          _inputEmail = _inputEmailController.text;
          _inputEmailTouched = true;
        });
      });
  }

  // Membersihkan controller dari memori saat widget dihancurkan.
  @override
  void dispose() {
    _inputNameController.dispose();
    _inputEmailController.dispose();
    // _inputReferralController.dispose();
    super.dispose();
  }

  /// Register user
  ///  Menandai bahwa input sudah pernah disentuh untuk validasi.
  _register() {
    setState(() {
      _inputNameTouched = true;
      _inputEmailTouched = true;
    });
    if (_controller.getInputNameError(_inputName, _inputNameTouched) != null) {
      return; // Jika validasi gagal. hentikan Proses.
    }
    // Email tetap Optional.
    if (_controller.getInputEmailError(_inputEmail, _inputEmailTouched) !=
        null) {
      print(
          '- Email tidak valid: ${_controller.getInputEmailError(_inputEmail, _inputEmailTouched)}');
    }
    // Proses dilanjutkan jika validasi nama lolos.
    setState(() {
      _isLoading = true;
    });
    // Mengambil token pengguna dari SharedPreferences.
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    // Membuat data pengguna dari input yang diterima.
    var data = {
      'username': _inputName,
      'email': _inputEmail.isNotEmpty ? _inputEmail : null,
    };

    UserRepository().updateOne(token!, data).then((result) {
      setState(() {
        _isLoading =
            false; // Menghentikan indikator pemuatan setelah proses selesai.
      });
      if (result.isSuccess) {
        print('Data Berhasil disimpan: $data');
        Navigator.of(context).pushReplacementNamed(RegisterSuccessScreen.ROUTE_NAME);
      } else {
        print('Error berhasil disimpan: $data');
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  content: Text(result.error ?? 'Gagal menyimpan data user',
                      style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.red,
                  elevation: 24.0,
                ));
      }
    }).catchError((e) {
      setState(() {
        _isLoading = false;
      });
    });
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              content: Text('Terjadi kesalahan: $e',
                  style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.red,
              elevation: 24.0,
            ));
    // Mengirim data ke backend, lalu menampilkan hasil sukses atau gagal.
  }

  @override
  Widget build(BuildContext context) {
    // Memvalidasi error pada input nama
    String? inputNameError =
        _controller.getInputNameError(_inputName, _inputNameTouched);

    return Scaffold(
      body: Container(
        // Memastikan latar belakang gradien memenuhi layar penuh
        width: double.infinity,
        height: double.infinity,
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
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Gambar Header
                Image.asset(
                  'assets/register_screen/pensiunku.png',
                  height: 45,
                ),
                SizedBox(height: 60.0),

                // Teks judul
                Text(
                  'Masukkan E-Mail anda',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
               
                Text(
                  '(Untuk Pemulihan Akun)',
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.normal,
                    color: Colors.black26,
                  ),
                ),
                SizedBox(height: 24.0),

                // Input Nama Lengkap
                CustomTextField(
                  controller: _inputNameController,
                  labelText: '',
                  keyboardType: TextInputType.name,
                  enabled: !_isLoading,
                  errorText: inputNameError,
                  borderRadius: 12.0,
                  hintText: 'Nama Lengkap',
                  useLabel: false,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 20.0,
                  ),
                ),
                SizedBox(height: 16.0),

                // Input Email
                CustomTextField(
                  controller: _inputEmailController,
                  labelText: '',
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isLoading,
                  borderRadius: 12.0,
                  hintText: 'E-Mail',
                  useLabel: false,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 20.0,
                  ),
                ),
                SizedBox(height: 32.0),

                // Tombol Daftar
                ElevatedButtonLoading(
                  text: 'DAFTAR',
                  onTap: _register,
                  isLoading: _isLoading,
                  disabled: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:pensiunku/repository/user_repository.dart';
// import 'package:pensiunku/screen/home/home_screen.dart';
// import 'package:pensiunku/screen/register/register_controller.dart';
// import 'package:pensiunku/util/shared_preferences_util.dart';
// import 'package:pensiunku/widget/custom_text_field.dart';
// import 'package:pensiunku/widget/elevated_button_loading.dart';

// class RegisterScreen extends StatefulWidget {
//   static const String ROUTE_NAME =
//       '/register'; // Mendefenisikan rute statis untuk navigasi ke halaman ini.

//   @override
//   _RegisterScreenState createState() =>
//       _RegisterScreenState(); // Menghubungkan widget dengan state-nya.
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   // AccountModel _accountModel = AccountModel();
//   RegisterController _controller =
//       RegisterController(); // Membuat instance dari RegisterController untuk validasi.
//   bool _isLoading =
//       false; // state untuk mengontrol apakah proses sedang berlangsung.

// // Variabel dan controller untuk input nama.
//   String _inputName = '';
//   bool _inputNameTouched = false;
//   late TextEditingController _inputNameController;

// // Variabel dan controller untuk input nomor telepon
//   String _inputPhone = '';
//   bool _inputPhoneTouched = false;
//   late TextEditingController _inputPhoneController;

//   // Variabel dan controller untuk input Kota Domisili
//   String _inputCity = '';
//   bool _inputCityTouched = false;
//   late TextEditingController _inputCityController;

//   // Variabel dan controller untuk input Email
//   String _inputEmail = '';
//   bool _inputEmailTouched = false;
//   late TextEditingController _inputEmailController;

// // Variabel untuk menyimpan input kode referal (jika ada).
//   String _inputReferral = '';
//   // late TextEditingController _inputReferralController;

//   @override
//   void initState() {
//     super
//         .initState(); // Fungsi yang dijalankan pertama kali saat widget dibuat.

//     // Menginisialisasi controller nama dengan listener untuk mengupdate state.
//     _inputNameController = TextEditingController()
//       ..addListener(() {
//         setState(() {
//           _inputName = _inputNameController.text;
//           _inputNameTouched = true;
//         });
//       });

//     // Menginisialisasi controller telepon dengan listener untuk mengupdate state.
//     _inputPhoneController = TextEditingController()
//       ..addListener(() {
//         setState(() {
//           _inputPhone = _inputPhoneController.text;
//           _inputPhoneTouched = true;
//         });
//       });

//     // Menginisialisasi controller Kota Domisili listener untuk mengupdate state.
//     _inputCityController = TextEditingController()
//       ..addListener(() {
//         setState(() {
//           _inputCity = _inputCityController.text;
//           _inputCityTouched = true;
//         });
//       });

//     // Menginisialisasi controller Email listener untuk mengupdate state.
//     _inputEmailController = TextEditingController()
//       ..addListener(() {
//         setState(() {
//           _inputEmail = _inputEmailController.text;
//           _inputEmailTouched = true;
//         });
//       });
//   }

//   // Membersihkan controller dari memori saat widget dihancurkan.
//   @override
//   void dispose() {
//     _inputNameController.dispose();
//     _inputPhoneController.dispose();
//     _inputCityController.dispose();
//     _inputEmailController.dispose();
//     // _inputReferralController.dispose();
//     super.dispose();
//   }

//   /// Register user
//   ///  Menandai bahwa input sudah pernah disentuh untuk validasi.
//   _register() {
//     setState(() {
//       _inputNameTouched = true;
//       _inputPhoneTouched = true;
//       _inputCityTouched = true;
//       _inputEmailTouched = true;
//     });
//     if (_controller.isAllInputValid(
//       _inputName,
//       _inputNameTouched,
//       _inputPhone,
//       _inputPhoneTouched,
//       _inputCity,
//       _inputCityTouched,
//       _inputEmail,
//       _inputEmailTouched,
//     )) {
//       print('Validasi gagal:');
//       print(
//           '- Nama Lengkap: ${_controller.getInputNameError(_inputName, _inputNameTouched)}');
//       print(
//           '- No Telepon: ${_controller.getInputPhoneError(_inputPhone, _inputPhoneTouched)}');
//       print(
//           '- Kota Domisili: ${_controller.getInputCityError(_inputCity, _inputCityTouched)}');
//       print(
//           '- Email: ${_controller.getInputEmailError(_inputEmail, _inputEmailTouched)}');
//       return; // Jika input valid, lanjut ke proses berikutnya.
//     }
//     // Menandai bahwa proses sedang berlangsung.
//     setState(() {
//       _isLoading = true;
//     });
//     // Mengambil token pengguna dari SharedPreferences.
//     String? token = SharedPreferencesUtil()
//         .sharedPreferences
//         .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

//     // Membuat data pengguna dari input yang diterima.
//     var data = {
//       'username': _inputName,
//       'phone': _inputPhone,
//       'city': _inputCity,
//       'email': _inputEmail,
//     };

//     // Menambahkan kode referal ke data jika tidak kosong.
//     if (_inputReferral.trim().isNotEmpty) {
//       data['referal'] = _inputReferral;
//     }

//     UserRepository().updateOne(token!, data).then((result) {
//       setState(() {
//         _isLoading =
//             false; // Menghentikan indikator pemuatan setelah proses selesai.
//       });
//       if (result.isSuccess) {
//         print('Data Berhasil disimpan: $data');
//         Navigator.of(context).pushReplacementNamed(HomeScreen.ROUTE_NAME);
//       } else {
//         print('Error berhasil disimpan: $data');
//         showDialog(
//             context: context,
//             builder: (_) => AlertDialog(
//                   content: Text(result.error ?? 'Gagal menyimpan data user',
//                       style: TextStyle(color: Colors.white)),
//                   backgroundColor: Colors.red,
//                   elevation: 24.0,
//                 ));
//       }
//     });
//     showDialog(
//         context: context,
//         builder: (_) => AlertDialog(
//               content: Text('Terjadi kesalahan: $e',
//                   style: TextStyle(color: Colors.white)),
//               backgroundColor: Colors.red,
//               elevation: 24.0,
//             ));
//     // Mengirim data ke backend, lalu menampilkan hasil sukses atau gagal.
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Memvalidasi error pada input nama dan telepon
//     String? inputNameError =
//         _controller.getInputNameError(_inputName, _inputNameTouched);
//     String? inputPhoneError =
//         _controller.getInputPhoneError(_inputPhone, _inputPhoneTouched);
//     String? inputCityError =
//         _controller.getInputCityError(_inputCity, _inputCityTouched);
//     String? inputEmailError =
//         _controller.getInputEmailError(_inputEmail, _inputEmailTouched);
//     return Scaffold(
//       // Warna latar belakang halaman.
//       backgroundColor: Color(0xfff6f6f6),
//       body: SingleChildScrollView(
//         child: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 SizedBox(height: 24.0),
//                 SizedBox(
//                   height: 180,
//                   child: Image.asset('assets/register_screen/image_1.png'),
//                   // Menampilkan Gambar Header
//                 ),
//                 SizedBox(height: 24.0),
//                 // Input untuk nama Lengkap
//                 CustomTextField(
//                   controller: _inputNameController,
//                   labelText: '',
//                   keyboardType: TextInputType.name,
//                   enabled: !_isLoading,
//                   errorText: inputNameError,
//                   borderRadius: 36.0,
//                   hintText: 'Nama Lengkap',
//                   useLabel: false,
//                   fillColor: Colors.white,
//                   contentPadding: EdgeInsets.symmetric(
//                     horizontal: 24.0,
//                     vertical: 20.0,
//                   ),
//                 ),
//                 SizedBox(height: 10.0),
//                 // Input untuk Nomor telepon
//                 CustomTextField(
//                   controller: _inputPhoneController,
//                   labelText: '',
//                   keyboardType: TextInputType.phone,
//                   enabled: !_isLoading,
//                   errorText: inputPhoneError,
//                   borderRadius: 36.0,
//                   hintText: 'No Telepon',
//                   useLabel: false,
//                   fillColor: Colors.white,
//                   contentPadding: EdgeInsets.symmetric(
//                     horizontal: 24.0,
//                     vertical: 20.0,
//                   ),
//                 ),
//                 SizedBox(height: 10.0),
//                 // Input untuk Kota domisili
//                 CustomTextField(
//                   controller: _inputCityController,
//                   labelText: '',
//                   keyboardType: TextInputType.text,
//                   enabled: !_isLoading,
//                   errorText: inputCityError,
//                   borderRadius: 36.0,
//                   hintText: 'Kota Domisili',
//                   useLabel: false,
//                   fillColor: Colors.white,
//                   contentPadding: EdgeInsets.symmetric(
//                     horizontal: 24.0,
//                     vertical: 20.0,
//                   ),
//                 ),
//                 SizedBox(height: 10.0),
//                 // Input untuk email
//                 CustomTextField(
//                   controller: _inputEmailController,
//                   labelText: '',
//                   keyboardType: TextInputType.text,
//                   enabled: !_isLoading,
//                   errorText: inputEmailError,
//                   borderRadius: 36.0,
//                   hintText: 'Email',
//                   useLabel: false,
//                   fillColor: Colors.white,
//                   contentPadding: EdgeInsets.symmetric(
//                     horizontal: 24.0,
//                     vertical: 20.0,
//                   ),
//                 ),
//                 SizedBox(height: 24.0),
//                 // Tombol untuk memulai proses pendaftaran
//                 ElevatedButtonLoading(
//                   text: 'Daftar',
//                   onTap: _register,
//                   isLoading: _isLoading,
//                   disabled: _isLoading,
//                 ),
//                 SizedBox(height: 16.0),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:pensiunku/repository/user_repository.dart';
// import 'package:pensiunku/screen/home/home_screen.dart';
// import 'package:pensiunku/screen/register/register_controller.dart';
// import 'package:pensiunku/util/shared_preferences_util.dart';
// import 'package:pensiunku/widget/custom_text_field.dart';
// import 'package:pensiunku/widget/elevated_button_loading.dart';

// class RegisterScreen extends StatefulWidget {
//   static const String ROUTE_NAME = '/register';

//   @override
//   _RegisterScreenState createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   // AccountModel _accountModel = AccountModel();
//   RegisterController _controller = RegisterController();
//   bool _isLoading = false;

//   String _inputName = '';
//   bool _inputNameTouched = false;
//   late TextEditingController _inputNameController;

//   String _inputPhone = '';
//   bool _inputPhoneTouched = false;
//   late TextEditingController _inputPhoneController;

//   // String _inputEmail = '';
//   // bool _inputEmailTouched = false;
//   // late TextEditingController _inputEmailController;

//   // String _inputBirthDate = '';
//   // bool _inputBirthDateTouched = false;

//   // String _inputJob = '';
//   // bool _inputJobTouched = false;

//   String _inputReferral = '';
//   // late TextEditingController _inputReferralController;

//   @override
//   void initState() {
//     super.initState();

//     _inputNameController = TextEditingController()
//       ..addListener(() {
//         setState(() {
//           _inputName = _inputNameController.text;
//           _inputNameTouched = true;
//         });
//       });

//     _inputPhoneController = TextEditingController()
//       ..addListener(() {
//         setState(() {
//           _inputPhone = _inputPhoneController.text;
//           _inputPhoneTouched = true;
//         });
//       });
//     // _inputEmailController = TextEditingController()
//     //   ..addListener(() {
//     //     setState(() {
//     //       _inputEmail = _inputEmailController.text;
//     //       _inputEmailTouched = true;
//     //     });
//     //   });
//     // _inputReferralController = TextEditingController()
//     //   ..addListener(() {
//     //     setState(() {
//     //       _inputReferral = _inputReferralController.text;
//     //     });
//     //   });
//   }

//   @override
//   void dispose() {
//     _inputNameController.dispose();
//     _inputPhoneController.dispose();
//     // _inputEmailController.dispose();
//     // _inputReferralController.dispose();
//     super.dispose();
//   }

//   /// Register user
//   _register() {
//     setState(() {
//       _inputNameTouched = true;
//       _inputPhoneTouched = true;
//       // _inputEmailTouched = true;
//       // _inputBirthDateTouched = true;
//       // _inputJobTouched = true;
//     });
//     if (_controller.isAllInputValid(
//       _inputName,
//       _inputNameTouched,
//       _inputPhone,
//       _inputPhoneTouched,
//       // _inputEmail,
//       // _inputEmailTouched,
//       // _inputBirthDate,
//       // _inputBirthDateTouched,
//       // _inputJob,
//       // _inputJobTouched,
//     )) {
//       return;
//     }
//     setState(() {
//       _isLoading = true;
//     });
//     String? token = SharedPreferencesUtil()
//         .sharedPreferences
//         .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

//     var data = {
//       'username': _inputName,
//       'phone': _inputPhone,
//       // 'email': _inputEmail,
//       // 'tanggal_lahir': _inputBirthDate,
//       // 'pekerjaan': _inputJob,
//     };
//     if (_inputReferral.trim().isNotEmpty) {
//       data['referal'] = _inputReferral;
//     }

//     UserRepository().updateOne(token!, data).then((result) {
//       setState(() {
//         _isLoading = false;
//       });
//       if (result.isSuccess) {
//         Navigator.of(context).pushReplacementNamed(HomeScreen.ROUTE_NAME);
//       } else {
//         showDialog(
//             context: context,
//             builder: (_) => AlertDialog(
//                   content: Text(result.error ?? 'Gagal menyimpan data user',
//                       style: TextStyle(color: Colors.white)),
//                   backgroundColor: Colors.red,
//                   elevation: 24.0,
//                 ));
//         // WidgetUtil.showSnackbar(
//         //   context,
//         //   result.error ?? 'Gagal menyimpan data user',
//         // );
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     String? inputNameError =
//         _controller.getInputNameError(_inputName, _inputNameTouched);
//     String? inputPhoneError =
//         _controller.getInputPhoneError(_inputPhone, _inputPhoneTouched);
//     // String? inputEmailError =
//     //     _controller.getInputEmailError(_inputEmail, _inputEmailTouched);
//     // String? inputBirthDateError = _controller.getInputBirthDateError(
//     //     _inputBirthDate, _inputBirthDateTouched);
//     // String? inputJobError =
//     //     _controller.getInputJobError(_inputJob, _inputJobTouched);

//     return Scaffold(
//       backgroundColor: Color(0xfff6f6f6),
//       body: SingleChildScrollView(
//         child: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 SizedBox(height: 24.0),
//                 SizedBox(
//                   height: 180,
//                   child: Image.asset('assets/register_screen/image_1.png'),
//                 ),
//                 SizedBox(height: 24.0),
//                 CustomTextField(
//                   controller: _inputNameController,
//                   labelText: '',
//                   keyboardType: TextInputType.name,
//                   enabled: !_isLoading,
//                   errorText: inputNameError,
//                   borderRadius: 36.0,
//                   hintText: 'Nama Lengkap',
//                   useLabel: false,
//                   fillColor: Colors.white,
//                   contentPadding: EdgeInsets.symmetric(
//                     horizontal: 24.0,
//                     vertical: 20.0,
//                   ),
//                 ),

//                 //dev by yoga
//                 // SizedBox(height: 24.0),
//                 // CustomTextField(
//                 //   controller: _inputPhoneController,
//                 //   labelText: '',
//                 //   keyboardType: TextInputType.number,
//                 //   enabled: !_isLoading,
//                 //   errorText: inputPhoneError,
//                 //   borderRadius: 36.0,
//                 //   hintText: 'Phone',
//                 //   useLabel: false,
//                 //   fillColor: Colors.white,
//                 //   contentPadding: EdgeInsets.symmetric(
//                 //     horizontal: 24.0,
//                 //     vertical: 20.0,
//                 //   ),
//                 // ),
//                 // SizedBox(height: 24.0),
//                 // CustomTextField(
//                 //   controller: _inputEmailController,
//                 //   labelText: '',
//                 //   keyboardType: TextInputType.emailAddress,
//                 //   enabled: !_isLoading,
//                 //   errorText: inputEmailError,
//                 //   borderRadius: 36.0,
//                 //   hintText: 'Email',
//                 //   useLabel: false,
//                 //   fillColor: Colors.white,
//                 //   contentPadding: EdgeInsets.symmetric(
//                 //     horizontal: 24.0,
//                 //     vertical: 20.0,
//                 //   ),
//                 // ),
//                 // // SizedBox(height: 12.0),
//                 // // CustomTextField(
//                 // //   labelText: 'Alamat',
//                 // //   keyboardType: TextInputType.multiline,
//                 // //   enabled: !_isLoading,
//                 // //   minLines: 2,
//                 // //   maxLines: 5,
//                 // // ),
//                 // SizedBox(height: 12.0),
//                 // CustomDateField(
//                 //   labelText: 'Tanggal Lahir',
//                 //   currentValue: _accountModel.birthDate,
//                 //   enabled: !_isLoading,
//                 //   onChanged: (DateTime? newBirthDate) {
//                 //     setState(() {
//                 //       _inputBirthDate =
//                 //           DateFormat('yyyy-MM-dd').format(newBirthDate!);
//                 //       _accountModel.birthDate = newBirthDate;
//                 //     });
//                 //   },
//                 //   buttonType: 'button_text_field',
//                 //   errorText: inputBirthDateError,
//                 //   hintText: 'Tanggal Lahir',
//                 //   useLabel: false,
//                 //   fillColor: Colors.white,
//                 //   borderRadius: 36.0,
//                 //   lastDate: DateTime.now(),
//                 // ),
//                 // // SizedBox(height: 12.0),
//                 // // CustomSelectField(
//                 // //   labelText: 'Jenis Kelamin',
//                 // //   searchLabelText: 'Pilih Jenis Kelamin',
//                 // //   currentOption: _accountModel.gender,
//                 // //   options: GenderRepository.getGenders(),
//                 // //   enabled: !_isLoading,
//                 // //   onChanged: (OptionModel newGender) {
//                 // //     setState(() {
//                 // //       _accountModel.gender = newGender;
//                 // //     });
//                 // //   },
//                 // //   enableSearch: false,
//                 // //   buttonType: 'grey_select_button',
//                 // // ),
//                 // SizedBox(height: 12.0),
//                 // CustomSelectField(
//                 //   labelText: 'Pekerjaan',
//                 //   searchLabelText: 'Cari Pekerjaan',
//                 //   currentOption: _accountModel.job,
//                 //   options: JobRepository.getJobs(),
//                 //   enabled: !_isLoading,
//                 //   onChanged: (OptionModel newJob) {
//                 //     setState(() {
//                 //       _inputJob = newJob.text;
//                 //       _accountModel.job = newJob;
//                 //     });
//                 //   },
//                 //   buttonType: 'button_text_field',
//                 //   errorText: inputJobError,
//                 //   hintText: 'Pekerjaan',
//                 //   useLabel: false,
//                 //   fillColor: Colors.white,
//                 //   borderRadius: 36.0,
//                 // ),
//                 // SizedBox(height: 24.0),
//                 // CustomTextField(
//                 //   controller: _inputReferralController,
//                 //   labelText: '',
//                 //   keyboardType: TextInputType.name,
//                 //   enabled: !_isLoading,
//                 //   borderRadius: 36.0,
//                 //   hintText: 'Referal',
//                 //   useLabel: false,
//                 //   fillColor: Colors.white,
//                 //   contentPadding: EdgeInsets.symmetric(
//                 //     horizontal: 24.0,
//                 //     vertical: 20.0,
//                 //   ),
//                 // ),
//                 SizedBox(height: 24.0),

//                 ElevatedButtonLoading(
//                   text: 'Daftar',
//                   onTap: _register,
//                   isLoading: _isLoading,
//                   disabled: _isLoading,
//                 ),
//                 SizedBox(height: 16.0),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
