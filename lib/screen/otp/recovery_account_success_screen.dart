import 'package:flutter/material.dart';
import 'package:pensiunku/screen/otp/otp_screen.dart';

class RecoveryAccountSuccessScreen extends StatelessWidget {
  static const String ROUTE_NAME = '/recovery-success';
  final String phone;

  const RecoveryAccountSuccessScreen({Key? key, required this.phone})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Colors.white,
                Color.fromARGB(255, 170, 231, 170),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: mq.width * 0.06,
                vertical: mq.height * 0.01,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo kecil, lebih dekat ke atas
                    Image.asset(
                      'assets/register_screen/pensiunku.png',
                      height: 50,
                    ),
                    SizedBox(height: mq.height * 0.04),

                    // Ilustrasi sukses
                    AspectRatio(
                      aspectRatio: 1.5,
                      child: Image.asset(
                        'assets/otp_screen/recovery_success.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: mq.height * 0.03),

                    // Judul
                    Text(
                      'Akun Anda Berhasil Dipulihkan!',
                      style: TextStyle(
                        fontSize: mq.width * 0.06,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: mq.height * 0.02),

                    // Subjudul
                    Text(
                      'Sekarang Anda bisa login dengan nomor baru',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: mq.height * 0.04),

                    // Tombol proporsional ke teks
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => OtpScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: mq.width * 0.06,
                            vertical: mq.height * 0.010,
                          ),
                          backgroundColor: Color(0xFFFFC950),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                        ),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            fontSize: mq.width * 0.045,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
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
