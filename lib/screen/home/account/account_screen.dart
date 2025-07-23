import 'package:flutter/material.dart';
import 'package:pensiunku/model/user_model.dart';

import 'package:pensiunku/model/result_model.dart';
import 'package:pensiunku/repository/user_repository.dart';
import 'package:pensiunku/screen/home/account/TNC/term_and_condition.dart';
import 'package:pensiunku/screen/home/account/account_info/account_info_screen.dart';
import 'package:pensiunku/screen/home/account/customer_support/customer_support_screen.dart';
import 'package:pensiunku/screen/home/account/faq/faq_screen.dart';
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
  bool _isActivated = false;

  @override
  void initState() {
    super.initState();

    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);
    if (token != null) {
      _future = UserRepository().getOne(token);
      _future.then((result) {
        if (result.error == null) {
          setState(() {
            _userModel = result.data;
            _isActivated = _userModel?.isActivated ??
                false; // Mengecek status aktifasi dari user

            // Tambahkan log ini untuk melihat ID di konsol
            print('User ID: ${_userModel?.id}');
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var menus = [
      {
        'title': 'Pengajuan Anda',
        'image': 'assets/icon/profile/pengajuan_anda.png',
        'onTap': () {
          Navigator.of(context)
              .pushNamed(RiwayatPengajuanAndaScreen.ROUTE_NAME)
              .then((newIndex) {
            if (newIndex is int) {
              widget.onChangeBottomNavIndex(newIndex);
            }
          });
        }
      },
      {
        'title': 'FAQ',
        'image': 'assets/icon/profile/faq.png',
        'onTap': () {
          Navigator.of(context)
              .pushNamed(FaqScreen.ROUTE_NAME)
              .then((newIndex) {
            if (newIndex is int) {
              widget.onChangeBottomNavIndex(newIndex);
            }
          });
        },
      },
      {
        'title': 'Customer Support',
        'image': 'assets/icon/profile/cs.png',
        'onTap': () {
          Navigator.of(context)
              .pushNamed(CustomerSupportScreen.ROUTE_NAME)
              .then((newIndex) {
            if (newIndex is int) {
              widget.onChangeBottomNavIndex(newIndex);
            }
          });
        },
      },
      {
        'title': 'Syarat dan Ketentuan',
        'image': 'assets/icon/profile/syarat_ketentuan.png',
        'onTap': () {
          Navigator.of(context)
              .pushNamed(TermAndConditionScreen.ROUTE_NAME)
              .then((newIndex) {
            if (newIndex is int) {
              widget.onChangeBottomNavIndex(newIndex);
            }
          });
        },
      },
      {
        'title': 'Kebijakan Privasi',
        'image': 'assets/icon/profile/kebijakan_privasi.png',
        'onTap': () {
          Navigator.of(context)
              .pushNamed(PrivacyPolicyScreen.ROUTE_NAME)
              .then((newIndex) {
            if (newIndex is int) {
              widget.onChangeBottomNavIndex(newIndex);
            }
          });
        },
      },
    ];

    return WillPopScope(
      onWillPop: () async {
        widget.onChangeBottomNavIndex(0);
        return true;
      },
      child: Scaffold(
        body: Stack(
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
              padding: const EdgeInsets.symmetric(
                vertical: 35.0,
                horizontal: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button and title
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Color(0xFF017964)),
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
                  const SizedBox(height: 25.0),
                  // Profil Container
                  InkWell(
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed(AccountInfoScreen.ROUTE_NAME)
                          .then((newIndex) {
                        if (newIndex is int) {
                          widget.onChangeBottomNavIndex(newIndex);
                        }
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
                            radius: 30,
                            backgroundColor: Colors.white,
                            child: const Icon(
                              Icons.person,
                              size: 40,
                              color: Color(0xFF017964),
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          // Nama dan Email
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_userModel?.username ?? 'Pengguna'}',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4.0),
                                Text(
                                  '${_userModel?.email ?? 'Pengguna'}',
                                  style: TextStyle(
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
