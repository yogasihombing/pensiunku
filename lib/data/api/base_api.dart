import 'package:dio/dio.dart';
import 'package:pensiunku/config.dart' show apiHost, defaultApiOptions;

class BaseApi {
  static String tag = 'BaseApi';
  static String? baseUrl = apiHost;
  // Perbaikan: Gunakan Duration secara langsung
  static Duration connectTimeout =
      const Duration(milliseconds: 10000); // Waktu tunggu koneksi
  static Duration receiveTimeout =
      const Duration(milliseconds: 5000); // Waktu tunggu penerimaan data

  Dio _createDio() {
    var dio = Dio();
    // Perbaikan: Tetapkan Duration langsung ke dio.options
    dio.options.connectTimeout = connectTimeout;
    dio.options.receiveTimeout = receiveTimeout;
    return dio;
  }

  bool _isCloudflareChallenge(Response response) {
    // Memastikan response.data adalah String sebelum memanggil contains
    return response.statusCode == 200 &&
        response.data != null &&
        response.data is String && // Tambahkan cek tipe data
        response.data.toString().contains('One moment, please...');
  }

  Future<Response> httpGet(
    String url, {
    Options? options,
    bool bypassCloudflare = true,
    int maxRetry = 3,
  }) async {
    String fullUrl = '$baseUrl$url';
    print('--- Permintaan HTTP GET Dijalankan ---');
    print('URL Lengkap: $fullUrl');

    Options finalOptions = options ?? defaultApiOptions;
    if (finalOptions.headers != null) {
      print('Opsi GET (Header): ${finalOptions.headers}');
    }

    Dio dio = _createDio();
    Response? response;
    DioException? lastError; // Perbaikan: Gunakan DioException untuk Dio 5+

    // Buat opsi dasar untuk permintaan
    final baseRequestOptions = RequestOptions(
      path: fullUrl,
      method: 'GET',
      headers: finalOptions.headers,
      contentType: finalOptions.contentType,
      responseType: finalOptions.responseType,
      // Perbaikan: Gunakan Duration langsung
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
    );

    for (int percobaan = 1; percobaan <= maxRetry; percobaan++) {
      try {
        print('$tag: Percobaan $percobaan/$maxRetry');
        response = await dio.get(fullUrl, options: finalOptions);

        if (bypassCloudflare && _isCloudflareChallenge(response)) {
          print('$tag: Tantangan Cloudflare terdeteksi');

          // Ambil cookie dari respons
          // Pastikan headers['set-cookie'] tidak null dan memiliki elemen pertama
          final String? cookie = response.headers['set-cookie']?.first;

          if (cookie != null) {
            print('$tag: Mendapatkan cookie Cloudflare: $cookie');

            // Perbarui header dengan cookie
            Map<String, dynamic> headerBaru =
                Map.from(finalOptions.headers ?? {});
            headerBaru['cookie'] = cookie;

            // Buat opsi baru dengan cookie
            finalOptions = finalOptions.copyWith(
                headers:
                    headerBaru); // Gunakan copyWith untuk mempertahankan properti lain

            // Tunggu sebelum mencoba lagi
            await Future.delayed(const Duration(seconds: 2));
            continue; // Lanjutkan ke percobaan berikutnya
          }
        }

        // Jika bukan tantangan, kembalikan respons
        print('--- Respons HTTP GET Diterima ---');
        print('URL: $fullUrl');
        print('Status Kode: ${response.statusCode}');
        print('--- Permintaan GET Selesai ---');
        return response;
      } on DioException catch (e) {
        // Perbaikan: Tangkap DioException
        lastError = e;
        print('!!! Error HTTP GET Ditemukan !!!');
        print('URL Gagal: $fullUrl');
        print('Tipe Error: ${e.type}');
        print('Pesan Error: ${e.message}');

        if (e.response != null) {
          print('Status Kode: ${e.response?.statusCode}');
          print('Data Error: ${e.response?.data}');
        }

        // Tunggu sebelum mencoba lagi
        await Future.delayed(const Duration(seconds: 2));
      } catch (e, stackTrace) {
        // Tangkap error umum dan stack trace
        print('!!! Kesalahan tidak diketahui saat HTTP GET !!!');
        print('URL Gagal: $fullUrl');
        print('Pesan Error: $e');
        print('Stack Trace: $stackTrace'); // Cetak stack trace untuk debugging
        lastError = DioException(
          requestOptions: baseRequestOptions,
          error: 'Kesalahan tidak diketahui: $e',
          type: DioExceptionType
              .unknown, // Perbaikan: Gunakan DioExceptionType.unknown
        );
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    print('!!! Semua percobaan gagal !!!');
    print('URL Gagal: $fullUrl');

    // Tangani error dengan benar
    if (lastError != null) {
      throw lastError;
    } else {
      // Ini seharusnya tidak tercapai jika lastError selalu diatur, tapi sebagai fallback
      throw DioException(
        // Perbaikan: Gunakan DioException
        requestOptions: baseRequestOptions,
        error: 'Kesalahan tidak diketahui setelah $maxRetry percobaan',
        type: DioExceptionType
            .unknown, // Perbaikan: Gunakan DioExceptionType.unknown
      );
    }
  }

  // Metode HTTP POST
  Future<Response> httpPost(
    String url, {
    dynamic data,
    Options? options,
  }) async {
    String fullUrl = '$baseUrl$url';
    print('--- Permintaan HTTP POST Dijalankan ---');
    print('URL Lengkap: $fullUrl');
    print('Data POST: $data');

    final baseRequestOptions = RequestOptions(
      path: fullUrl,
      method: 'POST',
      headers: options?.headers,
      contentType: options?.contentType,
      responseType: options?.responseType,
      // Perbaikan: Gunakan Duration langsung
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
    );

    try {
      var dio = _createDio();
      Response response = await dio.post(fullUrl, data: data, options: options);
      print('--- Respons HTTP POST Diterima ---');
      print('URL: $fullUrl');
      print('Status Kode: ${response.statusCode}');
      print('--- Permintaan POST Selesai ---');
      return response;
    } on DioException catch (e) {
      // Perbaikan: Tangkap DioException
      print('!!! Error HTTP POST Ditemukan !!!');
      print('URL Gagal: $fullUrl');
      print('Tipe Error: ${e.type}');
      print('Pesan Error: ${e.message}');
      if (e.response != null) {
        print('Status Kode: ${e.response?.statusCode}');
        print('Data Error: ${e.response?.data}');
      }
      rethrow;
    } catch (e, stackTrace) {
      // Tangkap error umum dan stack trace
      print('!!! Kesalahan POST tidak diketahui !!!');
      print('URL Gagal: $fullUrl');
      print('Pesan Error: $e');
      print('Stack Trace: $stackTrace');
      throw DioException(
        // Perbaikan: Gunakan DioException
        requestOptions: baseRequestOptions,
        error: 'Kesalahan POST tidak diketahui: $e',
        type: DioExceptionType
            .unknown, // Perbaikan: Gunakan DioExceptionType.unknown
      );
    }
  }

  // Metode HTTP DELETE
  Future<Response> httpDelete(
    String url, {
    Options? options,
  }) async {
    String fullUrl = '$baseUrl$url';
    print('--- Permintaan HTTP DELETE Dijalankan ---');
    print('URL Lengkap: $fullUrl');

    final baseRequestOptions = RequestOptions(
      path: fullUrl,
      method: 'DELETE',
      headers: options?.headers,
      contentType: options?.contentType,
      responseType: options?.responseType,
      // Perbaikan: Gunakan Duration langsung
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
    );

    try {
      var dio = _createDio();
      Response response = await dio.delete(fullUrl, options: options);
      print('--- Respons HTTP DELETE Diterima ---');
      print('URL: $fullUrl');
      print('Status Kode: ${response.statusCode}');
      print('--- Permintaan DELETE Selesai ---');
      return response;
    } on DioException catch (e) {
      // Perbaikan: Tangkap DioException
      print('!!! Error HTTP DELETE Ditemukan !!!');
      print('URL Gagal: $fullUrl');
      print('Tipe Error: ${e.type}');
      print('Pesan Error: ${e.message}');
      if (e.response != null) {
        print('Status Kode: ${e.response?.statusCode}');
        print('Data Error: ${e.response?.data}');
      }
      rethrow;
    } catch (e, stackTrace) {
      // Tangkap error umum dan stack trace
      print('!!! Kesalahan DELETE tidak diketahui !!!');
      print('URL Gagal: $fullUrl');
      print('Pesan Error: $e');
      print('Stack Trace: $stackTrace');
      throw DioException(
        // Perbaikan: Gunakan DioException
        requestOptions: baseRequestOptions,
        error: 'Kesalahan DELETE tidak diketahui: $e',
        type: DioExceptionType
            .unknown, // Perbaikan: Gunakan DioExceptionType.unknown
      );
    }
  }

  // Metode HTTP PUT
  Future<Response> httpPut(
    String url, {
    dynamic data,
    Options? options,
  }) async {
    String fullUrl = '$baseUrl$url';
    print('--- Permintaan HTTP PUT Dijalankan ---');
    print('URL Lengkap: $fullUrl');
    print('Data PUT: $data');

    final baseRequestOptions = RequestOptions(
      path: fullUrl,
      method: 'PUT',
      headers: options?.headers,
      contentType: options?.contentType,
      responseType: options?.responseType,
      // Perbaikan: Gunakan Duration langsung
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
    );

    try {
      var dio = _createDio();
      Response response = await dio.put(fullUrl, data: data, options: options);
      print('--- Respons HTTP PUT Diterima ---');
      print('URL: $fullUrl');
      print('Status Kode: ${response.statusCode}');
      print('--- Permintaan PUT Selesai ---');
      return response;
    } on DioException catch (e) {
      // Perbaikan: Tangkap DioException
      print('!!! Error HTTP PUT Ditemukan !!!');
      print('URL Gagal: $fullUrl');
      print('Tipe Error: ${e.type}');
      print('Pesan Error: ${e.message}');
      if (e.response != null) {
        print('Status Kode: ${e.response?.statusCode}');
        print('Data Error: ${e.response?.data}');
      }
      rethrow;
    } catch (e, stackTrace) {
      // Tangkap error umum dan stack trace
      print('!!! Kesalahan PUT tidak diketahui !!!');
      print('URL Gagal: $fullUrl');
      print('Pesan Error: $e');
      print('Stack Trace: $stackTrace');
      throw DioException(
        // Perbaikan: Gunakan DioException
        requestOptions: baseRequestOptions,
        error: 'Kesalahan PUT tidak diketahui: $e',
        type: DioExceptionType
            .unknown, // Perbaikan: Gunakan DioExceptionType.unknown
      );
    }
  }
}
