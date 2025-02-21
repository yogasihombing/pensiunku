import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pensiunku/model/user_model.dart';
import 'package:pensiunku/repository/result_model.dart';
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
  final List<TextEditingController> pinControllers =
      List.generate(6, (index) => TextEditingController());
  late Future<ResultModel<UserModel>> _futureData;
  UserModel? _userModel;

  Future<void> submitPin(String pin) async {
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
        // Tambahkan navigasi ke halaman berikutnya jika diperlukan
        // Cek isSuccess sebelum navigasi
        if (isSuccess) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => KonfirmasiPinPensiunkuPlusScreen(),
            ),
          );
        }
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
    }
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

  @override
  void dispose() {
    for (var controller in pinControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
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
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF006C4E)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0),
                  Image.asset(
                    'assets/pensiunkuplus/pensiunku.png',
                    height: 100,
                  ),
                  SizedBox(height: 10),
                  Image.asset(
                    'assets/pensiunkuplus/daftarkan_pin.png',
                    height: 200,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Daftarkan PIN',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'Daftarkan PIN agar akunmu lebih aman',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 30),
                  // Centered PIN Input Fields with Container
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Form(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(6, (index) {
                          return Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: SizedBox(
                                height: 45.0,
                                child: TextFormField(
                                  controller: pinControllers[index],
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
                                  obscureText: true,
                                  obscuringCharacter: '•',
                                  onChanged: (value) {
                                    if (value.length == 1 && index < 5) {
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
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFC950),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 40.0,
                      ),
                    ),
                    onPressed: () async {
                      String pin = pinControllers
                          .map((controller) => controller.text)
                          .join();
                      if (pin.length == 6) {
                        await submitPin(pin);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Harap isi semua field PIN')),
                        );
                      }
                    },
                    child: Text(
                      'Verifikasi',
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
