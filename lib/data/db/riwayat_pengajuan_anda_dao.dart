import 'package:flutter/foundation.dart';
import 'package:pensiunku/data/api/riwayat_pengajuan_anda_api.dart';
import 'package:pensiunku/model/riwayat_pengajuan_anda_model.dart';

class RiwayatPengajuanAndaDao {
  final RiwayatPengajuanAndaApi _api = RiwayatPengajuanAndaApi();

  Future<List<RiwayatPengajuanAndaModel>> getPengajuanAndaData(
      String telepon) async {
    debugPrint(
        'DAO: Mengambil data dari API untuk telepon: $telepon'); // Typo "Mangambil" diperbaiki
    try {
      final List<RiwayatPengajuanAndaModel> data =
          await _api.fetchPengajuanAnda(telepon);
      debugPrint('DAO: Data berhasil diambil. Jumlah item: ${data.length}');
      return data;
    } catch (e) {
      debugPrint('DAO: Error saat mengambil data - $e');
      rethrow;
    }
  }
}
