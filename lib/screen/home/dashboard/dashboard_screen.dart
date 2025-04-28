import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
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
import 'package:pensiunku/screen/home/dashboard/franchise/franchise_screen.dart';
import 'package:pensiunku/screen/home/dashboard/halopensiun/halopensiun_screen.dart';
import 'package:pensiunku/screen/home/dashboard/icon_menu.dart';
import 'package:pensiunku/screen/home/dashboard/ajukan/pengajuan_anda_screen.dart';
import 'package:pensiunku/screen/home/dashboard/karir/karir_screen.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/aktifkan_pensiunku_plus_screen.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/daftarkan_pin_screen.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/ktp/prepare_ktp_screen.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/member_reject_screen.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/member_waiting_screen.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/wallet/e_wallet_screen.dart';
import 'package:pensiunku/screen/home/dashboard/simulasi/simulasi_cepat_screen.dart';
import 'package:pensiunku/screen/home/dashboard/toko/toko_screen.dart';
import 'package:pensiunku/screen/home/dashboard/usaha/usaha_screen.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:pensiunku/widget/chip_tab.dart';
import 'package:http/http.dart' as http;
import 'package:pensiunku/widget/floating_bottom_navigation_bar.dart';
import 'dart:convert';

import 'package:pensiunku/screen/home/dashboard/poster/poster_dialog.dart';

