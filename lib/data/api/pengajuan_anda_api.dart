import 'dart:convert';
import 'dart:io'; // Import the dart:io package
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class PengajuanAndaApi {
  final Dio _dio = Dio(); // Inisialisasi objek Dio untuk melakukan HTTP request

  Future<bool> kirimPengajuanAnda({
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
      print('Memulai proses kirim pengajuan...'); // Print awal proses

      // Membaca file KTP dan mengkonversi ke base64
      print('Membaca file KTP: $fotoKTPPath');
      List<int> ktpBytes = await File(fotoKTPPath).readAsBytes();
      String base64KTP = base64Encode(ktpBytes);
      print('Berhasil encode file KTP ke base64');

      // Membaca file NPWP dan mengkonversi ke base64
      print('Membaca file NPWP: $fotoNPWPPath');
      List<int> npwpBytes = await File(fotoNPWPPath).readAsBytes();
      String base64NPWP = base64Encode(npwpBytes);
      print('Berhasil encode file NPWP ke base64');

      // Membaca file Karip dan mengkonversi ke base64
      print('Membaca file Karip: $fotoKaripPath');
      List<int> karipBytes = await File(fotoKaripPath).readAsBytes();
      String base64Karip = base64Encode(karipBytes);
      print('Berhasil encode file Karip ke base64');

      // Membuat payload JSON untuk dikirim ke API
      Map<String, dynamic> formData = {
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
        'https://api.pensiunku.id/new.php/pengajuan',
        data: formData,
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        print('Pengajuan berhasil dikirim!'); // Print jika sukses
        return true; // Success
      } else {
        print('Gagal mengirim pengajuanAnda. Status: ${response.statusCode}');
        print(
            'Response body: ${response.data}'); // Tambahan print untuk detail response
        return false;
      }
    } on DioError catch (e) {
      // Tangani error dari Dio dengan detail yang lebih komprehensif
      print('Error dalam pengiriman:');
      print('Status Code: ${e.response?.statusCode}');
      print('Error Message: ${e.message}');
      print('Response Data: ${e.response?.data}');
      return false;
    } catch (e) {
      // Tangani error umum yang mungkin terjadi
      print('Error tidak terduga: $e');
      return false;
    }
  }
}
