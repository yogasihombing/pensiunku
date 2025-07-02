import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pensiunku/model/riwayat_pengajuan_anda_model.dart';

class RiwayatPengajuanAndaApi {
  final Dio _dio;

  RiwayatPengajuanAndaApi()
      : _dio = Dio(BaseOptions(
          connectTimeout: const Duration(milliseconds: 15000),
          receiveTimeout: const Duration(milliseconds: 15000),
        )) {
    // Konfigurasi SSL (Hanya untuk debugging, jangan gunakan di produksi tanpa pemahaman yang memadai)
    if (kDebugMode) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }
  }

  Future<List<RiwayatPengajuanAndaModel>> fetchPengajuanAnda(
      String telepon) async {
    debugPrint(
        'API: Mengirim POST request ke https://api.pensiunku.id/new.php/getPengajuan dengan telepon: $telepon');
    try {
      final response = await _dio.post(
        'https://api.pensiunku.id/new.php/getPengajuan',
        data: jsonEncode(
            {'telepon': telepon}), // Pastikan data dikirim sebagai JSON string
        options: Options(
          headers: {"Content-Type": "application/json"},
        ),
      );

      debugPrint('API: Response Status Kode: ${response.statusCode}');
      debugPrint('API: Response Data: ${response.data}');

      if (response.statusCode == 200) {
        dynamic responseData;
        try {
          // Dio seringkali sudah mengurai JSON secara otomatis.
          // Cek apakah response.data sudah berupa Map/List atau masih String
          if (response.data is String) {
            responseData = jsonDecode(response.data);
          } else {
            responseData = response.data;
          }
        } catch (e) {
          debugPrint('API: Gagal menguraikan respons JSON: $e');
          // Ini mungkin terjadi jika respons bukan JSON valid sama sekali (misal: HTML)
          throw Exception('Format respons tidak valid: $e');
        }

        // Cek struktur respons untuk "data tidak ditemukan.."
        if (responseData is Map &&
            responseData.containsKey('text') &&
            responseData['text'] is Map &&
            responseData['text']['message'] == 'data tidak ditemukan..') {
          debugPrint(
              'API: Respons menunjukkan data tidak ditemukan. Mengembalikan daftar kosong.');
          return []; // Mengembalikan daftar kosong sebagai respons sukses tapi tanpa data
        }

        // --- PERBAIKAN DIMULAI DI SINI ---
        // Data riwayat pengajuan sekarang berada di dalam responseData['text']['data']
        if (responseData is Map &&
            responseData.containsKey('text') &&
            responseData['text'] is Map &&
            responseData['text'].containsKey('data') &&
            responseData['text']['data'] is List) {
          debugPrint(
              'API: Data diterima dalam key "text.data" dan berupa List. Memproses data.');
          return (responseData['text']['data'] as List) // Akses path yang benar
              .map<RiwayatPengajuanAndaModel>((json) {
            return RiwayatPengajuanAndaModel.fromJson(json);
          }).toList();
        } else {
          debugPrint('API: Format respons tidak sesuai harapan: $responseData');
          throw Exception('Format respons tidak sesuai: $responseData');
        }
        // --- PERBAIKAN BERAKHIR DI SINI ---

      } else {
        // Jika status code bukan 200, berarti ada masalah di server
        debugPrint(
            'API: Gagal fetch data dengan status code: ${response.statusCode}');
        throw Exception(
            'Gagal fetch data: Status ${response.statusCode}, Body: ${response.data}');
      }
    } on DioException catch (e) {
      debugPrint('API: DioError saat fetch data: ${e.message}');
      debugPrint('API: Response data DioError: ${e.response?.data}');
      // Menangani error SSL/TLS seperti BAD_DECRYPT di sini
      if (e.type == DioExceptionType.unknown && e.error is HttpException) {
        if (e.error.toString().contains('BAD_DECRYPT') ||
            e.error
                .toString()
                .contains('DECRYPTION_FAILED_OR_BAD_RECORD_MAC')) {
          throw Exception(
              'Kesalahan Koneksi Aman (SSL/TLS): Gagal mengenkripsi/mendekripsi data dengan server. Ini mungkin masalah konfigurasi server atau jaringan. Error: ${e.message}');
        }
      }
      throw Exception('Kesalahan Jaringan/Server: ${e.message}');
    } catch (e) {
      debugPrint('API: Error tidak terduga saat fetch data: $e');
      throw Exception('Error tidak terduga: $e');
    }
  }
}
