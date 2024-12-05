import 'package:pensiunku/data/db/riwayat_pengajuan_anda_dao.dart';
import 'package:pensiunku/model/riwayat_pengajuan_anda_model.dart';


class RiwayatPengajuanAndaRepository {
  final RiwayatPengajuanAndaDao dao = RiwayatPengajuanAndaDao();

  Future<List<RiwayatPengajuanAndaModel>> getRiwayatPengajuanAnda(
      String telepon) async {
    print('Repository: Meminta data dari DAO untuk telepon: $telepon');
    try {
      final data = await dao.getPengajuanAndaData(telepon);
      print('Repository: Data diterima dari DAO: $data');
      return data.map((e) => RiwayatPengajuanAndaModel.fromJson(e)).toList();
    } catch (e) {
      print('Repository: Error saat parsing data - $e');
      rethrow;
    }
  }
}
