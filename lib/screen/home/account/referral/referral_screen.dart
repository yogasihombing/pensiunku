import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pensiunku/model/ktp_model.dart';
import 'package:pensiunku/model/referral_model.dart';
import 'package:pensiunku/repository/referral_repository.dart';
import 'package:pensiunku/repository/result_model.dart';
import 'package:pensiunku/screen/home/account/referral/confirm_ktp_referral_screen.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/ktp/camera_ktp_screen.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/ktp/preview_ktp_screen.dart';
import 'package:pensiunku/screen/permission/permission_screen.dart';
import 'package:pensiunku/util/firebase_vision_util.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:pensiunku/util/widget_util.dart';
import 'package:pensiunku/widget/floating_bottom_navigation_bar.dart';
import 'package:pensiunku/widget/sliver_app_bar_sheet_top.dart';
import 'package:pensiunku/widget/sliver_app_bar_title.dart';
import 'package:permission_handler/permission_handler.dart';

class ReferralScreenArguments {
  final ReferralModel referralModel;
  final void Function(BuildContext context) onSuccess;

  ReferralScreenArguments({
    required this.referralModel,
    required this.onSuccess,
  });

  Map toJson() => {
        'referralModel': referralModel,
        'onSuccess': onSuccess,
      };
}

//migrate from RaisedButton to ElevatedButton
final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
  primary: Color(0xff16826e),
  padding: EdgeInsets.all(10.0),
  textStyle: TextStyle(
    color: Colors.white,
  ),
  onSurface: Color(0xfff29724),
  shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(10.0))),
);

class ReferralScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/referal';
  final ReferralModel referralModel;
  final void Function(BuildContext context) onSuccess;

  const ReferralScreen({
    Key? key,
    required this.referralModel,
    required this.onSuccess,
  }) : super(key: key);

  @override
  _ReferralScreenState createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  ScrollController scrollController = new ScrollController();
  bool _isBottomNavBarVisible = false;
  late Future<ResultModel<ReferralModel>> _futureData;
  late ReferralModel referralModel;

  @override
  void initState() {
    super.initState();
    _refreshData();

    Future.delayed(Duration(milliseconds: 0), () {
      setState(() {
        _isBottomNavBarVisible = true;
      });
    });
  }

  _refreshData() {
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    return _futureData = ReferralRepository().getAll(token!).then((value) {
      if (value.error != null) {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  content: Text(value.error.toString(),
                      style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.red,
                  elevation: 24.0,
                ));
        // WidgetUtil.showSnackbar(
        //   context,
        //   value.error.toString(),
        // );
      }
      setState(() {});
      return value;
    });
  }

  Future<void> _showDescriptionDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  ElevatedButton(
                    style: raisedButtonStyle,
                    onPressed: () {
                      Navigator.of(
                        context,
                        rootNavigator: true,
                      )
                          .pushNamed(PermissionScreen.ROUTE_NAME)
                          .then((permissionStatus) {
                        switch (permissionStatus) {
                          case PermissionStatus.granted:
                            // Navigator.of(context, rootNavigator: true)
                            //     .pushNamed(CameraKtpNewScreen.ROUTE_NAME);
                            Navigator.of(
                              context,
                              rootNavigator: true,
                            )
                                .pushNamed(
                              CameraKtpScreen.ROUTE_NAME,
                              arguments: CameraKtpScreenArgs(
                                  cameraFilter: 'assets/ktp_filter.png',
                                  buildFilter: (context) {
                                    return Container(
                                      constraints:
                                          const BoxConstraints.expand(),
                                      child: CustomPaint(
                                        painter: KtpFramePainter(
                                          screenSize:
                                              MediaQuery.of(context).size,
                                          outerFrameColor: Color(0x73442C2E),
                                          innerFrameColor: Colors.transparent,
                                        ),
                                      ),
                                    );
                                  },
                                  onProcessImage: (file, _) =>
                                      FirebaseVisionUtils
                                          .getKtpVisionDataFromImage(
                                        file,
                                        isDrawSearchingArea: false,
                                        isDrawExtractedArea: true,
                                      ),
                                  onPreviewImage: (pageContext, ktpModel) {
                                    return Navigator.of(pageContext).pushNamed(
                                      PreviewKtpScreen.ROUTE_NAME,
                                      arguments: PreviewKtpScreenArgs(
                                        ktpModel: ktpModel as KtpModel,
                                      ),
                                    );
                                  }),
                            )
                                .then((value) {
                              if (value != null) {
                                KtpModel ktpModel = value as KtpModel;
                                Navigator.of(context)
                                    .pushNamed(
                                  ConfirmKtpReferalScreen.ROUTE_NAME,
                                  arguments: ConfirmKtpReferalScreenArgs(
                                    referralModel: widget.referralModel,
                                    ktpModel: ktpModel,
                                    onSuccess: (_) => widget.onSuccess(context),
                                  ),
                                )
                                    .then((returnValue) {
                                  if (returnValue is int) {
                                    // User presses BottomNavBar item
                                    Navigator.of(context).pop(returnValue);
                                  } else if (returnValue == true) {
                                    // User completes KTP
                                    widget.onSuccess(context);
                                  }
                                });
                              }
                            });
                            break;
                          case PermissionStatus.limited:
                          case PermissionStatus.denied:
                          case PermissionStatus.permanentlyDenied:
                          case PermissionStatus.restricted:
                          default:
                            WidgetUtil.showSnackbar(
                              context,
                              'Tolong izinkan Kredit Pensiun untuk mengakses kamera Anda.',
                              snackbarAction: SnackBarAction(
                                label: 'Pengaturan',
                                onPressed: () {
                                  openAppSettings();
                                },
                              ),
                            );
                        }
                      });
                    },
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Open Camera',
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    // Widget Dimensions
    Size screenSize = MediaQuery.of(context).size;
    double sliverAppBarExpandedHeight = screenSize.height * 0.32;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        child: Stack(
          children: [
            Container(
              height: sliverAppBarExpandedHeight + 72,
            ),
            Positioned.fill(
              top: 10,
              left: 40,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Referral',
                  style: theme.textTheme.headline5?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: sliverAppBarExpandedHeight,
                  flexibleSpace: FlexibleSpaceBar(
                    title: SliverAppBarTitle(
                      child: SizedBox(
                        height: AppBar().preferredSize.height * 0.4,
                      ),
                    ),
                    titlePadding: const EdgeInsets.only(
                      left: 16.0,
                      bottom: 16.0,
                    ),
                    background: Stack(
                      children: [
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 31, 157, 159),
                                  Color.fromARGB(255, 255, 221, 123),
                                ],
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: InkWell(
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: screenSize.width,
                                          child: Image.asset(
                                              'assets/referal_screen/referral-02.png',
                                              fit: BoxFit.fill),
                                        ),
                                        Positioned.fill(
                                          top: 110,
                                          left: 32,
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Program \nReferral',
                                              style: theme.textTheme.headline3
                                                  ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverAppBarSheetTop(),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Stack(
                    children: [
                      Positioned(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xfff2f2f2),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 0.0,
                              bottom: 12.0,
                              left: 32,
                              right: 32,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ambil swafoto beserta KTP Anda',
                                  style: theme.textTheme.headline6?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                    'Arahkan kamera Anda tepat sesuai frame yang telah kami tentukan. Setelah foto, mohon untuk melakukan verifikasi data KTP anda!'),
                                SizedBox(height: 25.0),
                                Text(
                                  'Cara Pengambilan Foto KTP Yang Tepat',
                                  style: theme.textTheme.headline6?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Text('\u2022 Pencahayaan terang'),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                    '\u2022 Posisikan KTP sesuaikan informasi KTP sejajar dengan tanda garis'),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                    '\u2022 Letakkan foto sejajar atau letakkan tepat masuk dalam kotak'),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                    '\u2022 Gunakan KTP yang jelas tidak Blur sehingga data dapat terbaca oleh sistem'),
                                SizedBox(
                                  height: 5,
                                ),
                                SizedBox(height: 32.0),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 100,
                                            child: Image.asset(
                                                'assets/document/ktp.png'),
                                          ),
                                          SizedBox(height: 16.0),
                                          Text(
                                            'Foto KTP',
                                            style: theme.textTheme.caption,
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 32.0),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 100,
                                            child: Image.asset(
                                                'assets/document/selfie.png'),
                                          ),
                                          SizedBox(height: 16.0),
                                          Text(
                                            'Swafoto dengan KTP',
                                            style: theme.textTheme.caption,
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 32.0),
                                Align(
                                  alignment: Alignment.center,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _showDescriptionDialog(context);
                                    },
                                    child: Text('Ambil Foto'),
                                  ),
                                ),
                                SizedBox(height: 100.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            FloatingBottomNavigationBar(
              isVisible: _isBottomNavBarVisible,
              currentIndex: 2,
              onTapItem: (newIndex) {
                Navigator.of(context).pop(newIndex);
              },
            ),
          ],
        ),
      ),
    );
  }
}
