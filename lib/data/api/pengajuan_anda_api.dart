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
    required String nip,
    required String fotoKTPPath,
    required String namaFotoKTP,
    required String fotoNPWPPath,
    required String namaFotoNPWP,
    required String fotoKaripPath,
    required String namaFotoKarip,
  }) async {
    try {
      print('Memulai proses kirim pengajuan...');

      // Membaca file dan mengubah ke base64
      String base64KTP = base64Encode(await File(fotoKTPPath).readAsBytes());
      String base64NPWP = base64Encode(await File(fotoNPWPPath).readAsBytes());
      String base64Karip =
          base64Encode(await File(fotoKaripPath).readAsBytes());

      // Membuat payload JSON
      Map<String, dynamic> formData = {
        "nama": nama,
        "telepon": telepon,
        "domisili": domisili,
        "nip": nip,
        "foto_ktp": base64KTP,
        "nama_foto_ktp": namaFotoKTP,
        "foto_npwp": base64NPWP,
        "nama_foto_npwp": namaFotoNPWP,
        "foto_karip": base64Karip,
        "nama_foto_karip": namaFotoKarip,
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
        // Pastikan response.data memiliki struktur seperti {"text": {"message": "success"}}
        if (responseData is Map) {
          final text = responseData['text'];
          if (text is Map && text['message'] == 'success') {
            print('Pesan dari server: ${text['message']}');
            return true; // Menandakan pengajuan berhasil
          } else {
            print('Struktur respon tidak sesuai atau pesan tidak sukses.');
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
