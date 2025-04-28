import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PosterDialog {
  // Variabel statis untuk melacak apakah dialog sudah ditampilkan dalam sesi ini
  static bool _hasShownInCurrentSession = false;
  // URL Google Play Store yang akan dibuka
  static const String playstoreUrl =
      'https://play.google.com/store/apps/details?id=com.taspen.tcds';

  // Method untuk membuka URL
  static Future<void> _launchURL() async {
    try {
      final Uri url = Uri.parse(playstoreUrl);
      if (!await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      )) {
        throw Exception('Tidak dapat membuka $playstoreUrl');
      }
    } catch (e) {
      debugPrint('Error membuka URL: $e');
    }
  }

  // Method statis untuk menampilkan dialog poster dengan animasi
  static void show(BuildContext context) {
    // Cek apakah sudah ditampilkan dalam sesi ini
    if (!_hasShownInCurrentSession) {
      _hasShownInCurrentSession = true; // Tandai bahwa dialog sudah ditampilkan

      showGeneralDialog(
        context: context,
        barrierDismissible: false,
        barrierLabel: "Poster Dialog",
        barrierColor: Colors.black.withOpacity(0.7),
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => Container(), // Tidak digunakan
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          return ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            ),
            child: FadeTransition(
              opacity: animation,
              child: Dialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                insetPadding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Container untuk poster dengan shadow
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            // Gambar poster
                            Image.asset(
                              'assets/poster/show_poster1.png',
                              fit: BoxFit.cover,
                            ),
                            // Gradient overlay di bagian bawah untuk tombol
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 80,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.8),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Badge "Baru" di pojok kanan atas
                            Positioned(
                              top: 16,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFC950),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  "BARU",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Tombol untuk action
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Tombol Tutup
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20), // Sesuaikan padding horizontal
                            minimumSize:
                                const Size(0, 35), // Hilangkan lebar minimum
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 5,
                            shadowColor: Colors.black.withOpacity(0.1),
                            visualDensity:
                                VisualDensity.compact, // Padatkan layout
                          ),
                          child: const Text(
                            'Tutup',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        // Tombol Play Store
                        ElevatedButton(
                          onPressed: _launchURL,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF017964),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15), // Sesuaikan padding
                            minimumSize: const Size(0, 35),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 5,
                            shadowColor:
                                const Color(0xFF01875F).withOpacity(0.3),
                            visualDensity: VisualDensity.compact,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // const Icon(Icons.android, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'Play Store',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
  }

  // Method untuk reset status (dipanggil saat aplikasi dibuka)
  static void resetShowStatus() {
    _hasShownInCurrentSession = false;
  }

  // Method untuk menampilkan dialog dengan animasi konfeti
  static void showWithConfetti(BuildContext context) {
    show(context);
    // Tambahkan tampilan konfeti di sini jika menggunakan library konfeti
    // Contoh: jika menggunakan confetti package
    // ConfettiController confettiController = ConfettiController(duration: const Duration(seconds: 2));
    // confettiController.play();
  }
}

// Tambahan: Widget untuk tampilan poster dengan animasi shimmer ketika loading
class ShimmerPosterLoader extends StatefulWidget {
  final double width;
  final double height;

  const ShimmerPosterLoader({
    Key? key,
    this.width = 300,
    this.height = 450,
  }) : super(key: key);

  @override
  State<ShimmerPosterLoader> createState() => _ShimmerPosterLoaderState();
}

class _ShimmerPosterLoaderState extends State<ShimmerPosterLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment(_animation.value, 0),
                end: Alignment(_animation.value + 1, 0),
                colors: [
                  Colors.grey[300]!,
                  Colors.grey[100]!,
                  Colors.grey[300]!,
                ],
                stops: const [0.35, 0.5, 0.65],
              ).createShader(bounds);
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// /// Class PosterDialog yang telah ditingkatkan dengan fitur canggih
// class PosterDialog {
//   // Variabel statis untuk melacak status
//   static bool _hasShownInCurrentSession = false;
//   static int _lastShownPosterIndex = 0;
//   static const String _prefKeyLastShownDate = 'poster_last_shown_date';
//   static const String _prefKeyDontShowAgain = 'poster_dont_show_again';

