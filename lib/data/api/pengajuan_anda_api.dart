import 'dart:convert';
import 'dart:io'; // Import the dart:io package
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';

class PengajuanAndaApi {
  final Dio _dio; // Inisialisasi objek Dio untuk melakukan HTTP request

  PengajuanAndaApi()
      : _dio = Dio(BaseOptions(
          connectTimeout: 10000, // 10 detik
          receiveTimeout: 10000, // 10 detik
        )) {
    // Konfigurasi SSL (Hanya untuk debugging)
    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
  }

  Future<bool> kirimPengajuanAnda({
    required String nama,
    required String telepon,
    required String domisili,
  }) async {
    try {
      print('Memulai proses kirim pengajuan...');

      // Membuat payload JSON
      Map<String, dynamic> formData = {
        "nama": nama,
        "telepon": telepon,
        "domisili": domisili,
      };

      print('Mengirim request ke API...');
      final response = await _dio.post(
        'https://api.pensiunku.id/new.php/pengajuan',
        data: formData,
        options: Options(
          headers: {"Content-Type": "application/json"},
        ),
      );
      print('Respon API: ${response.data}');

      // Memproses respons dari API
      if (response.statusCode == 200) {
        print('Respons API diterima: ${response.data}');
        dynamic responseData = response.data;

        // Pastikan respons berupa Map dengan melakukan parsing jika diperlukan
        if (responseData is String) {
          responseData = jsonDecode(response.data);
        }
        if (responseData is Map) {
          // Log seluruh respons
          print('Data lengkap dari respons API: $responseData');
          // Memeriksa apakah ID User tersedia ###
          if (responseData.containsKey('id_user')) {
            final idUser = responseData['id_user'];
            print('Pengajuan berhasil! ID User Anda: $idUser');
          } else {
            print('Pengajuan berhasil, tetapi ID User tidak tersedia.');
          }
          // Validasi pesan sukses
          if (responseData['text'] is Map &&
              responseData['text']['message'] == 'success') {
            print('Pesan dari server: ${responseData['text']['message']}');
            return true;
          } else {
            print('Pesan tidak sukses atau struktur tidak sesuai.');
          }
        } else {
          print('Data respons bukan dalam format Map.');
        }
      } else {
        print('Status code tidak berhasil: ${response.statusCode}');
        print('Respon data: ${response.data}');
      }
    } on DioError catch (e) {
      print('Error dalam pengiriman (DioError): ${e.message}');
      print('Respons Data: ${e.response?.data}');
    } catch (e) {
      print('Error tidak terduga: $e');
    }

    return false;
  }
}
