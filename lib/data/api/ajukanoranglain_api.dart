import 'dart:convert';
import 'dart:io'; // Import the dart:io package
import 'package:dio/dio.dart';

class AjukanOrangLainApi {
  final Dio _dio = Dio();

  Future<bool> kirimPengajuan({
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
      // Read file KTP and encode it to base64
      List<int> ktpBytes = await File(fotoKTPPath).readAsBytes();
      String base64KTP = base64Encode(ktpBytes);

      // Read file NPWP and encode it to base64
      List<int> npwpBytes = await File(fotoNPWPPath).readAsBytes();
      String base64NPWP = base64Encode(npwpBytes);

      // Read file SK Pensiun and encode it to base64
      List<int> karipBytes = await File(fotoKaripPath).readAsBytes();
      String base64Karip = base64Encode(karipBytes);

      // Create JSON payload
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

      // Send POST request
      final response = await _dio.post(
        'https://api.pensiunku.id/new.php/pengajuanOther',
        data: formData,
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        return true; // Success
      } else {
        print('Failed with status: ${response.statusCode}');
        return false;
      }
    } on DioError catch (e) {
      print('Error: ${e.response?.statusCode} - ${e.message}');
      return false;
    }
  }
}