//   /// Preload gambar poster untuk menghindari lag saat ditampilkan
//   static Future<void> preloadPosterImages(BuildContext context) async {
//     final posters = _getAvailablePosters();
//     for (final poster in posters) {
//       await precacheImage(AssetImage(poster), context);
//     }
//   }

//   /// Mendapatkan daftar poster yang tersedia
//   static List<String> _getAvailablePosters() {
//     return [
//       'assets/poster/show_poster1.png',
//       'assets/poster/show_poster2.png',
//       'assets/poster/show_poster3.png',
//     ];
//   }

//   /// Mendapatkan poster berikutnya untuk sistem rotasi
//   static String _getNextPosterAsset({bool random = false}) {
//     final posters = _getAvailablePosters();
    
//     if (random) {
//       final randomIndex = DateTime.now().millisecondsSinceEpoch % posters.length;
//       _lastShownPosterIndex = randomIndex;
//       return posters[randomIndex];
//     }
    
//     final currentIndex = _lastShownPosterIndex;
//     _lastShownPosterIndex = (currentIndex + 1) % posters.length;
//     return posters[_lastShownPosterIndex];
//   }

//   /// Memeriksa apakah poster boleh ditampilkan berdasarkan pengaturan
//   static Future<bool> _canShowPoster() async {
//     final prefs = await SharedPreferences.getInstance();
    
//     // Cek pengaturan "jangan tampilkan lagi"
//     final dontShowAgain = prefs.getBool(_prefKeyDontShowAgain) ?? false;
//     if (dontShowAgain) {
//       return false;
//     }
    
//     // Cek tanggal terakhir kali ditampilkan
//     final lastShownDateString = prefs.getString(_prefKeyLastShownDate);
//     if (lastShownDateString != null) {
//       final lastShownDate = DateTime.parse(lastShownDateString);
//       final currentDate = DateTime.now();
      
//       // Jika sudah ditampilkan hari ini, jangan tampilkan lagi
//       if (lastShownDate.year == currentDate.year && 
//           lastShownDate.month == currentDate.month && 
//           lastShownDate.day == currentDate.day) {
//         return false;
//       }
//     }
    
//     return true;
//   }

//   /// Menyimpan tanggal terakhir poster ditampilkan
//   static Future<void> _saveLastShownDate() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_prefKeyLastShownDate, DateTime.now().toIso8601String());
//   }

//   /// Menyimpan pengaturan "jangan tampilkan lagi"
//   static Future<void> setDontShowAgain(bool value) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(_prefKeyDontShowAgain, value);
//   }

//   /// Reset semua pengaturan poster
//   static Future<void> resetAllSettings() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_prefKeyLastShownDate);
//     await prefs.remove(_prefKeyDontShowAgain);
//     _hasShownInCurrentSession = false;
//   }

//   /// Method untuk reset status sesi
//   static void resetShowStatus() {
//     _hasShownInCurrentSession = false;
//   }

//   /// Catat analitik untuk interaksi dengan poster
//   static Future<void> _logAnalytics(String action, {Map<String, dynamic>? extraData}) async {
//     // Implementasi integrasi dengan Firebase Analytics atau layanan lain
//     debugPrint('PosterDialog Analytics: $action ${extraData ?? {}}');
    
//     // Contoh untuk Firebase Analytics:
//     // FirebaseAnalytics.instance.logEvent(
//     //   name: 'poster_$action',
//     //   parameters: extraData,
//     // );
//   }

//   /// Method utama untuk menampilkan dialog poster dengan konfigurasi default
//   static Future<void> show(BuildContext context) async {
//     await showCustom(context: context);
//   }

