import 'package:flutter/material.dart';
import 'package:pensiunku/model/ktp_model.dart';
import 'package:pensiunku/model/submission_model.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/ktp/camera_ktp_screen.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/ktp/confirm_ktp_screen.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/ktp/preview_ktp_screen.dart';
// import 'package:pensiunku/screen/ktp/camera_ktp_screen.dart';
// import 'package:pensiunku/screen/ktp/confirm_ktp_screen.dart';
// import 'package:pensiunku/screen/ktp/preview_ktp_screen.dart';
import 'package:pensiunku/screen/permission/permission_screen.dart';
import 'package:pensiunku/util/firebase_vision_util.dart';
import 'package:pensiunku/util/widget_util.dart';
import 'package:pensiunku/widget/floating_bottom_navigation_bar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';

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

class PrepareKtpScreenArguments {
  final SubmissionModel submissionModel;
  final void Function(BuildContext context) onSuccess;

  PrepareKtpScreenArguments({
    required this.submissionModel,
    required this.onSuccess,
  });
}

class PrepareKtpScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/ktp/prepare';

  final SubmissionModel submissionModel;
  final void Function(BuildContext context) onSuccess;

  const PrepareKtpScreen({
    Key? key,
    required this.submissionModel,
    required this.onSuccess,
  }) : super(key: key);

  @override
  _PrepareKtpScreenState createState() => _PrepareKtpScreenState();
}

class _PrepareKtpScreenState extends State<PrepareKtpScreen> {
  bool _isBottomNavBarVisible = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: 0), () {
      setState(() {
        _isBottomNavBarVisible = true;
      });
    });
  }

  void _openGallery() async {
    var picture = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      // file = picture;
    });
    Navigator.of(context).pop();
  }

  Future<void> _showDescriptionDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Cara Pengambilan Foto KTP Yang Tepat',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
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
                                  ConfirmKtpScreen.ROUTE_NAME,
                                  arguments: ConfirmKtpScreenArgs(
                                    submissionModel: widget.submissionModel,
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

  Future<void> _showChoiceDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Pilih Foto KTP',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  ElevatedButton(
                    style: raisedButtonStyle,
                    onPressed: () {
                      _showDescriptionDialog(context);
                    },
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Camera',
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    style: raisedButtonStyle,
                    onPressed: () => {},
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Gallery',
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

    return Scaffold(
      appBar: WidgetUtil.getNewAppBar(context, 'Informasi Identitas', 1,
          (newIndex) {
        Navigator.of(context).pop(newIndex);
      }, () {
        Navigator.of(context).pop();
      }, useNotificationIcon: false),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height -
                      AppBar().preferredSize.height,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 32.0,
                    horizontal: 24.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      SizedBox(height: 32.0),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 100,
                                  child: Image.asset('assets/document/ktp.png'),
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
                                      'assets/document/selfie_new.png'),
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
                      SizedBox(height: 24.0),
                      Text(
                        '*Sebelum mengambil foto, mohon pastikan Rotation Lock/Kunci Rotasi pada Hp anda telah aktif!',
                        style: theme.textTheme.subtitle1?.copyWith(
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(height: 28.0),
                      Align(
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          onPressed: () {
                            _showDescriptionDialog(context);
                            // Navigator.of(
                            //   context,
                            //   rootNavigator: true,
                            // )
                            //     .pushNamed(PermissionScreen.ROUTE_NAME)
                            //     .then((permissionStatus) {
                            //   switch (permissionStatus) {
                            //     case PermissionStatus.granted:
                            //       // Navigator.of(context, rootNavigator: true)
                            //       //     .pushNamed(CameraKtpNewScreen.ROUTE_NAME);
                            //       Navigator.of(
                            //         context,
                            //         rootNavigator: true,
                            //       )
                            //           .pushNamed(
                            //         CameraKtpScreen.ROUTE_NAME,
                            //         arguments: CameraKtpScreenArgs(
                            //             cameraFilter: 'assets/ktp_filter.png',
                            //             buildFilter: (context) {
                            //               return Container(
                            //                 constraints:
                            //                     const BoxConstraints.expand(),
                            //                 child: CustomPaint(
                            //                   painter: KtpFramePainter(
                            //                     screenSize:
                            //                         MediaQuery.of(context).size,
                            //                     outerFrameColor:
                            //                         Color(0x73442C2E),
                            //                     innerFrameColor:
                            //                         Colors.transparent,
                            //                   ),
                            //                 ),
                            //               );
                            //             },
                            //             onProcessImage: (file, _) =>
                            //                 FirebaseVisionUtils
                            //                     .getKtpVisionDataFromImage(
                            //                   file,
                            //                   isDrawSearchingArea: false,
                            //                   isDrawExtractedArea: true,
                            //                 ),
                            //             onPreviewImage:
                            //                 (pageContext, ktpModel) {
                            //               return Navigator.of(pageContext)
                            //                   .pushNamed(
                            //                 PreviewKtpScreen.ROUTE_NAME,
                            //                 arguments: PreviewKtpScreenArgs(
                            //                   ktpModel: ktpModel as KtpModel,
                            //                 ),
                            //               );
                            //             }),
                            //       )
                            //           .then((value) {
                            //         if (value != null) {
                            //           KtpModel ktpModel = value as KtpModel;
                            //           Navigator.of(context)
                            //               .pushNamed(
                            //             ConfirmKtpScreen.ROUTE_NAME,
                            //             arguments: ConfirmKtpScreenArgs(
                            //               submissionModel:
                            //                   widget.submissionModel,
                            //               ktpModel: ktpModel,
                            //               onSuccess: (_) =>
                            //                   widget.onSuccess(context),
                            //             ),
                            //           )
                            //               .then((returnValue) {
                            //             if (returnValue is int) {
                            //               // User presses BottomNavBar item
                            //               Navigator.of(context)
                            //                   .pop(returnValue);
                            //             } else if (returnValue == true) {
                            //               // User completes KTP
                            //               widget.onSuccess(context);
                            //             }
                            //           });
                            //         }
                            //       });
                            //       break;
                            //     case PermissionStatus.limited:
                            //     case PermissionStatus.denied:
                            //     case PermissionStatus.permanentlyDenied:
                            //     case PermissionStatus.restricted:
                            //     default:
                            //       WidgetUtil.showSnackbar(
                            //         context,
                            //         'Tolong izinkan Kredit Pensiun untuk mengakses kamera Anda.',
                            //         snackbarAction: SnackBarAction(
                            //           label: 'Pengaturan',
                            //           onPressed: () {
                            //             openAppSettings();
                            //           },
                            //         ),
                            //       );
                            //   }
                            // });
                          },
                          child: Text('Ambil Foto'),
                        ),
                      ),
                      SizedBox(height: 80.0),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // FloatingBottomNavigationBar(
          //   isVisible: _isBottomNavBarVisible,
          //   currentIndex: 1,
          //   onTapItem: (newIndex) {
          //     Navigator.of(context).pop(newIndex);
          //   },
          // ),
        ],
      ),
    );
  }
}
