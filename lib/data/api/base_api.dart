import 'dart:developer'; // Digunakan untuk fungsi log, yang lebih baik untuk logging di Flutter daripada print biasa
import 'package:dio/dio.dart'; // Pustaka Dio untuk melakukan HTTP request
import 'package:flutter/foundation.dart'; // Digunakan untuk kDebugMode, agar log hanya muncul di mode debug
import 'package:pensiunku/config.dart'
    show apiHost; // Mengimpor apiHost dari file config.dart

class BaseApi {
  static String tag = 'BaseApi'; // Tag untuk identifikasi log dari kelas ini
  static String? baseUrl = apiHost; // URL dasar untuk semua permintaan API
  // Menggunakan int untuk timeout, sesuai dengan perilaku Dio versi 3.x.x
  static int connectTimeout = 10000; // Waktu tunggu koneksi dalam milidetik
  static int receiveTimeout =
      5000; // Waktu tunggu penerimaan data dalam milidetik

  /// Fungsi helper pribadi untuk menginisialisasi Dio dengan opsi umum
  Dio _createDio() {
    var dio = Dio();
    // Penting: Mengatur batas waktu koneksi dan penerimaan data.
    // Untuk Dio 3.x.x, ini adalah int dalam milidetik, bukan Duration.
    dio.options.connectTimeout = connectTimeout;
    dio.options.receiveTimeout = receiveTimeout;
    return dio;
  }

  /// Melakukan permintaan HTTP GET
  Future<Response> httpGet(
    String url, {
    Options? options,
  }) async {
    String fullUrl = '$baseUrl$url';
    // Log ini akan selalu muncul di konsol
    print('--- HTTP GET Request Dijalankan ---');
    print('URL Lengkap: $fullUrl');
    if (options != null) {
      print('Opsi GET (Header dll): ${options.headers}');
    }

    try {
      var dio = _createDio();
      Response response = await dio.get(fullUrl, options: options);
      // Log respons sukses, akan selalu muncul di konsol
      print('--- HTTP GET Response Diterima ---');
      print('URL: $fullUrl');
      print('Status Kode: ${response.statusCode}');
      print('Data Respons: ${response.data}');
      print('--- Selesai GET Request ---');
      return response;
    } on DioError catch (e) {
      // Penting: Menangkap DioError untuk Dio versi 3.x.x
      // Log error, akan selalu muncul di konsol
      print('!!! HTTP GET Error Ditemukan !!!');
      print('URL Gagal: $fullUrl');
      if (e.response != null) {
        print('Data Respons Error: ${e.response?.data}');
        print('Header Respons Error: ${e.response?.headers}');
        print('Status Kode Respons Error: ${e.response?.statusCode}');
      }
      print('Tipe Error Dio: ${e.type}');
      print('Pesan Error Dio: ${e.message}');
      print('!!! Selesai GET Error Log ---');
      rethrow; // Melemparkan kembali error agar bisa ditangani lebih lanjut
    } catch (e) {
      // Menangkap error umum lainnya
      // Log error tak terduga, akan selalu muncul di konsol
      print('!!! HTTP GET Error Tak Terduga Ditemukan !!!');
      print('URL Gagal: $fullUrl');
      print('Detail Error: $e');
      print('!!! Selesai GET Unexpected Error Log ---');
      rethrow;
    }
  }

