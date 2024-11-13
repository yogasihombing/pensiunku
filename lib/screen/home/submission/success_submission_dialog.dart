import 'package:flutter/material.dart';

class SuccessSubmissionDialog extends StatefulWidget {
  @override
  _SuccessSubmissionDialogState createState() =>
      _SuccessSubmissionDialogState();
}

class _SuccessSubmissionDialogState extends State<SuccessSubmissionDialog> {
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 5), () {
      Navigator.of(context).pop(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
        child: Wrap(
          children: [
            Container(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 40.0,
                  horizontal: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Terima Kasih',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headline5?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'Pengajuan anda telah kami terima, mohon tunggu 1 x 24 jam',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headline6,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
