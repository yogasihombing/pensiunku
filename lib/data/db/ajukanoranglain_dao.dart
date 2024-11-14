import 'package:pensiunku/model/ajukanoranglain_model.dart';
import 'package:pensiunku/repository/ajukanoranglain_repository.dart';

class AjukanOrangLainDao {
  final AjukanOrangLainRepository _ajukanOrangLainRepository =
      AjukanOrangLainRepository();

  Future<bool> kirimPengajuan({
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
    AjukanOrangLainModel ajukan = AjukanOrangLainModel(
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
    return await _ajukanOrangLainRepository.kirimPengajuan(ajukan);
  }

  fetchRiwayatPengajuan(String telepon) {}
}