  /// Melakukan permintaan HTTP POST
  Future<Response> httpPost(
    String url, {
    dynamic data,
    Options? options,
  }) async {
    String fullUrl = '$baseUrl$url';
    print('--- HTTP POST Request Dijalankan ---');
    print('URL Lengkap: $fullUrl');
    print('Data POST: $data');
    if (options != null) {
      print('Opsi POST (Header dll): ${options.headers}');
    }

    try {
      var dio = _createDio();
      Response response = await dio.post(fullUrl, data: data, options: options);
      print('--- HTTP POST Response Diterima ---');
      print('URL: $fullUrl');
      print('Status Kode: ${response.statusCode}');
      print('Data Respons: ${response.data}');
      print('--- Selesai POST Request ---');
      return response;
    } on DioError catch (e) {
      // Penting: Menggunakan DioError
      print('!!! HTTP POST Error Ditemukan !!!');
      print('URL Gagal: $fullUrl');
      if (e.response != null) {
        print('Data Respons Error: ${e.response?.data}');
        print('Header Respons Error: ${e.response?.headers}');
        print('Status Kode Respons Error: ${e.response?.statusCode}');
      }
      print('Tipe Error Dio: ${e.type}');
      print('Pesan Error Dio: ${e.message}');
      print('!!! Selesai POST Error Log ---');
      rethrow;
    } catch (e) {
      print('!!! HTTP POST Error Tak Terduga Ditemukan !!!');
      print('URL Gagal: $fullUrl');
      print('Detail Error: $e');
      print('!!! Selesai POST Unexpected Error Log ---');
      rethrow;
    }
  }

  /// Melakukan permintaan HTTP DELETE
  Future<Response> httpDelete(
    String url, {
    Options? options,
  }) async {
    String fullUrl = '$baseUrl$url';
    print('--- HTTP DELETE Request Dijalankan ---');
    print('URL Lengkap: $fullUrl');
    if (options != null) {
      print('Opsi DELETE (Header dll): ${options.headers}');
    }

    try {
      var dio = _createDio();
      Response response = await dio.delete(fullUrl, options: options);
      print('--- HTTP DELETE Response Diterima ---');
      print('URL: $fullUrl');
      print('Status Kode: ${response.statusCode}');
      print('Data Respons: ${response.data}');
      print('--- Selesai DELETE Request ---');
      return response;
    } on DioError catch (e) {
      // Penting: Menggunakan DioError
      print('!!! HTTP DELETE Error Ditemukan !!!');
      print('URL Gagal: $fullUrl');
      if (e.response != null) {
        print('Data Respons Error: ${e.response?.data}');
        print('Header Respons Error: ${e.response?.headers}');
        print('Status Kode Respons Error: ${e.response?.statusCode}');
      }
      print('Tipe Error Dio: ${e.type}');
      print('Pesan Error Dio: ${e.message}');
      print('!!! Selesai DELETE Error Log ---');
      rethrow;
    } catch (e) {
      print('!!! HTTP DELETE Error Tak Terduga Ditemukan !!!');
      print('URL Gagal: $fullUrl');
      print('Detail Error: $e');
      print('!!! Selesai DELETE Unexpected Error Log ---');
      rethrow;
    }
  }

  /// Melakukan permintaan HTTP PUT
  Future<Response> httpPut(
    String url, {
    dynamic data,
    Options? options,
  }) async {
    String fullUrl = '$baseUrl$url';
    print('--- HTTP PUT Request Dijalankan ---');
    print('URL Lengkap: $fullUrl');
    print('Data PUT: $data');
    if (options != null) {
      print('Opsi PUT (Header dll): ${options.headers}');
    }

    try {
      var dio = _createDio();
      Response response = await dio.put(fullUrl, data: data, options: options);
      print('--- HTTP PUT Response Diterima ---');
      print('URL: $fullUrl');
      print('Status Kode: ${response.statusCode}');
      print('Data Respons: ${response.data}');
      print('--- Selesai PUT Request ---');
      return response;
    } on DioError catch (e) {
      // Penting: Menggunakan DioError
      print('!!! HTTP PUT Error Ditemukan !!!');
      print('URL Gagal: $fullUrl');
      if (e.response != null) {
        print('Data Respons Error: ${e.response?.data}');
        print('Header Respons Error: ${e.response?.headers}');
        print('Status Kode Respons Error: ${e.response?.statusCode}');
      }
      print('Tipe Error Dio: ${e.type}');
      print('Pesan Error Dio: ${e.message}');
      print('!!! Selesai PUT Error Log ---');
      rethrow;
    } catch (e) {
      print('!!! HTTP PUT Error Tak Terduga Ditemukan !!!');
      print('URL Gagal: $fullUrl');
      print('Detail Error: $e');
      print('!!! Selesai PUT Unexpected Error Log ---');
      rethrow;
    }
  }
}
