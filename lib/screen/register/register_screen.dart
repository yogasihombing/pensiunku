import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pensiunku/data/api/user_api.dart';
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
        Navigator.of(context)
            .pushReplacementNamed(RegisterSuccessScreen.ROUTE_NAME);
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
    String? inputEmailError =
        _controller.getInputEmailError(_inputEmail, _inputEmailTouched);

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
                  errorText: inputEmailError,
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

//   // Variabel dan controller untuk input Email
//   String _inputEmail = '';
//   bool _inputEmailTouched = false;
//   late TextEditingController _inputEmailController;

// // Variabel untuk menyimpan input kode referal (jika ada).
//   // String _inputReferral = '';
//   // // late TextEditingController _inputReferralController;

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

//     //Menginisialisasi controller Email listener untuk mengupdate state.
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
//     _inputEmailController.dispose();
//     // _inputReferralController.dispose();
//     super.dispose();
//   }

//   /// Register user
//   ///  Menandai bahwa input sudah pernah disentuh untuk validasi.
//   _register() {
//     setState(() {
//       _inputNameTouched = true;
//       _inputEmailTouched = true;
//     });
//     if (_controller.getInputNameError(_inputName, _inputNameTouched) != null) {
//       return; // Jika validasi gagal. hentikan Proses.
//     }
//     // Email tetap Optional.
//     if (_controller.getInputEmailError(_inputEmail, _inputEmailTouched) !=
//         null) {
//       print(
//           '- Email tidak valid: ${_controller.getInputEmailError(_inputEmail, _inputEmailTouched)}');
//     }
//     // Proses dilanjutkan jika validasi nama lolos.
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
//       'email': _inputEmail.isNotEmpty ? _inputEmail : null,
//     };

//     UserRepository().updateOne(token!, data).then((result) {
//       setState(() {
//         _isLoading =
//             false; // Menghentikan indikator pemuatan setelah proses selesai.
//       });
//       if (result.isSuccess) {
//         print('Data Berhasil disimpan: $data');
//         Navigator.of(context).pushReplacementNamed(RegisterSuccessScreen.ROUTE_NAME);
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
//     }).catchError((e) {
//       setState(() {
//         _isLoading = false;
//       });
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
//     // Memvalidasi error pada input nama
//     String? inputNameError =
//         _controller.getInputNameError(_inputName, _inputNameTouched);

//     return Scaffold(
//       body: Container(
//         // Memastikan latar belakang gradien memenuhi layar penuh
//         width: double.infinity,
//         height: double.infinity,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Colors.white,
//               Colors.white,
//               Color.fromARGB(255, 138, 217, 165),
//             ],
//             stops: [0.0, 0.5, 1.0],
//           ),
//         ),
//         child: Center(
//           child: SingleChildScrollView(
//             padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 // Gambar Header
//                 Image.asset(
//                   'assets/register_screen/pensiunku.png',
//                   height: 45,
//                 ),
//                 SizedBox(height: 60.0),

//                 // Teks judul
//                 Text(
//                   'Masukkan E-Mail anda',
//                   style: TextStyle(
//                     fontSize: 20.0,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                 ),
               
//                 Text(
//                   '(Untuk Pemulihan Akun)',
//                   style: TextStyle(
//                     fontSize: 15.0,
//                     fontWeight: FontWeight.normal,
//                     color: Colors.black26,
//                   ),
//                 ),
//                 SizedBox(height: 24.0),

//                 // Input Nama Lengkap
//                 CustomTextField(
//                   controller: _inputNameController,
//                   labelText: '',
//                   keyboardType: TextInputType.name,
//                   enabled: !_isLoading,
//                   errorText: inputNameError,
//                   borderRadius: 12.0,
//                   hintText: 'Nama Lengkap',
//                   useLabel: false,
//                   fillColor: Colors.white,
//                   contentPadding: EdgeInsets.symmetric(
//                     horizontal: 24.0,
//                     vertical: 20.0,
//                   ),
//                 ),
//                 SizedBox(height: 16.0),

//                 // Input Email
//                 CustomTextField(
//                   controller: _inputEmailController,
//                   labelText: '',
//                   keyboardType: TextInputType.emailAddress,
//                   enabled: !_isLoading,
//                   borderRadius: 12.0,
//                   hintText: 'E-Mail',
//                   useLabel: false,
//                   fillColor: Colors.white,
//                   contentPadding: EdgeInsets.symmetric(
//                     horizontal: 24.0,
//                     vertical: 20.0,
//                   ),
//                 ),
//                 SizedBox(height: 32.0),

//                 // Tombol Daftar
//                 ElevatedButtonLoading(
//                   text: 'DAFTAR',
//                   onTap: _register,
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


