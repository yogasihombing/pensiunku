import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:pensiunku/model/article_model.dart';
import 'package:pensiunku/model/event_model.dart';
import 'package:pensiunku/model/forum_model.dart';
import 'package:pensiunku/model/submission_model.dart';
import 'package:pensiunku/model/user_model.dart';
import 'package:pensiunku/model/result_model.dart';
import 'package:pensiunku/repository/article_repository.dart';
import 'package:pensiunku/repository/user_repository.dart';
import 'package:pensiunku/screen/home/account/account_screen.dart';
import 'package:pensiunku/screen/home/dashboard/ajukan/pengajuan_orang_lain_screen.dart';
import 'package:pensiunku/screen/home/dashboard/article/article_screen.dart';
import 'package:pensiunku/screen/home/dashboard/article_list.dart';
import 'package:pensiunku/screen/home/dashboard/event/event_screen.dart';
import 'package:pensiunku/screen/home/dashboard/forum/forum_screen.dart';
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
import 'package:pensiunku/widget/showcase/app_showcase_keys.dart';
import 'dart:convert';

import 'package:showcaseview/showcaseview.dart';

// Global variables for Firebase Messaging
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description:
      'This channel is used for important notifications.', // description
  importance: Importance.max,
);

// Variabel untuk menentukan mode produksi
bool isProd = true;

// Host API berdasarkan mode produksi
String get apiHost {
  return isProd
      ? "https://pensiunku.id/mobileapi"
      : "https://pensiunku.id/mobileapi";
}

// Konfigurasi header default untuk API
Map<String, String> get defaultApiHeaders {
  return {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36',
    'Accept': 'application/json',
    'Accept-Language': 'id-ID,id;q=0.9,en-US;q=0.8,en;q=0.7',
    'X-Requested-With': 'com.pensiunku.app',
    'Content-Type': 'application/json',
  };
}

