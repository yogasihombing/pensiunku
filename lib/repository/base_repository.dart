import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:pensiunku/model/result_model.dart';

class BaseRepository {
  Future<ResultModel<T>> getResultModel<T>({
    required String tag,
    required Future<T?> Function() getFromDb,
    required Future<Response> Function() getFromApi,
    required T Function(dynamic responseJson) getDataFromApiResponse,
    required Future<void> Function(T dataApi)
        removeFromDb, // Sesuai dengan permintaan Anda
    required Future<void> Function(T dataApi)
        insertToDb, // Sesuai dengan permintaan Anda
    required String errorMessage,
  }) async {
    String finalErrorMessage = errorMessage;
    T? dataDb = await getFromDb(); // Mengambil data dari DB di awal

    // Log ini akan selalu muncul di konsol
    print('$tag: getResultModel dipanggil.');
    print('$tag: Data awal dari DB: ${dataDb != null ? 'Ada' : 'Tidak ada'}.');

    try {
      // Coba ambil dari API
      print('$tag: Mencoba ambil data dari API...');
      Response response = await getFromApi();
      var responseJson = response.data;

      // Log ini akan selalu muncul di konsol
      print('$tag: Respons API diterima. Status Kode: ${response.statusCode}');
      print('$tag: Data respons mentah API: $responseJson');

      if (responseJson['status'] == 'success') {
        print('$tag: Status API adalah sukses. Memproses data...');
        T dataApi = getDataFromApiResponse(responseJson);

        print('$tag: Menghapus data lama dari DB...');
        await removeFromDb(
            dataApi); // Menggunakan dataApi sesuai permintaan Anda

        print('$tag: Memasukkan data baru ke DB...');
        await insertToDb(dataApi); // Menggunakan dataApi sesuai permintaan Anda

        // PENTING: Mengambil ulang data dari DB setelah insert, sesuai logika asli Anda.
        // Jika data dari DB ini null, ini bisa menyebabkan masalah "artikel tidak muncul".
        dataDb = await getFromDb();

        print(
            '$tag: Data baru berhasil disimpan ke DB dan diambil ulang. Mengembalikan ResultModel sukses.');
        return ResultModel(
          isSuccess: true,
          data: dataDb, // Menggunakan data yang diambil ulang dari DB
        );
      } else {
        // Jika status API bukan 'success'
        print(
            '$tag: Status API bukan sukses: ${responseJson['status']}. Pesan: ${responseJson['msg'] ?? 'Tidak ada pesan spesifik.'}');
        return ResultModel(
          isSuccess: false,
          error: finalErrorMessage,
          data: dataDb, // Menggunakan data dari DB yang diambil di awal
        );
      }
    } catch (e) {
      // Log ini akan selalu muncul di konsol
      print('$tag: Terjadi error: $e'); // Menggunakan print()
      if (e is DioError) {
        print('$tag: DioError terjadi: ${e.message}. Tipe: ${e.type}');
        if (e.response != null) {
          print(
              '$tag: Respons error Dio: ${e.response?.data}. Status: ${e.response?.statusCode}');
        }
        int? statusCode = e.response?.statusCode;
        if (statusCode != null) {
          if (statusCode >= 400 && statusCode < 500) {
            // Client error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
              data: dataDb, // Menggunakan data dari DB yang diambil di awal
            );
          } else if (statusCode >= 500 && statusCode < 600) {
            // Server error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
              data: dataDb, // Menggunakan data dari DB yang diambil di awal
            );
          }
        }
        if (e.message?.contains('SocketException') ?? false) {
          print('$tag: SocketException (masalah koneksi internet).');
          return ResultModel(
            isSuccess: false,
            error: finalErrorMessage,
            data: dataDb, // Menggunakan data dari DB yang diambil di awal
          );
        }
      }
      print('$tag: Error lain yang tidak tertangani: $e');
      return ResultModel(
        isSuccess: false,
        error: finalErrorMessage,
        data: dataDb, // Menggunakan data dari DB yang diambil di awal
      );
    }
  }
}
