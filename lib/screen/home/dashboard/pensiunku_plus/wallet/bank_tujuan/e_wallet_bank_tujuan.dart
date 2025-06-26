import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pensiunku/model/e_wallet/user_bank_detail_model.dart';
import 'package:pensiunku/model/user_model.dart';
import 'package:pensiunku/repository/user_repository.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/wallet/bank_tujuan/form_daftar_bank.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';

class EWalletBankTujuan extends StatefulWidget {
  static const String ROUTE_NAME = '/e-wallet-bank-tujuan';
  @override
  State<EWalletBankTujuan> createState() => _EWalletBankTujuanState();
}

class _EWalletBankTujuanState extends State<EWalletBankTujuan> {
  // State untuk data pengguna, saldo, dan daftar rekening bank
  UserModel? _userModel;
  late Future<String> _futureGreeting;
  String _userBalance = 'Rp 0';
  bool _isLoadingBalance = false;
  List<UserBankDetail>? _userBankDetails; // Mengubah menjadi List
  bool _isLoadingBankDetail = false;

  // Screen dimensions - diinisialisasi di didChangeDependencies
  late double screenWidth;
  late double screenHeight;

  @override
  void initState() {
    super.initState();
    debugPrint('EWalletBankTujuan initialized');
    // Pastikan SharedPreferencesUtil diinisialisasi sebelum digunakan
    SharedPreferencesUtil().init().then((_) {
      _refreshData(); // Panggil refresh data awal setelah SharedPreferences siap
    });
    _futureGreeting = fetchGreeting();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Inisialisasi dimensi responsif saat dependensi berubah (misalnya orientasi layar)
    _initializeResponsiveDimensions();
  }

  /// Inisialisasi dimensi responsif berdasarkan ukuran layar
  void _initializeResponsiveDimensions() {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
  }

