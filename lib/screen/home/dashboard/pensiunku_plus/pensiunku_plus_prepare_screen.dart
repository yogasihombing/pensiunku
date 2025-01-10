import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pensiunku/model/referral_model.dart';
import 'package:pensiunku/repository/referral_repository.dart';
import 'package:pensiunku/repository/result_model.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';

class PensiunkuPlusPrepareScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/pensiunkuplus_prepare';

  @override
  _PensiunkuPlusPrepareScreenState createState() =>
      _PensiunkuPlusPrepareScreenState();
}

class _PensiunkuPlusPrepareScreenState
    extends State<PensiunkuPlusPrepareScreen> {
  ScrollController scrollController = ScrollController();
  bool _isBottomNavBarVisible = false;
  late Future<ResultModel<ReferralModel>> _futureData;

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

    _futureData = ReferralRepository().getAll(token!).then((value) {
      if (value.error != null) {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  content: Text(value.error.toString(),
                      style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.red,
                  elevation: 24.0,
                ));
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff16826e),
                      padding: EdgeInsets.all(10.0),
                      disabledForegroundColor:
                          Color(0xfff29724).withOpacity(0.38),
                      disabledBackgroundColor:
                          Color(0xfff29724).withOpacity(0.12),
                      textStyle: TextStyle(
                        color: Colors.white,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Open Camera'),
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
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 31, 157, 159),
                      Color.fromARGB(255, 255, 221, 123)
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Program Referral',
                      style: theme.textTheme.headline3?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () {
                        _showDescriptionDialog(context);
                      },
                      child: Text('Ambil Foto'),
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
