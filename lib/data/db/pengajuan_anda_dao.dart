import 'package:pensiunku/model/pengajuan_anda_model.dart';
import 'package:pensiunku/repository/pengajuan_anda_repository.dart';

class PengajuanAndaDao {
  static final PengajuanAndaRepository _pengajuanAndaRepository =
      PengajuanAndaRepository();

  static Future<bool> kirimPengajuanAnda({
    required String nama,
    required String telepon,
    required String domisili,

  }) async {
    // Create the AjukanModel with all the necessary data
    PengajuanAndaModel pengajuanAnda = PengajuanAndaModel(
      nama: nama,
      telepon: telepon,
      domisili: domisili,

    );

    // Call the repository to send the data
    return await _pengajuanAndaRepository.kirimPengajuanAnda(pengajuanAnda);
  }

  fetchRiwayatPengajuanAnda(String telepon) {}
}