//   /// Method untuk menampilkan dialog poster dengan animasi konfeti
//   static Future<void> showWithConfetti(BuildContext context) async {
//     await showCustom(
//       context: context,
//       enableConfetti: true
//     );
//   }

//   /// Method utama dengan parameter konfigurasi lengkap
//   static Future<void> showCustom({
//     required BuildContext context,
//     String? posterAsset,
//     Duration? displayDuration,
//     Color primaryButtonColor = Colors.blue,
//     String primaryButtonText = 'Lihat Detail',
//     VoidCallback? onPrimaryButtonPressed,
//     Color secondaryButtonColor = Colors.white,
//     String secondaryButtonText = 'Tutup',
//     bool showBadge = true,
//     String badgeText = 'BARU',
//     Color badgeColor = Colors.red,
//     bool enableSwipeToDismiss = true,
//     bool enableConfetti = false,
//     bool checkTimeRestrictions = true,
//     AnimationType animationType = AnimationType.scale,
//     bool enableRotation = false,
//     bool randomPoster = false,
//     bool showDontShowAgainOption = true,
//     bool enableAnalytics = true,
//   }) async {
//     // Cek apakah sudah ditampilkan dalam sesi ini dan cek preferensi lainnya
//     if (_hasShownInCurrentSession) {
//       return;
//     }
    
//     // Cek preferensi pengguna jika checkTimeRestrictions diaktifkan
//     if (checkTimeRestrictions) {
//       final canShow = await _canShowPoster();
//       if (!canShow) {
//         return;
//       }
//     }
    
//     _hasShownInCurrentSession = true;
//     await _saveLastShownDate();
    
//     // Pilih asset poster
//     final assetToShow = posterAsset ?? 
//                       (enableRotation ? _getNextPosterAsset(random: randomPoster) : 
//                       _getAvailablePosters().first);
    
//     // Catat analitik jika diaktifkan
//     if (enableAnalytics) {
//       await _logAnalytics('shown', extraData: {'poster': assetToShow});
//     }

//     // Durasi untuk auto-dismiss (opsional)
//     if (displayDuration != null) {
//       Future.delayed(displayDuration, () {
//         if (Navigator.of(context, rootNavigator: true).canPop()) {
//           Navigator.of(context, rootNavigator: true).pop();
//         }
//       });
//     }
    
//     return showGeneralDialog(
//       context: context,
//       barrierDismissible: enableSwipeToDismiss,
//       barrierLabel: "Poster Dialog",
//       barrierColor: Colors.black.withOpacity(0.7),
//       transitionDuration: const Duration(milliseconds: 400),
//       pageBuilder: (_, __, ___) => Container(), // Tidak digunakan
//       transitionBuilder: (context, animation, secondaryAnimation, child) {
//         Widget transitionWidget;
        
//         // Pilihan jenis animasi
//         switch (animationType) {
//           case AnimationType.scale:
//             transitionWidget = ScaleTransition(
//               scale: CurvedAnimation(
//                 parent: animation,
//                 curve: Curves.easeOutBack,
//               ),
//               child: FadeTransition(opacity: animation, child: child),
//             );
//             break;
//           case AnimationType.slideVertical:
//             transitionWidget = SlideTransition(
//               position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
//                   .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutQuart)),
//               child: FadeTransition(opacity: animation, child: child),
//             );
//             break;
//           case AnimationType.slideHorizontal:
//             transitionWidget = SlideTransition(
//               position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
//                   .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutQuart)),
//               child: FadeTransition(opacity: animation, child: child),
//             );
//             break;
//           case AnimationType.fade:
//             transitionWidget = FadeTransition(
//               opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
//               child: child,
//             );
//             break;
//         }
        
//         // Widget utama untuk dialog
//         return GestureDetector(
//           onVerticalDragEnd: enableSwipeToDismiss ? (details) {
//             if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
//               if (Navigator.of(context, rootNavigator: true).canPop()) {
//                 Navigator.of(context, rootNavigator: true).pop();
                
