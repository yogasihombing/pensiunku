
import 'package:flutter/material.dart';
import 'package:pensiunku/widget/dialog_helper.dart';

class DialoghelperContoh extends StatelessWidget {
  const DialoghelperContoh({Key? key}) : super(key: key);

  // Fungsi untuk menampilkan dialog sesuai kasus
  void _showCaseDialog(BuildContext context, int caseNumber) {
    switch (caseNumber) {
      case 1:
        // Case 1: Dialog dengan Title, Deskripsi, dan Auto-Navigate ke halaman berikutnya tanpa tombol.
        showDialog(
          context: context,
          builder: (context) => const DialogHelper(
            title: "Sukses!",
            description: "Data berhasil disimpan. Mengarahkan ke halaman berikutnya...",
            dialogType: DialogType.success,
            autoNavigate: true,
            nextPage: NextPage(),
          ),
        );
        break;
      case 2:
        // Case 2: Dialog dengan Deskripsi dan Tombol (tanpa Title) yang menjalankan aksi tertentu.
        showDialog(
          context: context,
          builder: (context) => DialogHelper(
            description: "Pastikan data yang diinput sudah benar.",
            buttonText: "OK",
            onButtonPress: () {
              // Aksi tambahan jika diperlukan
              print("Tombol ditekan pada dialog tanpa title");
            },
            dialogType: DialogType.info,
          ),
        );
        break;
      case 3:
        // Case 3: Dialog hanya dengan Deskripsi.
        showDialog(
          context: context,
          builder: (context) => const DialogHelper(
            description: "Hanya informasi saja tanpa aksi.",
            dialogType: DialogType.info,
          ),
        );
        break;
      case 4:
        // Case 4: Dialog dengan Title, Deskripsi, dan Tombol yang menavigasi ke halaman berikutnya.
        showDialog(
          context: context,
          builder: (context) => DialogHelper(
            title: "Informasi",
            description: "Klik tombol untuk melanjutkan ke halaman berikutnya.",
            buttonText: "Lanjut",
            onButtonPress: () {
              print("Navigasi ke halaman berikutnya...");
            },
            dialogType: DialogType.info,
            nextPage: const NextPage(),
          ),
        );
        break;
      case 5:
        // Case 5: Dialog dengan Title, Deskripsi, dan Auto-Back (kembali ke halaman sebelumnya) setelah 2 detik.
        showDialog(
          context: context,
          builder: (context) => const DialogHelper(
            title: "Selesai",
            description: "Operasi selesai. Kembali ke halaman sebelumnya...",
            dialogType: DialogType.info,
            autoNavigate: true,
            autoBack: true,
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Contoh DialogHelper")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            ElevatedButton(
              onPressed: () => _showCaseDialog(context, 1),
              child: const Text("Case 1: Auto-Navigate ke Next Page"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showCaseDialog(context, 2),
              child: const Text("Case 2: Dialog dengan Deskripsi & Tombol (No Title)"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showCaseDialog(context, 3),
              child: const Text("Case 3: Dialog Hanya Deskripsi"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showCaseDialog(context, 4),
              child: const Text("Case 4: Title, Deskripsi, & Tombol ke Next Page"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showCaseDialog(context, 5),
              child: const Text("Case 5: Auto-Back ke Halaman Sebelumnya"),
            ),
          ],
        ),
      ),
    );
  }
}

// Contoh halaman berikutnya
class NextPage extends StatelessWidget {
  const NextPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Halaman Berikutnya")),
      body: const Center(
        child: Text(
          "Ini adalah halaman berikutnya",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
