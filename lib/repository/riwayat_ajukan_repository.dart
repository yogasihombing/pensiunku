import 'package:pensiunku/data/db/riwayat_ajukan_dao.dart';
import 'package:pensiunku/model/riwayat_ajukan_model.dart';

class RiwayatPengajuanRepository {
  // Membuat instance DAO untuk berkomunikasi dengan data lokal atau API
  final RiwayatPengajuanDao _dao = RiwayatPengajuanDao();

  // Fungsi untuk mengambil data riwayat pengajuan
  Future<List<RiwayatPengajuanModel>> getRiwayatPengajuan(String telepon) async {
    try {
      print('Meminta data ke DAO...');
      final result = await _dao.fetchPengajuan(telepon);
      print('Data dari DAO: $result');
      return result;
    } catch (e) {
      print('Error di Repository: $e');
      rethrow;
    }
  }
}
