import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pensiunku/model/ktp_model.dart';

class PreviewKtpScreenArgs {
  final KtpModel ktpModel;

  PreviewKtpScreenArgs({
    required this.ktpModel,
  });
}

class PreviewKtpScreen extends StatelessWidget {
  static const String ROUTE_NAME = '/ktp/preview';

  final KtpModel ktpModel;

  const PreviewKtpScreen({
    Key? key,
    required this.ktpModel,
  }) : super(key: key);

  _retakePhoto(BuildContext context) {
    Navigator.of(context).pop(false);
  }

  _confirmPhoto(BuildContext context) {
    Navigator.of(context).pop(true);
  }

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
                  File(ktpModel.image.path),
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
                ElevatedButton(
                  onPressed: () => _retakePhoto(context),
                  child: Text('Ulangi'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: theme.colorScheme.secondary,
                  ),
                ),
                SizedBox(width: 32.0),
                ElevatedButton(
                  onPressed: () => _confirmPhoto(context),
                  child: Text('Lanjutkan'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
