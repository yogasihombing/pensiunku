import 'package:flutter/material.dart';
import 'package:pensiunku/screen/home/dashboard/dashboard_screen.dart';

class PensiunkuPlusSuccessScreen extends StatelessWidget {
  static const String ROUTE_NAME = '/PensiunkuPlusSuccessScreen';

  const PensiunkuPlusSuccessScreen({Key? key}) : super(key: key);

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
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 20.0),
                child: Column(
                  children: [
                    // // Back button and progress bar
                    // Row(
                    //   children: [
                    //     IconButton(
                    //       icon: Icon(Icons.arrow_back, color: Colors.black),
                    //       onPressed: () => Navigator.pop(context),
                    //     ),
                    //     Expanded(
                    //       child: LinearProgressIndicator(
                    //         value: 1,
                    //         backgroundColor: Colors.grey[300],
                    //         valueColor:
                    //             AlwaysStoppedAnimation<Color>(Color(0xFF006C4E)),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    SizedBox(height: 40),
                    // Logo
                    Image.asset(
                      'assets/pensiunkuplus/pensiunku.png',
                      height: 50,
                    ),
                    SizedBox(height: 30),
                    // Illustration
                    Image.asset(
                      'assets/pensiunkuplus/pensiunkuplus_success.png',
                      height: 200,
                    ),
                    SizedBox(height: 20),
                    // Title
                    Text(
                      'Selamat!\n Anda telah menjadi\n mitra Pensiunku+',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 30),

                    // Submit Button
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
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed(
                          DashboardScreen.ROUTE_NAME,
                          arguments: {
                            'onApplySubmission': (BuildContext context) {},
                            'onChangeBottomNavIndex': (int index) {},
                            'scrollController': ScrollController(),
                          },
                        );
                      },
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Kembali ke Halaman Utama',
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
        ],
      ),
    );
  }
}
