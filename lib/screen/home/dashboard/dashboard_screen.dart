import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:pensiunku/model/article_model.dart';
import 'package:pensiunku/model/event_model.dart';
import 'package:pensiunku/model/forum_model.dart';
import 'package:pensiunku/model/submission_model.dart';
import 'package:pensiunku/model/user_model.dart';
import 'package:pensiunku/repository/article_repository.dart';
import 'package:pensiunku/repository/result_model.dart';
import 'package:pensiunku/repository/user_repository.dart';
import 'package:pensiunku/screen/article/article_screen.dart';
import 'package:pensiunku/screen/home/account/account_screen.dart';
import 'package:pensiunku/screen/home/dashboard/ajukan/pengajuan_orang_lain_screen.dart';
import 'package:pensiunku/screen/home/dashboard/article_list.dart';
import 'package:pensiunku/screen/home/dashboard/event/event_screen.dart';
import 'package:pensiunku/screen/home/dashboard/forum/forum_screen.dart';
import 'package:pensiunku/screen/home/dashboard/halopensiun/halopensiun_screen.dart';
import 'package:pensiunku/screen/home/dashboard/icon_menu.dart';
import 'package:pensiunku/screen/home/dashboard/ajukan/pengajuan_anda_screen.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/aktifkan_pensiunku_plus_screen.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/daftarkan_pin_screen.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/konfirmasi_pin_screen.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/ktp/prepare_ktp_screen.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/member_reject_screen.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/member_waiting_screen.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/selfie/prepare_selfie_screen.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/wallet/e_wallet_screen.dart';
import 'package:pensiunku/screen/home/dashboard/simulasi/simulasi_cepat_screen.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:pensiunku/widget/chip_tab.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:pensiunku/widget/dialog_helper_contoh.dart';