//                 if (enableAnalytics) {
//                   _logAnalytics('dismissed_by_swipe');
//                 }
//               }
//             }
//           } : null,
//           child: transitionWidget,
//         );
//       },
//       builder: (context) {
//         return MediaQuery.withClampedTextScaling(
//           maxScaleFactor: 1.2,
//           child: Dialog(
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//             insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
//             child: ConstrainedBox(
//               constraints: BoxConstraints(
//                 maxWidth: 400,
//                 maxHeight: MediaQuery.of(context).size.height * 0.85,
//               ),
//               child: SingleChildScrollView(
//                 physics: const ClampingScrollPhysics(),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // Container untuk poster dengan shadow
//                     SizedBox(
//                       width: double.infinity,
//                       child: AspectRatio(
//                         aspectRatio: 2/3, // Rasio aspek standar untuk poster
//                         child: Container(
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(16),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.5),
//                                 blurRadius: 20,
//                                 spreadRadius: 5,
//                               ),
//                             ],
//                           ),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(16),
//                             child: Stack(
//                               fit: StackFit.expand,
//                               children: [
//                                 // Gambar poster
//                                 Image.asset(
//                                   assetToShow,
//                                   fit: BoxFit.cover,
//                                   errorBuilder: (context, error, stackTrace) {
//                                     debugPrint('Error loading poster: $error');
//                                     return Container(
//                                       color: Colors.grey[300],
//                                       child: const Center(
//                                         child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
//                                       ),
//                                     );
//                                   },
//                                 ),
                                
//                                 // Gradient overlay di bagian bawah untuk tombol
//                                 Positioned(
//                                   bottom: 0,
//                                   left: 0,
//                                   right: 0,
//                                   child: Container(
//                                     height: 100,
//                                     decoration: BoxDecoration(
//                                       gradient: LinearGradient(
//                                         begin: Alignment.bottomCenter,
//                                         end: Alignment.topCenter,
//                                         colors: [
//                                           Colors.black.withOpacity(0.8),
//                                           Colors.transparent,
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),

//                                 // Badge "Baru" di pojok kanan atas (jika diaktifkan)
//                                 if (showBadge)
//                                   Positioned(
//                                     top: 16,
//                                     right: 16,
//                                     child: Container(
//                                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                                       decoration: BoxDecoration(
//                                         color: badgeColor,
//                                         borderRadius: BorderRadius.circular(20),
//                                         boxShadow: [
//                                           BoxShadow(
//                                             color: Colors.black.withOpacity(0.3),
//                                             blurRadius: 8,
//                                             offset: const Offset(0, 2),
//                                           ),
//                                         ],
//                                       ),
//                                       child: Text(
//                                         badgeText,
//                                         style: const TextStyle(
//                                           color: Colors.white,
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 12,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
                                  
//                                 // Konfeti (jika diaktifkan)
//                                 if (enableConfetti)
//                                   const Positioned.fill(
//                                     child: ConfettiOverlay(),
//                                   ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
                    
//                     // Tombol untuk aksi
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         // Tombol Tutup (dengan efek)
//                         Expanded(
//                           child: ElevatedButton(
//                             onPressed: () {
//                               Navigator.of(context, rootNavigator: true).pop();
//                               if (enableAnalytics) {
//                                 _logAnalytics('closed');
//                               }
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: secondaryButtonColor,
//                               foregroundColor: Colors.black,
//                               minimumSize: const Size(0, 45),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(25),
//                               ),
//                               elevation: 8,
//                               shadowColor: Colors.black.withOpacity(0.3),
//                             ),
//                             child: Text(
//                               secondaryButtonText,
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         // Tombol Lihat Detail atau aksi utama
//                         Expanded(
//                           child: ElevatedButton(
//                             onPressed: () {
//                               Navigator.of(context, rootNavigator: true).pop();
//                               if (enableAnalytics) {
//                                 _logAnalytics('action_clicked');
//                               }
//                               if (onPrimaryButtonPressed != null) {
//                                 onPrimaryButtonPressed();
//                               }
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: primaryButtonColor,
//                               foregroundColor: Colors.white,
//                               minimumSize: const Size(0, 45),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(25),
//                               ),
//                               elevation: 8,
//                               shadowColor: primaryButtonColor.withOpacity(0.5),
//                             ),
//                             child: Text(
//                               primaryButtonText,
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
                    
