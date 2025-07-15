// File: lib/data/api/base_api.dart

import 'package:http/http.dart' as http; // Menggunakan paket http
import 'dart:convert'; // Untuk mengelola JSON
import 'dart:async'; // Untuk Future.timeout
import 'dart:io'; // Untuk SocketException
import 'package:pensiunku/config.dart'
    show apiHost, defaultApiHeaders; // Menggunakan defaultApiHeaders

// Kelas Exception kustom untuk menangani error HTTP, mirip DioException
class HttpException implements Exception {
  final int? statusCode;
  final String message;
  final dynamic responseBody; // Bisa berupa String atau Map
  final Uri? requestUrl;

  HttpException({
    this.statusCode,
    required this.message,
    this.responseBody,
    this.requestUrl,
  });

  @override
  String toString() {
    return 'HttpException: $message (Status: $statusCode, URL: $requestUrl)';
  }
}

class BaseApi {
  static String tag = 'BaseApi';
  static String? get baseUrl => apiHost;
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 5);

  bool _isCloudflareChallenge(http.Response response) {
    return response.statusCode == 200 &&
        response.body.contains('One moment, please...');
  }

  // --- PERUBAHAN: Memperbaiki parameter httpGet menjadi queryParameters ---
  Future<http.Response> httpGet(
    String url, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters, // Parameter untuk query string
    bool bypassCloudflare = true,
    int maxRetry = 3,
  }) async {
    Uri uri = Uri.parse('${baseUrl!}$url');
    if (queryParameters != null && queryParameters.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParameters);
    }

    print('--- Permintaan HTTP GET Dijalankan ---');
    print('URL Lengkap: $uri');

    Map<String, String> finalHeaders = {...defaultApiHeaders, ...?headers};
    print('Opsi GET (Header): $finalHeaders');

    http.Response? response;
    HttpException? lastError;

    for (int percobaan = 1; percobaan <= maxRetry; percobaan++) {
      try {
        print('$tag: Percobaan $percobaan/$maxRetry');
        response = await http.get(uri, headers: finalHeaders).timeout(
              connectTimeout + receiveTimeout,
              onTimeout: () {
                throw TimeoutException('Koneksi atau penerimaan data timeout');
              },
            );

        if (response.statusCode == 401) {
          throw HttpException(
            message: 'Sesi Anda telah berakhir. Mohon login kembali.',
            statusCode: 401,
            responseBody: response.body,
            requestUrl: uri,
          );
        }

        if (response.headers.containsKey('cf-mitigated') &&
            response.headers['cf-mitigated'] == 'challenge') {
          print(
              '$tag: Tantangan Cloudflare terdeteksi melalui header cf-mitigated.');
        } else if (bypassCloudflare && _isCloudflareChallenge(response)) {
          print('$tag: Tantangan Cloudflare terdeteksi (legacy check).');
          final String? cookie = response.headers['set-cookie'];
          if (cookie != null) {
            print('$tag: Mendapatkan cookie Cloudflare: $cookie');
            finalHeaders['cookie'] = cookie;
          }
        } else {
          print('--- Respons HTTP GET Diterima ---');
          print('URL: $uri');
          print('Status Kode: ${response.statusCode}');
          print('--- Permintaan GET Selesai ---');
          return response;
        }

        int delaySeconds = 1 << (percobaan - 1);
        if (delaySeconds > 30) delaySeconds = 30;
        print(
            '$tag: Menunggu ${delaySeconds} detik sebelum percobaan berikutnya...');
        await Future.delayed(Duration(seconds: delaySeconds));
      } on TimeoutException catch (e) {
        lastError = HttpException(
          statusCode: null,
          message: e.message ?? 'Permintaan HTTP timeout',
          requestUrl: uri,
        );
        print('!!! Error HTTP GET Ditemukan (Timeout) !!!');
        print('URL Gagal: $uri');
        print('Pesan Error: ${e.message}');
        int delaySeconds = 1 << (percobaan - 1);
        if (delaySeconds > 30) delaySeconds = 30;
        await Future.delayed(Duration(seconds: delaySeconds));
      } on SocketException catch (e) {
        lastError = HttpException(
          statusCode: null,
          message: 'Tidak ada koneksi internet. Tolong periksa Internet Anda.',
          requestUrl: uri,
        );
        print('!!! Error HTTP GET Ditemukan (SocketException) !!!');
        print('URL Gagal: $uri');
        print('Pesan Error: ${e.message}');
        int delaySeconds = 1 << (percobaan - 1);
        if (delaySeconds > 30) delaySeconds = 30;
        await Future.delayed(Duration(seconds: delaySeconds));
      } on HttpException catch (e) {
        lastError = e;
        print('!!! Error HTTP GET Ditemukan (HttpException) !!!');
        print('URL Gagal: $uri');
        print('Pesan Error: ${e.message}');
        if (e.responseBody != null) {
          print('Respons Error: ${e.responseBody}');
        }
        if (e.statusCode == 401) {
          rethrow;
        }
        int delaySeconds = 1 << (percobaan - 1);
        if (delaySeconds > 30) delaySeconds = 30;
        await Future.delayed(Duration(seconds: delaySeconds));
      } catch (e, stackTrace) {
        lastError = HttpException(
          statusCode: response?.statusCode,
          message: 'Kesalahan tidak diketahui: $e',
          responseBody: response?.body,
          requestUrl: uri,
        );
        print('!!! Error HTTP GET Ditemukan (Umum) !!!');
        print('URL Gagal: $uri');
        print('Pesan Error: $e');
        print('Stack Trace: $stackTrace');

        if (response != null) {
          print('Status Kode: ${response.statusCode}');
          print('Data Error: ${response.body}');
        }
        int delaySeconds = 1 << (percobaan - 1);
        if (delaySeconds > 30) delaySeconds = 30;
        await Future.delayed(Duration(seconds: delaySeconds));
      }
    }

    print('!!! Semua percobaan gagal !!!');
    print('URL Gagal: $uri');

    if (lastError != null) {
      throw lastError;
    } else {
      throw HttpException(
        message: 'Kesalahan tidak diketahui setelah $maxRetry percobaan',
        requestUrl: uri,
      );
    }
  }
  // --- AKHIR PERUBAHAN ---

  // --- PERUBAHAN: Memperbaiki parameter httpPost menjadi data dan queryParameters ---
  Future<http.Response> httpPost(
    String url, {
    dynamic data, // Parameter untuk request body
    Map<String, String>? headers,
    Map<String, String>? queryParameters, // Parameter untuk query string
  }) async {
    Uri uri = Uri.parse('${baseUrl!}$url');
    if (queryParameters != null && queryParameters.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParameters);
    }

    print('--- Permintaan HTTP POST Dijalankan ---');
    print('URL Lengkap: $uri');
    print('Data POST: $data');

    Map<String, String> finalHeaders = {...defaultApiHeaders, ...?headers};
    print('Opsi POST (Header): $finalHeaders');

    try {
      final response = await http
          .post(
            uri,
            headers: finalHeaders,
            body: data != null ? json.encode(data) : null,
          )
          .timeout(
            connectTimeout + receiveTimeout,
            onTimeout: () {
              throw TimeoutException('Koneksi atau penerimaan data timeout');
            },
          );

      if (response.statusCode == 401) {
        throw HttpException(
          message: 'Sesi Anda telah berakhir. Mohon login kembali.',
          statusCode: 401,
          responseBody: response.body,
          requestUrl: uri,
        );
      }

      print('--- Respons HTTP POST Diterima ---');
      print('URL: $uri');
      print('Status Kode: ${response.statusCode}');
      print('--- Permintaan POST Selesai ---');
      return response;
    } on TimeoutException catch (e) {
      throw HttpException(
        statusCode: null,
        message: e.message ?? 'Permintaan HTTP timeout',
        requestUrl: uri,
      );
    } on SocketException catch (e) {
      throw HttpException(
        statusCode: null,
        message: 'Tidak ada koneksi internet. Tolong periksa Internet Anda.',
        requestUrl: uri,
      );
    } on HttpException catch (e) {
      rethrow;
    } catch (e, stackTrace) {
      print('!!! Kesalahan POST tidak diketahui !!!');
      print('URL Gagal: $uri');
      print('Pesan Error: $e');
      print('Stack Trace: $stackTrace');
      throw HttpException(
        message: 'Kesalahan POST tidak diketahui: $e',
        requestUrl: uri,
      );
    }
  }
  // --- AKHIR PERUBAHAN ---

  // --- PERUBAHAN: Memperbaiki parameter httpDelete menjadi data dan queryParameters ---
  Future<http.Response> httpDelete(
    String url, {
    dynamic data, // Parameter untuk request body
    Map<String, String>? headers,
    Map<String, String>? queryParameters, // Parameter untuk query string
  }) async {
    Uri uri = Uri.parse('${baseUrl!}$url');
    if (queryParameters != null && queryParameters.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParameters);
    }

    print('--- Permintaan HTTP DELETE Dijalankan ---');
    print('URL Lengkap: $uri');

    Map<String, String> finalHeaders = {...defaultApiHeaders, ...?headers};
    print('Opsi DELETE (Header): $finalHeaders');

    try {
      final response = await http
          .delete(
            uri,
            headers: finalHeaders,
            body: data != null ? json.encode(data) : null,
          )
          .timeout(
            connectTimeout + receiveTimeout,
            onTimeout: () {
              throw TimeoutException('Koneksi atau penerimaan data timeout');
            },
          );

      if (response.statusCode == 401) {
        throw HttpException(
          message: 'Sesi Anda telah berakhir. Mohon login kembali.',
          statusCode: 401,
          responseBody: response.body,
          requestUrl: uri,
        );
      }

      print('--- Respons HTTP DELETE Diterima ---');
      print('URL: $uri');
      print('Status Kode: ${response.statusCode}');
      print('--- Permintaan DELETE Selesai ---');
      return response;
    } on TimeoutException catch (e) {
      throw HttpException(
        statusCode: null,
        message: e.message ?? 'Permintaan HTTP timeout',
        requestUrl: uri,
      );
    } on SocketException catch (e) {
      throw HttpException(
        statusCode: null,
        message: 'Tidak ada koneksi internet. Tolong periksa Internet Anda.',
        requestUrl: uri,
      );
    } on HttpException catch (e) {
      rethrow;
    } catch (e, stackTrace) {
      print('!!! Kesalahan DELETE tidak diketahui !!!');
      print('URL Gagal: $uri');
      print('Pesan Error: $e');
      print('Stack Trace: $stackTrace');
      throw HttpException(
        message: 'Kesalahan DELETE tidak diketahui: $e',
        requestUrl: uri,
      );
    }
  }
  // --- AKHIR PERUBAHAN ---

  // --- PERUBAHAN: Memperbaiki parameter httpPut menjadi data dan queryParameters ---
  Future<http.Response> httpPut(
    String url, {
    dynamic data, // Parameter untuk request body
    Map<String, String>? headers,
    Map<String, String>? queryParameters, // Parameter untuk query string
  }) async {
    Uri uri = Uri.parse('${baseUrl!}$url');
    if (queryParameters != null && queryParameters.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParameters);
    }

    print('--- Permintaan HTTP PUT Dijalankan ---');
    print('URL Lengkap: $uri');
    print('Data PUT: $data');

    Map<String, String> finalHeaders = {...defaultApiHeaders, ...?headers};
    print('Opsi PUT (Header): $finalHeaders');

    try {
      final response = await http
          .put(
            uri,
            headers: finalHeaders,
            body: data != null ? json.encode(data) : null,
          )
          .timeout(
            connectTimeout + receiveTimeout,
            onTimeout: () {
              throw TimeoutException('Koneksi atau penerimaan data timeout');
            },
          );

      if (response.statusCode == 401) {
        throw HttpException(
          message: 'Sesi Anda telah berakhir. Mohon login kembali.',
          statusCode: 401,
          responseBody: response.body,
          requestUrl: uri,
        );
      }

      print('--- Respons HTTP PUT Diterima ---');
      print('URL: $uri');
      print('Status Kode: ${response.statusCode}');
      print('--- Permintaan PUT Selesai ---');
      return response;
    } on TimeoutException catch (e) {
      throw HttpException(
        statusCode: null,
        message: e.message ?? 'Permintaan HTTP timeout',
        requestUrl: uri,
      );
    } on SocketException catch (e) {
      throw HttpException(
        statusCode: null,
        message: 'Tidak ada koneksi internet. Tolong periksa Internet Anda.',
        requestUrl: uri,
      );
    } on HttpException catch (e) {
      rethrow;
    } catch (e, stackTrace) {
      print('!!! Kesalahan PUT tidak diketahui !!!');
      print('URL Gagal: $uri');
      print('Pesan Error: $e');
      print('Stack Trace: $stackTrace');
      throw HttpException(
        message: 'Kesalahan PUT tidak diketahui: $e',
        requestUrl: uri,
      );
    }
  }
  // --- AKHIR PERUBAHAN ---
}