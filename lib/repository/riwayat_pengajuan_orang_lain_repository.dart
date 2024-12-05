import 'package:pensiunku/data/db/riwayat_pengajuan_orang_lain_dao.dart';
import 'package:pensiunku/model/riwayat_pengajuan_model.dart';

class RiwayatPengajuanOrangLainRepository {
  final RiwayatPengajuanOrangLainDao dao = RiwayatPengajuanOrangLainDao();

  Future<List<RiwayatPengajuanOrangLainModel>> getRiwayatPengajuanOrangLain(
      String telepon) async {
    print('Repository: Meminta data dari DAO untuk telepon: $telepon');
    try {
      final data = await dao.getPengajuanOrangLainData(telepon);
      print('Repository: Data diterima dari DAO: $data');
      return data.map((e) => RiwayatPengajuanOrangLainModel.fromJson(e)).toList();
    } catch (e) {
      print('Repository: Error saat parsing data - $e');
      rethrow;
    }
  }
}
