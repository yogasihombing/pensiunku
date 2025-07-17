import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pensiunku/model/e_wallet/transaction_history_model.dart';
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
  String _userBalance = 'Rp 0'; // State untuk menyimpan saldo
  bool _isLoadingBalance = false; // State untuk indikator loading saldo
  List<TransactionHistory>?
      _transactionHistory; // State untuk menyimpan histori transaksi
  bool _isLoadingHistory = false; // State untuk indikator loading histori

  // Screen dimensions - diinisialisasi di didChangeDependencies
  late double screenWidth;
  late double screenHeight;

  // Responsive padding dan sizing - diinisialisasi di didChangeDependencies
  late double horizontalPadding;
  late double verticalPadding;
  late double headerHeight;
  late double avatarRadius;
  late double iconSize; // Menggunakan ini untuk ukuran ikon di menu bawah
  late double cardPadding;

  @override
  void initState() {
    super.initState();
    debugPrint('EWalletHistori initialized');
    // Pastikan SharedPreferencesUtil diinisialisasi sebelum digunakan
    SharedPreferencesUtil().init().then((_) {
      _refreshData();
    });
    _futureGreeting = _fetchGreeting();
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

    horizontalPadding = screenWidth * 0.04;
    verticalPadding = screenHeight * 0.015;

    headerHeight = screenHeight * 0.28; // Header background
    avatarRadius = screenWidth * 0.10;
    iconSize = screenWidth * 0.18;
    cardPadding = screenWidth * 0.04;
  }

  /// Fungsi untuk refresh data pengguna, saldo, dan histori
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
          // Check mounted before setState
          if (userResult.isSuccess && userResult.data != null) {
            setState(() {
              _userModel = userResult.data;
              debugPrint('User ID: ${_userModel?.id}');
            });
            // Panggil fetch saldo dan histori setelah userModel tersedia
            if (_userModel?.id != null) {
              await _fetchBalance(_userModel!.id.toString());
              await _fetchTransactionHistory(_userModel!.id.toString(),
                  token); // Panggil fungsi histori transaksi
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
      debugPrint('Fetching greeting dari: $baseUrl');
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

  /// Fungsi untuk mengambil histori transaksi (Pencairan dan Insentif) dari API
  Future<void> _fetchTransactionHistory(String userId, String token) async {
    if (!mounted) return;
    setState(() {
      _isLoadingHistory = true;
      _transactionHistory = null; // Clear previous history
    });

    List<TransactionHistory> fetchedHistory = [];

    // Fetch history from the single API endpoint
    const String historyUrl =
        'https://api.pensiunku.id/new.php/getRiwayatWithdraw';
    try {
      debugPrint(
          'Fetching transaction history from: $historyUrl for user ID: $userId');
      final response = await http
          .post(
        Uri.parse(historyUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({'userid': userId}),
      )
          .timeout(const Duration(seconds: 10), onTimeout: () {
        debugPrint('Koneksi timeout saat mengambil riwayat transaksi.');
        throw TimeoutException('Koneksi timeout');
      });

      debugPrint(
          'Respons API Riwayat Transaksi (Status: ${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        // KOREKSI UTAMA DI SINI: Akses 'data' di dalam 'text'
        if (responseData['text'] != null &&
            responseData['text']['data'] is List) {
          List<dynamic> rawData =
              responseData['text']['data']; // Akses yang benar
          for (var item in rawData) {
            // Asumsi: TransactionHistory.fromJson sekarang akan menentukan tipe transaksi dari data JSON itu sendiri
            fetchedHistory.add(TransactionHistory.fromJson(item));
          }
        } else {
          debugPrint(
              "Error: Field 'text' atau 'data' di dalam 'text' bukan list dalam respons riwayat: ${response.body}");
        }
      } else {
        debugPrint(
            'Gagal memuat riwayat transaksi dengan status code: ${response.statusCode}');
      }
    } on SocketException {
      debugPrint(
          'Tidak ada koneksi internet saat mengambil riwayat transaksi.');
    } on HttpException {
      debugPrint(
          'Gagal mengambil data dari server (HttpException) saat mengambil riwayat transaksi.');
    } catch (e) {
      debugPrint('Terjadi kesalahan umum saat mengambil riwayat transaksi: $e');
    }

    // Sort history by date, newest first
    fetchedHistory.sort((a, b) => b.date.compareTo(a.date));

    if (mounted) {
      setState(() {
        _transactionHistory = fetchedHistory;
        _isLoadingHistory = false;
        debugPrint(
            'Histori transaksi berhasil dimuat. Jumlah: ${_transactionHistory?.length}');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dimensi responsif sudah diinisialisasi di didChangeDependencies
    // _initializeResponsiveDimensions(); // Tidak perlu panggil di build lagi

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
              onRefresh: _refreshData, // Memanggil fungsi refresh data
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bagian Header (tidak di-scroll)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: verticalPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: screenHeight * 0.001),
                          _buildAppBar(context, screenWidth),
                          SizedBox(height: screenHeight * 0.02),
                          Center(child: _buildProfileGreeting(screenWidth)),
                          SizedBox(height: screenHeight * 0.03),
                          _buildWalletBalance(
                              screenWidth), // Menampilkan saldo dari state
                        ],
                      ),
                    ),

                    // Bagian Konten (scrollable): Histori Transaksi
                    SizedBox(height: screenHeight * 0.03),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: _buildTransactionHistoryList(
                          screenWidth), // Menggunakan list histori
                    ),
                    SizedBox(
                        height: screenHeight * 0.03), // Padding di bagian bawah
                  ],
                ),
              ),
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

  /// Saldo Dompet: Menampilkan informasi saldo pengguna dari API
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

  /// Widget untuk menampilkan daftar histori transaksi (Pencairan dan Insentif)
  Widget _buildTransactionHistoryList(double screenWidth) {
    if (_isLoadingHistory) {
      return Center(
        child: CircularProgressIndicator(
          color: const Color(0xFF017964),
          strokeWidth: screenWidth * 0.008,
        ),
      );
    } else if (_transactionHistory != null && _transactionHistory!.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: screenWidth * 0.03),
            child: const Text(
              "Histori Transaksi",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _transactionHistory!.length,
            itemBuilder: (context, index) {
              final transaction = _transactionHistory![index];
              Color amountColor;
              String
                  amountPrefix; // This variable is not used but kept for clarity if future changes require it.

              if (transaction.type == TransactionType.pencairan) {
                amountColor = Colors.red;
                amountPrefix = '-';
              } else if (transaction.type == TransactionType.insentif) {
                amountColor = Colors.green;
                amountPrefix = '+';
              } else {
                amountColor = Colors.black;
                amountPrefix = '';
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenWidth * 0.035,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(screenWidth * 0.04),
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
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transaction.formattedDay,
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.005),
                            Text(
                              transaction.formattedMonthYear,
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Mengubah ini untuk menampilkan tipe transaksi
                            Text(
                              transaction.displayTypeName, // Tampilkan "Pencairan" atau "Insentif"
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: screenHeight * 0.005),
                            // Menampilkan deskripsi asli (Rekening BCA...) sebagai detail
                            Text(
                              transaction.description, // Menampilkan detail rekening bank
                              style: TextStyle(
                                fontSize: screenWidth * 0.025,
                                color: Colors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            transaction.formattedAmount,
                            style: TextStyle(
                              fontSize: screenWidth * 0.030,
                              fontWeight: FontWeight.bold,
                              color: amountColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
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
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: screenWidth * 0.03),
            child: const Text(
              "Histori Transaksi",
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
                "Belum ada histori transaksi.",
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
}

