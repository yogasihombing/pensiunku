import 'package:flutter/material.dart';
import 'package:pensiunku/model/submission_model.dart';
import 'package:pensiunku/screen/home/dashboard/dashboard_screen.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/selfie/prepare_selfie_screen.dart';

class AktifkanPensiunkuPlusScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/AktifkanPensiunkuPlusScreen';
  const AktifkanPensiunkuPlusScreen({Key? key}) : super(key: key);

  @override
  State<AktifkanPensiunkuPlusScreen> createState() =>
      _AktifkanPensiunkuPlusScreenState();
}

class _AktifkanPensiunkuPlusScreenState
    extends State<AktifkanPensiunkuPlusScreen> {
  bool _isLoadingOverlay = false;
  // Tambahkan method _handleSelfieSuccess
  void _handleSelfieSuccess(BuildContext context) {
    // Implementasikan logika setelah selfie berhasil, misalnya:
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Selfie berhasil diupload!')),
    );
    // Atau navigasi ke halaman lain, dsb.
  }

  void _startLoading() {
    setState(() {
      _isLoadingOverlay = true;
    });

    // Simulasi proses 3 detik
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _isLoadingOverlay = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigasi ke DashboardScreen ketika tombol kembali ditekan
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => DashboardScreen(
                    onApplySubmission: (context) {},
                    onChangeBottomNavIndex: (index) {},
                    scrollController: ScrollController(),
                  )),
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
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
                              const SizedBox(height: 30.0),
                              SizedBox(
                                height: 40,
                                child: Image.asset(
                                    'assets/pensiunkuplus/pensiunku.png'),
                              ),
                              SizedBox(
                                height: 220,
                                child: Image.asset(
                                    'assets/pensiunkuplus/pensiunkuplus_1.png'),
                              ),
                              const SizedBox(height: 30.0),
                              const Text(
                                'Bergabunglah menjadi \nmitra Pensiunku+',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 15.0),
                              const Text(
                                '• Potensi insentif s/d lebih dari Rp 5 Juta \n • Insentif langsung ke wallet akun \n • Tentukan sendiri target dan jam kerja',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 13.0),
                              ),
                              const SizedBox(height: 15.0),
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
                                child:Text(
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
            ),
            if (_isLoadingOverlay)
              Stack(
                children: [
                  Positioned.fill(
                    child: ModalBarrier(
                      color: Colors.black.withOpacity(0.5),
                      dismissible: false,
                    ),
                  ),
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Color(0xFF017964)),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Mohon tunggu...',
                            style: TextStyle(
                              color: Color(0xFF017964),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
