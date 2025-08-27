import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';

class KodeReferralScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/kode_referal';

  const KodeReferralScreen({Key? key}) : super(key: key);

  @override
  State<KodeReferralScreen> createState() => _KodeReferralScreenState();
}

class _KodeReferralScreenState extends State<KodeReferralScreen> {
  final TextEditingController _referralCodeController = TextEditingController();
  final String _myReferralCode = 'PENSIUNKU123';
  final String _appLink =
      'https://play.google.com/store/apps/details?id=com.pensiunku';

  @override
  void dispose() {
    _referralCodeController.dispose();
    super.dispose();
  }

  void _shareOnSocialMedia() {
    final String shareText =
        "Ayo gabung Pensiunku dan dapatkan 1000 koin! Gunakan kode referral saya: $_myReferralCode. Download sekarang juga!";
    final String shareUrl = '$_appLink&ref=$_myReferralCode';
    Share.share('$shareText\n\n$shareUrl');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = size.width * 0.05;
    final codeFontSize = size.width * 0.06;
    final titleFontSize = size.width * 0.055;
    final iconSize = size.width * 0.1;
    final verticalSpacing = size.height * 0.03;

    return Scaffold(
      // Memastikan gradient meluas ke belakang AppBar dan status bar
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF017964)),
        title: Text(
          'Kode Referral',
          style: TextStyle(
            color: const Color(0xFF017964),
            fontWeight: FontWeight.bold,
            fontSize: titleFontSize,
          ),
        ),
        
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: verticalSpacing),
                Container(
                  padding: EdgeInsets.all(padding),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kode Referral Anda',
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: verticalSpacing * 0.5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _myReferralCode,
                            style: TextStyle(
                              fontSize: codeFontSize,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF017964),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.copy,
                                size: iconSize * 0.8,
                                color: const Color(0xFF017964)),
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: _myReferralCode));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Kode referral berhasil disalin!'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: verticalSpacing),
                Center(
                  child: Text(
                    'Bagikan Kode Referral Anda',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                SizedBox(height: verticalSpacing * 0.5),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: padding,
                  runSpacing: verticalSpacing * 0.5,
                  children: [
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.squareWhatsapp,
                          size: iconSize, color: const Color(0xFF017964)),
                      onPressed: _shareOnSocialMedia,
                    ),
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.squareFacebook,
                          size: iconSize, color: const Color(0xFF017964)),
                      onPressed: _shareOnSocialMedia,
                    ),
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.squareInstagram,
                          size: iconSize, color: const Color(0xFF017964)),
                      onPressed: _shareOnSocialMedia,
                    ),
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.tiktok,
                          size: iconSize, color: const Color(0xFF017964)),
                      onPressed: _shareOnSocialMedia,
                    ),
                    IconButton(
                      icon: Icon(Icons.share,
                          size: iconSize, color: const Color(0xFF017964)),
                      onPressed: _shareOnSocialMedia,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
