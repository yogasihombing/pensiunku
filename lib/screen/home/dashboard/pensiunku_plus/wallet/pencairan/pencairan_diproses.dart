
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pensiunku/model/e_wallet/user_bank_detail_model.dart';
import 'package:pensiunku/screen/home/dashboard/dashboard_screen.dart';

class PencairanDiprosesScreen extends StatelessWidget {
  static const String ROUTE_NAME = '/pencairan-diproses';

  final DateTime transactionDate;
  final String referenceNumber;
  final UserBankDetail bankDetail;

  const PencairanDiprosesScreen({
    Key? key,
    required this.transactionDate,
    required this.referenceNumber,
    required this.bankDetail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    // Format tanggal dan waktu
    final dateTimeFormatter = DateFormat('dd MMMM yyyy • HH:mm:ss \'WIB\'', 'id_ID'); // Menggunakan id_ID untuk bulan
    final formattedDateTime = dateTimeFormatter.format(transactionDate);

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient full screen (putih ke kuning muda)
          Container(
            width: screenWidth,
            height: screenHeight,
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

          // Header background (kuning) dengan ketinggian 28% dari tinggi layar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.28,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFC950),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(screenWidth * 0.08),
                  bottomRight: Radius.circular(screenWidth * 0.08),
                ),
              ),
            ),
          ),

          // Konten Utama
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.02),
                  // AppBar (back button dan judul)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: const Color(0xFF017964),
                        size: screenWidth * 0.06,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Ilustrasi (Ganti dengan aset PNG/SVG Anda)
                  // Pastikan Anda menambahkan aset gambar ini ke pubspec.yaml
                  // Contoh: assets/images/pencairan_diproses_illustration.png
                  // Untuk demo, menggunakan placeholder dari NetworkImage
                  Container(
                    width: screenWidth * 0.6, // Ukuran responsif untuk ilustrasi
                    height: screenHeight * 0.2,
                    child: Image.network(
                      'https://placehold.co/300x200/FFD700/000000?text=Pencairan%20Diproses', // Placeholder
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.hourglass_empty,
                        color: Color(0xFF017964),
                        size: screenWidth * 0.3,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),

                  // Card "Mohon Ditunggu"
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(screenWidth * 0.05),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(screenWidth * 0.04),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Mohon Ditunggu",
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF017964),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Text(
                          "Pencairan Diproses",
                          style: TextStyle(
                            fontSize: screenWidth * 0.08,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF017964),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),

                  // Tanggal dan Referensi
                  Text(
                    formattedDateTime,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    "Ref: $referenceNumber",
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),

                  // Rekening Pencairan Card
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: screenWidth * 0.02, bottom: screenHeight * 0.01),
                      child: Text(
                        "Rekening Pencairan",
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(screenWidth * 0.04),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        // Logo Bank
                        Container(
                          width: screenWidth * 0.15,
                          height: screenWidth * 0.15,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(bankDetail.bankLogoUrl ??
                                  'https://placehold.co/${(screenWidth * 0.15).toInt()}x${(screenWidth * 0.15).toInt()}/000000/FFFFFF?text=BANK'),
                              fit: BoxFit.contain,
                              // onError: (context, error, stackTrace) {
                              //   debugPrint('Error loading bank logo: $error');
                              // },
                            ),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        // Detail Bank
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bankDetail.bankName,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: screenHeight * 0.005),
                              Text(
                                // Menggunakan getter maskedAccountNumber yang akan kita tambahkan
                                '${bankDetail.maskedAccountNumber} - ${bankDetail.accountHolderName}',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  color: Colors.grey[700],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),

                  // Tombol "Kembali ke Beranda"
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC950),
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        elevation: 5,
                      ),
                      onPressed: () {
                        // Navigasi ke halaman dashboard utama atau root
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          DashboardScreen.ROUTE_NAME, // Ganti dengan route ke Dashboard utama Anda
                          (Route<dynamic> route) => false, // Hapus semua route sebelumnya
                        );
                      },
                      child: Text(
                        'Kembali ke Beranda',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}