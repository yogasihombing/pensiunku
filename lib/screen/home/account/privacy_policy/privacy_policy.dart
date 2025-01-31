import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  static const String ROUTE_NAME = '/privacy_policy';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Kebijakan Privasi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0XFF017964),
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
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
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Kebijakan Privasi',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildParagraph(
                        "Kami di Pensiunku (\"Aplikasi\") menghormati privasi Anda dan berkomitmen untuk melindungi data pribadi Anda. Kebijakan Privasi ini menjelaskan bagaimana kami mengumpulkan, menggunakan, dan melindungi informasi yang Anda berikan saat menggunakan Aplikasi."),
                    SizedBox(height: 20),
                    ..._buildPolicySections(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPolicySections() {
    List<Map<String, dynamic>> sections = [
      {
        "title": "Apa Informasi Yang Kami Kumpulkan?",
        "content": _buildInformationList()
      },
      {
        "title": "Bagaimana Cara Kami Menggunakan Informasi Anda?",
        "content": _buildBulletPoints([
          "Memverifikasi identitas Anda.",
          "Memproses pengajuan pinjaman.",
          "Memberikan layanan yang sesuai dengan kebutuhan Anda.",
          "Mengirimkan pembaruan terkait layanan, promosi, atau informasi penting lainnya.",
          "Mematuhi kewajiban hukum dan regulasi yang berlaku."
        ])
      },
      {
        "title": "Berbagi Informasi Anda",
        "content": _buildBulletPoints([
          "Untuk memenuhi persyaratan hukum atau permintaan pemerintah yang sah.",
          "Kepada mitra layanan yang membantu operasional Aplikasi, seperti lembaga keuangan atau penyedia teknologi, dengan pengamanan yang sesuai."
        ])
      },
      {
        "title": "Keamanan Informasi",
        "content": _buildParagraph(
            "Kami menerapkan langkah-langkah keamanan yang sesuai untuk melindungi informasi Anda dari akses tidak sah, pengungkapan, atau kerusakan. Namun, harap dipahami bahwa tidak ada sistem keamanan yang sepenuhnya bebas risiko.")
      },
      {
        "title": "Penyimpanan Data",
        "content": _buildParagraph(
            "Informasi Anda akan disimpan selama diperlukan untuk menyediakan layanan atau mematuhi ketentuan hukum yang berlaku. Setelah itu, data akan dihapus atau dianonimkan.")
      },
      {
        "title": "Hak Anda",
        "content": _buildBulletPoints([
          "Mengakses data yang kami simpan tentang Anda.",
          "Memperbarui atau memperbaiki informasi yang tidak akurat.",
          "Meminta penghapusan data, sesuai dengan ketentuan hukum.",
          "Menarik persetujuan Anda kapan saja, dengan konsekuensi tertentu terhadap layanan yang diberikan."
        ])
      },
      {
        "title": "Perubahan Kebijakan Privasi",
        "content": _buildParagraph(
            "Kami dapat memperbarui Kebijakan Privasi ini sewaktu-waktu. Perubahan akan diberitahukan melalui Aplikasi atau media lainnya. Penggunaan berkelanjutan setelah pemberitahuan dianggap sebagai persetujuan Anda terhadap perubahan tersebut.")
      },
      {
        "title": "Hubungi Kami",
        "content": _buildBulletPoints(
            ["Email: pensiunku.hello@gmail.com", "Telepon: 087785833344"])
      },
    ];

    return sections.map((section) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(section["title"]!),
          section["content"]!,
          SizedBox(height: 20),
        ],
      );
    }).toList();
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0XFF017964),
        ),
      ),
    );
  }

  Widget _buildParagraph(String content) {
    return Text(
      content,
      textAlign: TextAlign.justify,
      style: TextStyle(
        fontSize: 14,
        color: Colors.black87,
        height: 1.5,
      ),
    );
  }

  Widget _buildBulletPoints(List<String> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: points.map((point) => _buildBulletPoint(point)).toList(),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• ", style: TextStyle(fontSize: 14, color: Colors.black87)),
          Expanded(
            child: Text(
              text,
              style:
                  TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformationList() {
    return _buildBulletPoints([
      "Informasi Pribadi: Nama, alamat, tanggal lahir, nomor KTP, nomor telepon, dan email.",
      "Informasi Keuangan: Informasi rekening bank, slip gaji, dan data pengajuan pinjaman.",
      "Informasi Teknis: Alamat IP, jenis perangkat, sistem operasi, dan aktivitas penggunaan Aplikasi."
    ]);
  }
}
