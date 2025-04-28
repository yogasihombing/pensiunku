import 'package:flutter/material.dart';
import 'package:pensiunku/screen/otp/otp_screen.dart';
import 'package:pensiunku/screen/welcome/welcome_text.dart';
import 'package:pensiunku/widget/fade_up_image.dart';


/// Welcome Screen
///
/// This screen is shown for first-time user.
// Widget WelcomeScreen dengan StatefulWidget untuk mengatur tampilan awal aplikasi
class WelcomeScreen extends StatefulWidget {
  // Nama rute yang digunakan untuk navigasi ke WelcomeScreen
  static const String ROUTE_NAME = '/welcome';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

// State dari WelcomeScreen
class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  // Indeks halaman saat ini (slider)
  int _currentIndex = -1;

  // Apakah pengguna melakukan scroll manual atau tidak
  bool _isUserManualScroll = false;

  // Controller untuk mengatur PageView
  late PageController _pageViewController;

  // Data untuk konten halaman slider
  final contents = [
    {
      'title': 'Proses Mudah',
      'subtitle': 'Semua Dari Rumah',
      'text':
          'Gak perlu jauh-jauh! \n semua bisa kamu buat mudah dan \n lakukan dari rumah. #Ajukandarirumah',
    },
    {
      'title': 'Kredit Sampai Dengan',
      'subtitle': '500 Juta',
      'text':
          'Limit Kredit besar dengan segudang\n keuntungan lain yang bisa kamu\n dapatkan!',
    },
    {
      'title': 'Tenor Hingga',
      'subtitle': '15 Tahun',
      'text':
          'Tak perlu khawatir, atur jangka waktu\n pinjamanmu sesuai dengan\n keinginanmu.',
    },
  ];

  @override
  void initState() {
    super.initState();

    // Inisialisasi PageController untuk mengatur halaman awal slider
    _pageViewController = PageController(initialPage: 0, keepPage: false);

    // Delay 500 milidetik sebelum memulai slider otomatis
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _currentIndex = 0; // Set indeks pertama
      });
      _slideNextCard(); // Mulai auto-slide
    });
  }

  // Fungsi untuk auto-slide ke halaman berikutnya setelah delay 3 detik
  void _slideNextCard() {
    Future.delayed(Duration(seconds: 3), () {
      if (!_isUserManualScroll) {
        if (_currentIndex < 2) {
          _onNextPage(false); // Pindah ke halaman berikutnya
          _slideNextCard(); // Panggil ulang untuk slide berikutnya
        }
      }
    });
  }

  // Fungsi untuk skip ke halaman terakhir
  _onSkip() {
    _pageViewController.jumpToPage(2); // Lompat ke halaman terakhir
    setState(() {
      _isUserManualScroll = true; // Tandai scroll manual
    });
  }

  // Fungsi untuk berpindah ke halaman berikutnya atau ke halaman daftar
  _onNextPageOrFinish() {
    if (_currentIndex >= 2) {
      // Jika di halaman terakhir, pindah ke halaman OTP
      Navigator.of(context).pushReplacementNamed(OtpScreen.ROUTE_NAME);
    } else {
      _onNextPage(
          true); // Jika belum di halaman terakhir, pindah ke halaman berikutnya
    }
  }

  // Fungsi untuk animasi pindah ke halaman berikutnya
  _onNextPage(isUserManualScroll) {
    if (_currentIndex < 2) {
      setState(() {
        _isUserManualScroll = isUserManualScroll; // Tandai jika manual scroll
        _pageViewController.animateToPage(
          _currentIndex + 1,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeIn, // Efek animasi perpindahan halaman
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Size screenSize = MediaQuery.of(context).size;

    // Menghitung ukuran tampilan berdasarkan tinggi layar
    double screenHeight = screenSize.height;
    double backdropHeight = screenHeight * 0.50;
    // double gradientHeight = screenHeight * 0.50;
    double imageSize = 240;

    // Menghitung ukuran teks untuk tampilan
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

    // Tinggi indikator halaman
    double indicatorHeight = backdropHeight +
        27.0 +
        titleSize.height +
        subtitleSize.height +
        16.0 +
        textSize.height +
        32.0;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient - full layar
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, // Gradient mulai dari kiri
                  end: Alignment.bottomCenter, // Gradient berakhir di kanan
                  colors: [
                    Color.fromARGB(255, 170, 231, 170), // Hijau muda (pinggir kiri)
                    Color(0xFFFFF8DD), // Kuning pucat (tengah)
                    Color.fromARGB(255, 170, 231, 170), // Hijau muda (pinggir kanan)
                  ],
                  stops: [0.0, 0.5, 1.0], // Titik berhenti warna di gradient
                ),
              ),
            ),
          ),
          // Elemen lain tetap seperti gambar, teks, dll
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: backdropHeight,
                child: Stack(
                  children: [
                    // Gambar slider di sini
                    Positioned(
                      top: 150,
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
          // PageView dan elemen lainnya tetap seperti kode sebelumnya

          // Slider PageView
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
              children: contents
                  .map(
                    (content) => WelcomeText(
                      offsetHeight: backdropHeight + 32.0,
                      title: content['title'] as String,
                      subtitle: content['subtitle'] as String,
                      text: content['text'] as String,
                    ),
                  )
                  .toList(),
            ),
          // Indikator Slider dengan Animasi
          Positioned(
            bottom: 100.0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                contents.length,
                (index) => AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 4.0),
                  height: 8.0,
                  width: _currentIndex == index ? 24.0 : 8.0,
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? Color(0xFF017964)
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(12.0),
                    
                  ),
                ),
              ),
            ),
          ),
          // Tombol Skip di halaman pertama
          if (_currentIndex == 0)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _onSkip,
                      child: Text(
                        'Skip',
                        style: theme.textTheme.button?.copyWith(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      

      // Tombol Lanjutkan atau Daftar
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _currentIndex >= 0
          ? Container(
              margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ElevatedButton(
                onPressed: _onNextPageOrFinish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // Warna tombol sesuai gambar
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32.0), // Tombol rounded
                  ),
                ),
                child: Text(
                  _currentIndex < 3 ? 'Lanjutkan' : 'DAFTAR',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              
            )
          : null,
         
    );
  }

  // Fungsi untuk menghitung ukuran teks
  Size _textSize(String text, TextStyle? style) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: 1,
        textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }
}
///
// class WelcomeScreen extends StatefulWidget {
//   static const String ROUTE_NAME = '/welcome';

