import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pensiunku/screen/otp/recovery_account_success_screen.dart';

class RecoveryUpdatePhoneScreen extends StatefulWidget {
  final String email; // Email yang diterima dari layar sebelumnya
  final String phone; // Nomor telepon lama yang diterima

  RecoveryUpdatePhoneScreen({required this.email, required this.phone});

  @override
  _RecoveryUpdatePhoneScreenState createState() =>
      _RecoveryUpdatePhoneScreenState();
}

class _RecoveryUpdatePhoneScreenState extends State<RecoveryUpdatePhoneScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitPhone() async {
    final phone = _phoneController.text.trim();

    print("=== START: Submit Phone ===");
    print("Email pengguna: ${widget.email}");
    print("Nomor telepon lama: ${widget.phone}");
    print("Nomor telepon baru yang dimasukkan: $phone");

    // Validasi input
    if (phone.isEmpty) {
      print("[VALIDASI]: Nomor telepon kosong.");
      _showAwesomeDialog(
          "Nomor telepon tidak boleh kosong.", DialogType.warning);
      return;
    } else if (!RegExp(r'^\d{10,15}$').hasMatch(phone)) {
      print("[VALIDASI]: Nomor telepon tidak sesuai format.");
      _showAwesomeDialog(
          "Nomor telepon harus berupa angka dan memiliki panjang 10-15 karakter.",
          DialogType.warning);
      return;
    }

    // Deteksi apakah nomor baru sama dengan nomor lama
    if (phone == widget.phone) {
      print("[VALIDASI]: Nomor telepon baru sama dengan nomor lama.");
      _showAwesomeDialog(
          "Silahkan masukkan nomor terbaru Anda.", DialogType.warning);
      return;
    }

    print("[STATUS]: Nomor telepon valid. Melanjutkan permintaan ke server...");

    // Mulai loading
    setState(() {
      _isLoading = true;
    });

    try {
      // Kirim data ke server
      print("[REQUEST]: Mengirim permintaan ke server...");
      final response = await http.post(
        Uri.parse('https://api.pensiunku.id/new.php/updateNomorTelepon'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': widget.email, 'phone': phone}),
      );

      print("[RESPONSE]: Status kode: ${response.statusCode}");
      print("[RESPONSE]: Respons body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("[RESPONSE PARSED]: $data");

        if (data['text']?['message'] == 'success') {
          print("[SUCCESS]: Nomor telepon berhasil diperbarui.");
          _showAwesomeDialog(
            "Nomor telepon berhasil diperbarui.",
            DialogType.success,
            onOk: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      RecoveryAccountSuccessScreen(phone: 'phone'),
                ),
              );
            },
          );
        } else if (data['text'] != null &&
            data['text']['message'] == 'Nomor telepon anda tidak berubah!') {
          print('Nomor telepon yang dimasukkan sama dengan yang lama.');
          AwesomeDialog(
            context: context,
            dialogType: DialogType.warning,
            animType: AnimType.bottomSlide,
            title: 'Nomor Tidak Berubah',
            desc: 'Silakan masukkan nomor telepon baru Anda.',
            btnOkOnPress: () {},
          ).show();
        }
      } else {
        print("[SERVER ERROR]: Status kode bukan 200.");
        _showAwesomeDialog(
            "Terjadi kesalahan server. Silakan coba lagi.", DialogType.error);
      }
    } catch (e) {
      print("[EXCEPTION]: Terjadi kesalahan: $e");
      _showAwesomeDialog(
          "Gagal terhubung ke server. Silakan coba lagi.", DialogType.error);
    } finally {
      print("[STATUS]: Permintaan selesai. Menghentikan loading...");
      setState(() {
        _isLoading = false;
      });
    }
    print("=== END: Submit Phone ===");
  }

  void _showAwesomeDialog(String message, DialogType dialogType,
      {void Function()? onOk}) {
    print("[DIALOG]: Menampilkan dialog dengan pesan: $message");
    AwesomeDialog(
      context: context,
      dialogType: dialogType,
      animType: AnimType.scale,
      title: dialogType == DialogType.success ? 'Berhasil' : 'Kesalahan',
      desc: message,
      btnOkOnPress: onOk ?? () {},
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    print("[BUILD]: RecoveryUpdatePhoneScreen dibangun.");
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.white,
              Color.fromARGB(255, 219, 218, 145),
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/register_screen/pensiunku.png',
                  height: 45.0,
                ),
                SizedBox(height: 70.0),
                Text(
                  'Pemulihan Akun',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Masukkan nomor telepon baru anda',
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    labelText: 'Nomor Telepon Baru',
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFC950),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    padding:
                        EdgeInsets.symmetric(vertical: 12.0, horizontal: 32.0),
                  ),
                  onPressed: _isLoading ? null : _submitPhone,
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Submit',
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