//                     // Opsi "Jangan tampilkan lagi"
//                     if (showDontShowAgainOption)
//                       Padding(
//                         padding: const EdgeInsets.only(top: 16),
//                         child: DontShowAgainCheckbox(
//                           onChanged: (value) async {
//                             if (value != null) {
//                               await setDontShowAgain(value);
//                               if (enableAnalytics) {
//                                 _logAnalytics('dont_show_again_set', extraData: {'value': value});
//                               }
//                             }
//                           },
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// /// Widget "Jangan tampilkan lagi" checkbox
// class DontShowAgainCheckbox extends StatefulWidget {
//   final Function(bool?)? onChanged;
  
//   const DontShowAgainCheckbox({
//     Key? key,
//     this.onChanged,
//   }) : super(key: key);

//   @override
//   State<DontShowAgainCheckbox> createState() => _DontShowAgainCheckboxState();
// }

// class _DontShowAgainCheckboxState extends State<DontShowAgainCheckbox> {
//   bool _isChecked = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadSavedPreference();
//   }

//   Future<void> _loadSavedPreference() async {
//     final prefs = await SharedPreferences.getInstance();
//     final savedValue = prefs.getBool(PosterDialog._prefKeyDontShowAgain) ?? false;
//     if (mounted) {
//       setState(() {
//         _isChecked = savedValue;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _isChecked = !_isChecked;
//         });
//         widget.onChanged?.call(_isChecked);
//       },
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           SizedBox(
//             width: 24,
//             height: 24,
//             child: Checkbox(
//               value: _isChecked,
//               onChanged: (value) {
//                 setState(() {
//                   _isChecked = value ?? false;
//                 });
//                 widget.onChanged?.call(value);
//               },
//             ),
//           ),
//           const SizedBox(width: 8),
//           const Text(
//             'Jangan tampilkan lagi',
//             style: TextStyle(color: Colors.white, fontSize: 14),
//           ),
//         ],
//       ),
//     );
//   }
// }

// /// Widget overlay konfeti
// class ConfettiOverlay extends StatefulWidget {
//   const ConfettiOverlay({Key? key}) : super(key: key);

//   @override
//   State<ConfettiOverlay> createState() => _ConfettiOverlayState();
// }

// class _ConfettiOverlayState extends State<ConfettiOverlay> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late List<ConfettiPiece> _confettiPieces;
//   final int _pieceCount = 100;
//   final Random _random = Random();

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 3),
//     );

//     _confettiPieces = List.generate(_pieceCount, (index) {
//       return ConfettiPiece(
//         color: _getRandomColor(),
//         position: Offset(_random.nextDouble(), -0.2),
//         size: _random.nextDouble() * 10 + 5,
//         speed: _random.nextDouble() * 300 + 200,
//         angle: _random.nextDouble() * 0.4 - 0.2,
//       );
//     });

//     _controller.forward();
//   }

//   Color _getRandomColor() {
//     final colors = [
//       Colors.red,
//       Colors.blue,
//       Colors.green,
//       Colors.yellow,
//       Colors.purple,
//       Colors.orange,
//       Colors.pink,
//     ];
//     return colors[_random.nextInt(colors.length)];
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _controller,
//       builder: (context, child) {
//         return CustomPaint(
//           painter: ConfettiPainter(
//             confettiPieces: _confettiPieces,
//             progress: _controller.value,
//           ),
//           size: Size.infinite,
//         );
//       },
//     );
//   }
// }

// /// Painter untuk konfeti
// class ConfettiPainter extends CustomPainter {
//   final List<ConfettiPiece> confettiPieces;
//   final double progress;

