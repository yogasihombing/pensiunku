import 'package:pensiunku/model/pengajuan_anda_model.dart';
import 'package:pensiunku/repository/pengajuan_anda_repository.dart';

class PengajuanAndaDao {
  static final PengajuanAndaRepository _pengajuanAndaRepository =
      PengajuanAndaRepository();

  static Future<bool> kirimPengajuanAnda({
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
    PengajuanAndaModel pengajuanAnda = PengajuanAndaModel(
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
    return await _pengajuanAndaRepository.kirimPengajuanAnda(pengajuanAnda);
  }

  fetchRiwayatPengajuanAnda(String telepon) {}
}
