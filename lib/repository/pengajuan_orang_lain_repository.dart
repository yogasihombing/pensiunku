import 'package:flutter/foundation.dart';
import 'package:pensiunku/data/api/pengajuan_orang_lain_api.dart';
import 'package:pensiunku/model/pengajuan_orang_lain_model.dart';

class PengajuanOrangLainRepository {
  final PengajuanOrangLainApi _pengajuanOrangLainApi = PengajuanOrangLainApi();

  Future<bool> kirimPengajuanOrangLain(
      PengajuanOrangLainModel pengajuanOrangLain) async {
    debugPrint('--- [Repository] Memulai kirimPengajuanOrangLain ---');
    debugPrint('Data yang akan dikirim:');
    debugPrint('  ID Pengaju: ${pengajuanOrangLain.id}');
    debugPrint('  Nama: ${pengajuanOrangLain.nama}');
    debugPrint('  Telepon: ${pengajuanOrangLain.telepon}');
    debugPrint('  Domisili: ${pengajuanOrangLain.domisili}');
    debugPrint('  NIP: ${pengajuanOrangLain.nip}');

    try {
      final result = await _pengajuanOrangLainApi.kirimPengajuanOrangLain(
        id: pengajuanOrangLain.id,
        nama: pengajuanOrangLain.nama,
        telepon: pengajuanOrangLain.telepon,
        domisili: pengajuanOrangLain.domisili,
        nip: pengajuanOrangLain.nip,
        fotoKTPPath: pengajuanOrangLain.fotoKTPPath,
        namaFotoKTP: pengajuanOrangLain.namaFotoKTP,
        fotoNPWPPath: pengajuanOrangLain.fotoNPWPPath,
        namaFotoNPWP: pengajuanOrangLain.namaFotoNPWP,
        fotoKaripPath: pengajuanOrangLain.fotoKaripPath,
        namaFotoKarip: pengajuanOrangLain.namaFotoKarip,
      );
      debugPrint('--- [Repository] Selesai kirimPengajuanOrangLain. Hasil: $result ---');
      return result;
    } catch (e) {
      debugPrint('--- [Repository] Error di kirimPengajuanOrangLain: $e ---');
      rethrow;
    }
  }
}
