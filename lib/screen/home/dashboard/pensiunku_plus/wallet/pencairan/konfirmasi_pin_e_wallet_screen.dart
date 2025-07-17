import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:pensiunku/model/e_wallet/user_bank_detail_model.dart';
import 'package:pensiunku/model/user_model.dart';
import 'package:pensiunku/repository/user_repository.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/wallet/pencairan/pencairan_diproses.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';

class KonfirmasiPinEWalletScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/konfirmasi-pin-ewallet';

  // Parameter yang diterima dari halaman EWalletPencairan
  final String rekeningId;
  final String userId;
  final String nominal;
  final UserBankDetail
      selectedBankDetail; // TIDAK LAGI OPSIONAL, karena PencairanDiprosesScreen memerlukannya

  const KonfirmasiPinEWalletScreen({
    Key? key,
    required this.rekeningId,
    required this.userId,
    required this.nominal,
    required this.selectedBankDetail, // Pastikan ini selalu diberikan dari EWalletPencairan
  }) : super(key: key);

  @override
  State<KonfirmasiPinEWalletScreen> createState() =>
      _KonfirmasiPinEWalletScreenState();
}

class _KonfirmasiPinEWalletScreenState
    extends State<KonfirmasiPinEWalletScreen> {
  final List<TextEditingController> pinControllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> pinFocusNodes =
      List.generate(6, (index) => FocusNode());
  bool _isLoadingOverlay = false;
  UserModel? _userModel; // Untuk menyimpan data user dari _refreshData

  @override
  void initState() {
    super.initState();
    print('=== Initializing Konfirmasi PIN E-Wallet Screen ===');
    // Inisialisasi SharedPreferences dan panggil _refreshData
    SharedPreferencesUtil().init().then((_) {
      _refreshData();
    });
  }

  @override
  void dispose() {
    for (var controller in pinControllers) {
      controller.dispose();
    }
    for (var node in pinFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _refreshData() async {
    print('=== Memulai refresh data Konfirmasi PIN E-Wallet ===');
    try {
      String? token = SharedPreferencesUtil()
          .sharedPreferences
          .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

      // --- DEBUG PRINT: Tampilkan PIN dari SharedPreferences (HANYA UNTUK DEBUGGING) ---
      String? storedPin = SharedPreferencesUtil()
          .sharedPreferences
          .getString('user_pin_for_debug'); // Asumsi PIN disimpan di sini
      if (storedPin != null) {
        debugPrint('DEBUG: PIN Anda yang tersimpan: $storedPin');
      } else {
        debugPrint('DEBUG: PIN tidak ditemukan di SharedPreferences.');
      }
      // --- END DEBUG PRINT ---

      if (token == null || token.isEmpty) {
        print('Error: Token is null or empty, cannot fetch user data.');
        // Beri tahu user atau arahkan ke login jika token tidak ada
        _showCustomDialog('Autentikasi Gagal',
            'Autentikasi gagal. Harap login kembali.', Colors.red);
        return;
      }

      final userResult = await UserRepository().getOne(token);
      if (userResult.isSuccess && userResult.data != null) {
        setState(() {
          _userModel = userResult.data;
          print('User data received: User ID: ${_userModel?.id}');
        });
      } else {
        print('Error fetching user data: ${userResult.error}');
        _showCustomDialog('Gagal Memuat Data',
            'Gagal memuat data pengguna: ${userResult.error}', Colors.red);
      }
    } catch (e, stackTrace) {
      print('Error in _refreshData (Konfirmasi PIN E-Wallet): $e');
      print('Stack trace: $stackTrace');
      _showCustomDialog('Terjadi Kesalahan',
          'Terjadi kesalahan saat memuat data: $e', Colors.red);
    }
  }

  Future<void> _verifyAndWithdraw(String pin) async {
    if (!mounted) return;
    setState(() {
      _isLoadingOverlay = true;
    });

    try {
      print(
          '=== Memulai proses pengajuan Withdraw (dengan validasi PIN di backend) ===');

      if (_userModel == null || _userModel!.id.toString() != widget.userId) {
        print('Error: User model is null or ID mismatch.');
        _showCustomDialog(
            'Data Tidak Valid', 'Data pengguna tidak valid.', Colors.red);
        return;
      }

      final String? token = SharedPreferencesUtil()
          .sharedPreferences
          .getString(SharedPreferencesUtil.SP_KEY_TOKEN);
      if (token == null || token.isEmpty) {
        print('Error: Token is null or empty.');
        _showCustomDialog('Token Tidak Tersedia',
            'Token autentikasi tidak tersedia.', Colors.red);
        return;
      }

      // LANGSUNG PANGGIL API pengajuanWithdraw
      var withdrawRequestBody = {
        "id_rekening": widget.rekeningId,
        "userid": widget.userId,
        "nominal": widget.nominal,
        "pin": pin, // PIN dikirim langsung ke endpoint withdraw
      };
      print(
          'Request body pengajuanWithdraw: ${jsonEncode(withdrawRequestBody)}');
      var withdrawResponse = await http
          .post(
            Uri.parse('https://api.pensiunku.id/new.php/pengajuanWithdraw'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(withdrawRequestBody),
          )
          .timeout(const Duration(seconds: 15));

      print('pengajuanWithdraw Status Code: ${withdrawResponse.statusCode}');
      print('pengajuanWithdraw Response Body: ${withdrawResponse.body}');

      if (withdrawResponse.statusCode == 200) {
        var withdrawResponseBody = jsonDecode(withdrawResponse.body);
        // Asumsi: API pengajuanWithdraw akan mengembalikan 'success' jika berhasil,
        // atau pesan error yang jelas jika PIN salah/saldo tidak cukup/dll.
        if (withdrawResponseBody['text']['message'] == "success") {
          print('Pengajuan withdraw berhasil!');
          // Navigasi ke PencairanDiprosesScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PencairanDiprosesScreen(
                transactionDate: DateTime.now(), // Waktu transaksi
                referenceNumber:
                    'REF-${DateTime.now().millisecondsSinceEpoch}', // Dummy reference
                bankDetail: widget
                    .selectedBankDetail, // Teruskan detail bank yang dipilih
                nominal: widget.nominal, // Teruskan nominal
              ),
            ),
          );
        } else {
          // Jika API mengembalikan pesan error (misal: "PIN Anda salah", "Saldo tidak mencukupi")
          print(
              'Pengajuan withdraw gagal: ${withdrawResponseBody['text']['message']}');
          _showCustomDialog(
              'Pencairan Gagal',
              'Pencairan gagal: ${withdrawResponseBody['text']['message'] ?? 'Pesan tidak diketahui'}',
              Colors.red);
        }
      } else {
        print(
            'Gagal pengajuan withdraw: Status Code ${withdrawResponse.statusCode}');
        _showCustomDialog('Pencairan Gagal',
            'Gagal mengajukan pencairan. Silakan coba lagi.', Colors.red);
      }
    } on TimeoutException {
      print('Koneksi timeout saat pengajuan withdraw.');
      _showCustomDialog(
          'Koneksi Timeout', 'Koneksi timeout. Silakan coba lagi.', Colors.red);
    } on SocketException {
      print('Tidak ada koneksi internet saat pengajuan withdraw.');
      _showCustomDialog(
          'Tidak Ada Koneksi', 'Tidak ada koneksi internet.', Colors.red);
    } on HttpException {
      print('Gagal berkomunikasi dengan server saat pengajuan withdraw.');
      _showCustomDialog(
          'Server Error', 'Gagal terhubung ke server.', Colors.red);
    } catch (e, stackTrace) {
      print('=== Error Detail di _verifyAndWithdraw ===');
      print('Pesan kesalahan: $e');
      print('Jejak tumpukan: $stackTrace');
      _showCustomDialog(
          'Terjadi Kesalahan', 'Terjadi kesalahan tak terduga: $e', Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingOverlay = false;
        });
      }
    }
  }

  // Perbaikan pada _showCustomDialog
  void _showCustomDialog(String title, String message, Color color,
      [VoidCallback? onOkPressed]) {
    showDialog(
      context: context,
      barrierDismissible: false, // Dialog tidak bisa ditutup dengan tap di luar
      builder: (BuildContext context) {
        return Center(
          child: AlertDialog(
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            title: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            content: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Tutup dialog
                  if (onOkPressed != null) {
                    onOkPressed(); // Jalankan callback jika ada
                  }
                },
                child: const Text('OK', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ambil ukuran layar untuk responsivitas
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    // Responsive values
    final double horizontalPadding = screenWidth * 0.1; // 5% dari lebar layar
    final double verticalPadding = screenHeight * 0.02; // 2% dari tinggi layar
    final double imageHeight = screenHeight * 0.25; // Tinggi gambar responsif
    final double pinFieldHeight =
        screenHeight * 0.06; // Tinggi field PIN responsif
    final double pinHorizontalPadding =
        screenWidth * 0.01; // Padding antar field PIN
    final double pinBorderRadius =
        screenWidth * 0.02; // Radius border field PIN
    final double buttonHeight = screenHeight * 0.06; // Tinggi tombol responsif
    final double buttonPaddingVertical =
        screenHeight * 0.015; // Padding vertikal tombol

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Colors.white,
                  Colors.white,
                  const Color.fromARGB(255, 233, 208, 127),
                ],
                stops: const [0.25, 0.5, 0.75, 1.0],
              ),
            ),
            // SafeArea dan SingleChildScrollView untuk konten utama
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding, vertical: verticalPadding),
                  child: Column(
                    children: [
                      // Tombol kembali (dengan margin responsif)
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: Colors
                                  .transparent), // Warna transparan agar tidak terlihat
                          onPressed: () => Navigator.pop(context, false),
                        ),
                      ),
                      // Gambar Pensiunku logo
                      Image.asset(
                        'assets/pensiunkuplus/pensiunku.png',
                        height: screenHeight * 0.065, // Sesuaikan tinggi logo
                      ),
                      SizedBox(height: screenHeight * 0.05),
                      // Gambar Daftarkan PIN
                      Image.asset(
                        'assets/pensiunkuplus/daftarkan_pin.png', // Sesuaikan dengan aset gambar PIN Anda
                        height: imageHeight,
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      // Judul
                      Text(
                        'Verifikasi', // Mengubah teks menjadi Konfirmasi PIN
                        style: TextStyle(
                          fontSize: screenWidth * 0.06, // Font size responsif
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      // Deskripsi
                      Text(
                        'Masukkan PIN untuk verifikasi pencairan anda', // Mengubah teks deskripsi
                        style: TextStyle(
                          fontSize: screenWidth * 0.03, // Font size responsif
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: screenHeight * 0.04),
                      // PIN input fields
                      SizedBox(
                        width: screenWidth * 0.9, // Lebar kotak PIN responsif
                        child: Form(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(6, (index) {
                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: pinHorizontalPadding),
                                  child: SizedBox(
                                    height: pinFieldHeight,
                                    child: TextFormField(
                                      controller: pinControllers[index],
                                      focusNode: pinFocusNodes[index],
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                              pinBorderRadius),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[200],
                                        counterText: '',
                                      ),
                                      keyboardType: TextInputType.number,
                                      maxLength: 1,
                                      obscureText: true,
                                      obscuringCharacter: '•',
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return '';
                                        }
                                        return null;
                                      },
                                      onChanged: (value) {
                                        // Pindah fokus ke field berikutnya jika digit dimasukkan
                                        if (value.isNotEmpty &&
                                            index < pinControllers.length - 1) {
                                          pinFocusNodes[index + 1]
                                              .requestFocus();
                                        } else if (value.isEmpty && index > 0) {
                                          // Pindah fokus ke field sebelumnya jika digit dihapus
                                          pinFocusNodes[index - 1]
                                              .requestFocus();
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      // Tombol Konfirmasi
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFC950),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  buttonHeight / 2), // Radius responsif
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical:
                                    buttonPaddingVertical, // Gunakan padding vertikal responsif
                                horizontal: screenWidth *
                                    0.1), // Sesuaikan horizontal padding untuk mengatur lebar
                          ),
                          onPressed: _isLoadingOverlay
                              ? null
                              : () async {
                                  String pin = pinControllers
                                      .map((controller) => controller.text)
                                      .join();
                                  if (pin.length == 6) {
                                    await _verifyAndWithdraw(pin);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Harap isi semua field PIN')),
                                    );
                                  }
                                },
                          child: _isLoadingOverlay
                              ? const CircularProgressIndicator(
                                  color: Colors.black)
                              : Text(
                                  'Verifikasi',
                                  style: TextStyle(
                                    fontSize: screenWidth *
                                        0.045, // Font size responsif
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Overlay loading
          if (_isLoadingOverlay)
            Positioned.fill(
              child: ModalBarrier(
                color: Colors.black.withOpacity(0.5),
                dismissible: false,
              ),
            ),
          if (_isLoadingOverlay)
            Center(
              child: Container(
                padding:
                    EdgeInsets.all(screenWidth * 0.05), // Padding responsif
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                      screenWidth * 0.03), // Radius responsif
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        const Color(0xFF017964),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02), // Spasi responsif
                    Text(
                      'Mohon tunggu...',
                      style: TextStyle(
                        color: const Color(0xFF017964),
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.04, // Font size responsif
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
