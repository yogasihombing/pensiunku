import 'dart:convert';
import 'dart:io'; // Import the dart:io package
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class PengajuanOrangLainApi {
  final Dio _dio = Dio(); // Inisialisasi objek Dio untuk melakukan HTTP request

  Future<bool> kirimPengajuanOrangLain({
    required String idUser,
    required String nama,
    required String telepon,
    required String domisili,
    required String nip,
    required String fotoKTPPath,
    required String namaFotoKTP,
    required String fotoNPWPPath,
    required String namaFotoNPWP,
    required String fotoKaripPath,
    required String namaFotoKarip,
  }) async {
    try {
      debugPrint('Memulai proses kirim pengajuan...'); // Print awal proses

      // Membaca file KTP dan mengkonversi ke base64
      debugPrint('Membaca file KTP: $fotoKTPPath');
      List<int> ktpBytes = await File(fotoKTPPath).readAsBytes();
      String base64KTP = base64Encode(ktpBytes);
      debugPrint('Berhasil encode file KTP ke base64');

      // Read file NPWP and encode it to base64
      debugPrint('Membaca file NPWP: $fotoNPWPPath');
      List<int> npwpBytes = await File(fotoNPWPPath).readAsBytes();
      String base64NPWP = base64Encode(npwpBytes);
      debugPrint('Berhasil encode file NPWP ke base64');

      // Read file SK Pensiun and encode it to base64
      debugPrint('Membaca file Karip: $fotoKaripPath');
      List<int> karipBytes = await File(fotoKaripPath).readAsBytes();
      String base64Karip = base64Encode(karipBytes);
      debugPrint('Berhasil encode file Karip ke base64');

      // Create JSON payload
      Map<String, dynamic> formData = {
        "id_user": idUser,
        "nama": nama,
        "telepon": telepon,
        "domisili": domisili,
        "nip": nip,
        "foto_ktp": base64KTP, // Send base64-encoded file
        "nama_foto_ktp": namaFotoKTP,
        "foto_npwp": base64NPWP, // Send base64-encoded file
        "nama_foto_npwp": namaFotoNPWP,
        "foto_karip": base64Karip, // Send base64-encoded file
        "nama_foto_karip": namaFotoKarip,
      };

      debugPrint('Mengirim request ke API...'); // Gunakan debugPrint

      // Kirim request POST
      final response = await _dio.post(
        'https://api.pensiunku.id/new.php/pengajuanOther',
        data: formData,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json", 
          },
        ),
      );

      if (response.statusCode == 200) {
        debugPrint('Pengajuan berhasil dikirim!'); // Print jika sukses
        return true; // Success
      } else {
        debugPrint('Gagal mengirim pengajuan. Status: ${response.statusCode}');
        debugPrint(
            'Response body: ${response.data}'); // Tambahan print untuk detail response
        return false;
      }
    } on DioError catch (e) {
      // Tangani error dari Dio dengan detail yang lebih komprehensif
      debugPrint('Error dalam pengiriman:');
      debugPrint('Status Code: ${e.response?.statusCode}');
      debugPrint('Error Message: ${e.message}');
      debugPrint('Response Data: ${e.response?.data}');
      return false;
    } catch (e) {
      // Tangani error umum yang mungkin terjadi
      debugPrint('Error tidak terduga: $e');
      return false;
    }
  }
}
