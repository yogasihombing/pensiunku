import 'package:flutter/foundation.dart';
import 'package:pensiunku/data/db/riwayat_pengajuan_anda_dao.dart';
import 'package:pensiunku/model/riwayat_pengajuan_anda_model.dart';

class RiwayatPengajuanAndaRepository {
  final RiwayatPengajuanAndaDao _dao = RiwayatPengajuanAndaDao();

  Future<List<RiwayatPengajuanAndaModel>> getRiwayatPengajuanAnda(
      String telepon) async {
    debugPrint('Repository: Meminta data dari DAO untuk telepon: $telepon');
    try {
      final List<RiwayatPengajuanAndaModel> data =
          await _dao.getPengajuanAndaData(telepon);
      debugPrint(
          'Repository: Data berhasil diterima dari DAO. Jumlah item: ${data.length}');
      return data;
    } catch (e) {
      debugPrint('Repository: Error saat mendapatkan riwayat pengajuan: $e');
      rethrow;
    }
  }
}