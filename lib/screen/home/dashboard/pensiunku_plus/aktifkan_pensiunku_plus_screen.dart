import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/pensiunku_plus_prepare_screen.dart';

class AktifkanPensiunkuPlusScreen extends StatelessWidget {
  static const String ROUTE_NAME = '/AktifkanPensiunkuPlusScreen';
  const AktifkanPensiunkuPlusScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aktifkan Pensiunku+'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aktifkan Pensiunku+',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Nikmati berbagai kemudahan dan layanan eksklusif dengan mengaktifkan Pensiunku+. Dengan fitur ini, Anda dapat mengelola dana pensiun lebih baik dan merencanakan masa depan yang cerah.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Text(
              'Keuntungan Aktifasi:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text('Akses layanan premium'),
            ),
            const ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text('Perencanaan pensiun yang lebih baik'),
            ),
            const ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text('Informasi dan konsultasi eksklusif'),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>  PensiunkuPlusPrepareScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Aktifkan Sekarang',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
