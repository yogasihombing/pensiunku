import 'package:pensiunku/data/api/pengajuan_anda_api.dart';
import 'package:pensiunku/model/pengajuan_anda_model.dart';

class PengajuanAndaDao {
  // Gunakan PengajuanAndaApi langsung jika PengajuanAndaRepository tidak ada atau hanya proxy
  // Jika PengajuanAndaRepository ada dan memiliki logika spesifik, pertahankan
  static final PengajuanAndaApi _pengajuanAndaApi = PengajuanAndaApi();

  static Future<bool> kirimPengajuanAnda({
    required String nama,
    required String telepon,
    required String domisili,
    required String tanggalLahir, // Tambahan
    required String pekerjaan,    // Tambahan
  }) async {
    // Create the PengajuanAndaModel with all the necessary data
    PengajuanAndaModel pengajuanAnda = PengajuanAndaModel(
      nama: nama,
      telepon: telepon,
      domisili: domisili,
      tanggalLahir: tanggalLahir, // Isi dengan data baru
      pekerjaan: pekerjaan,       // Isi dengan data baru
    );

    // Call the API directly (atau repository jika ada lapisan lain) to send the data
    return await _pengajuanAndaApi.kirimPengajuanAnda(
      nama: pengajuanAnda.nama,
      telepon: pengajuanAnda.telepon,
      domisili: pengajuanAnda.domisili,
      tanggalLahir: pengajuanAnda.tanggalLahir,
      pekerjaan: pengajuanAnda.pekerjaan,
    );
  }

  // Metode ini perlu implementasi lebih lanjut jika memang digunakan
  // Saat ini tidak digunakan dalam alur pengajuan, tetapi bisa digunakan
  // untuk mengambil riwayat dari database lokal jika ada.
  fetchRiwayatPengajuanAnda(String telepon) {
    // Implementasi untuk mengambil riwayat pengajuan Anda
  }
}