// Kelas utama DashboardScreen dengan StatefulWidget agar memiliki state yang dapat berubah
class DashboardScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/dashboard_screen';
  // Callback dan parameter lainnya
  final void Function(BuildContext)
      onApplySubmission; // Callback saat pengajuan dilakukan
  final void Function(int index)
      onChangeBottomNavIndex; // Callback untuk mengubah indeks navigasi bawah
  final ScrollController scrollController; // Controller untuk scroll
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
  // Variabel state untuk indeks artikel dan event
  int _currentArticleIndex = 0;
  int _currenEventIndex = 0;
  // Tambahkan variabel _currentIndex di sini
  bool _isBottomNavBarVisible = true; // Defaultnya 0 untuk tab Home

  // Future untuk mendapatkan data secara asinkron
  late Future<ResultModel<List<ArticleCategoryModel>>>
      _futureDataArticleCategories;
  late List<ArticleCategoryModel> _articleCategories = [];
  Future<ResultModel<List<ForumModel>>>? _futureData;
  late Future<ResultModel<List<EventModel>>> _futureDataEventModel;
  late List<EventModel> _EventModel = [];
  late Future<String> _futureGreeting;
  UserModel? _userModel;
  late Future<ResultModel<UserModel>> _future;
  Future<int>? _futureMemberStatus;

  // Variabel untuk loading overlay dan status lainnya
  bool _isLoadingOverlay = false;
  bool _isActivated = false;
  bool _isInDevelopment = true;
  bool _isLoadingCheckMemberBalanceCard = false;
  bool _isLoadingCheckMemberActionButton = false;

  // Controller untuk input teks
  TextEditingController namaController = TextEditingController();

  final dataKey = GlobalKey(); // Key global untuk widget tertentu

  // Ukuran default carousel (bisa disesuaikan secara dinamis menggunakan MediaQuery)
  final double articleCarouselHeight = 150.0;
  final double eventCarouselHeight = 200.0;

  final List<String> simulationFormTypeTitle = [
    'KREDIT PRA-PENSIUN',
    'KREDIT PENSIUN',
    'KREDIT PLATINUM',
  ];

  @override
  void initState() {
    super.initState();
    print('DashboardScreen initialized');
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

    //// aktifkan kembali nanti versi 2
    // Menampilkan poster setelah widget selesai rendering
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Panggil fungsi untuk menampilkan dialog poster
      PosterDialog.show(context);
    });
  }

  // Fungsi refresh untuk memuat data user dan data lainnya
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

      // Memuat kategori artikel
      _futureDataArticleCategories =
          ArticleRepository().getAllCategories().then((value) {
        if (value.error != null) {
          showDialog(
              context: context,
              builder: (_) => AlertDialog(
                    content: Text(
                      value.error.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
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

  // Fungsi fetchGreeting untuk mengambil sapaan dari server
  // Fungsi fetchGreeting: Logika di frontend berdasarkan waktu lokal
  Future<String> fetchGreeting() async {
    final now = DateTime.now();
    final int totalMinutes = now.hour * 60 + now.minute;

    if (totalMinutes >= 1 && totalMinutes <= 10 * 60) {
      return 'Selamat Pagi';
    } else if (totalMinutes > 10 * 60 && totalMinutes <= 14 * 60) {
      return 'Selamat Siang';
    } else if (totalMinutes > 14 * 60 && totalMinutes <= 18 * 60) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }

  // Fungsi untuk mengecek status member
  Future<int> cekMember(String id) async {
    const String url = 'https://api.pensiunku.id/new.php/cekMember';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_user': id}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
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
    setState(() {
      _isLoadingOverlay = true;
    });
    try {
      int status = await cekMember(_userModel!.id.toString());
      print("Status member (Balance Card): $status");

      if (mounted) {
        setState(() {
          _isLoadingOverlay = false;
        });
      }

      // Jika status 4 dan isFromBalanceCard = true, tampilkan dialog saja
      if (status == 4) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Informasi"),
              content: const Text(
                  "Fitur E-Wallet masih dalam tahap pengembangan. Mohon bersabar ya!"),
              actions: [
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        return; // Berhenti di sini, tidak perlu navigasi lagi
      }

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

      Widget nextScreen =
          _decideNextScreen(status, submission, isFromBalanceCard: true);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => nextScreen));
    } catch (error) {
      print("Error (Balance Card): $error");
      if (mounted) {
        setState(() {
          _isLoadingOverlay = false;
        });
      }
    }
  }

////Aktifkan kalo E-WALLET SUDAH SIAP DIGUNAKAN
  // // Handler untuk mengecek member dan menavigasi dari balance card
  // void _handleCheckMemberAndNavigateFromBalanceCard(
  //     BuildContext context) async {
  //   if (_userModel == null || _userModel!.id == null) {
  //     print("Error: User tidak terautentikasi atau ID tidak tersedia");
  //     return;
  //   }
  //   setState(() {
  //     _isLoadingOverlay = true;
  //   });
  //   try {
  //     int status = await cekMember(_userModel!.id.toString());
  //     print("Status member (Balance Card): $status");
  //     final submission = SubmissionModel(
  //       id: _userModel!.id,
  //       produk: 'Produk Default',
  //       name: _userModel!.username ?? 'Nama Default',
  //       phone: _userModel!.phone,
  //       birthDate: DateTime.now(),
  //       salary: 0,
  //       tenor: 0,
  //       plafond: 0,
  //       bankName: 'Bank Default',
  //     );
  //     if (mounted) {
  //       setState(() {
  //         _isLoadingOverlay = false;
  //       });
  //     }
  //     Widget nextScreen =
  //         _decideNextScreen(status, submission, isFromBalanceCard: true);
  //     Navigator.push(
  //         context, MaterialPageRoute(builder: (context) => nextScreen));
  //   } catch (error) {
  //     print("Error (Balance Card): $error");
  //     if (mounted) {
  //       setState(() {
  //         _isLoadingOverlay = false;
  //       });
  //     }
  //   }
  // }

  // Handler untuk mengecek member dan menavigasi dari action button
  void _handleCheckMemberAndNavigateFromActionButton(
      BuildContext context) async {
    if (_userModel == null || _userModel!.id == null) {
      print("Error: User tidak terautentikasi atau ID tidak tersedia");
      return;
    }
    setState(() {
      _isLoadingOverlay = true;
    });
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
      if (mounted) {
        setState(() {
          _isLoadingOverlay = false;
        });
      }
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

  // Modifikasi pada metode _decideNextScreen
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
        // Jika isFromBalanceCard true, tampilkan dialog dan jangan navigasi
        if (isFromBalanceCard) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              barrierDismissible:
                  false, // Mencegah dialog ditutup dengan tap di luar
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Informasi"),
                  content: const Text(
                      "Fitur E-Wallet masih dalam tahap pengembangan. Mohon bersabar ya!"),
                  actions: [
                    TextButton(
                      child: const Text("OK"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          });
          // Kembalikan screen saat ini (tidak navigasi ke EWalletScreen)
          return Container(); // Widget kosong, tidak ada navigasi
        }
        return PengajuanOrangLainScreen();
      case 5:
        return MemberRejectScreen();
      default:
        print("Error: Status member tidak dikenal: $status");
        return AktifkanPensiunkuPlusScreen(); // fallback
    }
  }

////Aktifkan kalo E-WALLET SUDAH SIAP DIGUNAKAN
  // // Menentukan screen selanjutnya berdasarkan status member
  // Widget _decideNextScreen(int status, SubmissionModel submission,
  //     {bool isFromBalanceCard = false}) {
  //   switch (status) {
  //     case 0:
  //       return AktifkanPensiunkuPlusScreen();
  //     case 1:
  //       return PrepareKtpScreen(
  //         onSuccess: (ctx) {
  //           print("PrepareKtpScreen onSuccess callback dipanggil");
  //         },
  //         submissionModel: submission,
  //       );
  //     case 2:
  //       return DaftarkanPinPensiunkuPlusScreen();
  //     case 3:
  //       return MemberWaitingScreen();
  //     case 4:
  //       return isFromBalanceCard ? EWalletScreen() : PengajuanOrangLainScreen();
  //     case 5:
  //       return MemberRejectScreen();
  //     default:
  //       print("Error: Status member tidak dikenal: $status");
  //       return AktifkanPensiunkuPlusScreen(); // fallback
  //   }
  // }

  // List untuk program dan gambar produk
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
    // Dapatkan informasi ukuran layar dari MediaQuery
    final Size screenSize = MediaQuery.of(context).size;
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      // Menggunakan Stack untuk menampilkan konten utama dan overlay loading bila diperlukan
      body: Stack(
        children: [
          // Kontainer background dengan gradient
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
                        // Header dengan logo dan icon akun
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: _buildHeader(),
                        ),
                        const SizedBox(height: 1),
                        // Greeting yang menyesuaikan teks greeting dan nama user
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: _buildGreeting(),
                        ),
                        const SizedBox(height: 6),
                        // Balance Card dengan tombol untuk verifikasi
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: _buildBalanceCard(),
                        ),
                        const SizedBox(height: 12),

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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: _buildActionButtons(context),
                        ),
                        const SizedBox(height: 16),
                        // Widget gambar header yang dinamis
                        _buildHeaderImage(),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: _buildMenuFeatures(),
                        ),
                        const SizedBox(height: 16),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        //   child: _buildMenuFeatures2(),
                        // ),
                        // const SizedBox(height: 16),
                        _buildCarouselSlider(),
                        const SizedBox(height: 16),
                        _buildArticleFeatures(),
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Tambahkan floating navigation bar
          FloatingBottomNavigationBar(
            isVisible: _isBottomNavBarVisible,
            currentIndex: 2,
            onTapItem: (newIndex) {
              Navigator.of(context).pop(newIndex);
            },
          ),
          // Overlay loading jika _isLoadingOverlay true
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
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF017964)),
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

  // =========================
  // Widget Pendukung (Header, Greeting, dll)
  // =========================

  // Widget Header: Menampilkan logo dan ikon akun
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Gunakan Image.asset dengan ukuran responsif
          Image.asset(
            'assets/logo_pensiunku.png',
            height: MediaQuery.of(context).size.width *
                0.12, // contoh ukuran dinamis
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(
                    builder: (context) => AccountScreen(
                          onChangeBottomNavIndex: (int index) {},
                        )))
                .then((_) {
              // Refresh data ketika kembali dari AccountScreen
              _refreshData();
            }),
            color: Colors.black54,
          ),
        ],
      ),
    );
  }

  // Widget Greeting: Menampilkan sapaan berdasarkan data dari API dan nama user
  Widget _buildGreeting() {
    const TextStyle greetingStyle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.normal,
      color: Color(0Xff017964),
    );
    const TextStyle boldStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Color(0Xff017964),
    );

    String userName = _userModel?.username?.split(' ').first ?? 'Pengguna';

    Widget buildGreetingText(String greeting) {
      return RichText(
        text: TextSpan(
          children: [
            TextSpan(text: '$greeting, ', style: greetingStyle),
            TextSpan(text: userName, style: boldStyle),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 15.0),
      child: FutureBuilder<String>(
        future: _futureGreeting,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return buildGreetingText('Selamat Datang');
          } else if (snapshot.hasError) {
            return buildGreetingText('Selamat Datang');
          } else if (snapshot.hasData) {
            return buildGreetingText(snapshot.data!);
          }
          return buildGreetingText('Selamat Datang');
        },
      ),
    );
  }

  // Widget Balance Card: Menampilkan informasi dompet dan tombol aksi
  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 1,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.account_balance_wallet_outlined, color: Colors.black),
              SizedBox(width: 8),
              Text(
                'Dompet Anda',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Spacer(),
              Text(
                'Rp 0',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _isLoadingCheckMemberBalanceCard
              ? const Center(child: CircularProgressIndicator())
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
                    shadowColor: Colors.grey.withOpacity(0.5),
                    elevation: 5,
                  ),
                  child: RichText(
                    text: TextSpan(
                      text: 'Aktifkan ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.green[900],
                      ),
                      children: const [
                        TextSpan(
                            text: 'Pensiunku+',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(
                            text: ' Sekarang',
                            style: TextStyle(fontWeight: FontWeight.normal)),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  // Widget Simulasi Pensiunku: Navigasi ke Simulasi Cepat
  Widget _buildSimulasiPensiunku(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => SimulasiCepatScreen()));
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFFFC950),
          borderRadius: BorderRadius.circular(10),
          image: const DecorationImage(
            image: AssetImage('assets/dashboard_screen/simulasi-cepat.png'),
            fit: BoxFit
                .cover, // Pastikan gambar selalu mengisi container dengan proporsional
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: const Center(
            child: Text(
              'Simulasi Cepat',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  // Widget Wallet: Navigasi ke EWalletScreen
  Widget _buildWallet(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => EWalletScreen()));
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF017964),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Center(
            child: Text(
              'Cek Progress E-Wallet Pensiunku+',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  // Widget Action Buttons: Menampilkan dua tombol aksi dengan ukuran dan padding dinamis
  Widget _buildActionButtons(BuildContext context) {
    // Fungsi helper untuk membuat tombol dengan ikon dan teks
    Widget _buildButton(
        String iconPath, Widget textWidget, VoidCallback onPressed,
        {Color backgroundColor = Colors.white,
        Color shadowColor = Colors.transparent}) {
      final mediaQuery = MediaQuery.of(context);
      final double imageSize =
          mediaQuery.size.width * 0.14; // Ukuran ikon berdasarkan lebar layar
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
                          fontWeight: FontWeight.normal, color: Colors.black)),
                  TextSpan(
                      text: 'Pinjaman Sekarang',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black)),
                ],
              ),
            ),
            () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => PengajuanAndaScreen()));
            },
            shadowColor: Colors.grey.withOpacity(0.5),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _isLoadingCheckMemberActionButton
              ? const Center(child: CircularProgressIndicator())
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
                                color: Colors.black)),
                        TextSpan(
                            text: 'Pensiunku+',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
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

  // Widget Header Image: Menampilkan carousel gambar header dengan ukuran dinamis
  Widget _buildHeaderImage() {
    // Daftar gambar header
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
                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
        // Gunakan LayoutBuilder untuk mengakses lebar layar dan menghitung tinggi secara dinamis
        LayoutBuilder(
          builder: (context, constraints) {
            // Sesuaikan tinggi carousel dengan rasio yang tepat untuk gambar Anda
            double carouselHeight = constraints.maxWidth * 0.45;
            return Container(
              width: double.infinity,
              height: carouselHeight,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: CarouselSlider.builder(
                itemCount: images.length,
                options: CarouselOptions(
                  height: carouselHeight,
                  enlargeCenterPage: true,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 3),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  viewportFraction: 0.94,
                  aspectRatio: 16 / 9,
                  reverse: true,
                  enlargeStrategy: CenterPageEnlargeStrategy.height,
                  // Tambahkan efek transisi yang lebih menarik
                  pageViewKey: const PageStorageKey('carousel'),
                ),
                itemBuilder: (context, index, realIndex) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                          20), // Border radius yang lebih besar
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                          20), // Border radius yang sama dengan parent
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.asset(
                              images[index],
                              fit: BoxFit
                                  .cover, // Menggunakan cover dengan pengaturan yang lebih baik
                              filterQuality: FilterQuality.high,
                              gaplessPlayback: true,
                            ),
                          ),
                          // Tambahkan overlay gradient untuk efek estetik (opsional)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.15),
                                  ],
                                  stops: const [0.7, 1.0],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  // Widget Menu Features: Menampilkan menu-menu fitur dengan ikon
  Widget _buildMenuFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
          child: Row(
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
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: IconMenu(
                  image: "assets/dashboard_screen/icon_toko.png",
                  title: "Toko",
                  routeNamed: TokoScreen.ROUTE_NAME,
                  arguments: TokoScreenArguments(categoryId: 1),
                  useBox: false,
                ),
              ),
              // SizedBox(width: 10),
              SizedBox(
                width: 80,
                child: IconMenu(
                  image: "assets/dashboard_screen/icon_franchise.png",
                  title: "Franchise",
                  routeNamed: UsahaScreen.ROUTE_NAME,
                  useBox: false,
                ),
              ),
              SizedBox(width: 10),
              SizedBox(
                width: 130,
                child: IconMenu(
                  image: "assets/dashboard_screen/icon_karir.png",
                  title: "Karir",
                  routeNamed: KarirScreen.ROUTE_NAME,
                  useBox: false,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget Carousel Slider: Menampilkan produk menggunakan carousel
  Widget _buildCarouselSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'Produk',
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.9),
          child: CarouselSlider.builder(
            options: CarouselOptions(
              height:
                  200, // Ukuran tinggi bisa disesuaikan lebih lanjut bila diperlukan
              autoPlay: true,
              enlargeCenterPage: true,
              aspectRatio: 0.8,
              autoPlayCurve: Curves.fastOutSlowIn,
              enableInfiniteScroll: true,
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              viewportFraction: 0.45,
            ),
            itemCount: programList.length,
            itemBuilder: (BuildContext context, int index, int realIndex) {
              return Container(
                margin: const EdgeInsets.all(1.0),
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
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            shadows: [
                              Shadow(
                                blurRadius: 5.0,
                                color: Colors.black38,
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

  // Fungsi untuk mendapatkan kategori artikel
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

  // Widget Article Features: Menampilkan daftar artikel berdasarkan kategori yang dipilih
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
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ),
          FutureBuilder<List<ArticleCategoryModel>>(
            future: _getArticleCategories(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Tidak ada data artikel tersedia.',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }
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
                      // Misal: tinggi carousel artikel 60% dari lebar layar
                      double carouselHeight = constraints.maxWidth * 0.6;
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
}



// void _showUnderDevelopmentDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: true,
//       builder: (BuildContext context) {
//         return BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
//           child: AlertDialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(15),
//             ),
//             backgroundColor: Colors
//                 .transparent, // Make the AlertDialog background transparent
//             insetPadding: EdgeInsets.symmetric(horizontal: 15),
//             content: Container(
//               decoration: BoxDecoration(
//                 color: Color(0XFFF017964), // Set the background color to green
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               padding: EdgeInsets.all(16),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     'Untuk mengakses Fitur ini Anda diwajibkan untuk Bergabung menjadi mitra pensiunku+ !',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors
//                           .white, // Set the text color to white for better contrast
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       foregroundColor: Color(0xFF017964),
//                       backgroundColor:
//                           Colors.white, // Set the text color to green
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     onPressed: () {
//                       Navigator.of(context).pop(); // Close the dialog
//                       Navigator.of(context).push(
//                         MaterialPageRoute(
//                           builder: (context) => AktifkanPensiunkuPlusScreen(),
//                         ),
//                       );
//                     },
//                     child: Text('Aktifkan Pensiunku+'),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

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