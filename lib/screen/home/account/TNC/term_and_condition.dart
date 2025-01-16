import 'package:flutter/material.dart';

class TermAndConditionScreen extends StatelessWidget {
  static const String ROUTE_NAME = '/terms_and_conditions';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient - full layar
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Colors.white,
                    Color.fromARGB(225, 138, 217, 165), // Hijau Muda
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Syarat dan Ketentuan',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Syarat dan Ketentuan Penggunaan Aplikasi Pensiunku',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                          SizedBox(height: 20),
                          _buildSectionTitle('1. Pendahuluan'),
                          _buildSectionContent(
                              'Selamat datang di aplikasi Pensiunku. Dengan mendaftar dan menggunakan Aplikasi ini, Anda setuju untuk mematuhi Syarat dan Ketentuan yang ditetapkan di bawah ini. Jika Anda tidak setuju dengan bagian mana pun dari Syarat dan Ketentuan ini, mohon untuk tidak melanjutkan proses pendaftaran atau penggunaan Aplikasi.'),
                          SizedBox(height: 20),
                          _buildSectionTitle('2. Definisi'),
                          _buildSectionContent(
                              'Aplikasi: Pensiunku, platform yang menyediakan layanan pengajuan pinjaman untuk prapensiun atau pensiunan PNS, TNI, POLRI, BUMN, dan BUMD.\nPengguna: Individu yang mendaftar dan menggunakan layanan yang disediakan oleh Aplikasi.\nLayanan: Fasilitas yang ditawarkan oleh Aplikasi, termasuk namun tidak terbatas pada pengajuan pinjaman dan informasi terkait produk pinjaman.'),
                          SizedBox(height: 20),
                          _buildSectionTitle('3. Kelayakan Pengguna'),
                          _buildSectionContent(
                              'Untuk mendaftar dan menggunakan Aplikasi, Anda harus memenuhi kriteria berikut:\n- Usia: Minimal 21 tahun atau telah menikah dan tidak berada di bawah perwalian.\n- Status: Masyarakat Indonesia.\n- Dokumen: Memiliki KTP yang sah dan dokumen pendukung lainnya sesuai dengan persyaratan yang ditetapkan.'),
                          SizedBox(height: 20),
                          _buildSectionTitle('4. Pendaftaran Akun'),
                          _buildSectionContent(
                              '- Informasi Akurat: Pengguna wajib memberikan informasi yang akurat, lengkap, dan terbaru selama proses pendaftaran.\n- Keamanan Akun: Pengguna bertanggung jawab untuk menjaga kerahasiaan informasi akun dan kata sandi. Segala aktivitas yang terjadi dalam akun Anda menjadi tanggung jawab Anda sepenuhnya.'),
                          SizedBox(height: 20),
                          _buildSectionTitle('5. Penggunaan Layanan'),
                          _buildSectionContent(
                              '- Kepatuhan Hukum: Pengguna setuju untuk menggunakan Aplikasi sesuai dengan hukum dan peraturan yang berlaku di Indonesia.\n- Larangan: Pengguna dilarang menggunakan Aplikasi untuk tujuan yang melanggar hukum, menipu, atau merugikan pihak lain.'),
                          SizedBox(height: 20),
                          _buildSectionTitle('6. Data Pribadi'),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kami mengumpulkan data pribadi Anda untuk keperluan verifikasi dan pemrosesan pengajuan pinjaman.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  height: 1.5,
                                ),
                              ),
                              SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, '/privacy_policy');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade600,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                child: Text('Lihat Kebijakan Privasi'),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          _buildSectionTitle('7. Persetujuan Pengguna'),
                          _buildSectionContent(
                              'Dengan mendaftar, Anda memberikan persetujuan kepada kami untuk:\n- Verifikasi: Melakukan verifikasi data yang Anda berikan.\n- Informasi Produk: Mengirimkan informasi terkait produk dan layanan kami melalui email atau media komunikasi lainnya.'),
                          SizedBox(height: 20),
                          _buildSectionTitle('8. Pembatasan Tanggung Jawab'),
                          _buildSectionContent(
                              'Kami berupaya untuk menyediakan layanan terbaik, namun tidak menjamin bahwa Aplikasi akan selalu berfungsi tanpa gangguan atau bebas dari kesalahan. Kami tidak bertanggung jawab atas kerugian yang timbul akibat penggunaan Aplikasi.'),
                          SizedBox(height: 20),
                          _buildSectionTitle(
                              '9. Perubahan Syarat dan Ketentuan'),
                          _buildSectionContent(
                              'Kami berhak untuk mengubah Syarat dan Ketentuan ini sewaktu-waktu. Perubahan akan diberitahukan melalui Aplikasi atau media lainnya. Penggunaan berkelanjutan setelah pemberitahuan perubahan dianggap sebagai persetujuan Anda terhadap perubahan tersebut.'),
                          SizedBox(height: 20),
                          _buildSectionTitle('10. Hubungi Kami'),
                          _buildSectionContent(
                              'Jika Anda memiliki pertanyaan atau membutuhkan informasi lebih lanjut, silakan hubungi kami melalui:\n- Email: ...\n- Telepon: ...'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.green.shade800,
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Text(
      content,
      style: TextStyle(
        fontSize: 14,
        color: Colors.black87,
        height: 1.5,
      ),
    );
  }
}
