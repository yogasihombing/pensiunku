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
    required String fotoKTPPath,
    required String namaFotoKTP,
    required String fotoNPWPPath,
    required String namaFotoNPWP,
    required String fotoKaripPath,
    required String namaFotoKarip,
  }) async {
    try {
      // String id = await getLoggedInId();
      // if (id.isEmpty) {
      //   print('Error: ID User tidak boleh kosong.');
      //   return false;
      // }

      print('Memulai proses kirim pengajuan Orang Lain...');
      // Encode file ke Base64
      String base64KTP = base64Encode(await File(fotoKTPPath).readAsBytes());
      String base64NPWP = base64Encode(await File(fotoNPWPPath).readAsBytes());
      String base64Karip =
          base64Encode(await File(fotoKaripPath).readAsBytes());

      // print('ini yoga: ${jsonEncode(_userModel)}');
      // String id = "${_userModel?.id}";
      // Buat payload JSON
      Map<String, dynamic> formData = {
        // kiri adalah prameter API kanan value yg akan dikirim
        'id_user': id, // Catatan ID pengguna login
        'nama': nama,
        'telepon': telepon,
        'domisili': domisili,
        'nip': nip,
        'foto_ktp': base64KTP,
        'nama_foto_ktp': namaFotoKTP,
        'foto_npwp': base64NPWP,
        'nama_foto_npwp': namaFotoNPWP,
        'foto_karip': base64Karip,
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
    } catch (e) {
      print('Error: $e');
    }
    return false;
  }
}
