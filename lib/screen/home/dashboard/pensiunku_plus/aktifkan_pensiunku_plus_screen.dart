import 'package:flutter/material.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/upload_foto_wajah.dart';

class AktifkanPensiunkuPlusScreen extends StatelessWidget {
  static const String ROUTE_NAME = '/AktifkanPensiunkuPlusScreen';
  const AktifkanPensiunkuPlusScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool _isLoading = false;
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
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
            ),
          ),
          // Content
          Center(
            child: SafeArea(
                child: Column(
              children: [
                Expanded(
                    child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 20.0),
                        SizedBox(
                          height: 150,
                          child:
                              Image.asset('assets/pensiunkuplus/pensiunku.png'),
                        ),
                        SizedBox(
                          height: 200,
                          child: Image.asset(
                              'assets/pensiunkuplus/pensiunkuplus_1.png'),
                        ),
                        SizedBox(height: 12.0),
                        Text(
                          'Bergabunglah menjadi \nmitra Pensiunku+',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 16.0),
                        Text(
                          '• Potensi insentif s/d lebih dari Rp 5 Juta \n • Insentif langsung ke wallet akun \n • Tentukan sendiri target dan jam kerja',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13.0),
                        ),
                        SizedBox(height: 20.0),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFFC950),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.0),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 32.0),
                          ),
                          onPressed: () {
                            // Navigasi ke halaman UploadFotoWajahPensiunkuPlusScreen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UploadFotoWajahPensiunkuPlusScreen(),
                              ),
                            );
                          },
                          child: _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'Bergabung Sekarang',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),
                                ),
                        ),
                      ],
                    ),
                  ),
                ))
              ],
            )),
          )
        ],
      ),
    );
  }
}
