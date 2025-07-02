
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pensiunku/model/e_wallet/user_bank_detail_model.dart';
import 'package:pensiunku/screen/home/dashboard/dashboard_screen.dart';

class PencairanDiprosesScreen extends StatefulWidget {
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
  State<PencairanDiprosesScreen> createState() => _PencairanDiprosesScreenState();
}

class _PencairanDiprosesScreenState extends State<PencairanDiprosesScreen> {
  UserBankDetail? _bankDetail;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Jika detail bank sudah disediakan melalui konstruktor, gunakan itu.
    // Jika tidak, panggil API untuk mengambilnya.
    if (widget.bankDetail != null) {
      _bankDetail = widget.bankDetail;
      _isLoading = false;
    } else {
      _fetchBankDetail();
    }
  }

  // Fungsi untuk memanggil API dan mengambil detail bank
  Future<void> _fetchBankDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    const String apiUrl = 'https://api.pensiunku.id/new.php/getDetailWithdraw';
    const Map<String, String> requestBody = {
      'id': '3'
    }; // ID hardcode sesuai permintaan

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      debugPrint('API Response Status Code: ${response.statusCode}');
      debugPrint('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // Asumsi struktur respons API:
        // { "success": true, "data": { ...data bank... } }
        if (responseData['success'] == true && responseData['data'] != null) {
          setState(() {
            _bankDetail = UserBankDetail.fromJson(responseData['data']);
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = responseData['message'] ??
                'Gagal mengambil detail bank. Data tidak valid.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage =
              'Gagal terhubung ke server: Status ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan jaringan: $e';
        _isLoading = false;
      });
      debugPrint('Error fetching bank detail: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    // Format tanggal dan waktu
    final dateTimeFormatter = DateFormat('dd MMMM yyyy • HH:mm:ss \'WIB\'', 'id_ID'); // Menggunakan id_ID untuk bulan
    final formattedDateTime = dateTimeFormatter.format(widget.transactionDate);

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
            height: screenHeight * 0.45,
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
                  SizedBox(height: screenHeight * 0.03),
                  // AppBar (back button dan judul)
                  Align(
                    alignment: Alignment.centerLeft,
                    // child: IconButton(
                    //   icon: Icon(
                    //     Icons.arrow_back,
                    //     color: Color.transparent,
                    //     size: screenWidth * 0.06,
                    //   ),
                    //   onPressed: () => Navigator.pop(context),
                    // ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Ilustrasi (Ganti dengan aset PNG/SVG Anda)
                  // Pastikan Anda menambahkan aset gambar ini ke pubspec.yaml
                  // Contoh: assets/images/pencairan_diproses_illustration.png
                  // Untuk demo, menggunakan placeholder dari NetworkImage
                  Container(
                    width: screenWidth * 0.8, // Ukuran responsif untuk ilustrasi
                    height: screenHeight * 0.27,
                    child: Image.asset('assets/pensiunkuplus/e_wallet/pencairan_diproses.png')
                  
                    
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
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF3F3F3F),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Text(
                          "Pencairan Diproses",
                          style: TextStyle(
                            fontSize: screenWidth * 0.07,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF3F3F3F),
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
                    "Ref: ${widget.referenceNumber}",
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),

                  // Rekening Pencairan Card
                  Align(
                    alignment: Alignment.center,
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
                              image: NetworkImage(widget.bankDetail.bankLogoUrl ??
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
                                widget.bankDetail.bankName,
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
                                '${widget.bankDetail.maskedAccountNumber} - ${widget.bankDetail.accountHolderName}',
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
                    
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC950),
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.015,
                          horizontal: screenHeight * 0.02,
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
                          color: Color(0xFF3F3F3F),
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