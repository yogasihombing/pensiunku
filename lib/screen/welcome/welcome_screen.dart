import 'package:flutter/material.dart';
import 'package:pensiunku/screen/otp/otp_screen.dart';
import 'package:pensiunku/screen/welcome/welcome_text.dart';
import 'package:pensiunku/widget/carousel_indicator.dart';
import 'package:pensiunku/widget/fade_up_image.dart';
import 'package:pensiunku/widget/oval_gradient_painter.dart';

/// Welcome Screen
///
/// This screen is shown for first-time user.
///
class WelcomeScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/welcome';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  /// The slide's current index
  int _currentIndex = -1;

  /// Whether user has manually scrolled the slide or not.
  bool _isUserManualScroll = false;

  late PageController _pageViewController;

  final contents = [
    {
      'title': 'Pengajuan',
      'subtitle': 'Dari Rumah',
      'text':
          'Anda hanya perlu dirumah dan tak perlu repot-repot datang ke Bank untuk mengantri ataupun berkonsultasi.',
    },
    {
      'title': 'Kredit Sampai Dengan',
      'subtitle': '500 Juta',
      'text': 'Nikmati Plafond pengajuan yang besar hingga 500 Juta!',
    },
    {
      'title': 'Tenor Hingga',
      'subtitle': '15 Tahun',
      'text':
          'Tak perlu khawatir, atur jangka waktu pinjaman Anda secara suka - suka dan manfaatkan jangka waktu panjang hingga 15 tahun',
    },
  ];

  @override
  void initState() {
    super.initState();

    _pageViewController = PageController(initialPage: 0, keepPage: false);

    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _currentIndex = 0;
      });
      // Set auto scroll cards
      _slideNextCard();
    });
  }

  void _slideNextCard() {
    Future.delayed(Duration(seconds: 3), () {
      // If user hasn't manually scrolled, slide next card
      if (!_isUserManualScroll) {
        if (_currentIndex < 2) {
          _onNextPage(false);
          _slideNextCard();
        }
      }
    });
  }

  _onSkip() {
    _pageViewController.jumpToPage(2);
    setState(() {
      _isUserManualScroll = true;
    });
  }

  _onNextPageOrFinish() {
    if (_currentIndex >= 2) {
      Navigator.of(context).pushReplacementNamed(OtpScreen.ROUTE_NAME);
    } else {
      _onNextPage(true);
    }
  }

  _onNextPage(isUserManualScroll) {
    if (_currentIndex < 2) {
      setState(() {
        _isUserManualScroll = isUserManualScroll;
        _pageViewController.animateToPage(
          _currentIndex + 1,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Size screenSize = MediaQuery.of(context).size;

    double screenHeight = screenSize.height;
    double backdropHeight = screenHeight * 0.60;
    double gradientHeight = screenHeight * 0.50;
    double imageSize = 240;

    final Size titleSize = _textSize(
      contents[2]['title'] as String,
      theme.textTheme.headline5,
    );
    final Size subtitleSize = _textSize(
      contents[2]['subtitle'] as String,
      theme.textTheme.headline5,
    );
    final Size textSize = _textSize(
      contents[2]['text'] as String,
      theme.textTheme.caption,
    );
    double indicatorHeight = backdropHeight +
        32.0 +
        titleSize.height +
        subtitleSize.height +
        16.0 +
        textSize.height +
        32.0;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: backdropHeight,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: gradientHeight,
                      child: CustomPaint(
                        painter: OvalGradientPainter(),
                      ),
                    ),
                    Positioned(
                      top: 80.0,
                      left: 0.0,
                      right: 0.0,
                      child: SizedBox(
                        height: 60.0,
                        child: Image.asset('assets/logo_small_white.png'),
                      ),
                    ),
                    Positioned(
                      bottom: 0.0,
                      left: 0.0,
                      right: 0.0,
                      child: Container(
                        height: imageSize,
                        child: Stack(
                          children: [
                            FadeUpImage(
                              isActive: _currentIndex == 0,
                              assetName: 'assets/welcome_screen/image_1.png',
                              height: imageSize,
                            ),
                            FadeUpImage(
                              isActive: _currentIndex == 1,
                              assetName: 'assets/welcome_screen/image_2.png',
                              height: imageSize,
                            ),
                            FadeUpImage(
                              isActive: _currentIndex == 2,
                              assetName: 'assets/welcome_screen/image_3.png',
                              height: imageSize,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_currentIndex >= 0)
            PageView(
              onPageChanged: (newIndex) {
                setState(() {
                  if (newIndex < _currentIndex) {
                    _isUserManualScroll = true;
                  }
                  _currentIndex = newIndex;
                });
              },
              controller: _pageViewController,
              scrollDirection: Axis.horizontal,
              children: [
                ...contents.map(
                  (content) => WelcomeText(
                      offsetHeight: backdropHeight + 32.0,
                      title: content['title'] as String,
                      subtitle: content['subtitle'] as String,
                      text: content['text'] as String),
                ),
              ],
            ),
          if (_currentIndex >= 0)
            Positioned(
              top: indicatorHeight,
              left: 60.0,
              right: 0.0,
              child: CarouselIndicator(
                length: 3,
                currentIndex: _currentIndex.toInt(),
                vsync: this,
              ),
            ),
          if (_currentIndex == 0)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: Text(
                        'Skip',
                        style: theme.textTheme.button?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      onPressed: _onSkip,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _currentIndex >= 0
          ? InkWell(
              onTap: _onNextPageOrFinish,
              borderRadius: BorderRadius.circular(36.0),
              child: Ink(
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(36.0),
                ),
                child: _currentIndex >= 2
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 15.0,
                        ),
                        child: Text(
                          'Daftar',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1,
                            letterSpacing: 0.5,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ))
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 2.0,
                        ),
                        child: Icon(
                          Icons.arrow_right_alt_rounded,
                          size: 40.0,
                          color: Colors.white,
                        ),
                      ),
              ),
            )
          : null,
    );
  }

  Size _textSize(String text, TextStyle? style) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: 1,
        textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }
}
