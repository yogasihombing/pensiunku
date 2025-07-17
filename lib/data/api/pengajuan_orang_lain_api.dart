// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:io'; // Import the dart:io package
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:pensiunku/model/user_model.dart';

class PengajuanOrangLainApi {
  final Dio _dio; // Inisialisasi objek Dio untuk melakukan HTTP request
  UserModel? _userModel; // Model pengguna (opsional)

  PengajuanOrangLainApi()
      : _dio = Dio(BaseOptions(
          connectTimeout: const Duration(milliseconds: 10000), // 10 detik
          receiveTimeout: const Duration(milliseconds: 10000), // 10 detik
        )) {
    // Konfigurasi SSL (Hanya untuk debugging)
    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
  }

  Future<bool> kirimPengajuanOrangLain({
    required String id,
    required String nama,
    required String telepon,
    required String domisili,
    required String nip,
    required String fotoKTPPath, // Ini sekarang adalah string Base64
    required String namaFotoKTP,
    required String fotoNPWPPath, // Ini sekarang adalah string Base64
    required String namaFotoNPWP,
    required String fotoKaripPath, // Ini sekarang adalah string Base64
    required String namaFotoKarip,
  }) async {
    try {
      print('Memulai proses kirim pengajuan Orang Lain...');

      // --- PERBAIKAN PENTING DI SINI ---
      // fotoKTPPath, fotoNPWPPath, dan fotoKaripPath sudah berisi string Base64
      // dari PengajuanOrangLainScreen. Tidak perlu encode ulang.
      String base64KTP = fotoKTPPath;
      String base64NPWP = fotoNPWPPath;
      String base64Karip = fotoKaripPath;
      // --- AKHIR PERBAIKAN ---

      // Tambahkan logging untuk memastikan panjang string Base64 yang diterima
      print('Panjang Base64 KTP yang diterima: ${base64KTP.length} karakter');
      print('Panjang Base64 NPWP yang diterima: ${base64NPWP.length} karakter');
      print(
          'Panjang Base64 Karip yang diterima: ${base64Karip.length} karakter');

      // Buat payload JSON
      Map<String, dynamic> formData = {
        // kiri adalah prameter API kanan value yg akan dikirim
        'id_user': id, // Catatan ID pengguna login
        'nama': nama,
        'telepon': telepon,
        'domisili': domisili,
        'nip': nip,
        'foto_ktp': base64KTP, // Gunakan langsung string Base64
        'nama_foto_ktp': namaFotoKTP,
        'foto_npwp': base64NPWP, // Gunakan langsung string Base64
        'nama_foto_npwp': namaFotoNPWP,
        'foto_karip': base64Karip, // Gunakan langsung string Base64
        'nama_foto_karip': namaFotoKarip,
      };

      print('Payload yang dikirim: ${jsonEncode(formData)}');
      print('Mengirim request ke API...');

      final response = await _dio.post(
        'https://api.pensiunku.id/new.php/pengajuanOther',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      print('Respon API: ${response.data}');
      if (response.statusCode == 200) {
        final responseData =
            response.data is String ? jsonDecode(response.data) : response.data;
        if (responseData is Map &&
            responseData['text']?['message'] == 'success') {
          print('Pesan dari server: ${responseData['text']['message']}');
          return true;
        } else {
          print('Respon tidak sukses: ${responseData['text']}');
        }
      } else {
        print('Status code error: ${response.statusCode}');
      }
    } on DioError catch (e) {
      print('Error Dio: ${e.message}');
      print('Respons Data: ${e.response?.data}');
      // Tambahkan detail error yang lebih baik jika ada
      if (e.type == DioErrorType.connectionTimeout) {
        print(
            'Connection Timeout Error: Pastikan koneksi internet stabil dan URL API benar.');
      } else if (e.type == DioErrorType.badResponse) {
        print(
            'Bad Response Error: Status code ${e.response?.statusCode}, Data: ${e.response?.data}');
      }
    } catch (e) {
      print('Error umum: $e');
    }
    return false;
  }
}
