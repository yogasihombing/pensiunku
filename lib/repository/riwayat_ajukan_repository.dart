import 'package:pensiunku/data/db/riwayat_ajukan_dao.dart';
import 'package:pensiunku/model/riwayat_ajukan_model.dart';

class RiwayatPengajuanRepository {
  final RiwayatPengajuanDao dao = RiwayatPengajuanDao();

  Future<List<RiwayatPengajuanModel>> getRiwayatPengajuan(
      String telepon) async {
    print('Repository: Meminta data dari DAO untuk telepon: $telepon');
    try {
      final data = await dao.getPengajuanData(telepon);
      print('Repository: Data diterima dari DAO: $data');
      return data.map((e) => RiwayatPengajuanModel.fromJson(e)).toList();
    } catch (e) {
      print('Repository: Error saat parsing data - $e');
      rethrow;
    }
  }
}
