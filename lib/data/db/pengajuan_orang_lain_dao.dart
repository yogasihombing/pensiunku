import 'package:pensiunku/model/pengajuan_orang_lain_model.dart';
import 'package:pensiunku/repository/pengajuan_orang_lain_repository.dart';

class PengajuanOrangLainDao {
  static final PengajuanOrangLainRepository _pengajuanOrangLainRepository =
      PengajuanOrangLainRepository();

  static Future<bool> kirimPengajuanOrangLain({
    // required String id,
    required String nama,
    required String telepon,
    required String domisili,
    required String nip,
    required String fotoKTP,
    required String namaFotoKTP,
    required String fotoNPWP,
    required String namaFotoNPWP,
    required String fotoKarip,
    required String namaFotoKarip,
  }) async {
    // Create the AjukanModel with all the necessary data
    PengajuanOrangLainModel pengajuanOrangLain = PengajuanOrangLainModel(
      // id: id,
      nama: nama,
      telepon: telepon,
      domisili: domisili,
      nip: nip,
      fotoKTPPath: fotoKTP,
      namaFotoKTP: namaFotoKTP,
      fotoNPWPPath: fotoNPWP,
      namaFotoNPWP: namaFotoNPWP,
      fotoKaripPath: fotoKarip,
      namaFotoKarip: namaFotoKarip,
    );

    // Call the repository to send the data
    return await _pengajuanOrangLainRepository.kirimPengajuanOrangLain(pengajuanOrangLain);
  }

  fetchRiwayatPengajuanOrangLain(String telepon) {}
}