// 1. DashboardScreen
// Kelas utama DashboardScreen dengan StatefulWidget agar memiliki state yang dapat berubah
class DashboardScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/dashboard_screen';
  // Callback dan parameter lainnya
  final void Function(BuildContext)
      onApplySubmission; // Callback saat pengajuan dilakukan
  final void Function(int index)
      onChangeBottomNavIndex; // Callback untuk mengubah indeks navigasi bawah
  final ScrollController scrollController; // Controller untuk scroll
  // final int? walkthroughIndex; // Hapus parameter ini dari constructor

  const DashboardScreen({
    Key? key,
    required this.onApplySubmission,
    required this.onChangeBottomNavIndex,
    required this.scrollController,
    // this.walkthroughIndex, // Hapus parameter ini dari constructor
  }) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with AutomaticKeepAliveClientMixin<DashboardScreen> {
  // Tambahkan mixin ini

  // Variabel state untuk indeks artikel dan event
  int _currentArticleIndex = 0;
  int _currenEventIndex = 0; // Typo here, should be _currentEventIndex?
  bool _isBottomNavBarVisible = true;

  // Variabel state untuk saldo pengguna
  String _userBalance = '0';
  bool _isLoadingOverlay = false;
  bool _isActivated = false;
  bool _isInDevelopment = true;
  bool _isLoadingCheckMemberBalanceCard = false;
  bool _isLoadingCheckMemberActionButton = false;

  // Variabel untuk menyimpan daftar kategori artikel setelah diambil
  List<ArticleCategoryModel> _articleCategories = [];
  late Future<ResultModel<List<ArticleCategoryModel>>> _futureArticleCategories;

  Future<ResultModel<List<ForumModel>>>? _futureDataForum;
  late Future<ResultModel<List<EventModel>>> _futureDataEventModel;
  late List<EventModel> _EventModel = [];
  late Future<String> _futureGreeting;
  UserModel? _userModel;
  late Future<ResultModel<UserModel>> _futureUser;
  int? _memberStatus = 0;

  TextEditingController namaController = TextEditingController();

  final dataKey = GlobalKey();

  // Global Keys untuk ShowcaseView
  // Menggunakan GlobalKey yang diimpor dari app_showcase_keys.dart
  List<GlobalKey> _showcaseKeys = [
    // one,
    two,
    three,
    four,
    five,
    six,
    seven,
    eight,
  ];

  // Daftar path gambar carousel
  final List<String> _carouselImagePaths = const [
    'assets/dashboard_screen/image_1.png',
    'assets/dashboard_screen/image_2.png',
    'assets/dashboard_screen/image_3.png',
  ];

  @override
  bool get wantKeepAlive =>
      true; // Penting: Memberi tahu Flutter untuk menjaga status widget ini

  @override
  void initState() {
    super.initState();
    print('DashboardScreen initialized');
    _isLoadingOverlay = true;

    _futureArticleCategories = ArticleRepository().getAllCategories();

    _refreshData();
    _precacheCarouselImages(); // Panggil fungsi pre-cache

    _futureGreeting = fetchGreeting().whenComplete(() {
      if (mounted) {
        setState(() {
          _isLoadingOverlay = false;
          print('DashboardScreen: Overlay loading dinonaktifkan.');
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _startShowcase();
        });
      }
    });
  }

  // Fungsi untuk pre-cache gambar carousel
  Future<void> _precacheCarouselImages() async {
    for (final path in _carouselImagePaths) {
      try {
        // precacheImage akan memuat gambar ke dalam ImageCache
        await precacheImage(AssetImage(path), context);
        print('Precached image: $path');
      } catch (e, st) {
        print('Error precaching $path: $e\n$st');
        // Anda bisa menambahkan penanganan error di sini jika diperlukan
      }
    }
  }

  void _startShowcase() async {
    bool? isFinishedWalkthrough = SharedPreferencesUtil()
        .sharedPreferences
        .getBool(SharedPreferencesUtil.SP_KEY_IS_FINISHED_WALKTHROUGH);

    if (isFinishedWalkthrough != true) {
      ShowCaseWidget.of(context).startShowCase(_showcaseKeys);
      print('DashboardScreen: Memulai walkthrough.');
    } else {
      print('DashboardScreen: Walkthrough sudah selesai sebelumnya.');
    }
  }

  Future<void> _refreshData() async {
    print('DashboardScreen: _refreshData dipanggil.');
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    if (token == null) {
      print('DashboardScreen: Token pengguna null, tidak dapat memuat data.');
      setState(() {
        _isLoadingOverlay = false;
      });
      return;
    }

    print('DashboardScreen: Memulai pengambilan data user...');
    try {
      final userResult = await UserRepository().getOne(token);
      if (userResult.error == null) {
        setState(() {
          _userModel = userResult.data;
          print(
              'DashboardScreen: Data user berhasil diambil. User ID: ${_userModel?.id}');
        });
        if (_userModel?.id != null) {
          await _fetchBalance(_userModel!.id.toString());
          try {
            _memberStatus = await cekMember(_userModel!.id.toString());
          } catch (e) {
            print('DashboardScreen: Error mengambil status member: $e');
            _memberStatus = 0;
          }
        } else {
          print('DashboardScreen: User ID null setelah pengambilan data user.');
        }
      } else {
        print("DashboardScreen: Error mengambil user: ${userResult.error}");
      }
    } catch (e) {
      print("DashboardScreen: Exception saat mengambil user: $e");
    }

    print('DashboardScreen: Memulai pengambilan kategori artikel...');
    setState(() {
      _futureArticleCategories = ArticleRepository().getAllCategories();
    });

    try {
      final categoriesResult = await _futureArticleCategories;
      if (categoriesResult.error != null) {
        print(
            'DashboardScreen: Error mengambil kategori artikel: ${categoriesResult.error}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                categoriesResult.error.toString(),
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.redAccent,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _articleCategories = categoriesResult.data ?? [];
            print(
                'DashboardScreen: Kategori artikel berhasil diambil. Jumlah kategori: ${_articleCategories.length}');
            if (_articleCategories.isNotEmpty && _currentArticleIndex == 0) {}
          });
        }
      }
    } catch (e) {
      print("DashboardScreen: Exception saat mengambil kategori artikel: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal memuat kategori artikel: ${e.toString()}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }

    print('DashboardScreen: _refreshData selesai.');
  }

  Future<String> fetchGreeting() async {
    final now = DateTime.now();
    final int totalMinutes = now.hour * 60 + now.minute;
    print('DashboardScreen: Menghitung sapaan...');

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
                _userBalance = 'Error';
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
      if (mounted) {
        // No changes here as _isLoadingBalance was already removed
      }
    }
  }

  Future<int> cekMember(String id) async {
    print('DashboardScreen: Mengecek status member untuk ID: $id');
    const String url = 'https://api.pensiunku.id/new.php/cekMember';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_user': id}),
    );
    if (response.statusCode == 200) {
      if (response.body.contains('One moment, please...') ||
          response.body
              .contains('Access denied by Imunify360 bot-protection') ||
          response.body.trim().startsWith('<!DOCTYPE html>')) {
        throw Exception(
            'Deteksi tantangan keamanan (Cloudflare/Imunify360). Mohon coba lagi.');
      }

      final data = jsonDecode(response.body);
      print('DashboardScreen: Cek member API response: $data');
      if (data != null &&
          data['text'] != null &&
          data['text']['status'] != null) {
        final statusStr = data['text']['status'].toString();
        final status = int.tryParse(statusStr);
        if (status != null) {
          print('DashboardScreen: Status member berhasil diambil: $status');
          return status;
        } else {
          print(
              "DashboardScreen: Nilai status '$statusStr' tidak dapat dikonversi ke int");
          throw Exception(
              "Nilai status '$statusStr' tidak dapat dikonversi ke int");
        }
      } else {
        print(
            "DashboardScreen: Error: Field 'status' tidak ditemukan dalam response: ${response.body}");
        throw Exception("Field 'status' tidak ditemukan atau null");
      }
    } else {
      throw Exception(
          'Failed to load member status with status code: ${response.statusCode}');
    }
  }

  void _handleCheckMemberAndNavigateFromBalanceCard(
      BuildContext context) async {
    print(
        'DashboardScreen: _handleCheckMemberAndNavigateFromBalanceCard dipanggil.');
    if (_userModel == null || _userModel!.id == null) {
      print(
          "DashboardScreen: Error: User tidak terautentikasi atau ID tidak tersedia");
      return;
    }
    setState(() {
      _isLoadingOverlay = true;
    });
    try {
      int status = await cekMember(_userModel!.id.toString());
      print("DashboardScreen: Status member (Balance Card): $status");

      if (mounted) {
        setState(() {
          _isLoadingOverlay = false;
        });
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
      print(
          'DashboardScreen: Memutuskan layar berikutnya dari Balance Card dengan status: $status');
      Widget nextScreen =
          _decideNextScreen(status, submission, isFromBalanceCard: true);
      Navigator.push(
              context, MaterialPageRoute(builder: (context) => nextScreen))
          .then((_) {
        _refreshData();
      });
    } catch (error) {
      print("DashboardScreen: Error (Balance Card): $error");
      if (mounted) {
        setState(() {
          _isLoadingOverlay = false;
        });
      }
    }
  }

  void _handleCheckMemberAndNavigateFromActionButton(
      BuildContext context) async {
    print(
        'DashboardScreen: _handleCheckMemberAndNavigateFromActionButton dipanggil.');
    if (_userModel == null || _userModel!.id == null) {
      print(
          "DashboardScreen: Error: User tidak terautentikasi atau ID tidak tersedia");
      return;
    }
    setState(() {
      _isLoadingOverlay = true;
    });
    try {
      int status = await cekMember(_userModel!.id.toString());
      print("DashboardScreen: Status member (Action Button): $status");
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
      print(
          'DashboardScreen: Memutuskan layar berikutnya dari Action Button dengan status: $status');
      Widget nextScreen = _decideNextScreen(status, submission);
      Navigator.push(
              context, MaterialPageRoute(builder: (context) => nextScreen))
          .then((_) {
        _refreshData();
      });
    } catch (error) {
      print("DashboardScreen: Error (Action Button): $error");
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
    print(
        'DashboardScreen: _decideNextScreen dipanggil dengan status: $status');
    switch (status) {
      case 0:
        return AktifkanPensiunkuPlusScreen();
      case 1:
        return PrepareKtpScreen(
          onSuccess: (ctx) {
            print(
                "DashboardScreen: PrepareKtpScreen onSuccess callback dipanggil");
          },
          submissionModel: submission,
        );
      case 2:
        return DaftarkanPinPensiunkuPlusScreen();
      case 3:
        return MemberWaitingScreen();
      case 4:
        if (isFromBalanceCard) {
          print('DashboardScreen: Mengarahkan ke EWalletScreen.');
          return EWalletScreen();
        }
        print('DashboardScreen: Mengarahkan ke PengajuanOrangLainScreen.');
        return PengajuanOrangLainScreen();
      case 5:
        return MemberRejectScreen();
      default:
        print("DashboardScreen: Error: Status member tidak dikenal: $status");
        return AktifkanPensiunkuPlusScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(
        context); // Penting: Panggil super.build(context) saat menggunakan AutomaticKeepAliveClientMixin

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: Stack(
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
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: _refreshData,
                child: SingleChildScrollView(
                  controller: widget.scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: screenHeight * 0.010),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04),
                        child: _buildHeader(screenWidth, screenHeight),
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04),
                        child: _buildGreeting(screenWidth, screenHeight),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      // --- PERUBAHAN: Menampilkan _buildBalanceCard atau _aktifkanpensiunkuPlus berdasarkan _memberStatus ---
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04),
                        child: Showcase(
                          key:
                              three, // Key untuk Balance Card / Aktifkan Pensiunku+
                          description:
                              'Kamu bisa melihat nominal saldo yang ada di akun kamu.', // Detail text showcase
                          child: (_memberStatus ==
                                  4) // Jika status 4 (member aktif)
                              ? _buildBalanceCard(screenWidth, screenHeight)
                              : _aktifkanpensiunkuPlus(
                                  screenWidth, screenHeight),
                        ),
                      ),
                      // --- AKHIR PERUBAHAN ---
                      SizedBox(height: screenHeight * 0.015),

                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04),
                        child: Showcase(
                          key: four, // Key untuk Simulasi Cepat
                          description:
                              'Dengan fitur Simulasi Cepat PensiunKu, kamu bisa melakukan simulasi kredit dengan mudah dan cepat. \n\nCukup masukkan data yang diperlukan, dan aplikasi ini akan menghitung plafon kredit dan terima bersih yang bisa kamu dapatkan.', // Detail text showcase
                          child: _buildSimulasiPensiunku(
                              context, screenWidth, screenHeight),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      SizedBox(height: screenHeight * 0.015),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04),
                        child: _buildActionButtons(
                            context, screenWidth, screenHeight),
                      ),
                      SizedBox(height: screenHeight * 0.02),

                      Showcase(
                        // Showcase untuk seluruh bagian menu fitur
                        key: seven, // Key untuk Icon Menu Events
                        description:
                            'Kami juga menyediakan berbagai menu menarik yang dapat membantu kamu tetap aktif dan produktif di masa pensiun.', // Detail text showcase
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04),
                          child: _buildMenuFeatures(
                              context, screenWidth, screenHeight),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Showcase(
                        key: eight, // Key untuk Carousel Header Image
                        description:
                            'Kamu bisa melihat berbagai pengumuman dan informasi penting yang perlu diketahui.', // Detail text showcase
                        child: _buildHeaderImage(
                            context, screenWidth, screenHeight),
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      _buildArticleFeatures(context, screenWidth, screenHeight),
                      SizedBox(height: screenHeight * 0.06),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // FloatingBottomNavigationBar tidak dibungkus Showcase
          FloatingBottomNavigationBar(
            isVisible: _isBottomNavBarVisible,
            currentIndex: 2,
            onTapItem: (newIndex) {
              Navigator.of(context).pop(newIndex);
            },
          ),
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
                padding: EdgeInsets.all(screenWidth * 0.05),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF017964)),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    const Text(
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

  Widget _buildHeader(double screenWidth, double screenHeight) {
    return Padding(
      padding: EdgeInsets.only(left: screenWidth * 0.04),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            'assets/logo_pensiunku.png',
            height: screenHeight * 0.06,
          ),
          Showcase(
            key: two, // Key untuk Icon Akun
            description:
                'Kamu bisa menemukan berbagai informasi penting yang berhubungan dengan status pengajuan kredit dan pengaturan', // Detail text showcase
            child: IconButton(
              icon: const Icon(Icons.account_circle_outlined),
              iconSize: screenWidth * 0.06,
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(
                      builder: (context) => AccountScreen(
                            onChangeBottomNavIndex: (int index) {},
                          )))
                  .then((_) {
                _refreshData();
              }),
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting(double screenWidth, double screenHeight) {
    final TextStyle greetingStyle = TextStyle(
      fontSize: screenWidth * 0.032,
      fontWeight: FontWeight.normal,
      color: const Color(0Xff017964),
    );
    final TextStyle boldStyle = TextStyle(
      fontSize: screenWidth * 0.035,
      fontWeight: FontWeight.bold,
      color: const Color(0Xff017964),
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
      padding: EdgeInsets.only(left: screenWidth * 0.04),
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

  Widget _buildBalanceCard(double screenWidth, double screenHeight) {
    return GestureDetector(
      onTap: () => _handleCheckMemberAndNavigateFromBalanceCard(context),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
          color: Colors.white.withOpacity(0.4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.black,
                  size: screenWidth * 0.05,
                ),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  'Dompet Anda',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                Text(
                  _userBalance,
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _aktifkanpensiunkuPlus(double screenWidth, double screenHeight) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
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
            children: [
              Icon(Icons.account_balance_wallet_outlined,
                  color: Colors.black, size: screenWidth * 0.05),
              SizedBox(width: screenWidth * 0.02),
              Text(
                'Dompet Anda',
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              Text(
                'Rp 0',
                style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.01),
          _isLoadingCheckMemberBalanceCard
              ? Center(
                  child: CircularProgressIndicator(
                  strokeWidth: screenWidth * 0.008,
                ))
              : ElevatedButton(
                  onPressed: () {
                    _handleCheckMemberAndNavigateFromBalanceCard(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC950),
                    minimumSize: Size(double.infinity, screenHeight * 0.035),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.05),
                    ),
                    shadowColor: Colors.grey.withOpacity(0.5),
                    elevation: 5,
                  ),
                  child: RichText(
                    text: TextSpan(
                      text: 'Aktifkan ',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.normal,
                        color: Colors.green[900],
                      ),
                      children: [
                        const TextSpan(
                            text: 'Pensiunku+',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const TextSpan(
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

  Widget _buildSimulasiPensiunku(
      BuildContext context, double screenWidth, double screenHeight) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => SimulasiCepatScreen()));
      },
      child: PhysicalModel(
        color: const Color(0xFFFFDE6B1),
        elevation: 4,
        shadowColor: Colors.grey,
        borderRadius: BorderRadius.circular(screenWidth * 0.025),
        clipBehavior: Clip.antiAlias,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.02, horizontal: screenWidth * 0.03),
          child: Center(
            child: Text(
              'Simulasi Cepat Pensiunku!',
              style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, double screenWidth, double screenHeight) {
    Widget _buildButton(
        String iconPath, Widget textWidget, VoidCallback onPressed,
        {Color backgroundColor = Colors.white70,
        Color shadowColor = Colors.transparent,
        GlobalKey? showcaseKey,
        String? showcaseDescription}) {
      // Parameter ini sudah benar
      final double imageSize = screenWidth * 0.14;
      final double paddingHorizontal = screenWidth * 0.03;
      final double paddingVertical = screenHeight * 0.01;

      Widget buttonContent = ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.06),
          ),
          padding: EdgeInsets.symmetric(
              horizontal: paddingHorizontal, vertical: paddingVertical),
          shadowColor: shadowColor,
          elevation: shadowColor == Colors.transparent ? 0 : 4,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(iconPath, width: imageSize, height: imageSize),
            SizedBox(width: screenWidth * 0.02),
            Flexible(child: textWidget),
          ],
        ),
      );

      if (showcaseKey != null && showcaseDescription != null) {
        return Showcase(
          key: showcaseKey,
          description: showcaseDescription, // Digunakan di sini
          child: buttonContent,
        );
      }
      return buttonContent;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: _buildButton(
            'assets/dashboard_screen/pengajuanAnda.png',
            RichText(
              textAlign: TextAlign.start,
              text: TextSpan(
                children: [
                  TextSpan(
                      text: 'Ajukan\n',
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                          fontSize: screenWidth * 0.03)),
                  TextSpan(
                      text: 'Pinjaman',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: screenWidth * 0.03)),
                ],
              ),
            ),
            () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => PengajuanAndaScreen()));
            },
            shadowColor: Colors.grey.withOpacity(0.5),
            showcaseKey: five, // Key untuk Ajukan Pinjaman
            showcaseDescription:
                'Di menu Ajukan Pinjaman, kamu bisa mulai proses pengajuan kredit dengan mudah. \n\nCaranya, cukup mengisi form pengajuan kredit yang tersedia di sini dengan informasi yang diperlukan.\n\nSetelah itu, anda akan kami hubungi via Whatsapp', // PERBAIKAN: Menggunakan showcaseDescription
          ),
        ),
        SizedBox(width: screenWidth * 0.025),
        Expanded(
          child: _isLoadingCheckMemberActionButton
              ? Center(
                  child: CircularProgressIndicator(
                  strokeWidth: screenWidth * 0.008,
                ))
              : _buildButton(
                  'assets/dashboard_screen/mitra.png',
                  RichText(
                    textAlign: TextAlign.start,
                    text: TextSpan(
                      children: [
                        TextSpan(
                            text: 'Ajukan Mitra\n',
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                                fontSize: screenWidth * 0.03)),
                        TextSpan(
                            text: 'Pensiunku+',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: screenWidth * 0.03)),
                      ],
                    ),
                  ),
                  () {
                    _handleCheckMemberAndNavigateFromActionButton(context);
                  },
                  shadowColor: Colors.grey.withOpacity(0.5),
                  showcaseKey: six, // Key untuk Ajukan Mitra
                  showcaseDescription:
                      'Dengan menjadi Mitra Pensiunku+, anda bisa mendapatkan insentif dengan cara membantu mendapatkan nasabah baru dan mendaftarkannya di aplikasi.\n\nUntuk memulai, kamu harus menjadi Mitra App+ terlebih dahulu dengan mengisi form pendaftaran yang ada di menu ini.', // PERBAIKAN: Menggunakan showcaseDescription
                ),
        ),
      ],
    );
  }

  Widget _buildHeaderImage(
      BuildContext context, double screenWidth, double screenHeight) {
    // Gunakan _carouselImagePaths yang sudah didefinisikan di state
    final List<String> images = _carouselImagePaths;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
              left: screenWidth * 0.075, bottom: screenHeight * 0.01),
          child: Text(
            'Ada yang baru nih!',
            style: TextStyle(
                fontSize: screenWidth * 0.030,
                fontWeight: FontWeight.w600,
                color: Colors.black87),
          ),
        ),
        Container(
          width: double.infinity,
          height: screenHeight * 0.22,
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
          child: CarouselSlider.builder(
            itemCount: images.length,
            options: CarouselOptions(
              height: screenHeight * 0.22,
              enlargeCenterPage: true,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              viewportFraction: 0.94,
              aspectRatio: 16 / 9,
              reverse: true,
              enlargeStrategy: CenterPageEnlargeStrategy.height,
              pageViewKey: const PageStorageKey('carousel'),
            ),
            itemBuilder: (context, index, realIndex) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(screenWidth * 0.05),
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
                  borderRadius: BorderRadius.circular(screenWidth * 0.05),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          images[index],
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                          gaplessPlayback: true,
                          // Tambahkan cacheWidth dan cacheHeight untuk optimasi
                          cacheWidth: (screenWidth *
                                  0.94 *
                                  MediaQuery.of(context).devicePixelRatio)
                              .toInt(), // Sesuaikan dengan lebar viewport dan pixel ratio
                          cacheHeight: (screenHeight *
                                  0.22 *
                                  MediaQuery.of(context).devicePixelRatio)
                              .toInt(), // Sesuaikan dengan tinggi carousel dan pixel ratio
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint(
                                'Error memuat aset ${images[index]}: $error');
                            return Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: screenWidth * 0.1,
                                  color: Colors.grey[600],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.05),
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
        ),
      ],
    );
  }

  // Widget kustom untuk item menu "Coming Soon"
  Widget _buildComingSoonBox(double screenWidth, double screenHeight) {
    // Content that will be faded (original icon and title)
    final Widget fadedContent = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          "assets/dashboard_screen/icon_toko.png",
          width: screenWidth * 0.30,
          height: screenWidth * 0.16,
        ),
        // SizedBox(height: screenHeight * 0.001),
        Text(
          'Toko', // Original title
          style: Theme.of(context).textTheme.subtitle1?.copyWith(
                fontSize: screenWidth * 0.030,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );

    // Overlay content (lock icon and "Coming Soon" text)
    final Widget overlayContent = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.lock,
          size: screenWidth * 0.07,
          color: Colors.black.withOpacity(0.6),
        ),
        Text(
          'Coming Soon',
          style: Theme.of(context).textTheme.subtitle1?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );

    return Expanded(
      flex: 2, // Mengambil 2 ruang proporsional
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Fitur ini akan segera hadir!',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.blueAccent,
              duration: const Duration(seconds: 2),
            ),
          );
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
          // decoration: boxDecoration, // Apply the common box decoration
          child: Stack(
            // Use Stack to overlay content
            alignment: Alignment.center, // Center the children in the stack
            children: [
              // Faded background content
              Opacity(
                opacity: 0.3,
                child: fadedContent,
              ),
              // Overlay content (lock and "Coming Soon")
              overlayContent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuFeatures(
      BuildContext context, double screenWidth, double screenHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
              left: screenWidth * 0.030, bottom: screenHeight * 0.01),
          child: Text(
            'Jelajahi aplikasi Pensiunku!',
            style: TextStyle(
                fontSize: screenWidth * 0.030,
                fontWeight: FontWeight.w600,
                color: Colors.black87),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              // Added Expanded for proportional spacing
              child: IconMenu(
                image: "assets/dashboard_screen/icon_event.png",
                title: "Events",
                routeNamed: EventScreen.ROUTE_NAME,
                useBox: false,
              ),
            ),
            Expanded(
              // Added Expanded for proportional spacing
              child: IconMenu(
                image: "assets/dashboard_screen/icon_article.png",
                title: "Artikel",
                routeNamed: ArticleScreen.ROUTE_NAME,
                arguments: ArticleScreenArguments(
                    articleCategories: _articleCategories),
                useBox: false,
              ),
            ),
            Expanded(
              // Added Expanded for proportional spacing
              child: IconMenu(
                image: "assets/dashboard_screen/icon_halo_pensiun.png",
                title: "Halo Pensiun",
                routeNamed: HalopensiunScreen.ROUTE_NAME,
                useBox: false,
              ),
            ),
            Expanded(
              // Added Expanded for proportional spacing
              child: IconMenu(
                image: "assets/dashboard_screen/icon_forum.png",
                title: "PensiTalk",
                routeNamed: ForumScreen.ROUTE_NAME,
                useBox: false,
              ),
            ),
          ],
        ),
        // Baris kedua menu
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.0, vertical: screenHeight * 0.005),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                // Added Expanded for proportional spacing
                child: IconMenu(
                  image: "assets/dashboard_screen/icon_karir.png",
                  title: "Karir",
                  routeNamed: KarirScreen.ROUTE_NAME,
                  useBox: false,
                ),
              ),
              Expanded(
                // Added Expanded for proportional spacing
                child: IconMenu(
                  image: "assets/dashboard_screen/icon_franchise.png",
                  title: "Franchise",
                  routeNamed: UsahaScreen.ROUTE_NAME,
                  useBox: false,
                ),
              ),
              // Menggunakan widget kustom untuk "Coming Soon" dengan flex 2
              _buildComingSoonBox(screenWidth, screenHeight),
              // Expanded kosong dihapus karena _buildComingSoonBox sekarang mengambil 2 space
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildArticleFeatures(
      BuildContext context, double screenWidth, double screenHeight) {
    print('DashboardScreen: _buildArticleFeatures dipanggil.');
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: screenWidth * 0.075, bottom: screenHeight * 0.01),
            child: Text(
              'Artikel',
              style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ),
          FutureBuilder<ResultModel<List<ArticleCategoryModel>>>(
            future: _futureArticleCategories,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                print(
                    'DashboardScreen: FutureBuilder (kategori) - ConnectionState.waiting');
                return Center(
                  child: SizedBox(
                    height: screenHeight * 0.05,
                    width: screenHeight * 0.05,
                    child: const CircularProgressIndicator(),
                  ),
                );
              }
              if (snapshot.hasError) {
                print(
                    'DashboardScreen: FutureBuilder (kategori) - snapshot.hasError: ${snapshot.error}');
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: Text(
                    'Error memuat kategori: ${snapshot.error}',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: screenWidth * 0.035,
                    ),
                  ),
                );
              }
              if (!snapshot.hasData ||
                  snapshot.data?.data == null ||
                  snapshot.data!.data!.isEmpty) {
                print(
                    'DashboardScreen: FutureBuilder (kategori) - Tidak ada data kategori atau kosong.');
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: Text(
                    'Tidak ada data kategori artikel tersedia.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: screenWidth * 0.035,
                    ),
                  ),
                );
              }

              final List<ArticleCategoryModel> categories =
                  snapshot.data!.data!;
              print(
                  'DashboardScreen: FutureBuilder (kategori) - Data kategori berhasil dimuat. Jumlah: ${categories.length}');

              if (_currentArticleIndex >= categories.length) {
                _currentArticleIndex = 0;
                print(
                    'DashboardScreen: _currentArticleIndex direset karena di luar batas.');
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: screenHeight * 0.05,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ...categories
                              .asMap()
                              .map((index, category) {
                                return MapEntry(
                                  index,
                                  ChipTab(
                                    text: category.name,
                                    isActive: _currentArticleIndex == index,
                                    onTap: () {
                                      print(
                                          'DashboardScreen: ChipTab ${category.name} diketuk. Mengubah _currentArticleIndex ke $index.');
                                      setState(() {
                                        _currentArticleIndex = index;
                                      });
                                    },
                                    backgroundColor: const Color(0xFFFEC842),
                                  ),
                                );
                              })
                              .values
                              .toList(),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  if (categories.isNotEmpty &&
                      _currentArticleIndex < categories.length)
                    ArticleList(
                      articleCategory: categories[_currentArticleIndex],
                      carouselHeight: screenHeight * 0.35,
                    )
                  else
                    Center(
                      child: Text(
                        'Tidak ada artikel untuk kategori ini atau kategori tidak ditemukan.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: screenWidth * 0.035,
                        ),
                      ),
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
