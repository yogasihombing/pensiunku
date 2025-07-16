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
  int _currenEventIndex = 0; // Typo here, should be _currentEventIndex?
  bool _isBottomNavBarVisible = true;

  // Variabel state untuk saldo pengguna
  String _userBalance = '0';
  // --- PERUBAHAN: Menghapus _isLoadingBalance karena tidak lagi diperlukan untuk UI loading di kartu ---
  // bool _isLoadingBalance = false;
  // --- AKHIR PERUBAHAN ---

  // Variabel untuk menyimpan daftar kategori artikel setelah diambil
  List<ArticleCategoryModel> _articleCategories = [];
  // Deklarasi Future untuk kategori artikel, akan diinisialisasi di initState/refreshData
  late Future<ResultModel<List<ArticleCategoryModel>>> _futureArticleCategories;

  Future<ResultModel<List<ForumModel>>>?
      _futureDataForum; // Mengganti _futureData
  late Future<ResultModel<List<EventModel>>> _futureDataEventModel;
  late List<EventModel> _EventModel = [];
  late Future<String> _futureGreeting;
  UserModel? _userModel;
  late Future<ResultModel<UserModel>> _futureUser; // Mengganti _future
  // --- PERUBAHAN: Mengubah _futureMemberStatus menjadi int? dengan nilai default 0 ---
  int? _memberStatus = 0; // Menyimpan status member, default 0 (belum aktif)
  // --- AKHIR PERUBAHAN ---

  // Variabel untuk loading overlay dan status lainnya
  bool _isLoadingOverlay = false;
  bool _isActivated =
      false; // Variabel ini tidak digunakan, bisa dihapus jika tidak ada rencana penggunaan
  bool _isInDevelopment =
      true; // Variabel ini tidak digunakan, bisa dihapus jika tidak ada rencana penggunaan
  bool _isLoadingCheckMemberBalanceCard = false;
  bool _isLoadingCheckMemberActionButton = false;

  // Controller untuk input teks
  TextEditingController namaController = TextEditingController();

  final dataKey = GlobalKey(); // Key global untuk widget tertentu

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

    _futureArticleCategories = ArticleRepository().getAllCategories();

    _refreshData();

    _futureGreeting = fetchGreeting().whenComplete(() {
      if (mounted) {
        setState(() {
          _isLoadingOverlay = false;
          print('DashboardScreen: Overlay loading dinonaktifkan.');
        });
      }
    });
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
          // --- PERUBAHAN: Memanggil cekMember dan langsung update _memberStatus ---
          try {
            _memberStatus = await cekMember(_userModel!.id.toString());
          } catch (e) {
            print('DashboardScreen: Error mengambil status member: $e');
            _memberStatus = 0; // Default ke 0 jika ada error
          }
          // --- AKHIR PERUBAHAN ---
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
    // --- PERUBAHAN: Menghapus setState(_isLoadingBalance = true) di awal ---
    // setState(() {
    //   _isLoadingBalance = true;
    // });
    // --- AKHIR PERUBAHAN ---
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
        // --- PERUBAHAN: Menghapus setState(_isLoadingBalance = false) di finally ---
        // setState(() {
        //   _isLoadingBalance = false;
        // });
        // --- AKHIR PERUBAHAN ---
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
                        child: (_memberStatus ==
                                4) // Jika status 4 (member aktif)
                            ? _buildBalanceCard(screenWidth, screenHeight)
                            : _aktifkanpensiunkuPlus(screenWidth, screenHeight),
                      ),
                      // --- AKHIR PERUBAHAN ---
                      SizedBox(height: screenHeight * 0.015),

                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04),
                        child: _buildSimulasiPensiunku(
                            context, screenWidth, screenHeight),
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

                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04),
                        child: _buildMenuFeatures(
                            context, screenWidth, screenHeight),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      _buildHeaderImage(context, screenWidth, screenHeight),
                      SizedBox(height: screenHeight * 0.015),
                      _buildArticleFeatures(context, screenWidth, screenHeight),
                      SizedBox(height: screenHeight * 0.06),
                    ],
                  ),
                ),
              ),
            ),
          ),
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
          IconButton(
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
        ],
      ),
    );
  }

  Widget _buildGreeting(double screenWidth, double screenHeight) {
    final TextStyle greetingStyle = TextStyle(
      fontSize: screenWidth * 0.032,
      fontWeight: FontWeight.normal,
      color: Color(0Xff017964),
    );
    final TextStyle boldStyle = TextStyle(
      fontSize: screenWidth * 0.035,
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
                Spacer(),
                // --- PERUBAHAN: Menghilangkan CircularProgressIndicator, langsung tampilkan saldo atau "Error" ---
                Text(
                  _userBalance,
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                // --- AKHIR PERUBAHAN ---
              ],
            ),
            // --- PERUBAHAN: Menghilangkan _isLoadingCheckMemberBalanceCard ---
            // if (_isLoadingCheckMemberBalanceCard)
            //   Center(
            //     child: CircularProgressIndicator(
            //       strokeWidth: screenWidth * 0.008,
            //     ),
            //   ),
            // --- AKHIR PERUBAHAN ---
          ],
        ),
      ),
    );
  }

  // Widget _aktifkanpensiunkuPlus dipindahkan ke sini
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
              Spacer(),
              // --- PERUBAHAN: Menampilkan "Rp 0" secara langsung tanpa loading indicator ---
              Text(
                'Rp 0',
                style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              // --- AKHIR PERUBAHAN ---
            ],
          ),
          SizedBox(height: screenHeight * 0.01),
          // --- PERUBAHAN: Menghilangkan _isLoadingCheckMemberBalanceCard di sini juga ---
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
          // --- AKHIR PERUBAHAN ---
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
        Color shadowColor = Colors.transparent}) {
      final double imageSize = screenWidth * 0.14;
      final double paddingHorizontal = screenWidth * 0.03;
      final double paddingVertical = screenHeight * 0.01;

      return ElevatedButton(
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
                ),
        ),
      ],
    );
  }

  Widget _buildHeaderImage(
      BuildContext context, double screenWidth, double screenHeight) {
    final List<String> images = [
      'assets/dashboard_screen/image_1.png',
      'assets/dashboard_screen/image_2.png',
      'assets/dashboard_screen/image_3.png'
    ];

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
            IconMenu(
              image: "assets/dashboard_screen/icon_event.png",
              title: "Events",
              routeNamed: EventScreen.ROUTE_NAME,
              useBox: false,
            ),
            IconMenu(
              image: "assets/dashboard_screen/icon_article.png",
              title: "Artikel",
              routeNamed: ArticleScreen.ROUTE_NAME,
              arguments:
                  ArticleScreenArguments(articleCategories: _articleCategories),
              useBox: false,
            ),
            IconMenu(
              image: "assets/dashboard_screen/icon_halo_pensiun.png",
              title: "Halo Pensiun",
              routeNamed: HalopensiunScreen.ROUTE_NAME,
              useBox: false,
            ),
            IconMenu(
              image: "assets/dashboard_screen/icon_forum.png",
              title: "PensiTalk",
              routeNamed: ForumScreen.ROUTE_NAME,
              useBox: false,
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.0, vertical: screenHeight * 0.005),
          child: Row(
            children: [
              SizedBox(
                width: screenWidth * 0.22,
                child: IconMenu(
                  image: "assets/dashboard_screen/icon_karir.png",
                  title: "Karir",
                  routeNamed: KarirScreen.ROUTE_NAME,
                  useBox: false,
                ),
              ),
              SizedBox(width: screenWidth * 0.022),
              SizedBox(
                width: screenWidth * 0.22,
                child: IconMenu(
                  image: "assets/dashboard_screen/icon_franchise.png",
                  title: "Franchise",
                  routeNamed: UsahaScreen.ROUTE_NAME,
                  useBox: false,
                ),
              ),
              SizedBox(width: screenWidth * 0.073),
              SizedBox(
                width: screenWidth * 0.34,
                child: IconMenu(
                  image: "assets/dashboard_screen/icon_toko.png",
                  title: "",
                  routeNamed: TokoScreen.ROUTE_NAME,
                  arguments: TokoScreenArguments(categoryId: 1),
                  useBox: false,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<List<ArticleCategoryModel>> _getArticleCategories() async {
    print('DashboardScreen: _getArticleCategories dipanggil.');
    if (_articleCategories.isNotEmpty) {
      print(
          'DashboardScreen: Kategori artikel sudah tersedia: ${_articleCategories.length} kategori.');
      return Future.value(_articleCategories);
    } else {
      print(
          'DashboardScreen: Kategori artikel belum tersedia, menunggu hasil _futureArticleCategories...');
      try {
        final result = await _futureArticleCategories;
        if (result.data != null && result.data!.isNotEmpty) {
          if (mounted) {
            setState(() {
              _articleCategories = result.data!;
            });
          }
          print(
              'DashboardScreen: Kategori artikel berhasil diambil ulang: ${_articleCategories.length} kategori.');
          return _articleCategories;
        } else {
          print('DashboardScreen: Data kategori artikel kosong dari API.');
          throw Exception(result.error ?? 'Data artikel kosong.');
        }
      } catch (e) {
        print(
            'DashboardScreen: Error memuat kategori artikel di _getArticleCategories: ${e.toString()}');
        throw Exception(
            'Gagal memuat kategori artikel di _getArticleCategories.');
      }
    }
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
                    child: CircularProgressIndicator(),
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



// // Widget Balance Card: Menampilkan informasi dompet dan tombol aksi
//   Widget _buildBalanceCard(double screenWidth, double screenHeight) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(screenWidth * 0.04),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(screenWidth * 0.03),
//         color: Colors.white.withOpacity(0.5),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 1,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.account_balance_wallet_outlined,
//                   color: Colors.black, size: screenWidth * 0.05),
//               SizedBox(width: screenWidth * 0.02),
//               Text(
//                 'Dompet Anda',
//                 style: TextStyle(
//                   fontSize: screenWidth * 0.035,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),
//               Spacer(),
//               Text(
//                 'Rp 0',
//                 style: TextStyle(
//                     fontSize: screenWidth * 0.03,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87),
//               ),
//             ],
//           ),
//           SizedBox(height: screenHeight * 0.01),
//           _isLoadingCheckMemberBalanceCard
//               ? Center(
//                   child: CircularProgressIndicator(
//                   strokeWidth: screenWidth * 0.008,
//                 ))
//               : ElevatedButton(
//                   onPressed: () {
//                     _handleCheckMemberAndNavigateFromBalanceCard(context);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFFFFC950),
//                     minimumSize: Size(double.infinity, screenHeight * 0.035),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(screenWidth * 0.05),
//                     ),
//                     shadowColor: Colors.grey.withOpacity(0.5),
//                     elevation: 5,
//                   ),
//                   child: RichText(
//                     text: TextSpan(
//                       text: 'Aktifkan ',
//                       style: TextStyle(
//                         fontSize: screenWidth * 0.035,
//                         fontWeight: FontWeight.normal,
//                         color: Colors.green[900],
//                       ),
//                       children: [
//                         TextSpan(
//                             text: 'Pensiunku+',
//                             style: TextStyle(fontWeight: FontWeight.bold)),
//                         TextSpan(
//                             text: ' Sekarang',
//                             style: TextStyle(fontWeight: FontWeight.normal)),
//                       ],
//                     ),
//                   ),
//                 ),
//         ],
//       ),
//     );
//   }

// // Widget Carousel Slider: Menampilkan produk menggunakan carousel
//   Widget _buildCarouselSlider(
//       BuildContext context, double screenWidth, double screenHeight) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: EdgeInsets.only(
//               left: screenWidth * 0.075, bottom: screenHeight * 0.01),
//           child: Text(
//             'Produk',
//             style: TextStyle(
//                 fontSize: screenWidth * 0.035,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black),
//           ),
//         ),
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.002),
//           child: CarouselSlider.builder(
//             options: CarouselOptions(
//               height: screenHeight * 0.30,
//               autoPlay: true,
//               enlargeCenterPage: true,
//               aspectRatio: 0.8,
//               autoPlayCurve: Curves.fastOutSlowIn,
//               enableInfiniteScroll: true,
//               autoPlayAnimationDuration: const Duration(milliseconds: 800),
//               viewportFraction: 0.45,
//             ),
//             itemCount: programList.length,
//             itemBuilder: (BuildContext context, int index, int realIndex) {
//               return Container(
//                 margin: EdgeInsets.all(screenWidth * 0.001),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(screenWidth * 0.035),
//                   image: DecorationImage(
//                     image: AssetImage(imageList[index]),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//                 child: Stack(
//                   children: [
//                     Positioned(
//                       top: screenHeight * 0.025,
//                       left: 0,
//                       right: 0,
//                       child: Center(
//                         child: Text(
//                           programList[index],
//                           style: TextStyle(
//                             fontSize: screenWidth * 0.038,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black,
//                             shadows: [
//                               Shadow(
//                                 blurRadius: 5.0,
//                                 color: Colors.black38,
//                                 offset: Offset(2.0, 2.0),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

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