import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pensiunku/model/e_wallet/user_bank_detail_model.dart';
import 'package:pensiunku/screen/home/dashboard/dashboard_screen.dart';
import 'package:http/http.dart' as http;

class PencairanBerhasilScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/pencairan-berhasil';

  final double amount;
  final DateTime transactionDate;
  final String referenceNumber;
  final UserBankDetail bankDetail; // Ini tidak lagi opsional
  final String status; // Tambahkan status transaksi

  const PencairanBerhasilScreen({
    Key? key,
    required this.amount,
    required this.transactionDate,
    required this.referenceNumber,
    required this.bankDetail, // Pastikan ini selalu ada
    this.status = 'Berhasil', // Default status
  }) : super(key: key);

  @override
  State<PencairanBerhasilScreen> createState() =>
      _PencairanBerhasilScreenState();
}

class _PencairanBerhasilScreenState extends State<PencairanBerhasilScreen> {
  // _bankDetail, _isLoading, _errorMessage tidak lagi dibutuhkan sebagai state
  // karena data sudah dari widget.bankDetail
  // UserBankDetail? _bankDetail;
  // bool _isLoading = true;
  // String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Tidak perlu _fetchBankDetail lagi karena bankDetail sudah diterima via constructor
  }

  // _fetchBankDetail function is no longer needed here

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    // Format jumlah menjadi Rupiah
    final amountFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final formattedAmount = amountFormatter.format(widget.amount);

    // Format tanggal dan waktu
    final dateTimeFormatter = DateFormat('dd MMMM yyyy • HH:mm:ss \'WIB\'',
        'id_ID'); // Menggunakan id_ID untuk bulan
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
                  SizedBox(height: screenHeight * 0.04),
                  // Ilustrasi
                  Container(
                    width: screenWidth * 0.6,
                    height: screenHeight * 0.25,
                    child: Image.asset(
                        'assets/pensiunkuplus/e_wallet/pencairan_berhasil.png'),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Card "Pencairan Berhasil"
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
                          "Pencairan Berhasil",
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF3F3F3F),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Text(
                          formattedAmount,
                          style: TextStyle(
                            fontSize: screenWidth * 0.07,
                            fontWeight: FontWeight.bold,
                            color: const Color(
                                0xFF017964), // Warna hijau untuk nominal berhasil
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

                  // Rekening Pencairan Card - Menampilkan berdasarkan status loading/error/data
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: screenWidth * 0.02,
                          bottom: screenHeight * 0.01),
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
                  // Karena bankDetail sekarang wajib, kita bisa langsung menampilkannya
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
                              image: NetworkImage(widget
                                      .bankDetail.bankLogoUrl ??
                                  'https://placehold.co/${(screenWidth * 0.15).toInt()}x${(screenWidth * 0.15).toInt()}/000000/FFFFFF?text=BANK'),
                              fit: BoxFit.contain,
                              onError: (exception, stackTrace) {
                                debugPrint(
                                    'Error loading bank logo: $exception');
                              },
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
                        // Perbaikan: Kembali ke rute Dashboard yang sudah ada
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
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
