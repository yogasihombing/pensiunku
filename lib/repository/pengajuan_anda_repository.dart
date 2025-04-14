import 'package:pensiunku/data/api/pengajuan_anda_api.dart';
import 'package:pensiunku/model/pengajuan_anda_model.dart';

class PengajuanAndaRepository {
  final PengajuanAndaApi _pengajuanAndaApi = PengajuanAndaApi();

  

  Future<bool> kirimPengajuanAnda(PengajuanAndaModel pengajuanAnda) async {
    return await _pengajuanAndaApi.kirimPengajuanAnda(
      nama: pengajuanAnda.nama,
      telepon: pengajuanAnda.telepon,
      domisili: pengajuanAnda.domisili,

    );
  }
}
