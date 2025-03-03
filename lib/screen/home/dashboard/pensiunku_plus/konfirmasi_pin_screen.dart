import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pensiunku/model/user_model.dart';
import 'package:pensiunku/repository/result_model.dart';
import 'package:pensiunku/repository/user_repository.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/pensiunkuplus_success_screen.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:http/http.dart' as http;

class KonfirmasiPinPensiunkuPlusScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/UploadFotoWajahScreen';

  const KonfirmasiPinPensiunkuPlusScreen({Key? key}) : super(key: key);

  @override
  State<KonfirmasiPinPensiunkuPlusScreen> createState() =>
      _KonfirmasiPinPensiunkuPlusScreenState();
}

class _KonfirmasiPinPensiunkuPlusScreenState
    extends State<KonfirmasiPinPensiunkuPlusScreen> {
  final List<TextEditingController> pinControllers =
      List.generate(6, (index) => TextEditingController());
  bool _isLoading = false;
  late Future<ResultModel<UserModel>> _futureData;
  UserModel? _userModel;

  @override
  void initState() {
    super.initState();
    print('=== Initializing Konfirmasi PIN Screen ===');
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

  Future<void> verifyPin(String pin) async {
    try {
      setState(() {
        _isLoading = true;
      });

      print('=== Memulai proses verifikasi PIN ===');
      bool isSuccess = false;

      if (_userModel == null) {
        print('Error: User model is null');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data user belum tersedia')),
        );
        return;
      }

      print('User ID: ${_userModel?.id}');
      print('PIN yang akan diverifikasi: $pin');

      var requestBody = {
        'id_user': _userModel?.id,
        'pin': pin,
      };

      print('Request body: ${jsonEncode(requestBody)}');

      var response = await http.post(
        Uri.parse('https://api.pensiunku.id/new.php/KonfirmasiPIN'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer ${SharedPreferencesUtil().sharedPreferences.getString(SharedPreferencesUtil.SP_KEY_TOKEN)}',
        },
        body: jsonEncode(requestBody),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        if (responseBody['text']['message'] == "PIN Anda Belum Sesuai!") {
          print('Gagal memverifikasi PIN: ${responseBody['text']['message']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Gagal memverifikasi PIN: ${responseBody['text']['message']}')),
          );
        } else {
          print('PIN berhasil diverifikasi');
          isSuccess = true;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('PIN berhasil diverifikasi')),
          );

          if (isSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PensiunkuPlusSuccessScreen(),
              ),
            );
          }
        }
      } else {
        print('Gagal memverifikasi PIN: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memverifikasi PIN: ${response.body}')),
        );
      }
    } catch (e, stackTrace) {
      print('=== Error Detail ===');
      print('Pesan kesalahan: $e');
      print('Jejak tumpukan: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                          value: 1,
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
                    'Ulangi PIN',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'Masukkan PIN yang baru kamu daftarkan',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 30),
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
                        await verifyPin(pin);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Harap isi semua field PIN')),
                        );
                      }
                    },
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.black)
                        : Text(
                            'Verifikasi',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
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
