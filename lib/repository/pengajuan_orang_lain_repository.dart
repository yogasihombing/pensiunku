import 'package:pensiunku/data/api/pengajuan_orang_lain_api.dart';
import 'package:pensiunku/model/pengajuan_orang_lain_model.dart';

class PengajuanOrangLainRepository {
  final PengajuanOrangLainApi _pengajuanOrangLainApi = PengajuanOrangLainApi();

  Future<bool> kirimPengajuanOrangLain(
      PengajuanOrangLainModel pengajuanOrangLain) async {
    return await _pengajuanOrangLainApi.kirimPengajuanOrangLain(
      // id: pengajuanOrangLain.id,
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
  }
}
