import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pensiunku/model/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:pensiunku/repository/user_repository.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/wallet/e_wallet_bank_tujuan.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/wallet/e_wallet_histori.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/wallet/e_wallet_info_akun.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/wallet/e_wallet_pencairan.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';

class EWalletScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/e-wallet-screen';
  @override
  State<EWalletScreen> createState() => _EWalletScreenState();
}

class _EWalletScreenState extends State<EWalletScreen> {
  // Model data pengguna (simulasi)
  UserModel? _userModel;
  late Future<String> _futureGreeting;

  // Padding horizontal global untuk keseluruhan tampilan
  final double horizontalPadding = 16.0;

  @override
  void initState() {
    super.initState();
    print('DashboardScreen initialized');
    _refreshData();
    _futureGreeting = fetchGreeting();
  }

  // Fungsi untuk refresh data pengguna
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
      // Menggunakan Stack agar kita dapat meletakkan background di belakang
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
          // Header berwarna di bagian atas (dengan border radius di bawah)
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
          // Menyusun tampilan dengan header tetap dan menu scrollable
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bagian header (tidak discroll)
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding, vertical: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tombol kembali
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Color(0xFFF017964)),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(height: 14),
                      // Widget profil greeting (avatar, greeting, dan username)
                      Center(child: _buildProfileGreeting()),
                      const SizedBox(height: 24),
                      // Card Saldo Dompet
                      _buildWalletCard(),
                    ],
                  ),
                ),
                // Bagian menu (dapat discroll jika overflow)
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        // Baris menu ikon menggunakan Expanded agar tiap item berbagi lebar yang sama
                        Row(
                          children: [
                            Expanded(
                              child: _buildMenuIcon(
                                'assets/pensiunkuplus/e_wallet/pencairan.png',
                                "Pencairan",
                                EWalletPencairan.ROUTE_NAME,
                              ),
                            ),
                            Expanded(
                              child: _buildMenuIcon(
                                'assets/pensiunkuplus/e_wallet/histori.png',
                                "Histori",
                                EWalletHistori.ROUTE_NAME,
                              ),
                            ),
                            Expanded(
                              child: _buildMenuIcon(
                                'assets/pensiunkuplus/e_wallet/bank_tujuan.png',
                                "Bank Tujuan",
                                EWalletBankTujuan.ROUTE_NAME,
                              ),
                            ),
                            Expanded(
                              child: _buildMenuIcon(
                                'assets/pensiunkuplus/e_wallet/info_akun_wallet.png',
                                "Info Akun",
                                EWalletInfoAkun.ROUTE_NAME,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Baris menu box (baris 1)
                        Row(
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
                        const SizedBox(height: 16),
                        // Baris menu box (baris 2)
                        Row(
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
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Widget untuk menampilkan profil greeting (avatar, greeting, dan username).
  /// Teks dibungkus dengan FittedBox dan Flexible untuk menghindari overflow.
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
        // Avatar profil dengan ikon default
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.white.withOpacity(0.3),
          child: const Icon(Icons.person, color: Color(0xFFF017964)),
        ),
        const SizedBox(width: 20),
        // Kolom teks greeting dan username dengan Expanded agar memanfaatkan ruang yang tersedia
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
                    // Menggunakan FittedBox agar teks greeting responsif
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

  /// Widget untuk menampilkan card saldo dompet.
  /// Menggunakan FittedBox dan Flexible pada teks agar ukurannya responsif.
  Widget _buildWalletCard() {
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
          )
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
                child: Text(
                  'Dompet Anda',
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

  /// Widget untuk membuat menu ikon.
  /// Dibungkus dengan Expanded agar masing-masing ikon membagi ruang secara merata.
  Widget _buildMenuIcon(String imagePath, String label, String routeName) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, routeName);
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(7.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Gambar ikon
            Image.asset(
              imagePath,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 8),
            // Teks label ikon, menggunakan Flexible dan FittedBox agar responsif
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget untuk membuat box menu di bagian bawah.
  /// Menampilkan gambar, label, dan amount serta menggunakan FittedBox agar teks tidak overflow.
  Widget _buildBoxMenu(String imagePath, String label, {String amount = 'Rp 5.000.000'}) {
    return Container(
      margin: const EdgeInsets.all(8), // Jarak antar box
      padding: const EdgeInsets.all(8), // Padding internal box
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image.asset(
              imagePath,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                amount,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
