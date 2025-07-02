import 'package:flutter/foundation.dart';
import 'package:pensiunku/data/api/pengajuan_anda_api.dart';
import 'package:pensiunku/model/pengajuan_anda_model.dart';

class PengajuanAndaRepository {
  final PengajuanAndaApi _pengajuanAndaApi = PengajuanAndaApi();

  Future<bool> kirimPengajuanAnda(PengajuanAndaModel pengajuanAnda) async {
    debugPrint('--- [Repository] Starting kirimPengajuanAnda ---');
    debugPrint('Data to be sent:');
    debugPrint('   Name: ${pengajuanAnda.nama}');
    debugPrint('   Phone: ${pengajuanAnda.telepon}');
    debugPrint('   Domicile: ${pengajuanAnda.domisili}');
    debugPrint('   Birth Date: ${pengajuanAnda.tanggalLahir}'); // New
    debugPrint('   Occupation: ${pengajuanAnda.pekerjaan}');     // New

    try {
      final result = await _pengajuanAndaApi.kirimPengajuanAnda(
        nama: pengajuanAnda.nama,
        telepon: pengajuanAnda.telepon,
        domisili: pengajuanAnda.domisili,
        tanggalLahir: pengajuanAnda.tanggalLahir, // Passing new data
        pekerjaan: pengajuanAnda.pekerjaan,       // Passing new data
      );
      debugPrint('--- [Repository] Finished kirimPengajuanAnda. Result: $result ---');
      return result;
    } catch (e) {
      debugPrint('--- [Repository] Error in kirimPengajuanAnda: $e ---');
      rethrow;
    }
  }
}
