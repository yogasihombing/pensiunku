import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pensiunku/model/user_model.dart';
import 'package:pensiunku/model/result_model.dart';
import 'package:pensiunku/repository/user_repository.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/konfirmasi_pin_screen.dart';
import 'package:http/http.dart' as http;
import 'package:pensiunku/util/shared_preferences_util.dart';

class DaftarkanPinPensiunkuPlusScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/DaftarkanPinPensiunkuPlusScreen';

  const DaftarkanPinPensiunkuPlusScreen({Key? key}) : super(key: key);

  @override
  State<DaftarkanPinPensiunkuPlusScreen> createState() =>
      _DaftarkanPinPensiunkuPlusScreenState();
}

class _DaftarkanPinPensiunkuPlusScreenState
    extends State<DaftarkanPinPensiunkuPlusScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> pinControllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> pinFocusNodes = List.generate(6, (_) => FocusNode());
  // Variabel untuk mengontrol tampilan loading overlay
  bool _isLoadingOverlay = false;
  String? _pinErrorMessage;

  UserModel? _userModel;
  late Future<ResultModel<UserModel>> _futureData;

  Future<void> submitPin(String pin) async {
    // Validasi PIN terlebih dahulu
    if (!_validatePin(pin)) {
      return;
    }

    // Set overlay loading tampil
    setState(() {
      _isLoadingOverlay = true;
    });
    try {
      print('=== Memulai proses submit PIN ===');
      bool isSuccess = false; // Menambahkan variabel isSuccess

      // Pastikan _userModel sudah terisi
      if (_userModel == null) {
        print('Error: User model is null');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data user belum tersedia')),
        );
        return;
      }

      print('User ID: ${_userModel?.id}');
      print('PIN yang akan dikirim: $pin');

      var requestBody = {
        'id_user': _userModel?.id,
        'pin': pin,
      };

      print('Request body: ${jsonEncode(requestBody)}');

      var response = await http.post(
        Uri.parse('https://api.pensiunku.id/new.php/BuatPIN'),
        headers: {
          'Content-Type': 'application/json',
          // Tambahkan token jika diperlukan
          'Authorization':
              'Bearer ${SharedPreferencesUtil().sharedPreferences.getString(SharedPreferencesUtil.SP_KEY_TOKEN)}',
        },
        body: jsonEncode(requestBody),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('PIN berhasil didaftarkan');
        isSuccess = true; // Set isSuccess ke true jika berhasil
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PIN berhasil didaftarkan')),
        );
        // Tampilkan dialog kustom
        _showCustomDialog(context, 'PIN berhasil didaftarkan');
        Future.delayed(Duration(seconds: 3), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => KonfirmasiPinPensiunkuPlusScreen(),
            ),
          );
        });
      } else {
        print('Gagal mendaftarkan PIN: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mendaftarkan PIN: ${response.body}')),
        );
      }
    } catch (e, stackTrace) {
      print('=== Error Detail ===');
      print('Error message: $e');
      print('Stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    } finally {
      // Sembunyikan overlay loading
      setState(() {
        _isLoadingOverlay = false;
      });
    }
  }

  bool _validatePin(String pin) {
    setState(() => _pinErrorMessage = null);

    // Validasi panjang PIN
    if (pin.length != 6) {
      setState(() => _pinErrorMessage = 'PIN harus 6 digit');
      return false;
    }

    // Validasi hanya angka
    if (!RegExp(r'^[0-9]+$').hasMatch(pin)) {
      setState(() => _pinErrorMessage = 'PIN hanya boleh berisi angka');
      return false;
    }

    // Validasi PIN tidak boleh semua digit sama
    if (RegExp(r'^(\d)\1+$').hasMatch(pin)) {
      setState(() =>
          _pinErrorMessage = 'PIN tidak boleh sama semua (misalnya 111111)');
      return false;
    }

    // Validasi PIN tidak boleh berurutan menaik
    if (pin == '123456' ||
        pin == '234567' ||
        pin == '345678' ||
        pin == '456789' ||
        pin == '567890') {
      setState(() => _pinErrorMessage =
          'PIN tidak boleh berurutan menaik (misalnya 123456)');
      return false;
    }

    // Validasi PIN tidak boleh berurutan menurun
    if (pin == '987654' ||
        pin == '876543' ||
        pin == '765432' ||
        pin == '654321' ||
        pin == '543210') {
      setState(() => _pinErrorMessage =
          'PIN tidak boleh berurutan menurun (misalnya 987654)');
      return false;
    }

    return true;
  }

  void _showCustomDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: AlertDialog(
            content: Text(
              message,
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.green,
            contentTextStyle: TextStyle(color: Colors.white),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    print('=== Initializing Screen ===');
    _refreshData();
  }

  _refreshData() async {
    print('=== Memulai refresh data ===');
    try {
      String? token = SharedPreferencesUtil()
          .sharedPreferences
          .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

      print('Token: $token');

      if (token == null) {
        print('Error: Token is null');
        return;
      }

      _futureData = UserRepository().getOne(token).then((value) {
        print('Response from UserRepository: $value');

        if (value.error != null) {
          print('Error from UserRepository: ${value.error}');
          showDialog(
              context: context,
              builder: (_) => AlertDialog(
                    content: Text(value.error.toString(),
                        style: TextStyle(color: Colors.white)),
                    backgroundColor: Colors.red,
                    elevation: 24.0,
                  ));
        } else {
          print('User data received successfully');
          print('User ID: ${value.data?.id}');
        }

        setState(() {
          _userModel = value.data;
        });

        return value;
      });
    } catch (e, stackTrace) {
      print('Error in _refreshData: $e');
      print('Stack trace: $stackTrace');
    }
  }

  // void _clearAllFields() {
  //   for (var controller in pinControllers) {
  //     controller.clear();
  //   }
  //   if (pinFocusNodes.isNotEmpty) {
  //     FocusScope.of(context).requestFocus(pinFocusNodes[0]);
  //   }
  //   setState(() => _pinErrorMessage = null);
  // }

  @override
  void dispose() {
    for (var controller in pinControllers) {
      controller.dispose();
    }
    for (var focusNode in pinFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Colors.white,
                  Colors.white,
                  Color.fromARGB(255, 233, 208, 127),
                ],
                stops: [0.25, 0.5, 0.75, 1.0],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenHeight * 0.025,
                      vertical: screenHeight * 0.025),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.black),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: 0.75,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF006C4E)),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Image.asset(
                        'assets/pensiunkuplus/pensiunku.png',
                        height: screenHeight * 0.06,
                      ),
                      SizedBox(height: screenHeight * 0.060),
                      Image.asset(
                        'assets/pensiunkuplus/daftarkan_pin.png',
                        height: screenHeight * 0.30,
                      ),
                      SizedBox(height: screenHeight * 0.050),
                      Text(
                        'Daftarkan PIN',
                        style: TextStyle(
                          fontSize: screenHeight * 0.025,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Daftarkan PIN agar akunmu lebih aman',
                        style: TextStyle(
                          fontSize: screenHeight * 0.015,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.04),
                      // Centered PIN Input Fields with Container
                      Container(
                        width: screenWidth * 0.7,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(6, (index) {
                                  return Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: screenHeight * 0.005,
                                      ),
                                      child: SizedBox(
                                        height: screenHeight * 0.056,
                                        child: TextFormField(
                                          controller: pinControllers[index],
                                          focusNode: pinFocusNodes[index],
                                          textAlign: TextAlign.center,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: BorderSide(
                                                color: _pinErrorMessage != null
                                                    ? Colors.red
                                                    : Colors.grey,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: BorderSide(
                                                color: _pinErrorMessage != null
                                                    ? Colors.red
                                                    : Colors.grey,
                                              ),
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey[200],
                                            counterText: '',
                                          ),
                                          keyboardType: TextInputType.number,
                                          maxLength: 1,
                                          obscureText: true,
                                          obscuringCharacter: '•',
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          onChanged: (value) {
                                            if (value.length == 1 &&
                                                index < 5) {
                                              FocusScope.of(context)
                                                  .requestFocus(
                                                      pinFocusNodes[index + 1]);
                                            } else if (value.isEmpty &&
                                                index > 0) {
                                              FocusScope.of(context)
                                                  .requestFocus(
                                                      pinFocusNodes[index - 1]);
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              if (_pinErrorMessage != null) ...[
                                SizedBox(height: screenHeight * 0.01),
                                Row(
                                  children: [
                                    Icon(Icons.error_outline,
                                        color: Colors.red,
                                        size: screenHeight * 0.02),
                                    SizedBox(width: screenHeight * 0.005),
                                    Expanded(
                                      child: Text(
                                        _pinErrorMessage!,
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: screenHeight * 0.015,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      // // Tombol hapus PIN
                      // TextButton(
                      //   onPressed: _clearAllFields,
                      //   child: Text(
                      //     'Hapus Semua',
                      //     style: TextStyle(
                      //       color: Color(0xFF006C4E),
                      //       fontSize: screenHeight * 0.016,
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(height: screenHeight * 0.01),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFFC950),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.015,
                            horizontal: screenHeight * 0.05,
                          ),
                        ),
                        onPressed: () async {
                          String pin = pinControllers
                              .map((controller) => controller.text)
                              .join();
                          await submitPin(pin);
                        },
                        child: Text(
                          'Verifikasi',
                          style: TextStyle(
                              fontSize: screenHeight * 0.02,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.025),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Tampilkan overlay loading bila _isLoadingOverlay true
          if (_isLoadingOverlay)
            Positioned.fill(
              child: ModalBarrier(
                color: Colors.black.withOpacity(0.5),
                dismissible: false,
              ),
            ),
          if (_isLoadingOverlay)
            Center(
              child: Container(
                padding: EdgeInsets.all(screenHeight * 0.025),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF017964),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      'Mohon tunggu...',
                      style: TextStyle(
                        color: Color(0xFF017964),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
