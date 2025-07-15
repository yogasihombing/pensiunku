// File: lib/repository/base_repository.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:pensiunku/data/api/base_api.dart'; // Pastikan ini diimpor untuk HttpException

import '../model/result_model.dart'; // Pastikan path ini benar

abstract class BaseRepository {
  // Fungsi generik untuk mengambil data dari DB atau API
  // T adalah tipe data yang diharapkan (misalnya List<ArticleModel>, List<ForumModel>, bool, String, dll.)
  Future<ResultModel<T>> getResultModel<T>({
    required String tag,
    Future<T?> Function()? getFromDb, // Fungsi untuk mengambil data dari DB (opsional)
    required Future<http.Response> Function() getFromApi, // Fungsi untuk mengambil data dari API
    required T Function(Map<String, dynamic> responseJson) getDataFromApiResponse, // Fungsi untuk parsing respons API
    Future<void> Function(T data)? removeFromDb, // Fungsi untuk menghapus data lama dari DB (opsional)
    Future<void> Function(T data)? insertToDb, // Fungsi untuk memasukkan data baru ke DB (opsional)
    required String errorMessage, // Pesan error default jika terjadi kegagalan
  }) async {
    T? dataDb; // Inisialisasi dataDb
    if (getFromDb != null) {
      try {
        dataDb = await getFromDb();
        if (dataDb != null) {
          print('$tag: Data berhasil diambil dari DB.');
          // return ResultModel(isSuccess: true, data: dataDb); // Jangan langsung return, coba dari API juga
        }
      } catch (e) {
        print('$tag: Gagal mengambil dari DB: $e');
        // Lanjutkan untuk mencoba dari API jika DB gagal
      }
    }

    // 2. Coba ambil dari API
    try {
      print('$tag: Mencoba ambil data dari API...');
      final http.Response response = await getFromApi();

      print('$tag: Respons API diterima. Status Kode: ${response.statusCode}');
      print(
          '$tag: Respons API mentah: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...'); // Log sebagian body

      // --- PERBAIKAN: Deteksi respons HTML dari Cloudflare/Imunify360 ---
      if (response.body.contains('One moment, please...') ||
          response.body.contains('Access denied by Imunify360 bot-protection') ||
          response.body.trim().startsWith('<!DOCTYPE html>')) {
        throw HttpException(
          message:
              'Deteksi tantangan keamanan (Cloudflare/Imunify360). Mohon coba lagi.',
          statusCode: response.statusCode,
          responseBody: response.body,
          requestUrl: response.request?.url,
        );
      }
      // --- AKHIR PERBAIKAN ---

      // Periksa status kode HTTP secara umum (ini sebagian besar ditangani oleh BaseApi sekarang)
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Respons sukses HTTP, sekarang validasi payload JSON
        final Map<String, dynamic> responseJson = json.decode(response.body);

        // --- PERBAIKAN PENTING: Validasi status 'success' di dalam JSON ---
        if (responseJson['status'] == 'success') {
          // Parsing data dari respons API
          final T parsedData = getDataFromApiResponse(responseJson);

          // 3. Simpan ke DB (jika ada)
          if (removeFromDb != null && insertToDb != null) {
            try {
              await removeFromDb(parsedData);
              await insertToDb(parsedData);
              print('$tag: Data berhasil disimpan ke DB.');
            } catch (e) {
              print('$tag: Gagal menyimpan ke DB: $e');
              // Lanjutkan tanpa melempar error, karena data API sudah didapat
            }
          }

          return ResultModel(isSuccess: true, data: parsedData);
        } else {
          // Jika status bukan 'success' di dalam JSON, anggap sebagai error dari server
          String serverMessage =
              responseJson['msg'] ?? responseJson['message'] ?? 'Respons server tidak sukses.';
          print('$tag: Status API bukan sukses: $serverMessage. Respons: $responseJson');
          throw HttpException(
            message: serverMessage,
            statusCode:
                response.statusCode, // Tetap gunakan status 200 dari HTTP, tapi pesan dari JSON
            responseBody: response.body,
            requestUrl: response.request?.url,
          );
        }
        // --- AKHIR PERBAIKAN ---
      } else {
        // Ini seharusnya jarang terjadi jika BaseApi sudah melempar HttpException untuk 401 dll.
        // Tapi sebagai fallback, kita bisa coba ekstrak pesan dari body.
        String specificErrorMessage = errorMessage;
        try {
          final Map<String, dynamic> errorJson = json.decode(response.body);
          specificErrorMessage =
              errorJson['msg'] ?? errorJson['message'] ?? errorMessage;
        } catch (_) {
          // Gagal parsing error body, gunakan pesan default
        }
        // Lempar HttpException agar ditangkap oleh blok catch di bawah
        throw HttpException(
          message: specificErrorMessage,
          statusCode: response.statusCode,
          responseBody: response.body,
          requestUrl: response.request?.url,
        );
      }
    } on HttpException catch (e) {
      // --- PERBAIKAN PENTING: Gunakan pesan dari HttpException secara langsung ---
      print('$tag: HttpException ditangkap: ${e.message}');
      return ResultModel(isSuccess: false, error: e.message, data: dataDb);
      // --- AKHIR PERBAIKAN ---
    } on SocketException catch (e) {
      // Ini seharusnya tidak terpicu jika SocketException sudah ditangkap di BaseApi
      // Tapi sebagai fallback, kita bisa tetap menanganinya di sini.
      print('$tag: SocketException ditangkap: ${e.message}');
      return ResultModel(
          isSuccess: false,
          error: 'Tidak ada koneksi internet. Tolong periksa Internet Anda.',
          data: dataDb);
    } catch (e, stackTrace) {
      print('$tag: Error tak terduga ditangkap: $e');
      print('Stack Trace: $stackTrace');
      return ResultModel(isSuccess: false, error: errorMessage, data: dataDb);
    }
  }
}