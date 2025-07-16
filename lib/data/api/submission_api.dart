import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:pensiunku/data/api/base_api.dart';

class SubmissionApi extends BaseApi {
  bool bypassPengajuan = false;
  Dio dio = Dio();

  Future<Response> uploadSelfie(
      String token, String selfieFilePath, String idUser) async {
    print('=== Start uploadWajah di API ===');
    print('URL: https://api.pensiunku.id/new.php/uploadWajah');
    print('User ID: $idUser');

    final file = File(selfieFilePath);
    if (!await file.exists()) {
      print('File tidak ditemukan: $selfieFilePath');
      throw Exception('File selfie tidak ditemukan');
    }

    print('File ditemukan: $selfieFilePath');
    print('Ukuran file: ${await file.length()} bytes');

    List<int> imageBytes = await file.readAsBytes();
    String base64Image = base64Encode(imageBytes);

    Map<String, dynamic> formData = {
      "foto_selfie": base64Image,
      "nama_foto_selfie": "selfie.jpg",
      "id_user": idUser
    };

    print('Mengirim JSON ke API (foto dan nama file)');

    return await dio.post(
      'https://api.pensiunku.id/new.php/uploadWajah',
      data: jsonEncode(formData),
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'X-User-ID': idUser, // Kirim user ID melalui header
        },
        responseType: ResponseType.json,
      ),
    );
  }
}