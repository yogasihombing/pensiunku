import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pensiunku/model/user_model.dart';
import 'package:pensiunku/repository/user_repository.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';

class EWalletPencairan extends StatefulWidget {
  static const String ROUTE_NAME = '/e-wallet-pencairan';

  @override
  State<EWalletPencairan> createState() => _EWalletPencairanState();
}

class _EWalletPencairanState extends State<EWalletPencairan> {
  UserModel? _userModel;
  late Future<String> _futureGreeting;

  // Variabel state untuk saldo pengguna dan status loading
  String _userBalance = '0'; // Saldo awal, akan diupdate dari API
  bool _isLoadingBalance = false; // Status loading untuk saldo

  // Form key & controllers
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _rekeningController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshData();
    _futureGreeting = _fetchGreeting();
  }

  @override
  void dispose() {
    _rekeningController.dispose();
    _jumlahController.dispose();
    super.dispose();
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
        // PENTING: Panggil _fetchBalance setelah _userModel berhasil diambil
        if (_userModel?.id != null) {
          await _fetchBalance(_userModel!.id.toString());
        }
      } else {
        debugPrint("Error fetching user: ${result.error}");
      }
    }
  }

  /// Mengambil greeting dari API eksternal
  Future<String> _fetchGreeting() async {
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

  /// Handler ketika tombol Submit ditekan
  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final rekening = _rekeningController.text;
      final jumlah = _jumlahController.text;
      debugPrint('Submit pencairan - Rekening: $rekening, Jumlah: $jumlah');

      // TODO: Panggil API pencairan di sini

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permintaan pencairan berhasil dikirim'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  /// PENTING: Fungsi untuk mengambil saldo pengguna dari API
  Future<void> _fetchBalance(String userId) async {
    setState(() {
      _isLoadingBalance = true; // Set status loading true
    });
    try {
      const String url = 'https://api.pensiunku.id/new.php/getBalance';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_user': userId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // PENTING: Akses field 'balance' sesuai dengan respons API
        if (data != null &&
            data['text'] != null &&
            data['text']['balance'] != null) {
          final balanceStr = data['text']['balance'].toString();
          // Format saldo sebagai mata uang Rupiah
          final formatter = NumberFormat.currency(
              locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
          setState(() {
            _userBalance = formatter.format(double.tryParse(balanceStr) ?? 0);
          });
        } else {
          print(
              "Error: Field 'balance' tidak ditemukan dalam response: ${response.body}");
          setState(() {
            _userBalance =
                'Error'; // Tampilkan error jika field tidak ditemukan
          });
        }
      } else {
        throw Exception(
            'Failed to load balance with status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching balance: $e");
      setState(() {
        _userBalance = 'Error'; // Tampilkan error jika ada exception
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingBalance = false; // Set status loading false setelah selesai
        });
      }
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
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.02),
                  _buildAppBar(context, screenWidth),
                  SizedBox(height: screenHeight * 0.02),
                  Center(child: _buildProfileGreeting(screenWidth)),
                  SizedBox(height: screenHeight * 0.02),
                  _buildWalletBalance(screenWidth),
                  SizedBox(height: screenHeight * 0.04),
                  _buildFormSection(screenWidth),
                  SizedBox(height: screenHeight * 0.04),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// AppBar Custom: Back button dan judul
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
                color: const Color(0xFFF017964),
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
                "Pencairan",
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
        SizedBox(width: screenWidth * 0.06),
        CircleAvatar(
          radius: avatarRadius,
          backgroundColor: Colors.white.withOpacity(0.2),
          child: Icon(
            Icons.person,
            color: const Color(0xFFF017964),
            size: avatarRadius,
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
              const Icon(Icons.account_balance_wallet, color: Colors.black),
              SizedBox(width: screenWidth * 0.02),
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
              child:
                  // PENTING: Tampilkan indikator loading atau saldo yang telah diambil
                  _isLoadingBalance
                      ? SizedBox(
                          width: screenWidth * 0.05,
                          height: screenWidth * 0.05,
                          child: CircularProgressIndicator(
                            strokeWidth: screenWidth * 0.005,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.black87),
                          ),
                        )
                      : Text(
                          _userBalance, // Menampilkan saldo dari state
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

  /// Bagian form pencairan: Judul + dua field + tombol Submit
  Widget _buildFormSection(double screenWidth) {
    final fieldRadius = screenWidth * 0.025; // radius untuk OutlineInputBorder
    final contentPadding = EdgeInsets.symmetric(
      horizontal: screenWidth * 0.04,
      vertical: screenWidth * 0.035,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Judul "Rekening Pencairan"
        Padding(
          padding: EdgeInsets.only(
            left: screenWidth * 0.01,
            bottom: screenWidth * 0.03,
          ),
          child: const Text(
            "Rekening Pencairan",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),

        // Container form pencairan
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
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Field pilih rekening (bisa ditingkatkan ke dropdown nantinya)
                TextFormField(
                  controller: _rekeningController,
                  style: TextStyle(fontSize: screenWidth * 0.035),
                  decoration: InputDecoration(
                    labelText: 'Pilih Rekening',
                    labelStyle: TextStyle(fontSize: screenWidth * 0.035),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(fieldRadius),
                    ),
                    contentPadding: contentPadding,
                  ),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Harap pilih rekening'
                      : null,
                ),
                SizedBox(height: screenWidth * 0.04),

                // Field jumlah pencairan
                TextFormField(
                  controller: _jumlahController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: screenWidth * 0.035),
                  decoration: InputDecoration(
                    labelText: 'Jumlah Pencairan',
                    labelStyle: TextStyle(fontSize: screenWidth * 0.035),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(fieldRadius),
                    ),
                    contentPadding: contentPadding,
                    prefixText: 'Rp ',
                    prefixStyle: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.black,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harap masukkan jumlah pencairan';
                    }
                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'Jumlah pencairan hanya boleh angka';
                    }
                    final amount = int.tryParse(value);
                    if (amount != null && amount < 10000) {
                      return 'Jumlah minimal pencairan Rp 10.000';
                    }
                    return null;
                  },
                ),

                SizedBox(height: screenWidth * 0.06),

                // Tombol Submit
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC950),
                      padding: EdgeInsets.symmetric(
                        vertical: screenWidth * 0.04,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    onPressed: _handleSubmit,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Submit',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
