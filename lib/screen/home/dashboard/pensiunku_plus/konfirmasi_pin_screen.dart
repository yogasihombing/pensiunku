import 'package:flutter/material.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/pensiunkuplus_success_screen.dart';

class KonfirmasiPinPensiunkuPlusScreen extends StatelessWidget {
  static const String ROUTE_NAME = '/UploadFotoWajahScreen';

  const KonfirmasiPinPensiunkuPlusScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool _isLoading = false;
    double backButtonToImageDistance =
        20.0; // Jarak antara tombol back dan gambar
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
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Column(
                children: [
                  // Back button and progress bar
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
                  // Logo
                  Image.asset(
                    'assets/pensiunkuplus/pensiunku.png',
                    height: 100,
                  ),
                  SizedBox(height: 10),
                  // Illustration
                  Image.asset(
                    'assets/pensiunkuplus/daftarkan_pin.png',
                    height: 200,
                  ),
                  SizedBox(height: 20),
                  // Title
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
                  // Upload Box
                  Form(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: SizedBox(
                            width: 50.0,
                            height: 50.0,
                            child: TextFormField(
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
                              onChanged: (value) {
                                if (value.length == 1 && index < 4) {
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
                        );
                      }),
                    ),
                  ),
                  SizedBox(height: 24),
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
                    onPressed: () {// Navigasi ke halaman PensiunkuPlusSuccessScreen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PensiunkuPlusSuccessScreen(),
                              ),
                            );},
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
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
        ],
      ),
    );
  }
}
