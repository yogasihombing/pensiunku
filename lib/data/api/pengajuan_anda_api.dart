// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:io'; // Import the dart:io package
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

class PengajuanAndaApi {
  final Dio _dio;

  PengajuanAndaApi()
      : _dio = Dio(BaseOptions(
          connectTimeout: const Duration(milliseconds: 15000),
          receiveTimeout: const Duration(milliseconds: 15000),
        )) {
    // Konfigurasi SSL (Hanya untuk debugging, jangan gunakan di produksi tanpa pemahaman yang memadai)
    // Pastikan Anda memahami risiko keamanan jika mengaktifkan ini di produksi.
    // Ini seringkali diperlukan untuk server dengan sertifikat SSL yang tidak standar atau self-signed.
    if (kDebugMode) { // Hanya aktifkan di mode debug
      (_dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }
  }

  Future<bool> kirimPengajuanAnda({
    required String nama,
    required String telepon,
    required String domisili,
    required String tanggalLahir,
    required String pekerjaan,
  }) async {
    try {
      debugPrint('Memulai proses kirim pengajuan...');

      Map<String, dynamic> formData = {
        "nama": nama,
        "telepon": telepon,
        "domisili": domisili,
        "tanggal_lahir": tanggalLahir,
        "pekerjaan": pekerjaan,
      };

      debugPrint('Data yang akan dikirim ke API: $formData');
      debugPrint('Mengirim request ke API...');
      final response = await _dio.post(
        'https://api.pensiunku.id/new.php/pengajuan',
        data: formData,
        options: Options(
          headers: {"Content-Type": "application/json"},
        ),
      );
      debugPrint('Respon API Status Code: ${response.statusCode}');
      debugPrint('Respon API Body: ${response.data}');

      if (response.data is String &&
          response.data.trim().startsWith('<!DOCTYPE html>')) {
        debugPrint(
            'Respons adalah HTML, bukan JSON. Mungkin ada tantangan keamanan (mis. Cloudflare).');
        throw Exception('Respons API bukan JSON yang valid (mungkin HTML)');
      }

      if (response.statusCode == 200) {
        dynamic responseData;
        try {
          if (response.data is String) {
            responseData = jsonDecode(response.data);
          } else {
            responseData = response.data;
          }
        } catch (e) {
          debugPrint('Gagal menguraikan respons JSON: $e');
          throw Exception('Gagal menguraikan respons API: $e');
        }

        if (responseData is Map) {
          debugPrint('Data lengkap dari respons API: $responseData');

          // Cek apakah ada key 'text' dan di dalamnya ada 'message'
          if (responseData.containsKey('text') && responseData['text'] is Map && responseData['text'].containsKey('message')) {
            final message = responseData['text']['message'];
            if (message == 'success') {
              debugPrint('Pengajuan berhasil!');
              if (responseData.containsKey('id_user')) {
                final idUser = responseData['id_user'];
                debugPrint('ID User Anda: $idUser');
              }
              return true;
            } else {
              debugPrint('Pengajuan gagal dengan pesan: $message');
              throw Exception('Pengajuan gagal: $message');
            }
          } else {
            debugPrint('Struktur respons tidak sesuai harapan. Tidak ada "text.message".');
            throw Exception('Struktur respons API tidak valid.');
          }
        } else {
          debugPrint('Data respons bukan dalam format Map setelah parsing.');
          throw Exception('Data respons API bukan format Map.');
        }
      } else {
        debugPrint('Status code tidak berhasil: ${response.statusCode}');
        debugPrint('Respon data: ${response.data}');
        throw Exception('Permintaan gagal dengan status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Error dalam pengiriman (DioError): ${e.message}');
      debugPrint('Respons Data: ${e.response?.data}');
      if (e.response != null &&
          e.response!.data is String &&
          e.response!.data.trim().startsWith('<!DOCTYPE html>')) {
        debugPrint('DioError juga mendapatkan respons HTML.');
        throw Exception('Server mengembalikan HTML, bukan JSON. Mungkin ada masalah dengan API.');
      }
      throw Exception('Kesalahan jaringan atau server: ${e.message}');
    } catch (e) {
      debugPrint('Error tidak terduga: $e');
      throw Exception('Terjadi error tidak terduga: $e');
    }
  }
}