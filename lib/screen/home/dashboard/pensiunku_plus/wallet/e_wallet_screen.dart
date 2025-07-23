import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:intl/intl.dart';
import 'package:pensiunku/model/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:pensiunku/repository/user_repository.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/wallet/bank_tujuan/e_wallet_bank_tujuan.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/wallet/histori/e_wallet_histori.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/wallet/info_wallet/e_wallet_info_akun.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/wallet/pencairan/e_wallet_pencairan.dart';
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

  // Variabel state untuk saldo pengguna dan status loading
  String _userBalance = 'Rp 0'; // Saldo awal, akan diupdate dari API
  bool _isLoadingBalance = false; // Status loading untuk saldo

  // NEW: Variabel state untuk data dari API getBalance (selain saldo)
  String _thisMonthIncome = 'Rp 0';
  String _totalIncome =
      'Rp 0'; // Sesuai konfirmasi: total pendapatan dari insentif
  String _greatestIncome = 'Rp 0';
  String _joinDate = 'N/A'; // Akan diformat menjadi tanggal yang mudah dibaca

  // Screen dimensions
  late double screenWidth;
  late double screenHeight;

  // Responsive padding dan sizing
  late double horizontalPadding;
  late double verticalPadding;
  late double headerHeight;
  late double avatarRadius;
  late double iconSize;
  late double cardPadding;

  // GlobalKey untuk mengukur tinggi Wallet Card
  final GlobalKey _walletCardKey = GlobalKey();
  double _walletCardHeight = 0.0;

  @override
  void initState() {
    super.initState();
    print('EWalletScreen initialized');
    // Inisialisasi data lokal untuk DateFormat
    initializeDateFormatting().then((_) {
      _refreshData(); // Memuat data pengguna dan saldo saat inisialisasi
    });
    _futureGreeting = _fetchGreeting(); // Memuat greeting

    // Tambahkan listener untuk mendapatkan tinggi wallet card setelah render pertama
    // Ini penting agar perhitungan posisi wallet card akurat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getWalletCardHeight();
    });
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

    // Responsive padding
    horizontalPadding = screenWidth * 0.04; // 4% dari lebar layar
    verticalPadding = screenHeight * 0.01; // 1% dari tinggi layar

    // Responsive sizes
    headerHeight = screenHeight * 0.25; // 25% dari tinggi layar
    avatarRadius = screenWidth * 0.08; // 8% dari lebar layar
    iconSize = screenWidth * 0.18; // 18% dari lebar layar
    cardPadding = screenWidth * 0.04; // 4% dari lebar layar
  }

  /// Fungsi untuk mendapatkan tinggi _buildWalletCard setelah dirender
  void _getWalletCardHeight() {
    if (_walletCardKey.currentContext != null) {
      final RenderBox renderBox =
          _walletCardKey.currentContext!.findRenderObject() as RenderBox;
      setState(() {
        _walletCardHeight = renderBox.size.height;
        debugPrint('Wallet Card Height: $_walletCardHeight');
      });
    }
  }

  /// Fungsi untuk refresh data pengguna dan saldo
  Future<void> _refreshData() async {
    try {
      // Pastikan SharedPreferencesUtil diinisialisasi
      await SharedPreferencesUtil().init();

      String? token = SharedPreferencesUtil()
          .sharedPreferences
          .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

      // Untuk tujuan demo, simpan token jika belum ada
      if (token == null || token.isEmpty) {
        token =
            "valid_token_123"; // Contoh token, ganti dengan logika login Anda
        await SharedPreferencesUtil()
            .sharedPreferences
            .setString(SharedPreferencesUtil.SP_KEY_TOKEN, token);
        print('Token disimpan ke SP: $token');
      }

      if (token != null) {
        final result = await UserRepository().getOne(token);
        if (result.error == null) {
          setState(() {
            _userModel = result.data;
            print('User ID: ${_userModel?.id}');
          });
          // PENTING: Panggil _fetchBalance setelah _userModel berhasil diambil
          if (_userModel?.id != null) {
            await _fetchBalance(_userModel!.id.toString());
          }
        } else {
          print("Error fetching user: ${result.error}");
        }
      }
    } catch (e) {
      print("Exception in _refreshData: $e");
    }
  }

  /// Fungsi untuk mengambil greeting dari API
  Future<String> _fetchGreeting() async {
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

  /// PENTING: Fungsi untuk mengambil saldo pengguna dan data lainnya dari API
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

      debugPrint(
          'Respons API Get Balance (Status: ${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data['text'] != null) {
          // Inisialisasi formatter Rupiah
          final formatter = NumberFormat.currency(
              locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

          // Fungsi helper untuk memparsing dan memformat nominal
          String formatAmount(dynamic value) {
            if (value == null) return 'Rp 0';
            String cleanValue = value
                .toString()
                .replaceAll('Rp ', '')
                .replaceAll('.', '')
                .replaceAll(',', '')
                .trim();
            return formatter.format(double.tryParse(cleanValue) ?? 0);
          }

          // Update _userBalance
          String balanceStr = data['text']['balance']?.toString() ?? '0';
          balanceStr = balanceStr
              .replaceAll('Rp ', '')
              .replaceAll('.', '')
              .replaceAll(',', '')
              .trim();

          if (mounted) {
            setState(() {
              _userBalance = formatter.format(double.tryParse(balanceStr) ?? 0);
              debugPrint('Saldo yang diformat dan ditampilkan: $_userBalance');

              // NEW: Update variabel state lainnya
              _thisMonthIncome = formatAmount(data['text']['this_month']);
              _totalIncome = formatAmount(data['text']['total']);
              _greatestIncome = formatAmount(data['text']['greatest']);

              // Format tanggal bergabung
              String? joinDateRaw = data['text']['join_date'];
              if (joinDateRaw != null && joinDateRaw.isNotEmpty) {
                try {
                  // Perbaikan di sini: gunakan format 'dd MMMM yyyy' untuk parsing karena API mengembalikan tahun
                  DateTime parsedJoinDate =
                      DateFormat('dd MMMM yyyy', 'en_US').parse(joinDateRaw);
                  _joinDate = DateFormat('dd MMMM yyyy', 'id_ID')
                      .format(parsedJoinDate); // Format ke bahasa Indonesia
                } catch (e) {
                  debugPrint('Error parsing join_date: $e');
                  _joinDate =
                      joinDateRaw; // Gunakan raw string jika gagal parse
                }
              } else {
                _joinDate = 'N/A';
              }

              // --- Debug Prints untuk verifikasi data ---
              debugPrint('--- Verifikasi Data API getBalance ---');
              debugPrint('Raw API Response (text): ${data['text']}');
              debugPrint(
                  'Pencapaian Bulan ini (this_month): ${data['text']['this_month']} -> Formatted: $_thisMonthIncome');
              debugPrint(
                  'Total Pendapatan (total): ${data['text']['total']} -> Formatted: $_totalIncome');
              debugPrint(
                  'Pendapatan Terbesar (greatest): ${data['text']['greatest']} -> Formatted: $_greatestIncome');
              debugPrint(
                  'Tanggal Bergabung (join_date): ${data['text']['join_date']} -> Formatted: $_joinDate');
              debugPrint('--- End Verifikasi Data ---');
            });
          }
        } else {
          debugPrint(
              "Error: Struktur respons 'text' tidak ditemukan dalam response: ${response.body}");
          if (mounted) {
            setState(() {
              _userBalance = 'Error';
              _thisMonthIncome = 'Error';
              _totalIncome = 'Error';
              _greatestIncome = 'Error';
              _joinDate = 'Error';
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
          _thisMonthIncome = 'Error';
          _totalIncome = 'Error';
          _greatestIncome = 'Error';
          _joinDate = 'Error';
        });
      }
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
    // Pastikan dimensi responsif diinisialisasi
    _initializeResponsiveDimensions();

    // Hitung posisi top untuk _buildWalletCard
    // Posisi top = tinggi header - (setengah tinggi wallet card)
    final double walletCardTopPosition = headerHeight -
        (_walletCardHeight / 2) +
        (screenHeight * 0.05); // Diubah dari 0.02 menjadi 0.05

    return Scaffold(
      body: Stack(
        children: [
          // 1. Background gradient penuh layar
          _buildBackgroundGradient(),

          // 2. Header berwarna di bagian atas (fixed)
          _buildColoredHeader(),

          // 3. Konten header tetap (tombol kembali, profil greeting)
          // Ditempatkan di sini agar tidak ikut scroll
          Positioned(
            top: MediaQuery.of(context).padding.top +
                screenHeight * 0.01, // Padding dari atas layar + sedikit ruang
            left: horizontalPadding,
            right: horizontalPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBackButton(),
                SizedBox(height: screenHeight * 0.02),
                Center(child: _buildProfileGreeting()),
              ],
            ),
          ),

          // 4. Wallet Card yang di-positioning secara absolut (fixed, overlapping)
          Positioned(
            top: walletCardTopPosition,
            left: horizontalPadding,
            right: horizontalPadding,
            child: _buildWalletCard(),
          ),

          // 5. Konten utama yang bisa di-scroll (menu icons dan menu boxes)
          // Dimulai setelah area header dan setengah wallet card
          Positioned.fill(
            // Menggunakan Positioned.fill untuk mengisi sisa ruang
            top: headerHeight +
                (_walletCardHeight /
                    2), // Mulai di bawah header + setengah wallet card + sedikit ruang
            child: RefreshIndicator(
              onRefresh: _refreshData, // Memanggil fungsi refresh data
              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(), // Memastikan scroll selalu aktif
                child: Padding(
                  // Padding internal untuk konten yang di-scroll
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    children: [
                      SizedBox(
                          height: screenHeight *
                              0.06), // Jarak antara wallet card dan baris ikon pertama
                      _buildMenuIcons(),
                      SizedBox(height: screenHeight * 0.03),
                      _buildMenuBoxesFirstRow(),
                      SizedBox(height: screenHeight * 0.02),
                      _buildMenuBoxesSecondRow(),
                      SizedBox(
                          height: screenHeight * 0.02), // Extra space at bottom
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget untuk background gradient
  Widget _buildBackgroundGradient() {
    return Container(
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
    );
  }

  /// Widget untuk header berwarna di bagian atas
  Widget _buildColoredHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 0.30 * screenHeight, // 30% dari tinggi layar
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFC950),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(screenWidth * 0.08),
            bottomRight: Radius.circular(screenWidth * 0.08),
          ),
        ),
      ),
    );
  }

  /// Widget untuk tombol kembali
  Widget _buildBackButton() {
    return IconButton(
      icon: Icon(
        Icons.arrow_back,
        color: const Color(0xFF017964),
        size: screenWidth * 0.06,
      ),
      onPressed: () => Navigator.pop(context),
    );
  }

  /// Widget untuk menampilkan profil greeting (avatar, greeting, dan username)
  Widget _buildProfileGreeting() {
    final TextStyle greetingStyle = TextStyle(
      fontSize: screenWidth * 0.03,
      fontWeight: FontWeight.normal,
      color: const Color(0xFF017964),
    );

    final TextStyle usernameStyle = TextStyle(
      fontSize: screenWidth * 0.035,
      fontWeight: FontWeight.bold,
      color: const Color(0xFF017964),
    );

    return Row(
      children: [
        CircleAvatar(
          radius: avatarRadius,
          backgroundColor: Colors.white.withOpacity(0.3),
          child: Icon(
            Icons.person,
            color: const Color(0xFF017964),
            size: avatarRadius * 0.8,
          ),
        ),
        SizedBox(width: screenWidth * 0.05),
        Expanded(
          child: Container(
            alignment: Alignment.centerLeft,
            child: FutureBuilder<String>(
              future: _futureGreeting,
              builder: (context, snapshot) {
                String greeting = _getGreetingText(snapshot);

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
                    SizedBox(height: screenHeight * 0.005),
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

  /// Helper method untuk mendapatkan teks greeting
  String _getGreetingText(AsyncSnapshot<String> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return 'Memuat...';
    } else if (snapshot.hasError) {
      return 'Selamat datang';
    } else if (snapshot.hasData) {
      return snapshot.data!;
    } else {
      return 'Selamat datang';
    }
  }

  /// PENTING: Widget untuk menampilkan card saldo dompet dengan data API
  Widget _buildWalletCard() {
    return Container(
      key: _walletCardKey, // Tambahkan GlobalKey di sini
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
                          textAlign: TextAlign
                              .center, // Tambahkan ini jika ingin teks saldo juga center
                        ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget untuk baris menu ikon
  Widget _buildMenuIcons() {
    final List<Map<String, String>> menuItems = [
      {
        'image': 'assets/pensiunkuplus/e_wallet/pencairan.png',
        'label': 'Pencairan',
        'route': EWalletPencairan.ROUTE_NAME,
      },
      {
        'image': 'assets/pensiunkuplus/e_wallet/histori.png',
        'label': 'Histori',
        'route': EWalletHistori.ROUTE_NAME,
      },
      {
        'image': 'assets/pensiunkuplus/e_wallet/bank_tujuan.png',
        'label': 'Bank Tujuan',
        'route': EWalletBankTujuan.ROUTE_NAME,
      },
      {
        'image': 'assets/pensiunkuplus/e_wallet/info_akun_wallet.png',
        'label': 'Panduan',
        'route': EWalletInfoAkun.ROUTE_NAME,
      },
    ];

    return Row(
      children: menuItems
          .map((item) => Expanded(
                child: _buildMenuIcon(
                  item['image']!,
                  item['label']!,
                  item['route']!,
                ),
              ))
          .toList(),
    );
  }

  /// Widget untuk baris pertama menu box
  Widget _buildMenuBoxesFirstRow() {
    return Row(
      children: [
        Expanded(
          child: _buildBoxMenu(
            'assets/pensiunkuplus/e_wallet/wallet-01.png',
            "Pencapaian Bulan ini",
            value: _thisMonthIncome, // Data dinamis
          ),
        ),
        Expanded(
          child: _buildBoxMenu(
            'assets/pensiunkuplus/e_wallet/wallet-02.png',
            "Total Pencairan", // Mengganti "Total Pencairan" menjadi "Total Pendapatan"
            value: _totalIncome, // Data dinamis
          ),
        ),
      ],
    );
  }

  /// Widget untuk baris kedua menu box
  Widget _buildMenuBoxesSecondRow() {
    return Row(
      children: [
        Expanded(
          child: _buildBoxMenu(
            'assets/pensiunkuplus/e_wallet/wallet-03.png',
            "Pendapatan Terbesar",
            value: _greatestIncome, // Data dinamis
          ),
        ),
        Expanded(
          child: _buildBoxMenu(
            'assets/pensiunkuplus/e_wallet/wallet-04.png',
            "Tanggal Bergabung",
            value: _joinDate, // Data dinamis
          ),
        ),
      ],
    );
  }

  /// Widget untuk membuat menu ikon
  Widget _buildMenuIcon(String imagePath, String label, String routeName) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, routeName),
      borderRadius: BorderRadius.circular(screenWidth * 0.04),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.02),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              imagePath,
              width: iconSize,
              height: iconSize,
              fit: BoxFit.cover,
            ),
            SizedBox(height: screenHeight * 0.01),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    fontWeight: FontWeight.w500,
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
  }

  /// Widget untuk membuat box menu di bagian bawah
  Widget _buildBoxMenu(
    String imagePath,
    String label, {
    required String value, // Mengubah menjadi required dan dynamic
  }) {
    return Container(
      margin: EdgeInsets.all(screenWidth * 0.02),
      padding: EdgeInsets.all(screenWidth * 0.02),
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image.asset(
              imagePath,
              width: screenWidth * 0.15,
              height: screenWidth * 0.15,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          // Mengubah alignment untuk label agar di tengah
          Center(
            // Wrap FittedBox with Center
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                textAlign: TextAlign.center, // Tambahkan TextAlign.center
                style: TextStyle(
                  fontSize: screenWidth * 0.03,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value, // Menampilkan nilai yang diterima
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
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
}
