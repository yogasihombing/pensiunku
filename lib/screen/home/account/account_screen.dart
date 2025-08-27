import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pensiunku/model/user_model.dart';

import 'package:pensiunku/model/result_model.dart';
import 'package:pensiunku/repository/user_repository.dart';
import 'package:pensiunku/screen/home/account/TNC/term_and_condition.dart';
import 'package:pensiunku/screen/home/account/account_info/account_info_screen.dart';
import 'package:pensiunku/screen/home/account/customer_support/customer_support_screen.dart';
import 'package:pensiunku/screen/home/account/faq/faq_screen.dart';
import 'package:pensiunku/screen/home/account/kode_referral/kode_referral_screen.dart';
import 'package:pensiunku/screen/home/account/privacy_policy/privacy_policy.dart';
import 'package:pensiunku/screen/home/submission/riwayat_pengajuan_anda.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';

class AccountScreen extends StatefulWidget {
  final void Function(int index) onChangeBottomNavIndex;

  const AccountScreen({
    Key? key,
    required this.onChangeBottomNavIndex,
  }) : super(key: key);

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  UserModel? _userModel; // Model pengguna (opsional)
  late Future<ResultModel<UserModel>> _future;
  String _appVersion = 'Versi: N/A'; // Variabel untuk menyimpan versi aplikasi

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _getAppVersion();
  }

  // Metode untuk memuat data pengguna dari API
  void _loadUserData() {
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);
    if (token != null) {
      _future = UserRepository().getOne(token);
      _future.then((result) {
        if (result.error == null && mounted) {
          setState(() {
            _userModel = result.data;
            print('User ID: ${_userModel?.id}');
          });
        }
      });
    }
  }

  // Metode untuk mendapatkan versi aplikasi
  Future<void> _getAppVersion() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = 'Versi: ${info.version} (${info.buildNumber})';
    });
  }

  @override
  Widget build(BuildContext context) {
    // Definisi menu dipindahkan ke dalam build method agar bisa diperbarui
    var menus = [
      {
        'title': 'Pengajuan Anda',
        'image': 'assets/icon/profile/pengajuan_anda.png',
        'onTap': () async {
          await Navigator.of(context)
              .pushNamed(RiwayatPengajuanAndaScreen.ROUTE_NAME);
          _loadUserData(); // Memuat ulang data setelah kembali
        }
      },
      {
        'title': 'FAQ',
        'image': 'assets/icon/profile/faq.png',
        'onTap': () async {
          await Navigator.of(context).pushNamed(FaqScreen.ROUTE_NAME);
          _loadUserData();
        },
      },
      {
        'title': 'Customer Support',
        'image': 'assets/icon/profile/cs.png',
        'onTap': () async {
          await Navigator.of(context)
              .pushNamed(CustomerSupportScreen.ROUTE_NAME);
          _loadUserData();
        },
      },
      {
        'title': 'Syarat dan Ketentuan',
        'image': 'assets/icon/profile/syarat_ketentuan.png',
        'onTap': () async {
          await Navigator.of(context)
              .pushNamed(TermAndConditionScreen.ROUTE_NAME);
          _loadUserData();
        },
      },
      {
        'title': 'Kebijakan Privasi',
        'image': 'assets/icon/profile/kebijakan_privasi.png',
        'onTap': () async {
          await Navigator.of(context).pushNamed(PrivacyPolicyScreen.ROUTE_NAME);
          _loadUserData();
        },
      },
      // {
      //   'title': 'Kode Referral',
      //   'image': 'assets/icon/profile/referral.png',
      //   'onTap': () async {
      //     await Navigator.of(context).pushNamed(KodeReferralScreen.ROUTE_NAME);
      //     _loadUserData();
      //   },
      // },
    ];

    return WillPopScope(
      onWillPop: () async {
        widget.onChangeBottomNavIndex(0);
        return true;
      },
      child: Scaffold(
        body: FutureBuilder<ResultModel<UserModel>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                  child: Text('Gagal memuat data: ${snapshot.error}'));
            } else if (snapshot.hasData && snapshot.data?.data != null) {
              _userModel = snapshot.data!.data!;
              return _buildMainContent(context, menus);
            } else {
              return const Center(child: Text('Tidak ada data pengguna.'));
            }
          },
        ),
      ),
    );
  }

  Widget _buildMainContent(
      BuildContext context, List<Map<String, dynamic>> menus) {
    // Ambil tinggi dan lebar layar
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        // Background gradient
        Positioned.fill(
          child: Container(
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
        ),
        // Main content
        Padding(
          // Padding vertikal dan horizontal proporsional
          padding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.04, // 4% dari tinggi layar
            horizontal: screenWidth * 0.05, // 5% dari lebar layar
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button and title
              Row(
                children: [
                  IconButton(
                    icon:
                        const Icon(Icons.arrow_back, color: Color(0xFF017964)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Akun',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF017964),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              // Jarak dinamis
              SizedBox(height: screenHeight * 0.03), // 3% dari tinggi layar
              // Profil Container
              InkWell(
                onTap: () {
                  Navigator.of(context)
                      .pushNamed(AccountInfoScreen.ROUTE_NAME)
                      .then((_) {
                    _loadUserData(); // Memuat ulang data saat kembali dari AccountInfoScreen
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: const Color(0XFFD9D9D9),
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 6.0,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Icon Profile
                      CircleAvatar(
                        radius: screenWidth * 0.08, // Radius proporsional
                        backgroundColor: Colors.white,
                        backgroundImage: _userModel?.profilePictureUrl != null
                            ? NetworkImage(_userModel!.profilePictureUrl!)
                                as ImageProvider<Object>?
                            : null,
                        child: _userModel?.profilePictureUrl == null
                            ? Icon(
                                Icons.person,
                                size: screenWidth * 0.1, // Ukuran dinamis
                                color: Color(0xFF017964),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16.0),
                      // Nama dan Email
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  _userModel?.username ?? 'Pengguna',
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (_userModel?.isPensiunkuPlus == true)
                                  Icon(
                                    Icons.verified,
                                    color: Colors.blue,
                                    size: screenWidth * 0.05, // Ukuran dinamis
                                  )
                              ],
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              _userModel?.email ?? 'Pengguna',
                              style: const TextStyle(
                                fontSize: 11.0,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8.0),
                  itemCount: menus.length,
                  itemBuilder: (context, index) {
                    final menu = menus[index];
                    return InkWell(
                      onTap: menu['onTap'] as void Function()?,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              blurRadius: 4.0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            if (menu['image'] != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 24.0),
                                child: Image.asset(
                                  menu['image'] as String,
                                  width: 30.0,
                                  height: 24.0,
                                ),
                              ),
                            Expanded(
                              child: Text(
                                menu['title'] as String,
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Tambahkan SizedBox untuk jarak di bawah ListView
              SizedBox(height: screenHeight * 0.02), // 2% dari tinggi layar
              // Teks versi aplikasi yang baru
              Center(
                child: Text(
                  _appVersion,
                  style: const TextStyle(
                    fontSize: 12.0,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
            ],
          ),
        ),
      ],
    );
  }
}