// Kelas utama DashboardScreen dengan StatefulWidget agar memiliki state yang dapat berubah
class DashboardScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/dashboard_screen';
  // Properti untuk fungsi callback dan parameter lain yang digunakan oleh widget ini
  final void Function(BuildContext)
      onApplySubmission; // Callback saat pengajuan dilakukan
  final void Function(int index)
      onChangeBottomNavIndex; // Callback untuk mengubah indeks navigasi bawah
  final ScrollController scrollController; // Mengontrol scroll di layar
  final int? walkthroughIndex; // Indeks untuk walkthrough (opsional)

  const DashboardScreen({
    Key? key,
    required this.onApplySubmission,
    required this.onChangeBottomNavIndex,
    required this.scrollController,
    this.walkthroughIndex,
  }) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Variabel untuk menyimpan indeks artikel dan event saat ini
  int _currentArticleIndex = 0;
  int _currenEventIndex = 0;

  // Future untuk mendapatkan data artikel dan event secara asinkron
  late Future<ResultModel<List<ArticleCategoryModel>>>
      _futureDataArticleCategories;
  late List<ArticleCategoryModel> _articleCategories = [];
  Future<ResultModel<List<ForumModel>>>? _futureData;
  late Future<ResultModel<List<EventModel>>> _futureDataEventModel;
  late List<EventModel> _EventModel = [];
  late Future<String> _futureGreeting;
  UserModel? _userModel; // Model pengguna (opsional)
  late Future<ResultModel<UserModel>> _future;
  // Variabel untuk menyimpan hasil cek member (dari API)
  Future<int>? _futureMemberStatus;

  bool _isLoadingOverlay = false; // Variabel baru untuk loading overlay
  bool _isActivated = false; // Menambahkan variabel aktifasi
  bool _isInDevelopment = true; // Atur ke true untuk mengunci fitur
  // Variabel untuk menandai loading saat pengecekan API
  bool _isLoadingCheckMemberBalanceCard = false;
  bool _isLoadingCheckMemberActionButton = false;

  // Controller untuk input teks
  TextEditingController namaController = TextEditingController();

  final dataKey = new GlobalKey(); // Key global untuk widget tertentu
  final double articleCarouselHeight = 150.0; // Tinggi carousel artikel
  final double eventCarouselHeight = 200.0;

  final List<String> simulationFormTypeTitle = [
    'KREDIT PRA-PENSIUN',
    'KREDIT PENSIUN',
    'KREDIT PLATINUM',
  ];

  // Fungsi initState untuk inisialisasi data saat widget pertama kali dibangun
  @override
  void initState() {
    super.initState();
    print('DashboardScreen initialized'); // Cetak saat widget diinisialisasi
    _isLoadingOverlay = true;
    _refreshData(); // Memuat data awal
    // Panggil fetchGreeting dan nonaktifkan overlay setelah selesai
    _futureGreeting = fetchGreeting().whenComplete(() {
      if (mounted) {
        setState(() {
          _isLoadingOverlay = false;
        });
      }
    });
  }

  // Fungsi untuk memuat data user dan data lain seperti sebelumnya
  Future<void> _refreshData() async {
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);
    if (token != null) {
      // Memuat data user
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

      _futureDataArticleCategories =
          ArticleRepository().getAllCategories().then((value) {
        if (value.error != null) {
          showDialog(
              context: context,
              builder: (_) => AlertDialog(
                    content: Text(value.error.toString(),
                        style: const TextStyle(color: Colors.white)),
                    backgroundColor: Colors.greenAccent,
                    elevation: 24.0,
                  ));
        } else {
          setState(() {
            _articleCategories = value.data!;
          });
        }
        return value;
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
        // Langsung return response.body karena sudah berupa string greeting
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

  Future<int> cekMember(String id) async {
    const String url = 'https://api.pensiunku.id/new.php/cekMember';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_user': id}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Mencari field 'status' di dalam objek 'text'
      if (data != null &&
          data['text'] != null &&
          data['text']['status'] != null) {
        final statusStr = data['text']['status'].toString();
        final status = int.tryParse(statusStr);
        if (status != null) {
          return status;
        } else {
          throw Exception(
              "Nilai status '$statusStr' tidak dapat dikonversi ke int");
        }
      } else {
        print(
            "Error: Field 'status' tidak ditemukan dalam response: ${response.body}");
        throw Exception("Field 'status' tidak ditemukan atau null");
      }
    } else {
      throw Exception('Failed to load member status');
    }
  }

  void _handleCheckMemberAndNavigateFromBalanceCard(
      BuildContext context) async {
    if (_userModel == null || _userModel!.id == null) {
      print("Error: User tidak terautentikasi atau ID tidak tersedia");
      return;
    }

    // Set status loading
    if (mounted) {
      setState(() {
        _isLoadingOverlay = true;
      });
    }

    try {
      int status = await cekMember(_userModel!.id.toString());
      print("Status member (Balance Card): $status");

      final submission = SubmissionModel(
        id: _userModel!.id,
        produk: 'Produk Default',
        name: _userModel!.username ?? 'Nama Default',
        phone: _userModel!.phone,
        birthDate: DateTime.now(),
        salary: 0,
        tenor: 0,
        plafond: 0,
        bankName: 'Bank Default',
      );

      // Sembunyikan overlay loading sebelum navigasi
      if (mounted) {
        setState(() {
          _isLoadingOverlay = false;
        });
      }

      // Navigasi setelah loading disembunyikan
      Widget nextScreen =
          _decideNextScreen(status, submission, isFromBalanceCard: true);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => nextScreen));
    } catch (error) {
      print("Error (Balance Card): $error");
      // Sembunyikan loading saat terjadi error
      if (mounted) {
        setState(() {
          _isLoadingOverlay = false;
        });
      }
    }
  }

  void _handleCheckMemberAndNavigateFromActionButton(
      BuildContext context) async {
    if (_userModel == null || _userModel!.id == null) {
      print("Error: User tidak terautentikasi atau ID tidak tersedia");
      return;
    }
    if (mounted) {
      setState(() {
        _isLoadingOverlay = true;
      });
    }

    try {
      int status = await cekMember(_userModel!.id.toString());
      print("Status member (Action Button): $status");

      final submission = SubmissionModel(
        id: _userModel!.id,
        produk: 'Produk Default',
        name: _userModel!.username ?? 'Nama Default',
        phone: _userModel!.phone,
        birthDate: DateTime.now(),
        salary: 0,
        tenor: 0,
        plafond: 0,
        bankName: 'Bank Default',
      );
      // Sembunyikan overlay loading sebelum navigasi
      if (mounted) {
        setState(() {
          _isLoadingOverlay = false;
        });
      }

      // Panggil dengan parameter tambahan isFromBalanceCard = false (default)
      Widget nextScreen = _decideNextScreen(status, submission);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => nextScreen));
    } catch (error) {
      print("Error (Action Button): $error");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingOverlay = false;
        });
      }
    }
  }

  Widget _decideNextScreen(int status, SubmissionModel submission,
      {bool isFromBalanceCard = false}) {
    switch (status) {
      case 0:
        return AktifkanPensiunkuPlusScreen();
      case 1:
        return PrepareKtpScreen(
          onSuccess: (ctx) {
            print("PrepareKtpScreen onSuccess callback dipanggil");
          },
          submissionModel: submission,
        );
      case 2:
        return DaftarkanPinPensiunkuPlusScreen();
      case 3:
        return MemberWaitingScreen();
      case 4:
        // Gunakan parameter isFromBalanceCard untuk menentukan screen tujuan
        return isFromBalanceCard ? EWalletScreen() : PengajuanOrangLainScreen();
      case 5:
        return MemberRejectScreen();
      default:
        print("Error: Status member tidak dikenal: $status");
        return AktifkanPensiunkuPlusScreen(); // fallback
    }
  }

  final List<String> programList = [
    'Pra-Pensiun',
    'Pensiun',
    'Platinum',
  ];

  final List<String> imageList = [
    'assets/application_screen/SLIDER-01.png',
    'assets/application_screen/SLIDER-02.png',
    'assets/application_screen/SLIDER-03.png',
  ];
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        // Wrap everything in a Stack
        children: [
          Container(
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
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                child: RefreshIndicator(
                  onRefresh: _refreshData,
                  child: SingleChildScrollView(
                    controller: widget.scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: _buildHeader(),
                        ),
                        const SizedBox(height: 1),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: _buildGreeting(),
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: _buildBalanceCard(),
                        ),
                        const SizedBox(height: 12),

                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        //   child: _buildDialogHelper(context),
                        // ),
                        // const SizedBox(height: 12),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: _buildSimulasiPensiunku(context),
                        ),
                        const SizedBox(height: 12),

                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        //   child: _buildWallet(context),
                        // ),
                        // const SizedBox(height: 12),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        //   child: _buildBottomSectionTitle(),
                        // ),
                        // const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: _buildActionButtons(context),
                        ),
                        const SizedBox(height: 16),
                        // Full screen widgets without padding
                        _buildHeaderImage(),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: _buildMenuFeatures(),
                        ),
                        const SizedBox(height: 16),
                        _buildCarouselSlider(),
                        const SizedBox(height: 16),
                        _buildArticleFeatures(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Tampilkan overlay loading bila _isLoadingOverlay true
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
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF017964),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Mohon tunggu...',
                      style: TextStyle(
                        color: Color(0xFF017964),
                        fontWeight: FontWeight.bold,
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

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.only(left: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            'assets/logo_pensiunku.png',
            height: 42,
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => Navigator.of(context)
                .push(
              MaterialPageRoute(
                builder: (context) => AccountScreen(
                  onChangeBottomNavIndex: (int index) {},
                ),
              ),
            )
                .then((_) {
              // Fungsi yang dipanggil saat kembali dari halaman AccountScreen
              _refreshData(); // Perbarui data di halaman utama
            }),
            color: Colors.black54,
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    TextStyle greetingStyle = const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.normal, // Gaya normal untuk teks greeting
      color: Color(0Xff017964),
    );

    TextStyle boldStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold, // Gaya bold untuk nama pengguna
      color: Color(0Xff017964),
    );

    String userName = _userModel?.username?.split(' ').first ?? 'Pengguna';

    Widget buildGreetingText(String greeting) {
      return RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$greeting, ', // Teks greeting dengan gaya normal
              style: greetingStyle,
            ),
            TextSpan(
              text: userName, // Nama pengguna dengan gaya bold
              style: boldStyle,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<String>(
            future: _futureGreeting, // Pakai yang sudah fix di initState
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return buildGreetingText('Selamat Datang');
              } else if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return buildGreetingText('Selamat datang');
                } else if (snapshot.hasData) {
                  return buildGreetingText(snapshot.data!);
                }
              }
              return buildGreetingText('Selamat datang');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16), // Berikan batasan padding
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 1,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_outlined,
                  color: Colors.black),
              const SizedBox(width: 8),
              const Text(
                'Dompet Anda',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              const Text(
                'Rp 0',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _isLoadingCheckMemberBalanceCard
              ? Center(
                  child: CircularProgressIndicator()) // Menampilkan loading
              : ElevatedButton(
                  onPressed: () {
                    _handleCheckMemberAndNavigateFromBalanceCard(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC950),
                    minimumSize: const Size(double.infinity, 22),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    shadowColor: Colors.grey
                        .withOpacity(0.5), // Tambahkan shadowColor di sini
                    elevation: 5, // Atur elevation untuk menampilkan shadow
                  ),
                  child: RichText(
                    text: TextSpan(
                      text: 'Aktifkan ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.green[900],
                      ),
                      children: [
                        TextSpan(
                          text: 'Pensiunku+',
                          style: TextStyle(
                            fontWeight: FontWeight
                                .bold, // Bold hanya untuk "Pensiunku+"
                          ),
                        ),
                        TextSpan(
                          text: ' Sekarang',
                          style: TextStyle(
                            fontWeight: FontWeight
                                .normal, // Normal untuk bagian lainnya
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

  // Widget _buildDialogHelper(BuildContext context) {
  //   return GestureDetector(
  //     onTap: () {
  //       // Navigasi ke EWalletScreen
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(builder: (context) => DialoghelperContoh()),
  //       );
  //     },
  //     child: Container(
  //       width: double.infinity, // Menyamakan lebar dengan _buildBalanceCard
  //       decoration: BoxDecoration(
  //         color: const Color(0xFF017964), // Latar hijau tua
  //         borderRadius: BorderRadius.circular(24), // Radius sudut kontainer
  //       ),
  //       child: Padding(
  //         padding: const EdgeInsets.symmetric(
  //           vertical: 8, // Padding atas-bawah
  //           horizontal: 16, // Padding kiri-kanan
  //         ),
  //         child: const Center(
  //           // Menengahkan teks secara horizontal dan vertikal
  //           child: Text(
  //             'Dialog Helper Contoh',
  //             style: TextStyle(
  //               fontSize: 11,
  //               fontWeight: FontWeight.bold,
  //               color: Colors.white, // Warna teks putih
  //             ),
  //             textAlign: TextAlign.center, // Teks rata tengah horizontal
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildSimulasiPensiunku(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigasi ke SimulasiCepatScreen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SimulasiCepatScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color:
              const Color(0xFFFFC950), // Warna default bila gambar gagal load
          borderRadius: BorderRadius.circular(10),
          image: const DecorationImage(
            image: AssetImage('assets/dashboard_screen/simulasi-cepat.png'),
            fit: BoxFit.cover, // Menyesuaikan gambar agar menutupi container
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 24,
            horizontal: 16,
          ),
          child: const Center(
            child: Text(
              'Simulasi Cepat',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWallet(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigasi ke EWalletScreen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EWalletScreen()),
        );
      },
      child: Container(
        width: double.infinity, // Menyamakan lebar dengan _buildBalanceCard
        decoration: BoxDecoration(
          color: const Color(0xFF017964), // Latar hijau tua
          borderRadius: BorderRadius.circular(24), // Radius sudut kontainer
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8, // Padding atas-bawah
            horizontal: 16, // Padding kiri-kanan
          ),
          child: const Center(
            // Menengahkan teks secara horizontal dan vertikal
            child: Text(
              'Cek Progress E-Wallet Pensiunku+',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Warna teks putih
              ),
              textAlign: TextAlign.center, // Teks rata tengah horizontal
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildBottomSectionTitle() {
  //   return Container(
  //     width: double.infinity, // Menyamakan lebar dengan _buildBalanceCard
  //     decoration: BoxDecoration(
  //       color: Color.fromARGB(255, 0, 0, 0), // Latar hijau tua
  //       borderRadius: BorderRadius.circular(24), // Radius sudut kontainer
  //     ),
  //     child: Padding(
  //       padding: const EdgeInsets.symmetric(
  //         vertical: 8, // Padding atas-bawah
  //         horizontal: 16, // Padding kiri-kanan
  //       ),
  //       child: const Center(
  //         // Menengahkan teks secara horizontal dan vertikal
  //         child: Text(
  //           'BUTUH UANG UNTUK MASA PENSIUNMU?',
  //           style: TextStyle(
  //             fontSize: 11,
  //             fontWeight: FontWeight.bold,
  //             color: Colors.white, // Warna teks putih
  //           ),
  //           textAlign: TextAlign.center, // Teks rata tengah horizontal
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildActionButtons(BuildContext context) {
    Widget _buildButton(
        String iconPath, Widget textWidget, VoidCallback onPressed,
        {Color backgroundColor = Colors.white,
        Color shadowColor = Colors.transparent}) {
      final mediaQuery = MediaQuery.of(context);
      final double imageSize = mediaQuery.size.width * 0.14;
      final double paddingHorizontal = mediaQuery.size.width * 0.03;
      final double paddingVertical = mediaQuery.size.height * 0.01;
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.symmetric(
              horizontal: paddingHorizontal, vertical: paddingVertical),
          shadowColor: shadowColor,
          elevation: shadowColor == Colors.transparent ? 0 : 5,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(iconPath, width: imageSize, height: imageSize),
            SizedBox(width: mediaQuery.size.width * 0.02),
            Flexible(child: textWidget),
          ],
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Tombol Ajukan Pinjaman Sekarang (tanpa cek status)
        Expanded(
          child: _buildButton(
            'assets/dashboard_screen/pengajuanAnda.png',
            RichText(
              textAlign: TextAlign.start,
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Ajukan\n',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: 'Pinjaman Sekarang',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => PengajuanAndaScreen()),
              );
            },
            shadowColor: Colors.grey.withOpacity(0.5),
          ),
        ),
        const SizedBox(width: 10),
        // Tombol Ajukan Mitra Pensiunku+ (dengan cek status)
        Expanded(
          child: _isLoadingCheckMemberActionButton
              ? Center(child: CircularProgressIndicator())
              : _buildButton(
                  'assets/dashboard_screen/mitra.png',
                  RichText(
                    textAlign: TextAlign.start,
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Ajukan Mitra\n',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: 'Pensiunku+',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  () {
                    _handleCheckMemberAndNavigateFromActionButton(context);
                  },
                  shadowColor: Colors.grey.withOpacity(0.5),
                ),
        ),
      ],
    );
  }

  Widget _buildHeaderImage() {
    final List<String> images = [
      'assets/dashboard_screen/image_1.png',
      'assets/dashboard_screen/image_2.png',
      'assets/dashboard_screen/image_3.png'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 30.0, bottom: 8.0),
          child: Text(
            'Ada yang baru nih!',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          height: 175,
          child: CarouselSlider(
            options: CarouselOptions(
              height: 175,
              enlargeCenterPage: true,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              viewportFraction: 0.96,
              aspectRatio: 16 / 9,
              reverse: true,
            ),
            items: images.map((imagePath) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: AssetImage(imagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconMenu(
                    image: "assets/icon/icon_event.png",
                    title: "Events",
                    routeNamed: EventScreen.ROUTE_NAME,
                    useBox: false,
                  ),
                  IconMenu(
                    image: "assets/icon/icon_artikel.png",
                    title: "Artikel",
                    routeNamed: ArticleScreen.ROUTE_NAME,
                    arguments: ArticleScreenArguments(
                        articleCategories: _articleCategories),
                    useBox: false,
                  ),
                  IconMenu(
                    image: "assets/icon/icon_halo_pensiun.png",
                    title: "Halo Pensiun",
                    routeNamed: HalopensiunScreen.ROUTE_NAME,
                    useBox: false,
                  ),
                  IconMenu(
                    image: "assets/icon/icon_forum.png",
                    title: "Forum",
                    routeNamed: ForumScreen.ROUTE_NAME,
                    useBox: false,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCarouselSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 30.0, bottom: 8.0),
          child: Text(
            'Produk',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 0.0), // Padding di sisi kiri dan kanan
          child: CarouselSlider.builder(
            options: CarouselOptions(
              height: 250,
              autoPlay: true,
              enlargeCenterPage: true,
              aspectRatio: 1.0,
              autoPlayCurve: Curves.fastOutSlowIn,
              enableInfiniteScroll: true,
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              viewportFraction: 0.6,
            ),
            itemCount: programList.length,
            itemBuilder: (BuildContext context, int index, int realIndex) {
              return Container(
                margin: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13.0),
                  image: DecorationImage(
                    image: AssetImage(imageList[index]),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 20,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          programList[index],
                          style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            shadows: [
                              Shadow(
                                blurRadius: 5.0,
                                color: Colors.black54,
                                offset: Offset(2.0, 2.0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<List<ArticleCategoryModel>> _getArticleCategories() async {
    try {
      final result = await _futureDataArticleCategories;
      if (result.data != null && result.data!.isNotEmpty) {
        return result.data!;
      } else {
        throw Exception(result.error ?? 'Data artikel kosong.');
      }
    } catch (e) {
      debugPrint('Error loading article categories: ${e.toString()}');
      throw Exception('Gagal memuat kategori artikel.');
    }
  }

  Widget _buildArticleFeatures() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 30.0, bottom: 15.0),
            child: Text(
              'Artikel',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          FutureBuilder<List<ArticleCategoryModel>>(
            future: _getArticleCategories(),
            builder: (context, snapshot) {
              // Handle loading state
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              // Handle error state
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              // Handle empty state
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Tidak ada data artikel tersedia.',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              // Handle successful data state
              final data = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: data.map((category) {
                        final index = data.indexOf(category);
                        return ChipTab(
                          text: category.name,
                          isActive: _currentArticleIndex == index,
                          onTap: () {
                            setState(() {
                              _currentArticleIndex = index;
                            });
                          },
                          backgroundColor: const Color(0xFFFEC842),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      double carouselHeight =
                          constraints.maxWidth * 0.6; // 40% dari lebar layar
                      return SizedBox(
                        height: carouselHeight,
                        child: _currentArticleIndex >= 0 &&
                                _currentArticleIndex < data.length
                            ? ArticleList(
                                articleCategory: data[_currentArticleIndex],
                                carouselHeight: carouselHeight,
                              )
                            : const Center(
                                child: Text(
                                  'Tidak ada artikel untuk kategori ini.',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _showUnderDevelopmentDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            backgroundColor: Colors
                .transparent, // Make the AlertDialog background transparent
            insetPadding: EdgeInsets.symmetric(horizontal: 15),
            content: Container(
              decoration: BoxDecoration(
                color: Color(0XFFF017964), // Set the background color to green
                borderRadius: BorderRadius.circular(15),
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Untuk mengakses Fitur ini Anda diwajibkan untuk Bergabung menjadi mitra pensiunku+ !',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors
                          .white, // Set the text color to white for better contrast
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Color(0xFF017964),
                      backgroundColor:
                          Colors.white, // Set the text color to green
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AktifkanPensiunkuPlusScreen(),
                        ),
                      );
                    },
                    child: Text('Aktifkan Pensiunku+'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}



// // Body layar dengan RefreshIndicator untuk refresh manual
//       body: RefreshIndicator(
//         onRefresh: _refreshData, // Fungsi refresh data
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               SizedBox(height: 24),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   Column(
//                     children: [
//                       GestureDetector(
//                         onTap: () {
//                           Navigator.of(context).push(MaterialPageRoute(
//                             builder: (context) => PengajuanAndaScreen(),
//                           ));
//                         },
//                         child: Container(
//                           width: 150,
//                           height: 50,
//                           decoration: BoxDecoration(
//                             borderRadius:
//                                 BorderRadius.all(Radius.circular(12.0)),
//                             color: Color(0xFF017964),
//                           ),
//                           child: Center(
//                             child: Text(
//                               'Ajukan Diri Sendiri',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 5),
//                       Text(
//                         '', // Tambahkan teks di sinis
//                       ),
//                     ],
//                   ),
//                   Column(
//                     children: [
//                       GestureDetector(
//                         onTap: () {
//                           Navigator.of(context).push(MaterialPageRoute(
//                             builder: (context) => PengajuanOrangLainScreen(),
//                           ));
//                         },
//                         child: Container(
//                           width: 150,
//                           height: 50,
//                           decoration: BoxDecoration(
//                             borderRadius:
//                                 BorderRadius.all(Radius.circular(12.0)),
//                             color: Color(0xFF017964),
//                           ),
//                           child: Center(
//                             child: Text(
//                               'Ajukan Orang Lain',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 5),
//                       Text(
//                         '', // Tambahkan teks di sinis
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               // Gambar header
//               Container(
//                 width: double.infinity,
//                 margin: EdgeInsets.all(2),
//                 padding: EdgeInsets.all(8),
//                 child: Image.asset(
//                   'assets/dashboard_screen/image_1.png', // Gambar header
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               // Fitur Menu
//               Container(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Padding(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 5.0,
//                         vertical: 9.0,
//                       ),
//                       child: Column(
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceAround,
//                             children: [
//                               IconMenu(
//                                 image: "assets/icon/icon_event.png",
//                                 title: "Events",
//                                 routeNamed: EventScreen.ROUTE_NAME,
//                               ),
//                               IconMenu(
//                                 image: "assets/icon/icon_artikel.png",
//                                 title: "Artikel",
//                                 routeNamed: ArticleScreen.ROUTE_NAME,
//                                 arguments: ArticleScreenArguments(
//                                     articleCategories: _articleCategories),
//                               ),
//                               IconMenu(
//                                 image: "assets/icon/icon_halo_pensiun.png",
//                                 title: "Halo Pensiun",
//                                 routeNamed: HalopensiunScreen.ROUTE_NAME,
//                               ),
//                               IconMenu(
//                                 image: "assets/icon/icon_forum.png",
//                                 title: "Forum",
//                                 routeNamed: ForumScreen.ROUTE_NAME,
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 19),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment
//                     .start, // Untuk memastikan semua elemen diatur ke kiri
//                 children: [
//                   Padding(
//                     padding: EdgeInsets.zero,
//                     child: Text(
//                       'Produk Kami',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xFF017964),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               // Carousel Slider
//               CarouselSlider.builder(
//                 options: CarouselOptions(
//                   height: 135,
//                   autoPlay: true,
//                   enlargeCenterPage: true,
//                   aspectRatio: 1.0,
//                   autoPlayCurve: Curves.fastOutSlowIn,
//                   enableInfiniteScroll: true,
//                   autoPlayAnimationDuration: Duration(milliseconds: 800),
//                   viewportFraction: 0.6,
//                 ),
//                 itemCount: programList.length,
//                 itemBuilder: (BuildContext context, int index, int realIndex) {
//                   return Container(
//                     margin: EdgeInsets.all(5.0),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(13.0),
//                       image: DecorationImage(
//                         image: AssetImage(imageList[index]),
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                     child: Center(
//                       child: Text(
//                         programList[index],
//                         style: TextStyle(
//                           fontSize: 20.0,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),

// // Kelas utama DashboardScreen dengan StatefulWidget agar memiliki state yang dapat berubah
// class DashboardScreen extends StatefulWidget {
//   // Properti untuk fungsi callback dan parameter lain yang digunakan oleh widget ini
//   final void Function(BuildContext)
//       onApplySubmission; // Callback saat pengajuan dilakukan
//   final void Function(int index)
//       onChangeBottomNavIndex; // Callback untuk mengubah indeks navigasi bawah
//   final ScrollController scrollController; // Mengontrol scroll di layar
//   final int? walkthroughIndex; // Indeks untuk walkthrough (opsional)

// // Constructor dengan parameter yang diperlukan
//   const DashboardScreen({
//     Key? key,
//     required this.onApplySubmission,
//     required this.onChangeBottomNavIndex,
//     required this.scrollController,
//     this.walkthroughIndex,
//   }) : super(key: key); // Memanggil constructor parent

//   // Membuat state untuk DashboardScreen
//   @override
//   _DashboardScreenState createState() => _DashboardScreenState();
// }

// // State dari DashboardScreen
// class _DashboardScreenState extends State<DashboardScreen> {
//   // Variabel untuk menyimpan indeks artikel dan event saat ini
//   int _currentArticleIndex = 0;
//   int _currenEventIndex = 0;

//   // Future untuk mendapatkan data artikel dan event secara asinkron
//   late Future<ResultModel<List<ArticleCategoryModel>>>
//       _futureDataArticleCategories;
//   late List<ArticleCategoryModel> _articleCategories = [];

//   late Future<ResultModel<List<EventModel>>> _futureDataEventModel;
//   late List<EventModel> _EventModel = [];
//   bool _isLoading = false; // Menandai apakah data sedang dimuat
//   UserModel? _userModel; // Model pengguna (opsional)

//   final dataKey = new GlobalKey(); // Key global untuk widget tertentu
//   final double articleCarouselHeight = 200.0; // Tinggi carousel artikel

//   // Daftar tipe simulasi kredit
//   final List<String> simulationFormTypeTitle = [
//     'KREDIT PRA-PENSIUN',
//     'KREDIT PENSIUN',
//     'KREDIT PLATINUM',
//   ];

//   // Fungsi initState untuk inisialisasi data saat widget pertama kali dibangun
//   @override
//   void initState() {
//     super.initState();
//     _refreshData(); // Memuat data awal
//   }

//   // Fungsi untuk memuat ulang data
//   Future<void> _refreshData() async {
//     String? token = SharedPreferencesUtil().sharedPreferences.getString(
//         SharedPreferencesUtil.SP_KEY_TOKEN); // Mendapatkan token pengguna

//     UserRepository().getOne(token!);

// // Memuat kategori artikel dan menangani error
//     _futureDataArticleCategories =
//         ArticleRepository().getAllCategories().then((value) {
//       if (value.error != null) {
//         showDialog(
//             context: context,
//             builder: (_) => AlertDialog(
//                   content: Text(value.error.toString(),
//                       style: TextStyle(
//                           color: Colors.white)), // Menampilkan pesan error
//                   backgroundColor: Colors.greenAccent,
//                   elevation: 24.0,
//                 ));
//       } else {
//         setState(() {
//           _articleCategories = value.data!; // Memperbarui kategori artikel
//           print(value);
//         });
//       }
//       return value;
//     });
//   }

// // Daftar nama program dan gambar untuk carousel
//   final List<String> programList = [
//     'Pra-Pensiun',
//     'Pensiun',
//     'Platinum',
//   ];

//   final List<String> imageList = [
//     'assets/application_screen/SLIDER-01.png',
//     'assets/application_screen/SLIDER-02.png',
//     'assets/application_screen/SLIDER-03.png',
//   ];

// // Fungsi build untuk menggambar UI
//   @override
//   Widget build(BuildContext context) {
//     ThemeData theme = Theme.of(context); // Tema aplikasi

//     // Widget Dimensions
//     Size screenSize = MediaQuery.of(context).size;

//     double articleCardSize = screenSize.width * 0.45; // Ukuran kartu artikel
//     double articleCarouselHeight =
//         articleCardSize + 70; // Tinggi carousel artikel

//     // Scaffold sebagai struktur dasar layar
//     return Scaffold(
//       appBar: AppBar(
//         // Bar atas dengan logo dan tombol notifikasi
//         title: SizedBox(
//           height: AppBar().preferredSize.height * 0.4,
//           child: Image.asset('assets/logo_name_white.png'),
//         ),
//         actions: [
//           IconButton(
//             tooltip: 'Notifikasi', // Tooltip untuk notifikasi
//             onPressed: () {
//               Navigator.of(context)
//                   .pushNamed(
//                 NotificationScreen.ROUTE_NAME,
//                 arguments: NotificationScreenArguments(
//                   currentIndex: 0,
//                 ),
//               )
//                   .then((newIndex) {
//                 _refreshData(); // Refresh data saat kembali dari notifikasi
//                 if (newIndex is int) {
//                   widget.onChangeBottomNavIndex(
//                       newIndex); // Update navigasi bawah
//                 }
//               });
//             },
//             icon: NotificationCounter(), // Ikon notifikasi dengan penghitung
//           ),
//         ],
//       ),
//       // Body layar dengan RefreshIndicator untuk refresh manual
//       body: RefreshIndicator(
//         onRefresh: _refreshData, // Fungsi refresh data
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               SizedBox(height: 5),
//               // Gambar header
//               Container(
//                 width: double.infinity,
//                 margin: EdgeInsets.all(2),
//                 padding: EdgeInsets.all(8),
//                 child: Image.asset(
//                   'assets/dashboard_screen/image_1.png', // Gambar header
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               // Fitur Menu
//               Container(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.only(left: 18.0),
//                       child: Text(
//                         'Fitur',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFF017964),
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 5.0,
//                         vertical: 9.0,
//                       ),
//                       child: Column(
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceAround,
//                             children: [
//                               IconMenu(
//                                 image: "assets/icon/icon_event.png",
//                                 title: "Events",
//                                 routeNamed: EventScreen.ROUTE_NAME,
//                               ),
//                               IconMenu(
//                                 image: "assets/icon/icon_artikel.png",
//                                 title: "Artikel",
//                                 routeNamed: ArticleScreen.ROUTE_NAME,
//                                 arguments: ArticleScreenArguments(
//                                     articleCategories: _articleCategories),
//                               ),
//                               IconMenu(
//                                 image: "assets/icon/icon_halo_pensiun.png",
//                                 title: "Halo Pensiun",
//                                 routeNamed: HalopensiunScreen.ROUTE_NAME,
//                               ),
//                               IconMenu(
//                                 image: "assets/icon/icon_forum.png",
//                                 title: "Forum",
//                                 routeNamed: ForumScreen.ROUTE_NAME,
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 19),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceAround,
//                             children: [
//                               Column(
//                                 children: [
//                                   GestureDetector(
//                                     onTap: () {
//                                       Navigator.of(context)
//                                           .push(MaterialPageRoute(
//                                         builder: (context) =>
//                                             PengajuanAndaScreen(),
//                                       ));
//                                     },
//                                     child: Container(
//                                       width: 150,
//                                       height: 50,
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.all(
//                                             Radius.circular(12.0)),
//                                         color: Color(0xFFFFAE58),
//                                       ),
//                                       child: Center(
//                                         child: Text(
//                                           'Ajukan Diri Sendiri',
//                                           style: TextStyle(
//                                             color: Colors.white,
//                                             fontSize: 15,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   SizedBox(height: 5),
//                                   Text(
//                                     '', // Tambahkan teks di sinis
//                                   ),
//                                 ],
//                               ),
//                               Column(
//                                 children: [
//                                   GestureDetector(
//                                     onTap: () {
//                                       Navigator.of(context)
//                                           .push(MaterialPageRoute(
//                                         builder: (context) =>
//                                             PengajuanOrangLainScreen(),
//                                       ));
//                                     },
//                                     child: Container(
//                                       width: 150,
//                                       height: 50,
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.all(
//                                             Radius.circular(12.0)),
//                                         color: Color(0xFFFFAE58),
//                                       ),
//                                       child: Center(
//                                         child: Text(
//                                           'Ajukan Orang Lain',
//                                           style: TextStyle(
//                                             color: Colors.white,
//                                             fontSize: 15,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   SizedBox(height: 5),
//                                   Text(
//                                     '', // Tambahkan teks di sinis
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               // Carousel Slider
//               CarouselSlider.builder(
//                 options: CarouselOptions(
//                   height: 135,
//                   autoPlay: true,
//                   enlargeCenterPage: true,
//                   aspectRatio: 1.0,
//                   autoPlayCurve: Curves.fastOutSlowIn,
//                   enableInfiniteScroll: true,
//                   autoPlayAnimationDuration: Duration(milliseconds: 800),
//                   viewportFraction: 0.6,
//                 ),
//                 itemCount: programList.length,
//                 itemBuilder: (BuildContext context, int index, int realIndex) {
//                   return Container(
//                     margin: EdgeInsets.all(5.0),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(13.0),
//                       image: DecorationImage(
//                         image: AssetImage(imageList[index]),
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                     child: Center(
//                       child: Text(
//                         programList[index],
//                         style: TextStyle(
//                           fontSize: 20.0,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 32.0,
//                   vertical: 16.0,
//                 ),
//                 child: Row(
//                   children: [
//                     SizedBox(
//                       height: 28,
//                       width: 28,
//                       child: Image.asset(
//                           'assets/dashboard_screen/icon_article.png'),
//                     ),
//                     SizedBox(width: 12.0),
//                     Expanded(
//                       child: Text(
//                         'Artikel',
//                         style: theme.textTheme.subtitle1?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               FutureBuilder(
//                 future: _futureDataArticleCategories,
//                 builder: (BuildContext context,
//                     AsyncSnapshot<ResultModel<List<ArticleCategoryModel>>>
//                         snapshot) {
//                   if (snapshot.hasData) {
//                     if (snapshot.data?.data?.isNotEmpty == true) {
//                       List<ArticleCategoryModel> data = snapshot.data!.data!;
//                       return Column(
//                         children: [
//                           Container(
//                             height: 28.0,
//                             child: ListView(
//                               scrollDirection: Axis.horizontal,
//                               children: [
//                                 SizedBox(width: 24.0),
//                                 ...data
//                                     .asMap()
//                                     .map((index, articleCategory) {
//                                       return MapEntry(
//                                         index,
//                                         ChipTab(
//                                           text: articleCategory.name,
//                                           isActive:
//                                               _currentArticleIndex == index,
//                                           onTap: () {
//                                             setState(() {
//                                               _currentArticleIndex = index;
//                                             });
//                                           },
//                                         ),
//                                       );
//                                     })
//                                     .values
//                                     .toList(),
//                                 SizedBox(width: 24.0),
//                               ],
//                             ),
//                           ),
//                           SizedBox(height: 16.0),
//                           ...data
//                               .asMap()
//                               .map((index, articleCategory) {
//                                 return MapEntry(
//                                   index,
//                                   _currentArticleIndex == index
//                                       ? ArticleList(
//                                           articleCategory: articleCategory,
//                                           carouselHeight: articleCarouselHeight,
//                                         )
//                                       : Container(),
//                                 );
//                               })
//                               .values
//                               .toList(),
//                         ],
//                       );
//                     } else {
//                       String errorTitle = 'Tidak dapat menampilkan artikel';
//                       String? errorSubtitle = snapshot.data?.error;
//                       return Container(
//                         child: ErrorCard(
//                           title: errorTitle,
//                           subtitle: errorSubtitle,
//                           iconData: Icons.warning_rounded,
//                         ),
//                       );
//                     }
//                   } else {
//                     return Container(
//                       height: articleCarouselHeight + 36 + 16.0,
//                       child: Center(
//                         child: CircularProgressIndicator(
//                           color: theme.primaryColor,
//                         ),
//                       ),
//                     );
//                   }
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Fungsi untuk mengatur visibilitas tombol
//   void _onShowButton(showButton, onPageChanged) {
//     if (onPageChanged == Center) {
//       showButton == true;
//     }
//     ;
//   }
// }
