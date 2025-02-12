import 'package:flutter/material.dart';
import 'package:pensiunku/model/referral_model.dart';
import 'package:pensiunku/util/widget_util.dart';

class ReferralSuccessScreenArgs {
  final ReferralModel referralModel;

  ReferralSuccessScreenArgs({
    required this.referralModel,
  });
}

class ReferralSuccessScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/referral/success';
  final ReferralModel referralModel;

  const ReferralSuccessScreen({
    Key? key,
    required this.referralModel,
  }) : super(key: key);

  @override
  _ReferralSuccessScreenState createState() => _ReferralSuccessScreenState();
}

class _ReferralSuccessScreenState extends State<ReferralSuccessScreen> {
  ReferralModel get referralModel => widget.referralModel;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(0);
        return false;
      },
      child: Scaffold(
        appBar: WidgetUtil.getNewAppBar(
          context,
          'Referral Screen',
          2,
              (newIndex) {
            Navigator.of(context).pop(newIndex);
          },
              () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Color(0xfff2f2f2),
        body: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height -
                  AppBar().preferredSize.height,
            ),
            Container(
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 90.0,
                      horizontal: 60.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 250,
                          width: 300,
                          child: Image.asset('assets/referal_screen/jump-04.png'),
                        ),
                        Text(
                          'Selamat!',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headline4?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Color(0xffffbc50),
                          ),
                        ),
                        SizedBox(height: 6.0),
                        Text(
                          'Anda sudah mengisi kode referral',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headline6?.copyWith(
                            color: Color(0xffffbc50),
                          ),
                        ),
                        SizedBox(height: 6.0),
                        Text(
                          'Kode referral anda adalah ${referralModel.referal}',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyText1?.copyWith(
                            color: Color(0xffffbc50),
                          ),
                        ),
                        SizedBox(height: 12.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