//   ConfettiPainter({
//     required this.confettiPieces,
//     required this.progress,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     for (final piece in confettiPieces) {
//       final paint = Paint()
//         ..color = piece.color
//         ..style = PaintingStyle.fill;

//       final position = Offset(
//         piece.position.dx * size.width,
//         piece.position.dy * size.height + (progress * piece.speed),
//       );

//       // Rotasi berdasarkan progress animasi
//       final rotation = piece.angle + progress * 2 * pi;

//       canvas.save();
//       canvas.translate(position.dx, position.dy);
//       canvas.rotate(rotation);

//       // Gambar bentuk konfeti (bisa kotak atau lingkaran)
//       if (piece.size % 2 == 0) {
//         canvas.drawRect(
//           Rect.fromCenter(center: Offset.zero, width: piece.size, height: piece.size),
//           paint,
//         );
//       } else {
//         canvas.drawCircle(Offset.zero, piece.size / 2, paint);
//       }

//       canvas.restore();
//     }
//   }

//   @override
//   bool shouldRepaint(ConfettiPainter oldDelegate) => true;
// }

// /// Class untuk representasi potongan konfeti
// class ConfettiPiece {
//   final Color color;
//   final Offset position; // posisi relatif (0-1)
//   final double size;
//   final double speed;
//   final double angle;

//   ConfettiPiece({
//     required this.color,
//     required this.position,
//     required this.size,
//     required this.speed,
//     required this.angle,
//   });
// }

// /// Widget untuk tampilan poster dengan animasi shimmer ketika loading
// class ShimmerPosterLoader extends StatefulWidget {
//   final double width;
//   final double height;
  
//   const ShimmerPosterLoader({
//     Key? key,
//     this.width = 300,
//     this.height = 450,
//   }) : super(key: key);

//   @override
//   State<ShimmerPosterLoader> createState() => _ShimmerPosterLoaderState();
// }

// class _ShimmerPosterLoaderState extends State<ShimmerPosterLoader> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1500),
//     )..repeat();
//     _animation = Tween<double>(begin: -2, end: 2).animate(_controller);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: widget.width,
//       height: widget.height,
//       decoration: BoxDecoration(
//         color: Colors.grey[300],
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: AnimatedBuilder(
//         animation: _animation,
//         builder: (context, child) {
//           return ShaderMask(
//             blendMode: BlendMode.srcATop,
//             shaderCallback: (bounds) {
//               return LinearGradient(
//                 begin: Alignment(_animation.value, 0),
//                 end: Alignment(_animation.value + 1, 0),
//                 colors: [
//                   Colors.grey[300]!,
//                   Colors.grey[100]!,
//                   Colors.grey[300]!,
//                 ],
//                 stops: const [0.35, 0.5, 0.65],
//               ).createShader(bounds);
//             },
//             child: Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(16),
//                 color: Colors.white,
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// /// Jenis animasi yang tersedia untuk dialog
// enum AnimationType {
//   scale,
//   slideVertical,
//   slideHorizontal,
//   fade,
// }

// /// Contoh penggunaan:
// /// 
// /// ```dart
// /// // Penggunaan dasar
// /// PosterDialog.show(context);
// /// 
// /// // Penggunaan dengan konfigurasi kustom
// /// PosterDialog.showCustom(
// ///   context: context,
// ///   posterAsset: 'assets/poster/special_promo.png',
// ///   primaryButtonText: 'Dapatkan Promo',
// ///   onPrimaryButtonPressed: () {
// ///     Navigator.pushNamed(context, '/promo');
// ///   },
// ///   enableSwipeToDismiss: true,
// ///   animationType: AnimationType.slideVertical,
// ///   showBadge: true,
// ///   badgeText: 'PROMO',
// ///   badgeColor: Colors.orange,
// /// );
// ///
// /// // Penggunaan dengan efek konfeti
// /// PosterDialog.showWithConfetti(context);
// /// ```