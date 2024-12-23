import 'package:flutter/material.dart';

/// Card displayed in the WelcomeScreen.
class WelcomeCard extends StatelessWidget {
  final String imageUrl;
  final String title;

  const WelcomeCard({
    Key? key,
    required this.imageUrl,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double cardWidth = screenWidth * 0.85; // Lebar card lebih fleksibel
    double cardHeight = cardWidth * 1.2; // Rasio tinggi card

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Card dengan shadow dan border radius
        Container(
          margin: const EdgeInsets.symmetric(
              vertical: 16.0), // Margin atas dan bawah
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(20.0), // Radius border lebih halus
            boxShadow: [
              BoxShadow(
                color: Colors.black26, // Warna shadow lebih soft
                offset: Offset(0, 4), // Posisi shadow sedikit ke bawah
                blurRadius: 12.0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0), // Sama dengan container
            child: AspectRatio(
              aspectRatio: 4 / 5, // Menjaga rasio gambar agar konsisten
              child: Image.asset(
                imageUrl,
                fit: BoxFit.cover, // Mengatur gambar agar mengisi container
              ),
            ),
          ),
        ),
        SizedBox(height: 16.0), // Jarak antara card dan teks
        // Judul teks
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headline6?.copyWith(
              fontSize: 20.0, // Ukuran font sedang
              fontWeight: FontWeight.w700, // Font lebih tegas
              color: Colors.black87, // Warna lebih netral
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:pensiunku/screen/welcome/welcome_screen.dart';

// /// Card displayed in the [WelcomeScreen].
// ///
// class WelcomeCard extends StatelessWidget {
//   final String imageUrl;
//   final String title;

//   const WelcomeCard({
//     Key? key,
//     required this.imageUrl,
//     required this.title,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     ThemeData theme = Theme.of(context);
//     Size screenSize = MediaQuery.of(context).size;
//     double screenWidth = screenSize.width;
//     double screenHeight = screenSize.height;

//     return Column(
//       children: [
//         SizedBox(height: 24.0),
//         Container(
//           decoration: BoxDecoration(
//             color: Colors.grey,
//             borderRadius: BorderRadius.circular(16.0),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey,
//                 offset: Offset(5, 5),
//                 blurRadius: 10.0,
//               ),
//             ],
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(16.0),
//             child: Container(
//               width: screenWidth * 0.75,
//               height: screenHeight * 0.65,
//               decoration: BoxDecoration(
//                 color: Colors.grey,
//                 image: DecorationImage(
//                   image: AssetImage(imageUrl),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//           ),
//         ),
//         SizedBox(height: 36.0),
//         Text(
//           title,
//           textAlign: TextAlign.center,
//           style: theme.textTheme.headline5?.copyWith(
//             color: theme.primaryColor,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ],
//     );
//   }
// }
