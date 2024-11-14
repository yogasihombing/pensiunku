import 'package:pensiunku/model/ajukan_model.dart';
import 'package:pensiunku/repository/ajukan_repository.dart';

class AjukanDao {
  final AjukanRepository _ajukanRepository = AjukanRepository();

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
    AjukanModel ajukan = AjukanModel(
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
    return await _ajukanRepository.kirimPengajuan(ajukan);
  }

  fetchRiwayatPengajuan(String telepon) {}
}
