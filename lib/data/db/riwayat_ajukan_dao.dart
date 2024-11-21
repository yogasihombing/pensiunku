import 'package:pensiunku/data/api/riwayat_ajukan_api.dart';
import 'package:pensiunku/model/riwayat_ajukan_model.dart';

class RiwayatPengajuanDao {
  // Membuat instance API untuk berkomunikasi dengan server
  final RiwayatPengajuanApi _api = RiwayatPengajuanApi();

  // Fungsi untuk mengambil dan memproses data dari API
  Future<List<RiwayatPengajuanModel>> fetchPengajuan(String telepon) async {
    try {
      print('Meminta data ke API...');
      // Memanggil API untuk mendapatkan data mentah
      final data = await _api.getRiwayatPengajuan(telepon);
      print('Data mentah dari API: $data');
      // Mapping data mentah ke dalam bentuk model
      return data.map((e) => RiwayatPengajuanModel.fromJson(e)).toList();
    } catch (e) {
      print('Error di DAO: $e');
      // Melempar error jika terjadi masalah
      rethrow;
    }
  }
}
