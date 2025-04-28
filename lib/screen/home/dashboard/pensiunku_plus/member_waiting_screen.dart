import 'package:flutter/material.dart';
import 'package:pensiunku/screen/home/dashboard/dashboard_screen.dart';

class MemberWaitingScreen extends StatelessWidget {
  const MemberWaitingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                            const SizedBox(height: 30.0),
                            SizedBox(
                              height: 45,
                              child: Image.asset(
                                  'assets/pensiunkuplus/pensiunku.png'),
                            ),
                            const SizedBox(height: 30.0),
                            SizedBox(
                              height: 220,
                              child: Image.asset(
                                  'assets/pensiunkuplus/waiting-pensiunkuplus.png'),
                            ),
                            const SizedBox(height: 30.0),
                            const Text(
                              'Mohon Menunggu \n Berkas Sedang Diproses',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 30.0),
                            ElevatedButton(
                                onPressed: () {
                                  // Gunakan pushReplacement bukan push
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DashboardScreen(
                                        onApplySubmission: (context) {
                                          // Implementasikan apa yang harus terjadi saat pengajuan
                                        },
                                        onChangeBottomNavIndex: (index) {
                                          // Ini harus menangani perubahan indeks bar navigasi
                                          // Kemungkinan perlu terhubung ke state management
                                        },
                                        scrollController: ScrollController(),
                                      ),
                                    ),
                                  );
                                },
                                child: Text('Kembali ke Halaman Utama')),
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
