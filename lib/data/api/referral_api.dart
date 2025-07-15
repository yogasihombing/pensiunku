import 'dart:developer';
import 'dart:convert'; // Diperlukan untuk json.encode
import 'dart:io'; // Diperlukan untuk File
import 'package:http/http.dart' as http; // Menggunakan paket http
import 'package:intl/intl.dart'; // Tetap diperlukan untuk DateFormat
import 'package:pensiunku/model/referral_model.dart'; // Pastikan path ini benar
import 'package:pensiunku/util/api_util.dart';
import 'package:pensiunku/data/api/base_api.dart'; // Import BaseApi

class ReferralApi extends BaseApi { // Menggunakan extends BaseApi

  /// Mendapatkan semua data referral
  Future<http.Response> getAll(String token) async {
    // Menggunakan httpGet dari BaseApi
    return httpGet(
      '/referal',
      headers: ApiUtil.getTokenHeaders(token), // Menggunakan headers parameter BaseApi
    );
  }

  /// Memasukkan data referral baru
  Future<http.Response> insert(String token, dynamic data) async {
    // Menggunakan httpPost dari BaseApi
    return httpPost(
      '/referal',
      data: data, // data akan di-json.encode oleh httpPost di BaseApi
      headers: ApiUtil.getTokenHeaders(token), // Menggunakan headers parameter BaseApi
    );
  }

  /// Mengunggah file KTP untuk referral
  Future<http.Response> uploadKtp(
    String token,
    ReferralModel referralModel,
    String ktpFile, // Path file KTP
  ) async {
    // Karena BaseApi.httpPost tidak mendukung multipart/form-data secara langsung,
    // kita tetap menggunakan http.MultipartRequest di sini.
    // Menggunakan BaseApi.baseUrl dari BaseApi untuk konsistensi URL
    final uri = Uri.parse('${BaseApi.baseUrl}/referal'); // Endpoint untuk upload
    final request = http.MultipartRequest('POST', uri);

    // Menambahkan header otorisasi
    request.headers.addAll(ApiUtil.getTokenHeaders(token)); // Menggunakan getTokenOptions untuk headers

    // Menambahkan file KTP
    request.files.add(await http.MultipartFile.fromPath(
      'foto_ktp', // Nama field di backend (sesuai dengan Dio MultipartFile)
      ktpFile,
      filename: 'ktp.jpg', // Nama file yang akan dikirim
    ));

    // Menambahkan field data lainnya
    request.fields['nama_ktp'] = referralModel.nameKtp ?? '';
    request.fields['nik_ktp'] = referralModel.nikKtp ?? '';
    request.fields['alamat_ktp'] = referralModel.addressKtp?.replaceAll('\n', ' ') ?? '';
    request.fields['pekerjaan_ktp'] = referralModel.jobKtp ?? '';
    request.fields['tanggal_lahir_ktp'] = referralModel.birthDateKtp != null
        ? DateFormat('yyyy-MM-dd').format(referralModel.birthDateKtp!)
        : '';
    request.fields['referal'] = referralModel.referal ?? '';

    log('Data MultipartRequest: ${request.fields}');
    log('Files MultipartRequest: ${request.files.map((f) => f.filename).toList()}');

    // Mengirim permintaan dan menunggu respons
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    log('Respons uploadKtp Status: ${response.statusCode}');
    log('Respons uploadKtp Body: ${response.body}');

    return response;
  }
}
