import 'package:flutter/material.dart';
import 'package:pensiunku/screen/home/home_screen.dart';

class RegisterSuccessScreen extends StatelessWidget {
  static const String ROUTE_NAME = '/register-success';

  @override
  Widget build(BuildContext context) {
    // Ambil tinggi layar
    final screenHeight = MediaQuery.of(context).size.height;

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
              Color.fromARGB(255, 138, 217, 165),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: screenHeight * 0.02, // padding vertikal relatif
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/register_screen/pensiunku.png',
                  height: screenHeight * 0.08, // 5% tinggi layar
                ),
                SizedBox(height: screenHeight * 0.10), // 15% tinggi layar
                AspectRatio(
                  aspectRatio: 1.5,
                  child: Image.asset(
                    'assets/otp_screen/recovery_success.png',
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: screenHeight * 0.10),

                Text(
                  'Akun anda berhasil dibuat',
                  style: TextStyle(
                    fontSize: screenHeight * 0.03, // font size relatif
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.03),

                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushReplacementNamed(HomeScreen.ROUTE_NAME);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal:
                          screenHeight * 0.04, // relatif terhadap tinggi
                      vertical: screenHeight * 0.02,
                    ),
                    backgroundColor: Color(0xFFFFC950),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                  child: Text(
                    'Masuk Ke Aplikasi',
                    style: TextStyle(
                      fontSize: screenHeight * 0.02,
                      color: Colors.black,
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
