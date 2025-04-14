import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pensiunku/model/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:pensiunku/repository/user_repository.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';

class EWalletScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/e-wallet-screen';
  @override
  State<EWalletScreen> createState() => _EWalletScreenState();
}

class _EWalletScreenState extends State<EWalletScreen> {
  // Data pengguna (simulasi)
  UserModel? _userModel;
  late Future<String> _futureGreeting;

  // Variabel untuk mengatur padding horizontal secara global
  final double horizontalPadding = 16.0;

  @override
  void initState() {
    super.initState();
    print('DashboardScreen initialized');
    _refreshData();
    _futureGreeting = fetchGreeting();
  }

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

  Future<String> fetchGreeting() async {
    const String baseUrl = 'https://api.pensiunku.id/new.php/greeting';
    try {
      print('Fetching greeting from: $baseUrl');
      final response = await http.post(Uri.parse(baseUrl)).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Koneksi timeout');
        },
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
          // Container FFC950 di bagian atas
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.34,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFFFC950),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),
          ),
          // Konten utama
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding, vertical: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Color(0xFFF017964)),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(height: 16),
                  // Widget profil: CircleAvatar di atas, greeting & username di bawah (semua terpusat)
                  Center(
                    child: _buildProfileGreeting(),
                  ),
                  SizedBox(height: 24),
                  // Saldo Dompet
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
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
                            Icon(Icons.account_balance_wallet,
                                color: Colors.black),
                            SizedBox(width: 8),
                            Text(
                              'Dompet Anda',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Rp 5.000.000',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  // Menu 1 - Atas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMenuIcon(
                          'assets/pensiunkuplus/e_wallet/pencairan.png',
                          "Pencairan"),
                      _buildMenuIcon(
                          'assets/pensiunkuplus/e_wallet/histori.png',
                          "Histori"),
                      _buildMenuIcon(
                          'assets/pensiunkuplus/e_wallet/bank_tujuan.png',
                          "Bank Tujuan"),
                      _buildMenuIcon(
                          'assets/pensiunkuplus/e_wallet/info_akun_wallet.png',
                          "Info Akun"),
                    ],
                  ),
                  SizedBox(height: 24),
                  // Menu 2 - Bawah
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildBoxMenu(
                          'assets/pensiunkuplus/e_wallet/wallet-01.png',
                          "Pencapaian Bulan ini",
                        ),
                      ),
                      Expanded(
                        child: _buildBoxMenu(
                          'assets/pensiunkuplus/e_wallet/wallet-02.png',
                          "Total Pencairan",
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
// Menu 3 - Bawah tambahan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildBoxMenu(
                          'assets/pensiunkuplus/e_wallet/wallet-03.png',
                          "Pendapatan Terbesar",
                        ),
                      ),
                      Expanded(
                        child: _buildBoxMenu(
                          'assets/pensiunkuplus/e_wallet/wallet-04.png',
                          "Tanggal Bergabung",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk profil greeting (CircleAvatar, greeting & username)
  Widget _buildProfileGreeting() {
    TextStyle greetingStyle = const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: Color(0xFF017964),
    );
    TextStyle usernameStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Color(0xFF017964),
    );

    return Row(
      children: [
        // CircleAvatar
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.white.withOpacity(0.3),
          child: const Icon(Icons.person, color: Color(0xFFF017964)),
        ),
        const SizedBox(width: 20),
        // Container untuk greeting & username yang di-align ke kiri
        Container(
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
                  Text(greeting, style: greetingStyle),
                  const SizedBox(height: 4),
                  Text(_userModel?.username ?? 'Pengguna',
                      style: usernameStyle),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // Widget untuk Menu Icon (atas) dengan Image
  Widget _buildMenuIcon(String imagePath, String label) {
    return Column(
      children: [
        Image.asset(
          imagePath,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // Widget untuk Menu Box (bawah) dengan Image Asset, label, dan jumlah saldo

  Widget _buildBoxMenu(String imagePath, String label,
      {String amount = 'Rp 5.000.000'}) {
    return Container(
      margin: EdgeInsets.all(8), // jarak antar box
      width: 150,
      padding: EdgeInsets.all(8), // jarak di dalam box
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          )
        ],
      ),
      // Hilangkan properti height agar container menyesuaikan tinggi isinya
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tampilkan image asset sebagai ikon
          Image.asset(
            imagePath,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
          // Label di bawah image (rata kiri)
          Text(
            label,
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          // Teks amount ditampilkan rata tengah
          Align(
            alignment: Alignment.center,
            child: Text(
              amount,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
