import 'package:flutter/material.dart';
import 'package:pensiunku/screen/otp/otp_screen.dart';

class RecoveryAccountSuccessScreen extends StatelessWidget {
  static const String ROUTE_NAME =
      '/recovery-success'; // Rute statis untuk navigasi.
  final String phone;

  RecoveryAccountSuccessScreen({required this.phone});
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
              Color.fromARGB(255, 219, 218, 145), // Warna gradasi hijau muda
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
                Image.asset(
                  'assets/register_screen/pensiunku.png', // Ikon keberhasilan.
                  height: 40,
                ),
                SizedBox(height: 100.0),

                // Teks Judul
                Text(
                  'Akun anda berhasil dipulihkan!',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.0),

                // Subjudul
                Text(
                  'Sekarang Anda bisa login dengan nomor baru',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.0),

                // Tombol ke Dashboard/HomePage
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => OtpScreen(),
                      ), // Mengirim data nomor baru. // Mengarah ke OtpScreen
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(horizontal: 48.0, vertical: 16.0),
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                  child: Text(
                    'Silahkan Login',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                    ),
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
