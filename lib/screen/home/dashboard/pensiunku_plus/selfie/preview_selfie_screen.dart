import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pensiunku/model/selfie_model.dart';
import 'package:pensiunku/model/submission_model.dart';
import 'package:pensiunku/repository/submission_repository.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:pensiunku/widget/elevated_button_loading.dart';

class PreviewSelfieScreenArgs {
  final SubmissionModel submissionModel;
  final SelfieModel selfieModel;

  PreviewSelfieScreenArgs({
    required this.submissionModel,
    required this.selfieModel,
  });
}

class PreviewSelfieScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/selfie/preview';

  final SubmissionModel submissionModel;
  final SelfieModel selfieModel;

  const PreviewSelfieScreen({
    Key? key,
    required this.submissionModel,
    required this.selfieModel,
  }) : super(key: key);

  @override
  State<PreviewSelfieScreen> createState() => _PreviewSelfieScreenState();
}

class _PreviewSelfieScreenState extends State<PreviewSelfieScreen> {
  bool _isLoading = false;

  _retakePhoto(BuildContext context) {
    Navigator.of(context).pop(false);
  }

  // _confirmPhoto(BuildContext context) {
  //   setState(() {
  //     _isLoading = true;
  //   });

  //   String? token = SharedPreferencesUtil()
  //       .sharedPreferences
  //       .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

  //   SubmissionRepository()
  //       .uploadSelfie(
  //     token!,
  //     widget.submissionModel,
  //     widget.selfieModel.image.path,
  //   )
  //       .then((result) {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     if (result.isSuccess) {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //       Navigator.of(context).pop(true);
  //     } else {
  //       showDialog(
  //           context: context,
  //           builder: (_) => AlertDialog(
  //                 content: Text(result.error ?? 'Gagal mengirimkan foto selfie',
  //                     style: TextStyle(color: Colors.white)),
  //                 backgroundColor: Colors.red,
  //                 elevation: 24.0,
  //               ));
  //       // WidgetUtil.showSnackbar(
  //       //     context, result.error ?? 'Gagal mengirimkan foto selfie');
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Color(0xfff2f2f2),
      body: Stack(
        children: [
          Positioned(
            top: 0.0,
            bottom: 0.0,
            left: 16.0,
            right: 16.0,
            child: Center(
              child: SizedBox(
                child: Image.file(
                  File(widget.selfieModel.image.path),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 32.0,
            left: 0.0,
            right: 0.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                !_isLoading
                    ? ElevatedButton(
                        onPressed: () => _retakePhoto(context),
                        child: Text('Ulangi'),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          onPrimary: theme.colorScheme.secondary,
                        ),
                      )
                    : TextButton(
                        onPressed: null,
                        child: Text('Ulangi'),
                      ),
                SizedBox(width: 32.0),
                // ElevatedButtonLoading(
                //   text: 'Lanjutkan',
                //   onTap: () => _confirmPhoto(context),
                //   isLoading: _isLoading,
                //   disabled: _isLoading,
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
