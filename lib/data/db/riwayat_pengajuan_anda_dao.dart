import 'package:pensiunku/data/api/riwayat_pengajuan_anda_api.dart';

class RiwayatPengajuanAndaDao {
  final RiwayatPengajuanAndaApi api = RiwayatPengajuanAndaApi();

  Future<List<Map<String, dynamic>>> getPengajuanAndaData(String telepon) async {
    print('DAO: Mangambil data dari API untuk telepon: $telepon');
    try {
      final data = await api.fetchPengajuanAnda(telepon);
      print('DAO: Data diterima dari API: $data');
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      print('DAO: Error saat mengambil data - $e');
      rethrow;
    }
  }
}
