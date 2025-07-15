// File: lib/repository/user_repository.dart

import 'dart:developer';
import 'dart:convert'; // Untuk json.decode
import 'dart:async'; // Untuk Future.delayed dan timeout

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http; // Menggunakan paket http
import 'package:pensiunku/data/api/user_api.dart'; // Pastikan path ini benar
import 'package:pensiunku/data/db/app_database.dart';
import 'package:pensiunku/model/user_model.dart';
import 'package:pensiunku/repository/base_repository.dart';
import 'package:pensiunku/model/result_model.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:pensiunku/data/api/base_api.dart'; // Import BaseApi untuk HttpException

class UserRepository extends BaseRepository {
  static String tag = 'UserRepository';
  UserApi api = UserApi(); // Asumsi UserApi juga menggunakan http.Client
  AppDatabase database = AppDatabase();

  static const int DEFAULT_TIMEOUT = 15000;
  static const int MAX_RETRY_ATTEMPTS = 2;
  static const int RETRY_DELAY_MS = 1500;

  Future<bool> _isConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Helper function untuk menangani kesalahan HttpException
  ResultModel<T> _handleHttpError<T>(
      HttpException e, String defaultErrorMessage) {
    final statusCode = e.statusCode;
    if (statusCode != null) {
      if (statusCode >= 400 && statusCode < 500) {
        // Client error
        if (statusCode == 401 || statusCode == 403) {
          return ResultModel(
            isSuccess: false,
            error: 'Anda tidak memiliki akses ke layanan ini.',
          );
        } else if (statusCode == 404) {
          return ResultModel(
            isSuccess: false,
            error: 'Layanan tidak ditemukan.',
          );
        }
        return ResultModel(
          isSuccess: false,
          error: e.responseBody?['message'] ?? defaultErrorMessage,
        );
      } else if (statusCode >= 500 && statusCode < 600) {
        // Server error
        return ResultModel(
          isSuccess: false,
          error: 'Terjadi kendala pada server. Coba lagi nanti.',
        );
      }
    } else if (e.message.contains('Failed host lookup') ||
        e.message.contains('Connection refused')) {
      return ResultModel(
        isSuccess: false,
        error:
            'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } else if (e.message.contains('Connection timed out')) {
      return ResultModel(
        isSuccess: false,
        error: 'Waktu koneksi habis. Periksa kecepatan internet Anda.',
      );
    }

    return ResultModel(
      isSuccess: false,
      error: defaultErrorMessage,
    );
  }

  // Helper function untuk retry request HTTP
  Future<http.Response> _retryHttpRequest(
      Future<http.Response> Function() requestFunction) async {
    int attempts = 0;
    HttpException? lastError;

    while (attempts <= MAX_RETRY_ATTEMPTS) {
      try {
        if (attempts > 0) {
          await Future.delayed(Duration(milliseconds: RETRY_DELAY_MS));
        }

        // Jalankan request dengan timeout
        return await requestFunction().timeout(
          Duration(milliseconds: DEFAULT_TIMEOUT),
          onTimeout: () {
            throw HttpException(
                message: 'Connection timed out',
                statusCode: 408); // Menggunakan HttpException
          },
        );
      } on HttpException catch (e) {
        lastError = e;
        attempts++;

        // Hanya retry untuk timeout atau masalah koneksi
        if (e.statusCode != 408 && // Request Timeout
            !e.message.contains('Connection timed out') &&
            !e.message.contains('Failed host lookup') &&
            !e.message.contains('Connection refused')) {
          rethrow; // Lempar error jika bukan masalah koneksi/timeout
        }
      } catch (e) {
        // Tangani error non-HttpException

        rethrow;
      }
    }
    throw lastError!; // Lempar error terakhir jika semua percobaan gagal
  }

  Future<ResultModel<bool>> sendOtp(String phone) async {
    assert(() {
      return true;
    }());

    if (!await _isConnected()) {
      return ResultModel(
        isSuccess: false,
        error: 'Tidak ada koneksi internet. Silakan periksa jaringan Anda.',
      );
    }

    String defaultErrorMessage = 'Gagal mengirim OTP.';
    try {
      // Asumsi api.sendOtp mengembalikan Future<http.Response>
      http.Response response =
          await _retryHttpRequest(() => api.sendOtp(phone));
      var responseJson = json.decode(response.body);
      print('sendOtp response: $responseJson');

      if (responseJson['status'] == 'success') {
        return ResultModel(
          isSuccess: true,
          data: true,
        );
      } else {
        String errorMsg = responseJson['message'] ?? defaultErrorMessage;
        return ResultModel(
          isSuccess: false,
          error: errorMsg,
        );
      }
    } on HttpException catch (e) {
      return _handleHttpError(e, defaultErrorMessage);
    } catch (e) {
      return ResultModel(
        isSuccess: false,
        error: defaultErrorMessage,
      );
    }
  }

  Future<ResultModel<String>> verifyOtp(String phone, String otp) async {
    assert(() {
      return true;
    }());

    if (!await _isConnected()) {
      return ResultModel(
        isSuccess: false,
        error: 'Tidak ada koneksi internet. Silakan periksa jaringan Anda.',
      );
    }

    String defaultErrorMessage =
        'Kode OTP tidak benar. Tolong periksa kode yang Anda masukkan.';
    try {
      // Asumsi api.verifyOtp mengembalikan Future<http.Response>
      http.Response response =
          await _retryHttpRequest(() => api.verifyOtp(phone, otp));
      var responseJson = json.decode(response.body);
      print('sendOtp response: $responseJson');

      if (responseJson['status'] == 'success') {
        Map<String, dynamic> data = responseJson['data'];
        return ResultModel(
          isSuccess: true,
          data: data['token'],
        );
      } else {
        return ResultModel(
          isSuccess: false,
          error: responseJson['message'] ?? defaultErrorMessage,
        );
      }
    } on HttpException catch (e) {
      return _handleHttpError(e, defaultErrorMessage);
    } catch (e) {
      return ResultModel(
        isSuccess: false,
        error: defaultErrorMessage,
      );
    }
  }

  Future<ResultModel<UserModel>> getOne(String token) async {
    assert(() {
      return true;
    }());

    UserModel? userDb = await database.userDao.getOne();

    if (!await _isConnected()) {
      if (userDb != null) {
        return ResultModel(
          isSuccess: true,
          data: userDb,
          isFromCache: true,
        );
      } else {
        return ResultModel(
          isSuccess: false,
          error: 'Tidak ada koneksi internet dan data lokal tidak tersedia.',
        );
      }
    }

    String defaultErrorMessage = 'Gagal mengambil data pengguna.';
    try {
      // Asumsi api.getOne mengembalikan Future<http.Response>
      http.Response response = await _retryHttpRequest(() => api.getOne(token));
      var responseJson = json.decode(response.body);
      print('sendOtp response: $responseJson');

      if (responseJson['status'] == 'success') {
        Map<String, dynamic> userJson = responseJson['data'];
        int? notificationCounter = userJson['notification_counter'] as int?;
        if (notificationCounter != null) {
          SharedPreferencesUtil().sharedPreferences.setInt(
                SharedPreferencesUtil.SP_KEY_NOTIFICATION_COUNTER,
                notificationCounter,
              );
        }

        UserModel user = UserModel.fromJson(userJson);

        await database.userDao.removeAll();
        await database.userDao.insert(user);

        return ResultModel(
          isSuccess: true,
          data: user,
        );
      } else {
        if (userDb != null) {
          return ResultModel(
            isSuccess: true,
            data: userDb,
            isFromCache: true,
          );
        }

        return ResultModel(
          isSuccess: false,
          error: responseJson['message'] ?? defaultErrorMessage,
        );
      }
    } on HttpException catch (e) {
      if (userDb != null) {
        return ResultModel(
          isSuccess: true,
          data: userDb,
          isFromCache: true,
        );
      }
      return _handleHttpError(e, defaultErrorMessage);
    } catch (e) {
      if (userDb != null) {
        return ResultModel(
          isSuccess: true,
          data: userDb,
          isFromCache: true,
        );
      }
      return ResultModel(
        isSuccess: false,
        error: defaultErrorMessage,
      );
    }
  }

  Future<ResultModel<UserModel>> getOneDb(String token) async {
    assert(() {
      return true;
    }());
    UserModel? userDb = await database.userDao.getOne();
    if (userDb != null) {
      return ResultModel(
        isSuccess: true,
        data: userDb,
        isFromCache: true,
      );
    } else {
      return ResultModel(
        isSuccess: false,
        error: 'Data pengguna tidak tersedia secara lokal.',
      );
    }
  }

  Future<ResultModel<UserModel>> updateOne(String token, dynamic data) async {
    assert(() {
      return true;
    }());

    if (!await _isConnected()) {
      return ResultModel(
        isSuccess: false,
        error: 'Tidak ada koneksi internet. Silakan periksa jaringan Anda.',
      );
    }

    String defaultErrorMessage = 'Gagal menyimpan data pengguna.';
    try {
      // Asumsi api.updateOne mengembalikan Future<http.Response>
      http.Response response =
          await _retryHttpRequest(() => api.updateOne(token, data));
      var responseJson = json.decode(response.body);
      print('updateOne response: $responseJson');

      if (responseJson['status'] == 'success') {
        Map<String, dynamic> userJson = responseJson['data'];
        UserModel user = UserModel.fromJson(userJson);

        await database.userDao.removeAll();
        await database.userDao.insert(user);

        return ResultModel(
          isSuccess: true,
          data: user,
        );
      } else {
        return ResultModel(
          isSuccess: false,
          error: responseJson['message'] ?? defaultErrorMessage,
        );
      }
    } on HttpException catch (e) {
      return _handleHttpError(e, defaultErrorMessage);
    } catch (e) {
      return ResultModel(
        isSuccess: false,
        error: defaultErrorMessage,
      );
    }
  }

  Future<ResultModel<bool>> userExists(String phone) async {
    assert(() {
      return true;
    }());

    if (!await _isConnected()) {
      return ResultModel(
        isSuccess: false,
        error: 'Tidak ada koneksi internet. Silakan periksa jaringan Anda.',
      );
    }

    String defaultErrorMessage = 'Gagal memeriksa status pengguna.';
    try {
      // Asumsi api.checkUserExists mengembalikan Future<http.Response>
      http.Response response =
          await _retryHttpRequest(() => api.checkUserExists(phone));
      var responseJson = json.decode(response.body);
      print('updateOne response: $responseJson');

      if (responseJson['status'] == 'success' && responseJson['data'] != null) {
        bool exists = responseJson['data']['exists'] as bool;

        if (!exists) {
          return ResultModel(
            isSuccess: false,
            error:
                "Nomor Anda belum terdaftar. Silakan daftar terlebih dahulu.",
            data: exists,
          );
        }

        return ResultModel(
          isSuccess: true,
          data: exists,
        );
      } else {
        return ResultModel(
          isSuccess: false,
          error: responseJson['message'] ?? defaultErrorMessage,
        );
      }
    } on HttpException catch (e) {
      return _handleHttpError(e, defaultErrorMessage);
    } catch (e) {
      return ResultModel(
        isSuccess: false,
        error: defaultErrorMessage,
      );
    }
  }

  Future<ResultModel<bool>> saveFcmToken(String token, String fcmToken) async {
    assert(() {
      return true;
    }());

    if (!await _isConnected()) {
      _saveFcmTokenLocally(token, fcmToken);
      return ResultModel(
        isSuccess: true,
        data: true,
        isFromCache: true,
      );
    }

    String defaultErrorMessage = 'Gagal menyimpan FCM token.';
    try {
      // Asumsi api.saveFcmToken mengembalikan Future<http.Response>
      http.Response response =
          await _retryHttpRequest(() => api.saveFcmToken(token, fcmToken));
      var responseJson = json.decode(response.body);
      print('updateOne response: $responseJson');

      if (responseJson['status'] == 'success') {
        return ResultModel(
          isSuccess: true,
          data: true,
        );
      } else {
        _saveFcmTokenLocally(token, fcmToken);
        return ResultModel(
          isSuccess: false,
          error: responseJson['message'] ?? defaultErrorMessage,
          isFromCache: true,
        );
      }
    } on HttpException catch (e) {
      _saveFcmTokenLocally(token, fcmToken);
      return ResultModel(
        isSuccess: true, // Masih mengembalikan true jika disimpan lokal
        data: true,
        isFromCache: true,
      );
    } catch (e) {
      _saveFcmTokenLocally(token, fcmToken);
      return ResultModel(
        isSuccess: true, // Masih mengembalikan true jika disimpan lokal
        data: true,
        isFromCache: true,
      );
    }
  }

  void _saveFcmTokenLocally(String token, String fcmToken) {
    SharedPreferencesUtil().sharedPreferences.setString(
          'PENDING_FCM_TOKEN',
          fcmToken,
        );
  }

  Future<bool> sendPendingFcmToken(String token) async {
    String? pendingFcmToken = SharedPreferencesUtil()
        .sharedPreferences
        .getString('PENDING_FCM_TOKEN');
    if (pendingFcmToken != null && await _isConnected()) {
      try {
        ResultModel<bool> result = await saveFcmToken(token, pendingFcmToken);
        if (result.isSuccess) {
          SharedPreferencesUtil().sharedPreferences.remove('PENDING_FCM_TOKEN');
          return true;
        }
      } catch (e) {}
    }
    return false;
  }
}
