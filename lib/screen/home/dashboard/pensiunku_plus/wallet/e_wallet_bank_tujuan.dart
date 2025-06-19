import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pensiunku/model/user_model.dart';
import 'package:pensiunku/repository/user_repository.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';

class EWalletBankTujuan extends StatefulWidget {
  static const String ROUTE_NAME = '/e-wallet-bank-tujuan';
  @override
  State<EWalletBankTujuan> createState() => _EWalletBankTujuanState();
}

class _EWalletBankTujuanState extends State<EWalletBankTujuan> {
  UserModel? _userModel;
  late Future<String> _futureGreeting;

  @override
  void initState() {
    super.initState();
    _refreshData();
    _futureGreeting = fetchGreeting();
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
  Future<String> fetchGreeting() async {
    const String baseUrl = 'https://api.pensiunku.id/new.php/greeting';
    try {
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
    final double horizontalPadding = screenWidth * 0.04; // misal 4% dari lebar

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

          // Header background (kuning) dengan ketinggian 34% dari tinggi layar
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
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.02), // 2% dari tinggi layar
                  _buildAppBar(context, screenHeight, screenWidth),
                  SizedBox(height: screenHeight * 0.02), // 2% dari tinggi layar
                  Center(child: _buildProfileGreeting(screenWidth)),
                  SizedBox(height: screenHeight * 0.02), // 2% dari tinggi layar
                  _buildWalletBalance(screenWidth),
                  SizedBox(height: screenHeight * 0.04),
                  _buildBankDetail(screenWidth),
                  SizedBox(height: screenHeight * 0.02),
                  _buildAddBank(screenWidth),
                  SizedBox(height: screenHeight * 0.02),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// AppBar Custom: Back button dan judul
  Widget _buildAppBar(
      BuildContext context, double screenHeight, double screenWidth) {
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
                color: const Color(0xFFF017964),
                size: screenWidth * 0.06, // ukuran ikon relatif
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // Judul di tengah
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: const Text(
                "Bank Tujuan",
                style: TextStyle(
                  color: Color(0xFF017964),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
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
    const TextStyle greetingStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: Color(0xFF017964),
    );
    const TextStyle usernameStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Color(0xFF017964),
    );

    return Row(
      children: [
        // CircleAvatar
        SizedBox(width: screenWidth * 0.06),
        CircleAvatar(
          radius: avatarRadius,
          backgroundColor: Colors.white.withOpacity(0.2),
          child: Icon(
            Icons.person,
            color: const Color(0xFFF017964),
            size: avatarRadius, // ikon seukuran radius
          ),
        ),
        SizedBox(width: screenWidth * 0.05), // 5% dari lebar layar
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
                  SizedBox(height: screenWidth * 0.01), // spasi kecil
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
      padding: EdgeInsets.all(screenWidth * 0.04), // 4% padding
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
              const Icon(Icons.account_balance_wallet, color: Colors.black),
              SizedBox(width: screenWidth * 0.02), // 2% spacing
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: const Text(
                    'Dompet Anda',
                    style: TextStyle(fontSize: 14, color: Colors.black),
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
              child: const Text(
                'Rp 5.000.000',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankDetail(double screenWidth) {
    final logoSize = screenWidth * 0.15; // 15% dari lebar layar

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Judul Rekening Pencairan

        Padding(
          padding: EdgeInsets.only(
              left: screenWidth * 0.01, bottom: screenWidth * 0.03),
          child: const Text(
            "Rekening Pencairan",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        // Box detail rekening
        Container(
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
          child: Row(
            children: [
              // Logo bank
              Container(
                width: logoSize,
                height: logoSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: const DecorationImage(
                    image: AssetImage('assets/bank_logo.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.03), // 3% dari lebar layar
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Bank Capital",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      "No. Rekening: 1234567890",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Pemilik: John Doe",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
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
      ],
    );
  }

  /// Tombol "Tambah Rekening Baru"
  Widget _buildAddBank(double screenWidth) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFC950),
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.08, // 8% padding kiri-kanan
            vertical: screenWidth * 0.035, // 3.5% padding atas-bawah
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        onPressed: () {
          // TODO: Aksi submit dapat ditambahkan di sini
        },
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: const Text(
            'Tambah Rekening Baru',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
