import 'package:flutter/material.dart';

class TermAndConditionScreen extends StatelessWidget {
  static const String ROUTE_NAME = '/terms_and_conditions';

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
          'Syarat dan Ketentuan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0XFF017964),
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
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
                      child: Column(
                        children: [
                          Text(
                            'Pensiunku Terms of Use',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Updated as of 31 / 01 / 2025',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildParagraph(
                      'Selamat datang di aplikasi Pensiunku. Dengan mendaftar dan menggunakan Aplikasi ini, Anda setuju untuk mematuhi Syarat dan Ketentuan yang ditetapkan di bawah ini. Jika Anda tidak setuju dengan bagian mana pun dari Syarat dan Ketentuan ini, mohon untuk tidak melanjutkan proses pendaftaran atau penggunaan Aplikasi.',
                    ),
                    SizedBox(height: 20),
                    ..._buildPolicySections(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPolicySections(BuildContext context) {
    List<Map<String, dynamic>> sections = [
      {
        "title": "Definisi",
        "content": _buildBulletPoints([
          "Aplikasi: Pensiunku, platform yang menyediakan layanan pengajuan pinjaman untuk prapensiun atau pensiunan PNS, TNI, POLRI, BUMN, dan BUMD.",
          "Pengguna: Individu yang mendaftar dan menggunakan layanan yang disediakan oleh Aplikasi.",
          "Layanan: Fasilitas yang ditawarkan oleh Aplikasi, termasuk namun tidak terbatas pada pengajuan pinjaman dan informasi terkait produk pinjaman.",
        ])
      },
      {
        "title": "Kelayakan Pengguna",
        "content": _buildBulletPoints([
          "Usia: Minimal 21 tahun atau telah menikah dan tidak berada di bawah perwalian.",
          "Status: Masyarakat Indonesia.",
          "Dokumen: Memiliki KTP yang sah dan dokumen pendukung lainnya sesuai dengan persyaratan yang ditetapkan.",
        ])
      },
      {
        "title": "Pendaftaran Akun",
        "content": _buildBulletPoints([
          "Informasi Akurat: Pengguna wajib memberikan informasi yang akurat, lengkap, dan terbaru selama proses pendaftaran.",
          "Keamanan Akun: Pengguna bertanggung jawab untuk menjaga kerahasiaan informasi akun dan kata sandi. Segala aktivitas yang terjadi dalam akun Anda menjadi tanggung jawab Anda sepenuhnya.",
        ])
      },
      {
        "title": "Penggunaan Layanan",
        "content": _buildBulletPoints([
          "Kepatuhan Hukum: Pengguna setuju untuk menggunakan Aplikasi sesuai dengan hukum dan peraturan yang berlaku di Indonesia.",
          "Larangan: Pengguna dilarang menggunakan Aplikasi untuk tujuan yang melanggar hukum, menipu, atau merugikan pihak lain.",
        ])
      },
      {
        "title": "Data Pribadi",
        "content": Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBulletPoints([
              "Pengumpulan Data: Kami mengumpulkan data pribadi Anda untuk keperluan verifikasi dan pemrosesan pengajuan pinjaman.",
              "Penggunaan Data: Data Anda akan digunakan sesuai dengan Kebijakan Privasi kami, yang dapat diakses melalui tautan ini.",
            ]),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/privacy_policy'),
              child: Text(
                'Kebijakan Privasi',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      },
      {
        "title": "Persetujuan Pengguna",
        "content": _buildBulletPoints([
          "Verifikasi: Melakukan verifikasi data yang Anda berikan.",
          "Informasi Produk: Mengirimkan informasi terkait produk dan layanan kami melalui email atau media komunikasi lainnya.",
        ])
      },
      {
        "title": "Pembatasan Tanggung Jawab",
        "content": _buildBulletPoints([
          "Kami berupaya untuk menyediakan layanan terbaik, namun tidak menjamin bahwa Aplikasi akan selalu berfungsi tanpa gangguan atau bebas dari kesalahan. Kami tidak bertanggung jawab atas kerugian yang timbul akibat penggunaan Aplikasi.",
        ])
      },
      {
        "title": "Perubahan Syarat dan Ketentuan",
        "content": _buildBulletPoints([
          "Kami berhak untuk mengubah Syarat dan Ketentuan ini sewaktu-waktu. Perubahan akan diberitahukan melalui Aplikasi atau media lainnya. Penggunaan berkelanjutan setelah pemberitahuan perubahan dianggap sebagai persetujuan Anda terhadap perubahan tersebut.",
        ])
      },
      {
        "title": "Hubungi Kami",
        "content": _buildBulletPoints([
          "Email: pensiunku.hello@gmail.com",
          "Telepon: 087785833344",
        ])
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
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
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
    // Split the text at the first colon if it exists
    final parts = text.split(': ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• ", style: TextStyle(fontSize: 14, color: Colors.black87)),
          Expanded(
            child: parts.length > 1
                ? RichText(
                    textAlign: TextAlign.justify,
                    text: TextSpan(
                      style: TextStyle(
                          fontSize: 14, color: Colors.black87, height: 1.5),
                      children: [
                        TextSpan(
                          text: parts[0] + ': ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: parts[1]),
                      ],
                    ),
                  )
                : Text(
                    text,
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
