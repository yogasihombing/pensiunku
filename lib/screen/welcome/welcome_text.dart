import 'package:flutter/material.dart';

class WelcomeText extends StatelessWidget {
  final double offsetHeight;
  final String title;
  final String subtitle;
  final String text;

  const WelcomeText({
    Key? key,
    required this.offsetHeight,
    required this.title,
    required this.subtitle,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 12.0), // Lebih fleksibel untuk jarak kiri-kanan
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
              height: offsetHeight), // Jarak atas sesuai dengan offsetHeight
          // Judul
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins', // Font Poppins
              fontSize: 24.0, // Ukuran lebih besar
              fontWeight: FontWeight.normal,
              color: Colors.black87, // Warna teks lebih kontras
            ),
          ),
          const SizedBox(height: 1), // Jarak antar judul dan subtitle
          // Subtitle
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins', // Font Poppins
              fontSize: 28.0, // Ukuran lebih kecil dari title
              fontWeight: FontWeight.bold,
              color: Colors.black, // Warna mengikuti tema utama
            ),
          ),
          const SizedBox(height: 16.0), // Jarak antar subtitle dan teks utama
          // Deskripsi teks
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins', // Font Poppins
                fontSize: 12.0, // Ukuran teks yang nyaman dibaca
                color: Colors.black87, // Warna abu-abu gelap
                height: 1.5, // Jarak antar baris
              ),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}


// class WelcomeText extends StatelessWidget {
//   final double offsetHeight;
//   final String title;
//   final String subtitle;
//   final String text;

//   const WelcomeText({
//     Key? key,
//     required this.offsetHeight,
//     required this.title,
//     required this.subtitle,
//     required this.text,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     ThemeData theme = Theme.of(context);
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 60.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(height: offsetHeight),
//           Text(
//             title,
//             style: theme.textTheme.headline5?.copyWith(
//               height: 1.0,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           Text(
//             subtitle,
//             style: theme.textTheme.headline5?.copyWith(
//               height: 1.0,
//               fontWeight: FontWeight.w600,
//               color: theme.primaryColor,
//             ),
//           ),
//           SizedBox(height: 16.0),
//           Text(
//             text,
//             style: theme.textTheme.caption?.copyWith(),
//             maxLines: 5,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ),
//     );
//   }
// }
