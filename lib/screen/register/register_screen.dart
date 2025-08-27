import 'package:flutter/material.dart';
import 'package:pensiunku/repository/user_repository.dart';
import 'package:pensiunku/screen/register/register_success_screen.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:pensiunku/widget/custom_text_field.dart';
import 'package:pensiunku/widget/elevated_button_loading.dart';

class RegisterScreen extends StatefulWidget {
  // Rute statis sehingga bisa dinavigasi dengan nama '/register'
  static const String ROUTE_NAME = '/register';

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Key untuk menangani validasi form secara manual
  final _formKey = GlobalKey<FormState>();

  // Controller teks untuk dua input
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  // State untuk menyimpan nilai dan tanda "sudah disentuh" (touched)
  String _name = '';
  bool _nameTouched = false;
  String _email = '';
  bool _emailTouched = false;

  // State loading ketika kirim data
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Inisialisasi controller dan listener untuk memperbarui state
    _nameController = TextEditingController()
      ..addListener(() {
        if (!mounted) return;
        setState(() {
          _name = _nameController.text;
          _nameTouched = true; // tandai bahwa user sudah interaksi
        });
      });

    _emailController = TextEditingController()
      ..addListener(() {
        if (!mounted) return;
        setState(() {
          _email = _emailController.text;
          _emailTouched = true;
        });
      });
  }

  @override
  void dispose() {
    // Buang controller saat widget dihancurkan
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Validasi Nama: wajib isi
  String? _validateName() {
    if (!_nameTouched) return null; // belum disentuh → no error
    return _name.isEmpty
        ? 'Nama lengkap wajib diisi' // jika kosong → error
        : null; // valid
  }

  // Validasi E-Mail: wajib isi + format dasar
  String? _validateEmail() {
    if (!_emailTouched) return null;
    if (_email.isEmpty) {
      return 'E-Mail wajib diisi'; // jika kosong → error
    }
    // Regex sederhana: harus ada @ dan . di belakangnya
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(_email)
        ? null // format benar
        : 'Format E-Mail tidak valid'; // format salah
  }

  // Tampilkan dialog error
  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Error', style: TextStyle(color: Colors.red[700])),
        content: Text(message),
        actions: [
          TextButton(
              child: Text('OK'), onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }

  // Tampilkan snackbar sukses
  void _showSuccessMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2)),
    );
  }

  // Proses registrasi asinkron
  Future<void> _registerAsync() async {
    if (!mounted) return;

    // Tampilkan semua error bila belum muncul
    setState(() {
      _nameTouched = true;
      _emailTouched = true;
    });

    // Cek validasi manual
    final nameError = _validateName();
    final emailError = _validateEmail();
    if (nameError != null || emailError != null) {
      // jika ada error, form tidak dikirim
      return;
    }

    try {
      setState(() => _isLoading = true);

      // Ambil token dari SharedPreferences
      final token = SharedPreferencesUtil()
          .sharedPreferences
          .getString(SharedPreferencesUtil.SP_KEY_TOKEN);
      if (token == null)
        throw Exception('Token tidak ditemukan. Silakan login kembali.');

      // Siapkan payload
      final data = {
        'username': _name,
        'email': _email,
      };

      // Kirim ke backend
      final result = await UserRepository().updateOne(token, data);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result.isSuccess) {
        _showSuccessMessage('Data berhasil disimpan');
        // Delay navigasi agar snackbar terlihat
        Future.delayed(Duration(milliseconds: 1500), () {
          if (!mounted) return;
          Navigator.of(context)
              .pushReplacementNamed(RegisterSuccessScreen.ROUTE_NAME);
        });
      } else {
        _showErrorDialog(result.error ?? 'Gagal menyimpan data user');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showErrorDialog('Terjadi kesalahan: ${e.toString()}');
    }
  }

  // Pemicu register (wrapper)
  void _register() => _registerAsync();

  @override
  Widget build(BuildContext context) {
    // Hitung error saat build (digunakan untuk properti errorText)
    final nameError = _validateName();
    final emailError = _validateEmail();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Gradient latar belakang
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.white,
              Colors.white,
              Color.fromARGB(255, 170, 231, 170)
            ],
            stops: [0.0, 0.25, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Form(
                key:
                    _formKey, // masih tersedia jika mau pakai validator FormField
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo
                    Image.asset('assets/register_screen/pensiunku.png',
                        height: 45),
                    SizedBox(height: 60),
                    // Judul
                    Text('Masukkan E-Mail anda',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('(Untuk Pemulihan Akun)',
                        style: TextStyle(fontSize: 15, color: Colors.black26)),
                    SizedBox(height: 24),
                    // Input Nama
                    CustomTextField(
                      controller: _nameController,
                      hintText: 'Nama Lengkap',
                      enabled: !_isLoading,
                      labelText: '',
                      errorText: nameError, // tampilkan error jika ada
                      fillColor: Colors.white,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      borderRadius: 12,
                    ),
                    SizedBox(height: 16),
                    // Input Email
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'E-Mail',
                      keyboardType: TextInputType.emailAddress,
                      labelText: '',
                      enabled: !_isLoading,
                      errorText: emailError,
                      fillColor: Colors.white,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      borderRadius: 12,
                    ),
                    SizedBox(height: 32),
                    // Tombol Daftar
                    ElevatedButtonLoading(
                      text: 'Daftar',
                      onTap: _isLoading
                          ? () {}
                          : () {
                              if (!mounted)
                                return; // Hindari akses ke context yang tidak valid
                              _register();
                            },
                      isLoading: _isLoading,
                      disabled: _isLoading,
                      textStyle: const TextStyle(
                        color: Colors.black, // Warna teks hitam
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    )
                  ],
                ),
              ),
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
//         Navigator.of(context)
//             .pushReplacementNamed(RegisterSuccessScreen.ROUTE_NAME);
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
//     String? inputEmailError =
//         _controller.getInputEmailError(_inputEmail, _inputEmailTouched);

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
//                   errorText: inputEmailError,
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


