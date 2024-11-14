import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:pensiunku/model/selfie_model.dart';
import 'package:pensiunku/model/submission_model.dart';
import 'package:pensiunku/screen/permission/permission_screen.dart';
import 'package:pensiunku/screen/selfie/preview_selfie_screen.dart';
import 'package:pensiunku/util/firebase_vision_util.dart';
import 'package:pensiunku/util/widget_util.dart';
import 'package:pensiunku/widget/floating_bottom_navigation_bar.dart';
import 'package:permission_handler/permission_handler.dart';

class PrepareSelfieScreenArguments {
  final void Function(BuildContext context) onSuccess;
  final SubmissionModel submissionModel;

  PrepareSelfieScreenArguments({
    required this.onSuccess,
    required this.submissionModel,
  });
}

class PrepareSelfieScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/selfie/prepare';

  final void Function(BuildContext context) onSuccess;
  final SubmissionModel submissionModel;

  const PrepareSelfieScreen({
    Key? key,
    required this.onSuccess,
    required this.submissionModel,
  }) : super(key: key);

  @override
  _PrepareSelfieScreenState createState() => _PrepareSelfieScreenState();
}

class _PrepareSelfieScreenState extends State<PrepareSelfieScreen> {
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
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 32.0,
                        horizontal: 24.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            child: Image.asset(
                              'assets/document/selfie_new.png',
                              fit: BoxFit.fill,
                            ),
                            height: 200,
                          ),
                          SizedBox(height: 16.0),
                          Text(
                              'Mohon untuk menangkap foto sesuai frame objek yang telah ditentukan. Jangan lupa pastikan Anda memiliki cahaya dan posisi yang cukup untuk menghasilkan foto yang baik. Foto yang jelas memudahkan kami untuk melakukan verifikasi pengajuan Anda.'),
                          SizedBox(height: 24.0),
                          Text(
                            '*Sebelum mengambil foto, mohon pastikan Rotation Lock/Kunci Rotasi pada Hp anda telah aktif!',
                            style: theme.textTheme.headline2?.copyWith(
                              color: Colors.red,
                            ),
                          ),
                          SizedBox(height: 28.0),
                          // Align(
                          //   alignment: Alignment.center,
                          //   child: ElevatedButton(
                          //     onPressed: () {
                          //       Navigator.of(
                          //         context,
                          //         rootNavigator: true,
                          //       )
                          //           .pushNamed(PermissionScreen.ROUTE_NAME)
                          //           .then((permissionStatus) {
                          //         switch (permissionStatus) {
                          //           case PermissionStatus.granted:
                          //             Navigator.of(
                          //               context,
                          //               rootNavigator: true,
                          //             )
                          //                 .pushNamed(
                          //               CameraKtpScreen.ROUTE_NAME,
                          //               arguments: CameraKtpScreenArgs(
                          //                 cameraFilter:
                          //                     'assets/selfie_filter.png',
                          //                 buildFilter: (context) {
                          //                   return Container(
                          //                     constraints:
                          //                         const BoxConstraints.expand(),
                          //                     child: CustomPaint(
                          //                       painter: SelfieFramePainter(
                          //                         screenSize:
                          //                             MediaQuery.of(context)
                          //                                 .size,
                          //                         outerFrameColor:
                          //                             Color(0x73442C2E),
                          //                         closeWindow: false,
                          //                         innerFrameColor:
                          //                             Colors.transparent,
                          //                         // offset: Offset(faceBoxOffsetX, 0),
                          //                       ),
                          //                     ),
                          //                   );
                          //                 },
                          //                 onProcessImage: (file,
                          //                         cameraLensDirection) =>
                          //                     FirebaseVisionUtils
                          //                         .getSelfieVisionDataFromImage(
                          //                   file,
                          //                   imageRotation:
                          //                       cameraLensDirection ==
                          //                               CameraLensDirection.back
                          //                           ? 0
                          //                           : 0,
                          //                 ),
                          //                 onPreviewImage:
                          //                     (pageContext, selfieModel) {
                          //                   return Navigator.of(pageContext)
                          //                       .pushNamed(
                          //                     PreviewSelfieScreen.ROUTE_NAME,
                          //                     arguments:
                          //                         PreviewSelfieScreenArgs(
                          //                       selfieModel:
                          //                           selfieModel as SelfieModel,
                          //                       submissionModel:
                          //                           widget.submissionModel,
                          //                     ),
                          //                   );
                          //                 },
                          //               ),
                          //             )
                          //                 .then((returnValue) {
                          //               // print('returnValue: $returnValue');
                          //               if (returnValue != null) {
                          //                 // User completes Selfie
                          //                 widget.onSuccess(context);
                          //               }
                          //             });
                          //             break;
                          //           case PermissionStatus.limited:
                          //           case PermissionStatus.denied:
                          //           case PermissionStatus.permanentlyDenied:
                          //           case PermissionStatus.restricted:
                          //           default:
                          //             WidgetUtil.showSnackbar(
                          //               context,
                          //               'Tolong izinkan Kredit Pensiun untuk mengakses kamera Anda.',
                          //               snackbarAction: SnackBarAction(
                          //                 label: 'Pengaturan',
                          //                 onPressed: () {
                          //                   openAppSettings();
                          //                 },
                          //               ),
                          //             );
                          //         }
                          //       });
                          //     },
                          //     child: Text('Ambil Foto'),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    SizedBox(height: 80.0),
                  ],
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