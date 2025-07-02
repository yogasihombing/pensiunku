import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:pensiunku/data/api/halopenisun_api.dart';
import 'package:pensiunku/model/halopensiun_model.dart';
import 'package:pensiunku/repository/base_repository.dart';
import 'package:pensiunku/model/result_model.dart';

/// Repository untuk mengelola data Halopensiun.
/// Bertanggung jawab untuk memanggil API dan menangani respons serta kesalahan.
class HalopensiunRepository extends BaseRepository {
  // Tag untuk logging, membantu identifikasi log dari kelas ini.
  static const String _tag = 'HalopensiunRepository';

  // Instance dari HalopensiunApi untuk melakukan panggilan API.
  final HalopensiunApi _api = HalopensiunApi();

  // Pesan kesalahan default yang akan ditampilkan kepada pengguna.
  static const String _defaultErrorMessage =
      'Tidak dapat mendapatkan data halopensiun terbaru. Tolong periksa Internet Anda atau coba lagi nanti.';

  /// Fungsi helper untuk menangani kesalahan Dio dan mengembalikan ResultModel.
  /// Ini membantu menghindari duplikasi kode penanganan kesalahan.
  ResultModel<T> _handleDioError<T>(DioException e) {
    log('DioError: ${e.toString()}', name: _tag, error: e);

    // Periksa jenis kesalahan Dio
    if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout) {
      // Kesalahan koneksi atau timeout
      return ResultModel(
        isSuccess: false,
        error: 'Koneksi internet bermasalah atau server tidak merespons. Silakan coba lagi.',
      );
    } else if (e.type == DioExceptionType.badResponse) {
      // Respons buruk dari server (misalnya 4xx, 5xx)
      final statusCode = e.response?.statusCode;
      if (statusCode != null) {
        if (statusCode >= 400 && statusCode < 500) {
          // Kesalahan klien (misalnya 401 Unauthorized, 404 Not Found)
          // Anda bisa menambahkan logika spesifik di sini jika ingin pesan yang berbeda
          // berdasarkan kode status tertentu, misalnya:
          // if (statusCode == 401) return ResultModel(isSuccess: false, error: 'Sesi Anda telah berakhir. Silakan login kembali.');
          return ResultModel(
            isSuccess: false,
            error: e.response?.data['message'] ?? _defaultErrorMessage, // Coba ambil pesan dari respons API
          );
        } else if (statusCode >= 500 && statusCode < 600) {
          // Kesalahan server
          return ResultModel(
            isSuccess: false,
            error: 'Terjadi kesalahan pada server. Silakan coba lagi nanti.',
          );
        }
      }
    } else if (e.type == DioExceptionType.unknown) {
      // Kesalahan tidak diketahui, mungkin SocketException atau lainnya
      if (e.error is Exception && e.error.toString().contains('SocketException')) {
        return ResultModel(
          isSuccess: false,
          error: 'Tidak ada koneksi internet. Silakan periksa pengaturan jaringan Anda.',
        );
      }
    }

    // Untuk semua kesalahan Dio lainnya atau yang tidak tertangkap di atas
    return ResultModel(
      isSuccess: false,
      error: _defaultErrorMessage,
    );
  }

  /// Mengambil daftar Halopensiun berdasarkan kategori dan kata kunci pencarian.
  ///
  /// [categoryId] ID kategori untuk memfilter hasil.
  /// [searchText] Teks untuk mencari halopensiun (opsional).
  /// [token] Token otentikasi.
  Future<ResultModel<HalopensiunModel>> getHalopensiuns(
      int categoryId, String? searchText, String token) async {
    // Log untuk tujuan debugging di lingkungan pengembangan.
    assert(() {
      log('Mengambil Halopensiun berdasarkan kategori dan kata kunci...', name: _tag);
      return true;
    }());

    try {
      // Panggil API untuk mendapatkan data.
      final Response response =
          await _api.getAllByCategoryAndKeyword(categoryId, searchText, token);
      final responseJson = response.data;

      // Log data respons untuk debugging.
      log('Data respons API: ${responseJson.toString()}', name: _tag);

      // Periksa status 'success' dari respons API.
      if (responseJson['status'] == 'success') {
        // Jika sukses, parse data ke HalopensiunModel dan kembalikan sukses.
        return ResultModel(
          isSuccess: true,
          data: HalopensiunModel.fromJson(responseJson['data']),
        );
      } else {
        // Jika status bukan 'success', kembalikan kesalahan dengan pesan dari API
        // atau pesan default jika tidak ada.
        return ResultModel(
          isSuccess: false,
          error: responseJson['message'] ?? _defaultErrorMessage,
        );
      }
    } on DioException catch (e) {
      // Tangani kesalahan Dio menggunakan fungsi helper.
      return _handleDioError(e);
    } catch (e, stackTrace) {
      // Tangani kesalahan umum lainnya.
      log('Kesalahan tidak terduga: ${e.toString()}', name: _tag, error: e, stackTrace: stackTrace);
      return ResultModel(
        isSuccess: false,
        error: _defaultErrorMessage,
      );
    }
  }

  /// Mengambil semua data Halopensiun.
  ///
  /// [token] Token otentikasi.
  Future<ResultModel<HalopensiunModel>> getAllHalopensiuns(String token) async {
    // Log untuk tujuan debugging di lingkungan pengembangan.
    assert(() {
      log('Mengambil semua Halopensiun...', name: _tag);
      return true;
    }());

    try {
      // Panggil API untuk mendapatkan semua data.
      final Response response = await _api.getAll(token);
      final responseJson = response.data;

      // Log data respons untuk debugging.
      log('Data respons API: ${responseJson.toString()}', name: _tag);

      // Periksa status 'success' dari respons API.
      if (responseJson['status'] == 'success') {
        // Jika sukses, parse data ke HalopensiunModel dan kembalikan sukses.
        return ResultModel(
          isSuccess: true,
          data: HalopensiunModel.fromJson(responseJson['data']),
        );
      } else {
        // Jika status bukan 'success', kembalikan kesalahan dengan pesan dari API
        // atau pesan default jika tidak ada.
        return ResultModel(
          isSuccess: false,
          error: responseJson['message'] ?? _defaultErrorMessage,
        );
      }
    } on DioException catch (e) {
      // Tangani kesalahan Dio menggunakan fungsi helper.
      return _handleDioError(e);
    } catch (e, stackTrace) {
      // Tangani kesalahan umum lainnya.
      log('Kesalahan tidak terduga: ${e.toString()}', name: _tag, error: e, stackTrace: stackTrace);
      return ResultModel(
        isSuccess: false,
        error: _defaultErrorMessage,
      );
    }
  }
}