//   @override
//   _WelcomeScreenState createState() => _WelcomeScreenState();
// }

// class _WelcomeScreenState extends State<WelcomeScreen>
//     with TickerProviderStateMixin {
//   /// The slide's current index
//   int _currentIndex = -1;

//   /// Whether user has manually scrolled the slide or not.
//   bool _isUserManualScroll = false;

//   late PageController _pageViewController;

//   final contents = [
//     {
//       'title': 'Proses Mudah',
//       'subtitle': 'Semua Dari Rumah',
//       'text':
//           'Gak perlu jauh-jauh! semua bisa kamu buat mudah dan lakukan dari rumah. #Ajukandarirumah',
//     },
//     {
//       'title': 'Kredit Sampai Dengan',
//       'subtitle': '500 Juta',
//       'text':
//           'Limit Kredit besar dengan segudang keuntungan lain yang bisa kamu dapatkan!',
//     },
//     {
//       'title': 'Tenor Hingga',
//       'subtitle': '15 Tahun',
//       'text':
//           'Tak perlu khawatir, atur jangka waktu pinjamanmu sesuai dengan keinginanmu.',
//     },
//   ];

//   @override
//   void initState() {
//     super.initState();

//     _pageViewController = PageController(initialPage: 0, keepPage: false);

//     Future.delayed(Duration(milliseconds: 500), () {
//       setState(() {
//         _currentIndex = 0;
//       });
//       // Set auto scroll cards
//       _slideNextCard();
//     });
//   }

//   void _slideNextCard() {
//     Future.delayed(Duration(seconds: 3), () {
//       // If user hasn't manually scrolled, slide next card
//       if (!_isUserManualScroll) {
//         if (_currentIndex < 2) {
//           _onNextPage(false);
//           _slideNextCard();
//         }
//       }
//     });
//   }

//   _onSkip() {
//     _pageViewController.jumpToPage(2);
//     setState(() {
//       _isUserManualScroll = true;
//     });
//   }

//   _onNextPageOrFinish() {
//     if (_currentIndex >= 2) {
//       Navigator.of(context).pushReplacementNamed(OtpScreen.ROUTE_NAME);
//     } else {
//       _onNextPage(true);
//     }
//   }

//   _onNextPage(isUserManualScroll) {
//     if (_currentIndex < 2) {
//       setState(() {
//         _isUserManualScroll = isUserManualScroll;
//         _pageViewController.animateToPage(
//           _currentIndex + 1,
//           duration: Duration(milliseconds: 300),
//           curve: Curves.easeIn,
//         );
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     ThemeData theme = Theme.of(context);
//     Size screenSize = MediaQuery.of(context).size;

//     double screenHeight = screenSize.height;
//     double backdropHeight = screenHeight * 0.60;
//     double gradientHeight = screenHeight * 0.50;
//     double imageSize = 240;

