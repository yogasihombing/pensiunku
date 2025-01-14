import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  static const String ROUTE_NAME = '/privacy_policy';

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
          SafeArea(
            child: Padding(
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
                          'Kebijakan Privasi',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      elevation: 8,
                      shadowColor: Colors.black45,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kebijakan Privasi Aplikasi Pensiunku',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal.shade900,
                              ),
                            ),
                            SizedBox(height: 20),
                            _buildSectionTitle('1. Pendahuluan'),
                            _buildSectionContent(
                                'Kami di Pensiunku ("Aplikasi") menghormati privasi Anda dan berkomitmen untuk melindungi data pribadi Anda. Kebijakan Privasi ini menjelaskan bagaimana kami mengumpulkan, menggunakan, dan melindungi informasi yang Anda berikan saat menggunakan Aplikasi.'),
                            SizedBox(height: 20),
                            _buildSectionTitle(
                                '2. Informasi yang Kami Kumpulkan'),
                            _buildSectionContent(
                                'Kami dapat mengumpulkan jenis informasi berikut dari Anda:\nInformasi Pribadi: Nama, alamat, tanggal lahir, nomor KTP, nomor telepon, dan email.\nInformasi Keuangan: Informasi rekening bank, slip gaji, dan data pengajuan pinjaman.\nInformasi Teknis: Alamat IP, jenis perangkat, sistem operasi, dan aktivitas penggunaan Aplikasi.'),
                            SizedBox(height: 20),
                            _buildSectionTitle(
                                '3. Cara Kami Menggunakan Informasi Anda'),
                            _buildSectionContent(
                                'Informasi yang kami kumpulkan digunakan untuk:\n- Memverifikasi identitas Anda.\n- Memproses pengajuan pinjaman.\n- Memberikan layanan yang sesuai dengan kebutuhan Anda.\n- Mengirimkan pembaruan terkait layanan, promosi, atau informasi penting lainnya.\n- Mematuhi kewajiban hukum dan regulasi yang berlaku.'),
                            SizedBox(height: 20),
                            _buildSectionTitle('4. Berbagi Informasi Anda'),
                            _buildSectionContent(
                                'Kami tidak akan membagikan informasi pribadi Anda kepada pihak ketiga tanpa persetujuan Anda, kecuali dalam situasi berikut:\n- Untuk memenuhi persyaratan hukum atau permintaan pemerintah yang sah.\n- Kepada mitra layanan yang membantu operasional Aplikasi, seperti lembaga keuangan atau penyedia teknologi, dengan pengamanan yang sesuai.'),
                            SizedBox(height: 20),
                            _buildSectionTitle('5. Keamanan Informasi'),
                            _buildSectionContent(
                                'Kami menerapkan langkah-langkah keamanan yang sesuai untuk melindungi informasi Anda dari akses tidak sah, pengungkapan, atau kerusakan. Namun, harap dipahami bahwa tidak ada sistem keamanan yang sepenuhnya bebas risiko.'),
                            SizedBox(height: 20),
                            _buildSectionTitle('6. Penyimpanan Data'),
                            _buildSectionContent(
                                'Informasi Anda akan disimpan selama diperlukan untuk menyediakan layanan atau mematuhi ketentuan hukum yang berlaku. Setelah itu, data akan dihapus atau dianonimkan.'),
                            SizedBox(height: 20),
                            _buildSectionTitle('7. Hak Anda'),
                            _buildSectionContent(
                                'Anda memiliki hak berikut terkait data pribadi Anda:\n- Mengakses data yang kami simpan tentang Anda.\n- Memperbarui atau memperbaiki informasi yang tidak akurat.\n- Meminta penghapusan data, sesuai dengan ketentuan hukum.\n- Menarik persetujuan Anda kapan saja, dengan konsekuensi tertentu terhadap layanan yang diberikan.'),
                            SizedBox(height: 20),
                            _buildSectionTitle(
                                '8. Perubahan Kebijakan Privasi'),
                            _buildSectionContent(
                                'Kami dapat memperbarui Kebijakan Privasi ini sewaktu-waktu. Perubahan akan diberitahukan melalui Aplikasi atau media lainnya. Penggunaan berkelanjutan setelah pemberitahuan dianggap sebagai persetujuan Anda terhadap perubahan tersebut.'),
                            SizedBox(height: 20),
                            _buildSectionTitle('9. Hubungi Kami'),
                            _buildSectionContent(
                                'Jika Anda memiliki pertanyaan atau kekhawatiran terkait Kebijakan Privasi ini, silakan hubungi kami melalui:\n- Email: ...\n- Telepon: ...'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
        color: Colors.teal.shade900,
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
