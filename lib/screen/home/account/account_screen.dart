import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pensiunku/model/ktp_model.dart';
import 'package:pensiunku/model/referral_model.dart';
import 'package:pensiunku/repository/referral_repository.dart';
import 'package:pensiunku/repository/result_model.dart';
import 'package:pensiunku/screen/home/account/account_info/account_info_screen.dart';
import 'package:pensiunku/screen/home/account/customer_support/customer_support_screen.dart';
import 'package:pensiunku/screen/home/account/faq/faq_screen.dart';
import 'package:pensiunku/screen/home/account/referral/confirm_ktp_referral_screen.dart';
import 'package:pensiunku/screen/home/account/referral/referral_screen.dart';
import 'package:pensiunku/screen/home/account/referral/referral_success_screen.dart';
import 'package:pensiunku/screen/home/submission/riwayat_pengajuan_anda.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:pensiunku/util/widget_util.dart';
import 'package:pensiunku/widget/grey_button.dart';
import 'package:pensiunku/config.dart' show apiHost;

class AccountScreen extends StatefulWidget {
  final void Function(int index) onChangeBottomNavIndex;
  // final ReferralModel referralModel;

  const AccountScreen({
    Key? key,
    required this.onChangeBottomNavIndex,
    // required this.referralModel,
  }) : super(key: key);

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late ResultModel<ReferralModel> resultReferralModel;

  @override
  void initState() {
    super.initState();

    // Future.delayed(Duration(milliseconds: 0), () {
    //   setState(() {
    //     _isBottomNavBarVisible = true;
    //   });
    // });

    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    ReferralRepository().getAll(token!).then((result) {
      setState(() {
        resultReferralModel = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var menus = [
      {
        'title': 'Informasi Akun',
        'onTap': () {
          Navigator.of(context)
              .pushNamed(AccountInfoScreen.ROUTE_NAME)
              .then((newIndex) {
            if (newIndex is int) {
              widget.onChangeBottomNavIndex(newIndex);
            }
          });
        },
      },
      {
        'title': 'Pengajuan Anda',
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
        'title': 'Hubungi Customer Support',
        'onTap': () {
          Navigator.of(context)
              .pushNamed(CustomerSupportScreen.ROUTE_NAME)
              .then((newIndex) {
            if (newIndex is int) {
              widget.onChangeBottomNavIndex(newIndex);
            }
          });
        }
      },
      {
        'title': 'Referral',
        'onTap': () {
          if (resultReferralModel.data?.fotoKtp == null) {
            log("masuk referal null");
            resultReferralModel = ResultModel(
                isSuccess: resultReferralModel.isSuccess,
                message: resultReferralModel.message,
                data: ReferralModel(
                    fotoKtp: null,
                    nameKtp: null,
                    nikKtp: null,
                    addressKtp: null,
                    jobKtp: null,
                    birthDateKtp: null,
                    referal: null));
            Navigator.of(context)
                .pushNamed(ReferralScreen.ROUTE_NAME,
                    arguments: ReferralScreenArguments(
                        referralModel: resultReferralModel.data!,
                        onSuccess: (referalContext) {
                          Navigator.of(referalContext).pop(true);
                        }))
                .then((newIndex) {
              if (newIndex is int) {
                widget.onChangeBottomNavIndex(newIndex);
              }
            });
          } else if (resultReferralModel.data?.referal == null) {
            log("masuk referal untuk input kode referal");
            Navigator.of(context)
                .pushNamed(ConfirmKtpReferalScreen.ROUTE_NAME,
                    arguments: ConfirmKtpReferalScreenArgs(
                        referralModel: resultReferralModel.data!,
                        ktpModel: KtpModel(
                            // image: File('asset/selfie_filter.png'),
                            image: File(
                                '$apiHost/fotoktp/${resultReferralModel.data!.fotoKtp?.replaceAll('.jpg', '')}'),
                            name: resultReferralModel.data!.nameKtp,
                            nik: resultReferralModel.data!.nikKtp,
                            address: resultReferralModel.data!.addressKtp,
                            birthDate: resultReferralModel.data!.birthDateKtp,
                            job: null,
                            jobConfidence: null,
                            jobOriginalText: resultReferralModel.data!.jobKtp),
                        onSuccess: (referalContext) {
                          Navigator.of(referalContext).pop(true);
                        }))
                .then((newIndex) {
              if (newIndex is int) {
                widget.onChangeBottomNavIndex(newIndex);
              }
            });
          } else {
            Navigator.of(context)
                .pushNamed(ReferralSuccessScreen.ROUTE_NAME,
                    arguments: ReferralSuccessScreenArgs(
                        referralModel: resultReferralModel.data!))
                .then((newIndex) {
              if (newIndex is int) {
                widget.onChangeBottomNavIndex(newIndex);
              }
            });
          }
        }
      },
    ];

    return WillPopScope(
      onWillPop: () async {
        widget.onChangeBottomNavIndex(0);
        return true;
      },
      child: Scaffold(
        appBar: WidgetUtil.getNewAppBar(
          context,
          'Akun',
          2,
          (newIndex) {
            widget.onChangeBottomNavIndex(newIndex);
          },
          () {
            Navigator.of(context).pop(); // Kembali ke halaman sebelumnya
            // widget.onChangeBottomNavIndex(0);
          },
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 32.0,
            horizontal: 24.0,
          ),
          child: Column(
            children: [
              ...menus.map(
                (menu) => Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: GreyButton(
                    title: menu['title'] as String,
                    color: Color(0xfff7f7f7),
                    borderRadius: 36.0,
                    onTap: () {
                      (menu['onTap'] as Function())();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
