

import 'package:pensiunku/data/db/riwayat_ajukan_dao.dart';
import 'package:pensiunku/model/riwayat_ajukan_model.dart';

class RiwayatPengajuanRepository {
  // Membuat instance DAO untuk berkomunikasi dengan data lokal atau API
  final RiwayatPengajuanDao _dao = RiwayatPengajuanDao();

  // Fungsi untuk mengambil data riwayat pengajuan
  Future<List<RiwayatPengajuanModel>> getRiwayatPengajuan(
      String telepon) async {
    try {
      print('[Repository] Meminta data ke DAO...');

      // Ambil data dari DAO
      final result = await _dao.fetchPengajuan(telepon);

      // Validasi apakah data kosong
      if (result.isEmpty) {
        print('[Repository] Data kosong untuk nomor telepon $telepon.');
        return [];
      }

      print('[Repository] Data berhasil diterima: $result');
      return result;
    } catch (e) {
      print('[Repository] Error saat mengambil data: $e');
      // Kirim ulang error ke UI layer agar bisa ditangani
      rethrow;
    }
  }
}


// import 'package:pensiunku/data/db/riwayat_ajukan_dao.dart';
// import 'package:pensiunku/model/riwayat_ajukan_model.dart';

// // Repository untuk menghubungkan antara ViewModel atau UI dan DAO
// class RiwayatPengajuanRepository {
//   // Membuat instance DAO
//   final RiwayatPengajuanDao _dao = RiwayatPengajuanDao();

//   // Fungsi untuk mendapatkan data riwayat pengajuan
//   Future<List<RiwayatPengajuanModel>> getRiwayatPengajuan(String telepon) async {
//     try {
//       print('Meminta data ke DAO...');
//       final result = await _dao.fetchPengajuan(telepon);
//       print('Data dari DAO: $result');

//       if (result.isEmpty) {
//         print('Data kosong untuk nomor telepon $telepon.');
//         return [];
//       }

//       return result;
//     } catch (e) {
//       print('Error di Repository: $e');
//       rethrow;
//     }
//   }
// }