  /// Fungsi untuk refresh data pengguna, saldo, dan detail bank
  Future<void> _refreshData() async {
    debugPrint('Memulai _refreshData...');
    final prefs = SharedPreferencesUtil().sharedPreferences;
    String? token = prefs.getString(SharedPreferencesUtil.SP_KEY_TOKEN);
    debugPrint('Token dari SP: $token');

    // Untuk tujuan demo/pengujian, set token jika null (Hapus ini di produksi)
    if (token == null || token.isEmpty) {
      token = "valid_token_123";
      await prefs.setString(SharedPreferencesUtil.SP_KEY_TOKEN, token);
      debugPrint('Token disimpan ke SP (demo): $token');
    }

    if (token != null && token.isNotEmpty) {
      try {
        debugPrint('--- HTTP GET Request (User Data) Dijalankan ---');
        // Log URL dan headers untuk debugging
        debugPrint('URL Lengkap: https://pensiunku.id/mobileapi/user');
        debugPrint('Opsi GET (Header dll): {Authorization: $token}');

        final userResult = await UserRepository().getOne(token);
        if (mounted) {
          if (userResult.isSuccess && userResult.data != null) {
            setState(() {
              _userModel = userResult.data;
              debugPrint('--- HTTP GET Response (User Data) Diterima ---');
              debugPrint('URL: https://pensiunku.id/mobileapi/user');
              debugPrint('Status Kode: 200');
              debugPrint('Data Respons: ${_userModel?.toJson()}');
              debugPrint('--- Selesai GET Request (User Data) ---');
              debugPrint(
                  'Data Pengguna Diterima: ${_userModel?.username}, ID: ${_userModel?.id}');
            });
            // Setelah userModel tersedia, panggil fetch saldo dan detail bank
            if (_userModel?.id != null) {
              await _fetchBalance(_userModel!.id.toString());
              await _fetchUserBankDetails(
                  _userModel!.id.toString(), token); // Panggil fungsi baru
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
  Future<String> fetchGreeting() async {
    debugPrint('Memulai fetchGreeting...');
    const String baseUrl = 'https://api.pensiunku.id/new.php/greeting';
    try {
      final response = await http
          .post(Uri.parse(baseUrl))
          .timeout(const Duration(seconds: 10), onTimeout: () {
        debugPrint('Koneksi timeout saat mengambil greeting.');
        throw TimeoutException('Koneksi timeout');
      });

      debugPrint(
          'Respons API Greeting (Status: ${response.statusCode}): ${response.body}');

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

  /// Mengambil saldo pengguna dari API
  Future<void> _fetchBalance(String userId) async {
    debugPrint('Memulai _fetchBalance untuk userId: $userId');
    if (!mounted) return;
    setState(() {
      _isLoadingBalance = true;
    });
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
        final data = jsonDecode(response.body);
        if (data != null &&
            data['text'] != null &&
            data['text']['balance'] != null) {
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
              _userBalance = formatter.format(double.tryParse(balanceStr) ?? 0);
              debugPrint('Saldo diterima dan diformat: $_userBalance');
            });
          }
        } else {
          debugPrint(
              "Error: Field 'balance' tidak ditemukan dalam response: ${response.body}");
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
      if (mounted) {
        setState(() {
          _isLoadingBalance = false;
        });
      }
    }
  }

  /// Fungsi baru untuk mengambil detail rekening bank pengguna dari API
  Future<void> _fetchUserBankDetails(String userId, String token) async {
    debugPrint('Memulai _fetchUserBankDetails untuk userId: $userId');
    if (!mounted) return;
    setState(() {
      _isLoadingBankDetail = true;
      _userBankDetails = null; // Clear previous data to show loading
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
        // Penting: Akses 'data' di dalam 'text' sesuai struktur JSON Anda
        if (responseData['text'] != null &&
            responseData['text'].containsKey('data') &&
            responseData['text']['data'] is List) {
          List<dynamic> rawData = responseData['text']['data'];
          List<UserBankDetail> fetchedDetails =
              rawData.map((item) => UserBankDetail.fromJson(item)).toList();
          if (mounted) {
            setState(() {
              _userBankDetails = fetchedDetails;
              debugPrint(
                  'Detail bank diterima. Jumlah: ${_userBankDetails?.length}');
            });
          }
        } else {
          debugPrint(
              "Error: Field 'text' atau 'data' di dalam 'text' tidak ditemukan atau bukan list dalam respons rekening bank: ${response.body}");
          if (mounted) {
            setState(() {
              _userBankDetails = []; // Set list kosong jika data tidak sesuai
            });
          }
        }
      } else {
        debugPrint(
            'Gagal memuat detail rekening bank dengan status code: ${response.statusCode}');
        if (mounted) {
          setState(() {
            _userBankDetails = []; // Set list kosong pada error API
          });
        }
      }
    } on SocketException {
      debugPrint(
          'Tidak ada koneksi internet saat mengambil detail rekening bank.');
      if (mounted) {
        setState(() {
          _userBankDetails = []; // Set list kosong pada error jaringan
        });
      }
    } on HttpException {
      debugPrint(
          'Gagal mengambil data dari server (HttpException) saat mengambil detail rekening bank.');
      if (mounted) {
        setState(() {
          _userBankDetails = []; // Set list kosong pada error http
        });
      }
    } catch (e) {
      debugPrint(
          'Terjadi kesalahan umum saat mengambil detail rekening bank: $e');
      if (mounted) {
        setState(() {
          _userBankDetails = []; // Set list kosong pada error lainnya
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingBankDetail = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dimensi responsif sudah diinisialisasi di didChangeDependencies
    final double horizontalPadding = screenWidth * 0.04;
    final double cardPadding = screenWidth * 0.04;

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
                  bottomLeft: Radius.circular(
                      screenWidth * 0.08), // Sesuaikan dengan screenWidth
                  bottomRight: Radius.circular(
                      screenWidth * 0.08), // Sesuaikan dengan screenWidth
                ),
              ),
            ),
          ),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _refreshData, // Panggil _refreshData saat direfresh
              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(), // Selalu bisa di-scroll untuk RefreshIndicator
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight * 0.001),
                    _buildAppBar(context, screenHeight, screenWidth),
                    SizedBox(height: screenHeight * 0.02),
                    Center(child: _buildProfileGreeting(screenWidth)),
                    SizedBox(height: screenHeight * 0.02),
                    _buildWalletCard(screenWidth, screenHeight, cardPadding),
                    SizedBox(height: screenHeight * 0.04),
                    _buildBankDetailsList(screenWidth),
                    SizedBox(height: screenHeight * 0.02),
                    _buildAddBank(context, screenWidth),
                    SizedBox(height: screenHeight * 0.02),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// AppBar Custom: Tombol kembali dan judul "Bank Tujuan"
  Widget _buildAppBar(
      BuildContext context, double screenHeight, double screenWidth) {
    return SizedBox(
      height: kToolbarHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
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

  /// Widget Profil dan Ucapan Selamat Datang
  Widget _buildProfileGreeting(double screenWidth) {
    final avatarRadius = screenWidth * 0.10;
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
                debugPrint('Error loading greeting: ${snapshot.error}');
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

  /// Widget Kartu Dompet
  Widget _buildWalletCard(
      double screenWidth, double screenHeight, double cardPadding) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: screenWidth * 0.02,
            offset: Offset(0, screenHeight * 0.005),
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
            ],
          ),
          SizedBox(height: screenHeight * 0.01),
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: _isLoadingBalance
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

  /// Widget untuk menampilkan daftar rekening bank pengguna
  Widget _buildBankDetailsList(double screenWidth) {
    final logoSize = screenWidth * 0.15;

    if (_isLoadingBankDetail) {
      return Center(
        child: CircularProgressIndicator(
          color: const Color(0xFF017964),
          strokeWidth: screenWidth * 0.008,
        ),
      );
    } else if (_userBankDetails != null && _userBankDetails!.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          ListView.builder(
            shrinkWrap:
                true, // Penting agar ListView tidak memakan ruang tak terbatas
            physics:
                const NeverScrollableScrollPhysics(), // Nonaktifkan scroll karena SingleChildScrollView sudah ada di atas
            itemCount: _userBankDetails!.length,
            itemBuilder: (context, index) {
              final bankDetail = _userBankDetails![index];
              return Padding(
                padding: const EdgeInsets.only(
                    bottom: 12.0), // Spasi antar kartu bank
                child: Container(
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
                      // Area logo bank
                      Container(
                        width: logoSize,
                        height: logoSize,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(bankDetail.bankLogoUrl ??
                                // Placeholder image jika URL logo null atau error
                                'https://placehold.co/${logoSize.toInt()}x${logoSize.toInt()}/000000/FFFFFF?text=BANK'),
                            fit: BoxFit.contain,
                            onError: (exception, stackTrace) {
                              debugPrint('Error loading image: $exception');
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      // Detail bank (nama bank, nomor rekening, nama pemilik)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bankDetail.bankName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              "No. Rekening: ${bankDetail.accountNumber}",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Pemilik: ${bankDetail.accountHolderName}",
                              style: const TextStyle(
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
              );
            },
          ),
        ],
      );
    } else {
      // Tampilan jika tidak ada detail bank atau sedang tidak loading
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(screenWidth * 0.04),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                "Belum ada rekening pencairan yang ditambahkan.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.038,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  /// Widget Tombol "Tambah Rekening Baru"
  Widget _buildAddBank(BuildContext context, double screenWidth) {
    return Center(
      child: SizedBox(
        // width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFC950),
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.07,
              vertical: screenWidth * 0.025,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
          onPressed: () async {
            debugPrint('Tombol "Tambah Rekening Baru" ditekan.');
            // Navigasi ke FormDaftarBankScreen dan tunggu hasilnya
            final bool? result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FormDaftarBankScreen(
                  userId: _userModel?.id,
                  token: SharedPreferencesUtil()
                      .sharedPreferences
                      .getString(SharedPreferencesUtil.SP_KEY_TOKEN),
                ),
              ),
            );

            // Jika result adalah true, berarti rekening baru berhasil ditambahkan, refresh data
            if (result == true) {
              debugPrint(
                  'Kembali dari FormDaftarBankScreen dengan sukses, me-refresh detail bank.');
              _refreshData(); // Memanggil _refreshData untuk memuat ulang data bank
            } else if (result == false) {
              debugPrint(
                  'Kembali dari FormDaftarBankScreen tanpa penambahan rekening.');
            }
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
      ),
    );
  }
}
