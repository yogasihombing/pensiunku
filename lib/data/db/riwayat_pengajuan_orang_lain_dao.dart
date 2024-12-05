import 'package:pensiunku/data/api/riwayat_pengajuan_orang_lain_api.dart';

class RiwayatPengajuanOrangLainDao {
  final RiwayatPengajuanOrangLainApi api = RiwayatPengajuanOrangLainApi();

  Future<List<Map<String, dynamic>>> getPengajuanOrangLainData(String telepon) async {
    print('DAO: Mengambil data dari API untuk telepon: $telepon');
    try {
      final data = await api.fetchPengajuanOrangLain(telepon);
      print('DAO: Data diterima dari API: $data');
      return data.cast<Map<String, dynamic>>(); // Pastikan respons bisa dicasting
    } catch (e) {
      print('DAO: Error saat mengambil data - $e');
      rethrow;
    }
  }

  // getRiwayatPengajuanOrangLain(String telepon) {}
}
