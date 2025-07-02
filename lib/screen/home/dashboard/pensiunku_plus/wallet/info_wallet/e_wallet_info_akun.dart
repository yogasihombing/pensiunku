import 'package:flutter/material.dart';

class EWalletInfoAkun extends StatefulWidget {
  static const String ROUTE_NAME = '/e-wallet-info-akun';
  @override
  State<EWalletInfoAkun> createState() => _EWalletInfoAkunState();
}

class _EWalletInfoAkunState extends State<EWalletInfoAkun> {
  // Padding horizontal global
  final double horizontalPadding = 16.0;

  @override
  void initState() {
    super.initState();
    print('EWalletInfoAkun initialized');
  }

  // Helper widget untuk membuat setiap bagian informasi
  Widget _buildInfoSection(
      {required String title,
      required String content,
      required BuildContext context}) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: screenWidth * 0.035, // Ukuran font responsif
            fontWeight: FontWeight.bold,
            color: const Color(0xFF3F3F3F),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          textAlign: TextAlign.justify,
          style: TextStyle(
            fontSize: screenWidth * 0.035, // Ukuran font responsif
            color: Colors.black.withOpacity(0.7),
            height: 1.5, // Jarak antar baris
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menggunakan Stack agar background gradient dan konten utama dapat ditempatkan terpisah
      body: Stack(
        children: [
          // Background gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Colors.white,
                  Colors.white,
                  Color.fromARGB(255, 220, 226, 147),
                ],
                stops: [0.25, 0.5, 0.75, 1.0],
              ),
            ),
          ),

          // Konten utama dalam SafeArea dan SingleChildScrollView
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding, vertical: 1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar: back button dan judul
                  SizedBox(
                    height: kToolbarHeight,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Tombol back di kiri
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Color(0xFF017964)),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        // Judul "Info Akun"
                        Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: const Text(
                              "Informasi eWallet",
                              style: TextStyle(
                                color: Color(0xFF017964),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Menambahkan konten informasi
                  _buildInfoSection(
                    context: context,
                    title: 'Tentang Fitur Dompet di Aplikasi Pensiunku',
                    content:
                        'Fitur Dompet (eWallet) di Pensiunku merupakan layanan penyimpanan digital yang disediakan bagi pengguna untuk menyimpan dana pencairan kredit serta mengatur transaksi keuangan secara mandiri, aman, dan transparan. Melalui fitur ini, pengguna dapat melihat saldo terkini, mencairkan dana ke rekening pribadi, serta mengakses riwayat transaksi mereka dengan mudah.',
                  ),
                  _buildInfoSection(
                    context: context,
                    title: 'Fungsi dan Manfaat',
                    content:
                        'Fitur Dompet memungkinkan pengguna menerima pencairan dana langsung ke saldo eWallet mereka setelah proses kredit disetujui. Dana tersebut dapat ditarik ke rekening bank yang terdaftar kapan saja, sesuai dengan ketentuan yang berlaku. Selain itu, pengguna dapat menambahkan lebih dari satu rekening tujuan dan memilihnya saat melakukan pencairan.',
                  ),
                  _buildInfoSection(
                    context: context,
                    title: 'Keamanan Transaksi',
                    content:
                        'Setiap proses pencairan dana dari Dompet ke rekening pengguna memerlukan verifikasi berupa 6 digit PIN. Hal ini bertujuan untuk melindungi transaksi dari penyalahgunaan atau akses tanpa izin. Sistem kami juga mencatat waktu dan status setiap transaksi untuk memberikan transparansi penuh kepada pengguna.',
                  ),
                  _buildInfoSection(
                    context: context,
                    title: 'Riwayat dan Status Transaksi',
                    content:
                        'Pengguna dapat mengakses riwayat lengkap transaksi pencairan, baik yang berhasil, sedang diproses, maupun yang gagal. Status transaksi akan ditampilkan secara real-time untuk memastikan pengguna mengetahui perkembangan setiap pencairan yang dilakukan.',
                  ),
                  _buildInfoSection(
                    context: context,
                    title: 'Ketentuan Penggunaan',
                    content:
                        'Penggunaan fitur Dompet tunduk pada syarat dan ketentuan yang berlaku di dalam aplikasi Pensiunku. Pengguna diwajibkan menjaga kerahasiaan informasi akun dan PIN mereka serta bertanggung jawab atas seluruh aktivitas yang terjadi dalam akun tersebut.',
                  ),
                  _buildInfoSection(
                    context: context,
                    title: 'Hubungi Kami',
                    content:
                        'Jika Anda memiliki pertanyaan, keluhan, atau mengalami kendala dalam penggunaan fitur Dompet, silakan hubungi tim dukungan Pensiunku melalui halaman “Hubungi Kami” yang tersedia di aplikasi.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
