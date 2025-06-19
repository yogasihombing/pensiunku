import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pensiunku/model/user_model.dart';
import 'package:pensiunku/repository/user_repository.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';

class EWalletHistori extends StatefulWidget {
  static const String ROUTE_NAME = '/e-wallet-histori';

  @override
  State<EWalletHistori> createState() => _EWalletHistoriState();
}

class _EWalletHistoriState extends State<EWalletHistori> {
  UserModel? _userModel;
  late Future<String> _futureGreeting;

  @override
  void initState() {
    super.initState();
    debugPrint('EWalletHistori initialized');
    _refreshData();
    _futureGreeting = _fetchGreeting();
  }

  /// Memuat ulang data pengguna (dengan token dari SharedPreferences)
  Future<void> _refreshData() async {
    final prefs = SharedPreferencesUtil().sharedPreferences;
    String? token = prefs.getString(SharedPreferencesUtil.SP_KEY_TOKEN);
    if (token != null) {
      final result = await UserRepository().getOne(token);
      if (result.error == null) {
        setState(() {
          _userModel = result.data;
          debugPrint('User ID: ${_userModel?.id}');
        });
      } else {
        debugPrint("Error fetching user: ${result.error}");
      }
    }
  }

  /// Mengambil greeting dari API eksternal
  Future<String> _fetchGreeting() async {
    const String baseUrl = 'https://api.pensiunku.id/new.php/greeting';
    try {
      debugPrint('Fetching greeting dari: $baseUrl');
      final response = await http
          .post(Uri.parse(baseUrl))
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Koneksi timeout');
      });

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception(
            'Failed to load greeting (Status: ${response.statusCode})');
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet');
    } on HttpException {
      throw Exception('Gagal mengambil data dari server');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil ukuran layar
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    // Padding horizontal relatif terhadap lebar layar
    final double horizontalPadding = screenWidth * 0.04; // 4% dari lebar

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient full screen
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
              decoration: const BoxDecoration(
                color: Color(0xFFFFC950),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
            ),
          ),

          // Konten utama
          SafeArea(
            child: Column(
              children: [
                // Bagian Header (tidak di-scroll)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: screenHeight * 0.015,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: screenHeight * 0.01),
                      _buildAppBar(context, screenWidth),
                      SizedBox(height: screenHeight * 0.02),
                      Center(child: _buildProfileGreeting(screenWidth)),
                      SizedBox(height: screenHeight * 0.03),
                      _buildWalletBalance(screenWidth),
                    ],
                  ),
                ),

                // Bagian Konten (scrollable): Histori Transaksi dan Insentif
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Column(
                      children: [
                        SizedBox(height: screenHeight * 0.03),
                        _buildTransactionPencairan(screenWidth, screenHeight),
                        SizedBox(height: screenHeight * 0.02),
                        _buildIncentiveTransaction(screenWidth, screenHeight),
                        SizedBox(height: screenHeight * 0.03),
                        // Tambahkan histori lain jika diperlukan
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// AppBar Custom: Tombol kembali dan judul "Histori"
  Widget _buildAppBar(BuildContext context, double screenWidth) {
    return SizedBox(
      height: kToolbarHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Tombol back di kiri
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
          // Judul di tengah
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "Histori",
                style: TextStyle(
                  color: const Color(0xFF017964),
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Profile Greeting: Avatar, greeting, dan username
  Widget _buildProfileGreeting(double screenWidth) {
    final avatarRadius = screenWidth * 0.10; // 10% dari lebar layar
    final greetingStyle = TextStyle(
      fontSize: screenWidth * 0.03,
      fontWeight: FontWeight.normal,
      color: const Color(0xFF017964),
    );
    final usernameStyle = TextStyle(
      fontSize: screenWidth * 0.035,
      fontWeight: FontWeight.bold,
      color: const Color(0xFF017964),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(width: screenWidth * 0.06),
        CircleAvatar(
          radius: avatarRadius,
          backgroundColor: Colors.white.withOpacity(0.2),
          child: Icon(
            Icons.person,
            color: const Color(0xFF017964),
            size: avatarRadius * 0.8,
          ),
        ),
        SizedBox(width: screenWidth * 0.05),
        Expanded(
          child: FutureBuilder<String>(
            future: _futureGreeting,
            builder: (context, snapshot) {
              String greeting;
              if (snapshot.connectionState == ConnectionState.waiting) {
                greeting = '...';
              } else if (snapshot.hasError) {
                greeting = 'Selamat datang';
              } else if (snapshot.hasData) {
                greeting = snapshot.data!;
              } else {
                greeting = 'Selamat datang';
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      greeting,
                      style: greetingStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _userModel?.username ?? 'Pengguna',
                      style: usernameStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  /// Saldo Dompet: Menampilkan informasi saldo pengguna
  Widget _buildWalletBalance(double screenWidth) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: Colors.black,
                size: screenWidth * 0.045,
              ),
              SizedBox(width: screenWidth * 0.02),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Dompet Anda',
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.02),
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Rp 5.000.000',
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget Histori Transaksi (Pengurangan Saldo)
  Widget _buildTransactionPencairan(double screenWidth, double screenHeight) {
    final containerPadding = EdgeInsets.symmetric(
      horizontal: screenWidth * 0.04,
      vertical: screenWidth * 0.035,
    );
    final borderRadius = screenWidth * 0.04;

    return Container(
      width: double.infinity,
      padding: containerPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tanggal
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "20",
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: screenHeight * 0.005),
                Text(
                  "Mei 2024",
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Deskripsi Transaksi
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pencairan",
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: screenHeight * 0.005),
                Text(
                  "BCA 12345678",
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // Nominal
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "-Rp500.000",
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget Insentif (Penambahan Saldo)
  Widget _buildIncentiveTransaction(double screenWidth, double screenHeight) {
    final containerPadding = EdgeInsets.symmetric(
      horizontal: screenWidth * 0.04,
      vertical: screenWidth * 0.035,
    );
    final borderRadius = screenWidth * 0.04;

    return Container(
      width: double.infinity,
      padding: containerPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tanggal
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "21",
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: screenHeight * 0.005),
                Text(
                  "Mei 2024",
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Deskripsi Transaksi
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Insentif",
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: screenHeight * 0.005),
                Text(
                  "Berkas a.n Enzo Fernandez",
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // Nominal
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "+Rp500.000",
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}