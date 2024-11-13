// lib/repository/riwayat_pengajuan_repository.dart

import 'package:pensiunku/data/api/riwayat_ajukan_api.dart';
import 'package:pensiunku/data/db/riwayat_ajukan_dao.dart';
import 'package:pensiunku/model/riwayat_ajukan_model.dart';

class RiwayatPengajuanRepository {
  final RiwayatPengajuanApi _api;
  final RiwayatPengajuanDao _dao;

  RiwayatPengajuanRepository({
    required RiwayatPengajuanApi api,
    required RiwayatPengajuanDao dao,
  })  : _api = api,
        _dao = dao;

  Future<List<RiwayatPengajuan>> getPengajuanList(String telepon) async {
    try {
      print('Memulai proses pengambilan data pengajuan');
      final response = await _api.getPengajuan(telepon);
      await _dao.cachePengajuanList(response);
      return response;
    } catch (e) {
      print('Terjadi error: $e');
      final cachedData = await _dao.getCachedPengajuanList();
      if (cachedData.isNotEmpty) {
        print('Menggunakan data cache');
        return cachedData;
      }
      rethrow;
    }
  }

  Future<void> refreshPengajuanList(String telepon) async {
    try {
      final freshData = await _api.getPengajuan(telepon);
      await _dao.cachePengajuanList(freshData);
    } catch (e) {
      print('Gagal refresh data: $e');
      rethrow;
    }
  }

  Future<void> clearCache() async {
    await _dao.clearCache();
  }
}
