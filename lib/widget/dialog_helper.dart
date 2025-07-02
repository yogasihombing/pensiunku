import 'dart:ui';
import 'package:flutter/material.dart';

// DialogHelper yang telah di-upgrade
enum DialogType { info, success, error }

class DialogHelper extends StatelessWidget {
  final String? title;
  final String description;
  final String? buttonText;
  final VoidCallback? onButtonPress;
  final DialogType dialogType;
  final bool autoNavigate;
  final bool autoBack;
  final Widget? nextPage;

  const DialogHelper({
    Key? key,
    this.title,
    required this.description,
    this.buttonText,
    this.onButtonPress,
    this.dialogType = DialogType.info,
    this.autoNavigate = false,
    this.autoBack = false,
    this.nextPage,
  }) : super(key: key);

  // Menambahkan kembali static showErrorDialog agar kompatibel dengan konstruktor baru
  static void showErrorDialog(
      BuildContext context, String title, String message,
      {String buttonText = "OK", VoidCallback? onOk}) {
    showDialog(
      context: context,
      builder: (context) => DialogHelper(
        title: title,
        description: message,
        dialogType: DialogType.error,
        buttonText:
            buttonText, // Explicitly pass buttonText, now nullable in constructor
        onButtonPress: onOk ?? () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Menentukan skema warna berdasarkan dialogType
    late Color backgroundColor;
    late Color titleTextColor;
    late Color descriptionTextColor;
    late Color buttonBackgroundColor;
    late Color buttonTextColor;

    switch (dialogType) {
      case DialogType.info:
        backgroundColor = const Color(0xFFFFC950);
        titleTextColor = Colors.black;
        descriptionTextColor = Colors.black;
        buttonBackgroundColor = Colors.black;
        buttonTextColor = backgroundColor;
        break;
      case DialogType.success:
        backgroundColor = const Color(0xFF017964);
        titleTextColor = Colors.white;
        descriptionTextColor = Colors.white;
        buttonBackgroundColor = Colors.white;
        buttonTextColor = backgroundColor;
        break;
      case DialogType.error:
        backgroundColor = Colors.red;
        titleTextColor = Colors.white;
        descriptionTextColor = Colors.white;
        buttonBackgroundColor = Colors.white;
        buttonTextColor = backgroundColor;
        break;
    }

    // Auto navigation: jika autoNavigate true, lakukan aksi setelah delay 2 detik.
    if (autoNavigate) {
      Future.delayed(const Duration(seconds: 2), () {
        if (autoBack) {
          Navigator.of(context).pop();
        } else if (nextPage != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => nextPage!),
          );
        }
      });
    }

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 15),
        content: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null) ...[
                Text(
                  title!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: titleTextColor,
                  ),
                ),
                const SizedBox(height: 10),
              ],
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: descriptionTextColor,
                ),
              ),
              if (buttonText != null) ...[
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: buttonTextColor,
                    backgroundColor: buttonBackgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Tutup dialog
                    if (onButtonPress != null) {
                      onButtonPress!();
                    }
                    if (nextPage != null) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => nextPage!),
                      );
                    }
                  },
                  child: Text(buttonText!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
// // Fungsi untuk menampilkan dialog sesuai kasus
//   void _showCaseDialog(BuildContext context, int caseNumber) {
//     switch (caseNumber) {
//       case 1:
//         // Case 1: Dialog dengan Title, Deskripsi, dan Auto-Navigate ke halaman berikutnya tanpa tombol.
//         showDialog(
//           context: context,
//           builder: (context) => const DialogHelper(
//             title: "Sukses!",
//             description: "Data berhasil disimpan. Mengarahkan ke halaman berikutnya...",
//             dialogType: DialogType.success,
//             autoNavigate: true,
//             nextPage: NextPage(),
//           ),
//         );
//         break;
//       case 2:
//         // Case 2: Dialog dengan Deskripsi dan Tombol (tanpa Title) yang menjalankan aksi tertentu.
//         showDialog(
//           context: context,
//           builder: (context) => DialogHelper(
//             description: "Pastikan data yang diinput sudah benar.",
//             buttonText: "OK",
//             onButtonPress: () {
//               // Aksi tambahan jika diperlukan
//               print("Tombol ditekan pada dialog tanpa title");
//             },
//             dialogType: DialogType.info,
//           ),
//         );
//         break;
//       case 3:
//         // Case 3: Dialog hanya dengan Deskripsi.
//         showDialog(
//           context: context,
//           builder: (context) => const DialogHelper(
//             description: "Hanya informasi saja tanpa aksi.",
//             dialogType: DialogType.info,
//           ),
//         );
//         break;
//       case 4:
//         // Case 4: Dialog dengan Title, Deskripsi, dan Tombol yang menavigasi ke halaman berikutnya.
//         showDialog(
//           context: context,
//           builder: (context) => DialogHelper(
//             title: "Informasi",
//             description: "Klik tombol untuk melanjutkan ke halaman berikutnya.",
//             buttonText: "Lanjut",
//             onButtonPress: () {
//               print("Navigasi ke halaman berikutnya...");
//             },
//             dialogType: DialogType.info,
//             nextPage: const NextPage(),
//           ),
//         );
//         break;
//       case 5:
//         // Case 5: Dialog dengan Title, Deskripsi, dan Auto-Back (kembali ke halaman sebelumnya) setelah 2 detik.
//         showDialog(
//           context: context,
//           builder: (context) => const DialogHelper(
//             title: "Selesai",
//             description: "Operasi selesai. Kembali ke halaman sebelumnya...",
//             dialogType: DialogType.info,
//             autoNavigate: true,
//             autoBack: true,
//           ),
//         );
//         break;
//     }
//   }
