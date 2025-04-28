import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pensiunku/model/user_model.dart';
import 'package:pensiunku/repository/user_repository.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';

class EWalletInfoAkun extends StatefulWidget {
  static const String ROUTE_NAME = '/e-wallet-info-akun';
  @override
  State<EWalletInfoAkun> createState() => _EWalletInfoAkunState();
}

class _EWalletInfoAkunState extends State<EWalletInfoAkun> {
  // Data pengguna (simulasi)
  UserModel? _userModel;
  late Future<String> _futureGreeting;

  // Padding horizontal global
  final double horizontalPadding = 16.0;

  @override
  void initState() {
    super.initState();
    print('EWalletInfoAkun initialized');
    _refreshData();
    _futureGreeting = fetchGreeting();
  }

  // Fungsi untuk refresh data pengguna dari repository
  Future<void> _refreshData() async {
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);
    if (token != null) {
      UserRepository().getOne(token).then((result) {
        if (result.error == null) {
          setState(() {
            _userModel = result.data;
            print('User ID: ${_userModel?.id}');
          });
        } else {
          print("Error fetching user: ${result.error}");
        }
      });
    }
  }

  // Fungsi untuk mengambil greeting dari API
  Future<String> fetchGreeting() async {
    const String baseUrl = 'https://api.pensiunku.id/new.php/greeting';
    try {
      print('Fetching greeting from: $baseUrl');
      final response = await http.post(Uri.parse(baseUrl)).timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('Koneksi timeout'),
          );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to load greeting');
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
          // Header background (warna kuning dengan border radius di bawah)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.34,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFC950),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
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
                                color: Color(0xFFF017964)),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        // Judul "Info Akun"
                        Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: const Text(
                              "Info Akun",
                              style: TextStyle(
                                color: Color(0xFF017964),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Profile Greeting: Avatar, greeting, dan username
                  Center(child: _buildProfileGreeting()),
                  const SizedBox(height: 24),
                  // Saldo Dompet
                  _buildWalletBalance(),
                  const SizedBox(height: 24),
                  // Konten tambahan (jika ada info akun lainnya, bisa ditambahkan di sini)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget untuk menampilkan Profile Greeting,
  /// yang berisi CircleAvatar, greeting, dan username.
  Widget _buildProfileGreeting() {
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
        // CircleAvatar dengan ikon default
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.white.withOpacity(0.3),
          child: const Icon(Icons.person, color: Color(0xFFF017964)),
        ),
        const SizedBox(width: 20),
        // Kolom teks greeting dan username dengan Expanded agar mengisi ruang yang tersedia
        Expanded(
          child: Container(
            alignment: Alignment.centerLeft,
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
                    const SizedBox(height: 4),
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
        ),
      ],
    );
  }

  /// Widget untuk menampilkan informasi saldo (Dompet Anda)
  Widget _buildWalletBalance() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet, color: Colors.black),
              const SizedBox(width: 8),
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
          const SizedBox(height: 8),
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
}
