import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pensiunku/model/e_wallet/user_bank_detail_model.dart';
import 'package:pensiunku/model/user_model.dart';
import 'package:pensiunku/repository/user_repository.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/wallet/bank_tujuan/e_wallet_bank_tujuan.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/wallet/pencairan/konfirmasi_pin_e_wallet_screen.dart';
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
  String _userBalance = 'Rp 0'; // Saldo awal, akan diupdate dari API
  bool _isLoadingBalance = false; // Status loading untuk saldo

  // State untuk daftar rekening bank dan rekening yang dipilih
  List<UserBankDetail>? _userBankDetails;
  UserBankDetail? _selectedWithdrawalAccount;
  bool _isLoadingBankDetails = false;

  // Form key & controllers
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _jumlahController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SharedPreferencesUtil().init().then((_) {
      _refreshData(); // Panggil refresh data awal setelah SharedPreferences siap
    });
    _futureGreeting = _fetchGreeting();
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    super.dispose();
  }

  /// Memuat ulang data pengguna (dengan token dari SharedPreferences), saldo, dan rekening bank
  Future<void> _refreshData() async {
    debugPrint('Memulai _refreshData...');
    final prefs = SharedPreferencesUtil().sharedPreferences;
    String? token = prefs.getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    // Untuk tujuan demo/pengujian, set token jika null
    if (token == null || token.isEmpty) {
      token = "valid_token_123";
      await prefs.setString(SharedPreferencesUtil.SP_KEY_TOKEN, token);
      debugPrint('Token diset untuk demo: $token');
    }

    if (token != null && token.isNotEmpty) {
      try {
        final userResult = await UserRepository().getOne(token);
        if (mounted) {
          if (userResult.isSuccess && userResult.data != null) {
            setState(() {
              _userModel = userResult.data;
              debugPrint('User ID: ${_userModel?.id}');
            });
            // PENTING: Panggil _fetchBalance dan _fetchUserBankDetails setelah _userModel berhasil diambil
            if (_userModel?.id != null) {
              await _fetchBalance(_userModel!.id.toString());
              await _fetchUserBankDetails(_userModel!.id.toString(), token);
            }
          } else {
            debugPrint(
                "Error fetching user: ${userResult.error ?? 'Unknown error'}");
          }
        }
      } catch (e) {
        debugPrint("Exception in _refreshData: $e");
      }
    } else {
      debugPrint("Token is null or empty, cannot refresh user data.");
    }
  }

  /// Mengambil greeting dari API eksternal
  Future<String> _fetchGreeting() async {
    const String baseUrl = 'https://api.pensiunku.id/new.php/greeting';
    try {
      final response = await http
          .post(Uri.parse(baseUrl))
          .timeout(const Duration(seconds: 10), onTimeout: () {
        debugPrint('Koneksi timeout saat mengambil greeting.');
        throw TimeoutException('Koneksi timeout');
      });

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception(
            'Failed to load greeting (Status: ${response.statusCode})');
      }
    } on SocketException {
      debugPrint('Tidak ada koneksi internet saat mengambil greeting.');
      throw Exception('Tidak ada koneksi internet');
    } on HttpException {
      debugPrint(
          'Gagal mengambil data dari server (HttpException) saat mengambil greeting.');
      throw Exception('Gagal mengambil data dari server');
    } catch (e) {
      debugPrint('Terjadi kesalahan umum saat mengambil greeting: $e');
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  /// PENTING: Fungsi untuk mengambil saldo pengguna dari API
  Future<void> _fetchBalance(String userId) async {
    if (!mounted) return;
    try {
      const String url = 'https://api.pensiunku.id/new.php/getBalance';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_user': userId}),
      );
      debugPrint(
          'Respons API Get Balance (Status: ${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.contains('One moment, please...') ||
            response.body
                .contains('Access denied by Imunify360 bot-protection') ||
            response.body.trim().startsWith('<!DOCTYPE html>')) {
          throw Exception(
              'Deteksi tantangan keamanan (Cloudflare/Imunify360). Mohon coba lagi.');
        }

        final data = jsonDecode(response.body);
        if (data != null && data['text'] != null) {
          // Periksa jika ada 'balance' atau 'message'
          if (data['text']['balance'] != null) {
            String balanceStr = data['text']['balance'].toString();
            balanceStr = balanceStr
                .replaceAll('Rp ', '')
                .replaceAll('.', '')
                .replaceAll(',', '')
                .trim();

            final formatter = NumberFormat.currency(
                locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
            if (mounted) {
              setState(() {
                _userBalance =
                    formatter.format(double.tryParse(balanceStr) ?? 0);
                debugPrint('Saldo diterima dan diformat: $_userBalance');
              });
            }
          } else if (data['text']['message'] != null &&
              data['text']['message'] == 'Wallet tidak ditemukan!') {
            // Jika wallet tidak ditemukan, set saldo ke Rp 0
            debugPrint("Wallet tidak ditemukan, setting saldo ke Rp 0.");
            if (mounted) {
              setState(() {
                _userBalance = 'Rp 0';
              });
            }
          } else {
            debugPrint(
                "Error: Field 'balance' tidak ditemukan atau response tidak dikenal: ${response.body}");
            if (mounted) {
              setState(() {
                _userBalance = 'Error'; // Atau 'Tidak Tersedia'
              });
            }
          }
        } else {
          debugPrint(
              "Error: Struktur respons 'text' tidak ditemukan: ${response.body}");
          if (mounted) {
            setState(() {
              _userBalance = 'Error';
            });
          }
        }
      } else {
        throw Exception(
            'Failed to load balance with status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Error fetching balance: $e");
      if (mounted) {
        setState(() {
          _userBalance = 'Error';
        });
      }
    } finally {
      if (mounted) {}
    }
  }

  /// Fungsi untuk mengambil detail rekening bank pengguna dari API
  Future<void> _fetchUserBankDetails(String userId, String token) async {
    debugPrint('Memulai _fetchUserBankDetails untuk userId: $userId');
    if (!mounted) return;
    setState(() {
      _isLoadingBankDetails = true;
      _userBankDetails = null; // Clear previous data
      _selectedWithdrawalAccount = null; // Clear selected account
    });

    try {
      const String url = 'https://api.pensiunku.id/new.php/getUserRekening';
      final response = await http
          .post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({'userid': userId}),
      )
          .timeout(const Duration(seconds: 10), onTimeout: () {
        debugPrint('Koneksi timeout saat mengambil detail rekening bank.');
        throw TimeoutException('Koneksi timeout');
      });

      debugPrint(
          'Respons API Get User Rekening (Status: ${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['text'] != null &&
            responseData['text']['data'] is List) {
          List<dynamic> rawData = responseData['text']['data'];
          List<UserBankDetail> fetchedDetails =
              rawData.map((item) => UserBankDetail.fromJson(item)).toList();
          if (mounted) {
            setState(() {
              _userBankDetails = fetchedDetails;
              // Jika ada rekening, set rekening pertama sebagai default terpilih
              if (_userBankDetails!.isNotEmpty) {
                _selectedWithdrawalAccount = _userBankDetails!.first;
              }
              debugPrint(
                  'Detail bank diterima. Jumlah: ${_userBankDetails?.length}');
            });
          }
        } else {
          debugPrint(
              "Error: Field 'text' atau 'data' di dalam 'text' bukan list dalam respons rekening bank: ${response.body}");
          if (mounted) {
            setState(() {
              _userBankDetails = [];
            });
          }
        }
      } else {
        debugPrint(
            'Gagal memuat detail rekening bank dengan status code: ${response.statusCode}');
        if (mounted) {
          setState(() {
            _userBankDetails = [];
          });
        }
      }
    } on SocketException {
      debugPrint(
          'Tidak ada koneksi internet saat mengambil detail rekening bank.');
      if (mounted) {
        setState(() {
          _userBankDetails = [];
        });
      }
    } on HttpException {
      debugPrint(
          'Gagal mengambil data dari server (HttpException) saat mengambil detail rekening bank.');
      if (mounted) {
        setState(() {
          _userBankDetails = [];
        });
      }
    } catch (e) {
      debugPrint(
          'Terjadi kesalahan umum saat mengambil detail rekening bank: $e');
      if (mounted) {
        setState(() {
          _userBankDetails = [];
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingBankDetails = false;
        });
      }
    }
  }

  /// Handler ketika tombol Submit ditekan
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      debugPrint('Validasi form gagal.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap isi semua kolom dengan benar.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedWithdrawalAccount == null) {
      debugPrint('Rekening pencairan belum dipilih.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap pilih rekening pencairan.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_userModel == null || _userModel!.id == null) {
      // Token sudah diperiksa di _refreshData
      debugPrint('Data pengguna tidak tersedia.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Data pengguna tidak lengkap. Harap coba refresh atau login kembali.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Navigasi ke halaman KonfirmasiPinEWalletScreen
    debugPrint('Navigasi ke KonfirmasiPinEWalletScreen untuk verifikasi PIN.');
    final bool? withdrawalSuccess = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KonfirmasiPinEWalletScreen(
          rekeningId: _selectedWithdrawalAccount!.id,
          userId: _userModel!.id.toString(),
          nominal: _jumlahController.text,
          selectedBankDetail: _selectedWithdrawalAccount!,
        ),
      ),
    );

    if (withdrawalSuccess == true) {
      debugPrint('Pencairan berhasil dari KonfirmasiPinEWalletScreen.');
      _jumlahController.clear(); // Bersihkan field jumlah
      _refreshData(); // Refresh saldo dan rekening setelah berhasil
    } else {
      debugPrint(
          'Pencairan dibatalkan atau gagal di KonfirmasiPinEWalletScreen.');
      // Optional: Tampilkan pesan jika dibatalkan/gagal di halaman PIN
    }
  }

  // _executeWithdrawal function is moved to KonfirmasiPinEWalletScreen

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
              decoration: BoxDecoration(
                color: const Color(0xFFFFC950),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(screenWidth *
                      0.08), // Menggunakan screenWidth untuk responsif
                  bottomRight: Radius.circular(screenWidth *
                      0.08), // Menggunakan screenWidth untuk responsif
                ),
              ),
            ),
          ),

          // Konten utama
          SafeArea(
            child: RefreshIndicator(
              // <--- RefreshIndicator di sini
              onRefresh: _refreshData, // Memanggil fungsi refresh data
              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(), // Selalu bisa di-scroll untuk RefreshIndicator
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
            color: const Color(0xFF017964),
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
                greeting = 'Memuat...';
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
            left: screenWidth * 0.06,
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

        Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.only(
              left: screenWidth * 0.03,
              right: screenWidth * 0.03, // Tambahkan padding kanan
              bottom: screenWidth * 0.03,
            ),
            child: Column(
              children: [
                // Field Pilih Rekening (Dropdown)
                _isLoadingBankDetails
                    ? const Center(
                        child: CircularProgressIndicator(
                        color: Color(0xFF017964),
                      ))
                    : DropdownButtonFormField<UserBankDetail>(
                        value: _selectedWithdrawalAccount,
                        hint: const Text('Pilih Rekening Pencairan'),
                        decoration: InputDecoration(
                          labelText: 'Pilih Rekening',
                          labelStyle: TextStyle(fontSize: screenWidth * 0.035),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(fieldRadius),
                          ),
                          contentPadding: contentPadding,
                        ),
                        items: _userBankDetails?.map((UserBankDetail bank) {
                              return DropdownMenuItem<UserBankDetail>(
                                value: bank,
                                child: Text(
                                  '${bank.bankName} - ${bank.id} (${bank.accountHolderName})',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              );
                            }).toList() ??
                            [],
                        onChanged: (UserBankDetail? newValue) {
                          setState(() {
                            _selectedWithdrawalAccount = newValue;
                            debugPrint('Rekening dipilih: $newValue');
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Harap pilih rekening pencairan';
                          }
                          return null;
                        },
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
                    final amount =
                        double.tryParse(value); // Gunakan double.tryParse
                    if (amount != null) {
                      // Hapus format Rupiah dari _userBalance sebelum perbandingan
                      final currentBalanceClean = double.tryParse(_userBalance
                              .replaceAll('Rp ', '')
                              .replaceAll('.', '')
                              .replaceAll(',', '')) ??
                          0.0;
                      if (amount < 10000) {
                        return 'Jumlah minimal pencairan Rp 10.000';
                      }
                      if (amount > currentBalanceClean) {
                        // Perbandingan dengan saldo yang sudah bersih
                        return 'Saldo tidak mencukupi';
                      }
                    }
                    return null;
                  },
                ),

                SizedBox(
                    height: screenWidth * 0.04), // Spasi sebelum tombol Submit

                // Tombol Submit
                Center(
                  child: SizedBox(
                    // width: double.infinity, // Membuat tombol full width
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC950),
                        padding: EdgeInsets.symmetric(
                            // vertical: buttonPaddingVertical, // Gunakan padding vertikal responsif
                            horizontal: screenWidth *
                                0.1), // Sesuaikan horizontal padding untuk mengatur lebar
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      onPressed: _isLoadingBalance || _isLoadingBankDetails
                          ? null
                          : _handleSubmit,
                      child: _isLoadingBalance || _isLoadingBankDetails
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 2,
                              ),
                            )
                          : FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Submit Pencairan',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                    ),
                  ),
                ),

                SizedBox(height: screenWidth * 0.1), // Spasi antar tombol

                // Teks "Rekeningmu belum ada?"
                Align(
                  // Menggunakan Align untuk menengahkan teks
                  alignment: Alignment.center,
                  child: Text(
                    'Rekeningmu belum ada?',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: screenWidth * 0.03,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                SizedBox(
                    height: screenWidth * 0.02), // Sedikit spasi di bawah teks

                // Tombol Tambah Rekening Baru
                Center(
                  child: SizedBox(
                    // width: double.infinity, // Membuat tombol full width
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC950),
                        padding: EdgeInsets.symmetric(
                            // vertical: buttonPaddingVertical, // Gunakan padding vertikal responsif
                            horizontal: screenWidth *
                                0.1), // Sesuaikan horizontal padding untuk mengatur lebar
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      onPressed: () {
                        // Navigasi ke EWalletBankTujuan ketika tombol ini ditekan
                        Navigator.pushNamed(
                          context,
                          EWalletBankTujuan.ROUTE_NAME,
                        ).then((_) {
                          // Panggil refresh data saat kembali dari halaman tambah bank
                          _refreshData();
                        });
                      },
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Tambah Rekening Baru',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),
                // Text(
                //   'Tombol Demo (Hapus di Produksi):',
                //   style: TextStyle(fontWeight: FontWeight.bold),
                // ),
                // SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// // Tombol Demo: Ke Pencairan Diproses Screen
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => PencairanDiprosesScreen(
//                           // Memberikan data dummy yang relevan untuk demo
//                           bankDetail: UserBankDetail(
//                             bankName: 'Bank Demo Proses',
//                             accountNumber: '1122334455', // Nomor rekening dummy
//                             accountHolderName: 'Pengguna Demo Proses',
//                             id: 'dummy_id_proses',
//                           ),
//                           referenceNumber:
//                               'DEMO-PROC-${DateTime.now().millisecondsSinceEpoch}', // Nomor referensi dummy
//                           transactionDate:
//                               DateTime.now(), // Tanggal transaksi saat ini
//                         ),
//                       ),
//                     );
//                   },
//                   // Pastikan child berisi Text widget
//                   child: Text('Demo: Ke Pencairan Diproses'),
//                 ),
//                 SizedBox(height: 8),

//                 // Tombol Demo: Ke Pencairan Berhasil Screen
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => PencairanBerhasilScreen(
//                           transactionDate:
//                               DateTime.now(), // Tanggal transaksi saat ini
//                           referenceNumber:
//                               'DEMO-DONE-${DateTime.now().millisecondsSinceEpoch}', // Nomor referensi dummy
//                           bankDetail: _selectedWithdrawalAccount ??
//                               UserBankDetail(
//                                 // Menggunakan _selectedWithdrawalAccount jika tersedia, atau dummy jika belum ada yang terpilih
//                                 bankName: 'Bank Demo Sukses',
//                                 accountNumber:
//                                     '9876543210', // Nomor rekening dummy
//                                 accountHolderName: 'Pengguna Demo Sukses',
//                                 id: 'dummy_id_sukses',
//                               ),
//                           // Mengambil nominal dari controller, jika null default ke 0.0
//                           amount:
//                               double.tryParse(_jumlahController.text) ?? 0.0,
//                         ),
//                       ),
//                     );
//                   },
//                   // Pastikan child berisi Text widget
//                   child: Text('Demo: Ke Pencairan Berhasil'),
//                 ),