//     final Size titleSize = _textSize(
//       contents[2]['title'] as String,
//       theme.textTheme.headline5,
//     );
//     final Size subtitleSize = _textSize(
//       contents[2]['subtitle'] as String,
//       theme.textTheme.headline5,
//     );
//     final Size textSize = _textSize(
//       contents[2]['text'] as String,
//       theme.textTheme.caption,
//     );
//     double indicatorHeight = backdropHeight +
//         27.0 +
//         titleSize.height +
//         subtitleSize.height +
//         16.0 +
//         textSize.height +
//         32.0;

//     return Scaffold(
//       body: Stack(
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Container(
//                 height: backdropHeight,
//                 child: Stack(
//                   children: [
//                     Container(
//                       width: double.infinity,
//                       height: gradientHeight,
//                       child: CustomPaint(
//                         painter: OvalGradientPainter(),
//                       ),
//                     ),
//                     Positioned(
//                       top: 80.0,
//                       left: 0.0,
//                       right: 0.0,
//                       child: SizedBox(
//                         height: 60.0,
//                         child: Image.asset('assets/logo_small_white.png'),
//                       ),
//                     ),
//                     Positioned(
//                       bottom: 0.0,
//                       left: 0.0,
//                       right: 0.0,
//                       child: Container(
//                         height: imageSize,
//                         child: Stack(
//                           children: [
//                             FadeUpImage(
//                               isActive: _currentIndex == 0,
//                               assetName: 'assets/welcome_screen/image_1.png',
//                               height: imageSize,
//                             ),
//                             FadeUpImage(
//                               isActive: _currentIndex == 1,
//                               assetName: 'assets/welcome_screen/image_2.png',
//                               height: imageSize,
//                             ),
//                             FadeUpImage(
//                               isActive: _currentIndex == 2,
//                               assetName: 'assets/welcome_screen/image_3.png',
//                               height: imageSize,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           if (_currentIndex >= 0)
//             PageView(
//               onPageChanged: (newIndex) {
//                 setState(() {
//                   if (newIndex < _currentIndex) {
//                     _isUserManualScroll = true;
//                   }
//                   _currentIndex = newIndex;
//                 });
//               },
//               controller: _pageViewController,
//               scrollDirection: Axis.horizontal,
//               children: [
//                 ...contents.map(
//                   (content) => WelcomeText(
//                       offsetHeight: backdropHeight + 32.0,
//                       title: content['title'] as String,
//                       subtitle: content['subtitle'] as String,
//                       text: content['text'] as String),
//                 ),
//               ],
//             ),
          // if (_currentIndex >= 0)
          //   Positioned(
          //     top: indicatorHeight,
          //     left: 60.0,
          //     right: 0.0,
          //     child: CarouselIndicator(
          //       length: 3,
          //       currentIndex: _currentIndex.toInt(),
          //       vsync: this,
          //     ),
          //   ),
//           if (_currentIndex == 0)
//             SafeArea(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     TextButton(
//                       child: Text(
//                         'Skip',
//                         style: theme.textTheme.button?.copyWith(
//                           color: Colors.white,
//                         ),
//                       ),
//                       onPressed: _onSkip,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//       floatingActionButton: _currentIndex >= 0
//           ? InkWell(
//               onTap: _onNextPageOrFinish,
//               borderRadius: BorderRadius.circular(36.0),
//               child: Ink(
//                   decoration: BoxDecoration(
//                     color: theme.primaryColor,
//                     borderRadius: BorderRadius.circular(36.0),
//                   ),
//                   child: Padding(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 16.0,
//                         vertical: 15.0,
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             _currentIndex < 2 ? 'Lanjutkan' : 'Daftar',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               fontSize: 13,
//                               height: 1,
//                               letterSpacing: 0.5,
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           if (_currentIndex < 2) ...[
//                             SizedBox(width: 8.0),
//                             Icon(
//                               Icons.arrow_forward_ios_rounded,
//                               size: 16.0,
//                               color: Colors.white,
//                             )
//                           ]
//                         ],
//                       ))
//                   // : Padding(
//                   //     padding: const EdgeInsets.symmetric(
//                   //       horizontal: 16.0,
//                   //       vertical: 2.0,
//                   //     ),
//                   //     child: Icon(
//                   //       Icons.arrow_right_alt_rou nded,
//                   //       size: 40.0,
//                   //       color: Colors.white,
//                   //     ),
//                   //   ),
//                   ),
//             )
//           : null,
//     );
//   }

//   Size _textSize(String text, TextStyle? style) {
//     final TextPainter textPainter = TextPainter(
//         text: TextSpan(text: text, style: style),
//         maxLines: 1,
//         textDirection: TextDirection.ltr)
//       ..layout(minWidth: 0, maxWidth: double.infinity);
//     return textPainter.size;
//   }
// }
