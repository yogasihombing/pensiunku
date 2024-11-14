import 'package:pensiunku/data/api/ajukan_api.dart';
import 'package:pensiunku/model/ajukan_model.dart';

class AjukanRepository {
  final AjukanApi _ajukanApi = AjukanApi();

  Future<bool> kirimPengajuan(AjukanModel ajukan) async {
    return await _ajukanApi.kirimPengajuan(
      nama: ajukan.nama,
      telepon: ajukan.telepon,
      domisili: ajukan.domisili,
      nip: ajukan.nip,
      fotoKTPPath: ajukan.fotoKTPPath,
      namaFotoKTP: ajukan.namaFotoKTP,
      fotoNPWPPath: ajukan.fotoNPWPPath,
      namaFotoNPWP: ajukan.namaFotoNPWP,
      fotoKaripPath: ajukan.fotoKaripPath,
      namaFotoKarip: ajukan.namaFotoKarip
    );
  }
}
