import 'package:pensiunku/data/api/riwayat_ajukan_api.dart';

class RiwayatPengajuanDao {
  final RiwayatPengajuanApi api = RiwayatPengajuanApi();

  Future<List<Map<String, dynamic>>> getPengajuanData(String telepon) async {
    print('DAO: Mengambil data dari API untuk telepon: $telepon');
    try {
      final data = await api.fetchPengajuan(telepon);
      print('DAO: Data diterima dari API: $data');
      return data.cast<Map<String, dynamic>>(); // Pastikan respons bisa dicasting
    } catch (e) {
      print('DAO: Error saat mengambil data - $e');
      rethrow;
    }
  }
}
