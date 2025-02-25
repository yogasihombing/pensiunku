import 'package:flutter/material.dart';
import 'package:pensiunku/model/submission_model.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/selfie/prepare_selfie_screen.dart';

class AktifkanPensiunkuPlusScreen extends StatelessWidget {
  static const String ROUTE_NAME = '/AktifkanPensiunkuPlusScreen';
  const AktifkanPensiunkuPlusScreen({Key? key}) : super(key: key);

  // Tambahkan method _handleSelfieSuccess
  void _handleSelfieSuccess(BuildContext context) {
    // Implementasikan logika setelah selfie berhasil, misalnya:
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Selfie berhasil diupload!')),
    );
    // Atau navigasi ke halaman lain, dsb.
  }

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
                            const SizedBox(height: 20.0),
                            SizedBox(
                              height: 150,
                              child: Image.asset(
                                  'assets/pensiunkuplus/pensiunku.png'),
                            ),
                            SizedBox(
                              height: 200,
                              child: Image.asset(
                                  'assets/pensiunkuplus/pensiunkuplus_1.png'),
                            ),
                            const SizedBox(height: 12.0),
                            const Text(
                              'Bergabunglah menjadi \nmitra Pensiunku+',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            const Text(
                              '• Potensi insentif s/d lebih dari Rp 5 Juta \n • Insentif langsung ke wallet akun \n • Tentukan sendiri target dan jam kerja',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13.0),
                            ),
                            const SizedBox(height: 20.0),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFC950),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24.0),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 32.0),
                              ),
                              onPressed: () {
                                // Navigasi ke halaman PrepareSelfieScreen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PrepareSelfieScreen(
                                      onSuccess: _handleSelfieSuccess,
                                      submissionModel: SubmissionModel(
                                        id: 0,
                                        name: '',
                                        birthDate: DateTime.now(),
                                        phone: '',
                                        bankName: '',
                                        plafond: 0,
                                        produk: '',
                                        salary: 0,
                                        tenor: 0,
                                      ), // Sesuaikan dengan model yang Anda gunakan
                                    ),
                                  ),
                                );
                              },
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : const Text(
                                      'Bergabung Sekarang',
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
