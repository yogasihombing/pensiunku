import 'package:pensiunku/data/api/ajukanoranglain_api.dart';
import 'package:pensiunku/model/ajukanoranglain_model.dart';

class AjukanOrangLainRepository {
  final AjukanOrangLainApi _ajukanOrangLainApi = AjukanOrangLainApi();

  Future<bool> kirimPengajuan(AjukanOrangLainModel ajukan) async {
    return await _ajukanOrangLainApi.kirimPengajuan(
      nama: ajukan.nama,
      telepon: ajukan.telepon,
      domisili: ajukan.domisili,
      nip: ajukan.nip,
      fotoKTPPath: ajukan.fotoKTPPath,
      namaFotoKTP: ajukan.namaFotoKTP,
      fotoNPWPPath: ajukan.fotoNPWPPath,
      namaFotoNPWP: ajukan.namaFotoNPWP,
      fotoKaripPath: ajukan.fotoKaripPath,
      namaFotoKarip: ajukan.namaFotoKarip,
    );
  }
}
