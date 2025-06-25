import 'dart:developer';
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:pensiunku/data/api/user_api.dart';
import 'package:pensiunku/data/db/app_database.dart';
import 'package:pensiunku/model/e_wallet/transaction_history_model.dart';
import 'package:pensiunku/model/e_wallet/user_bank_detail_model.dart';
import 'package:pensiunku/model/user_model.dart';
import 'package:pensiunku/repository/base_repository.dart';
import 'package:pensiunku/model/result_model.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/wallet/histori/e_wallet_histori.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';

class UserRepository extends BaseRepository {
  static String tag = 'UserRepository';
  UserApi api = UserApi();
  AppDatabase database = AppDatabase();

  static const int DEFAULT_TIMEOUT = 15000;
  static const int MAX_RETRY_ATTEMPTS = 2;
  static const int RETRY_DELAY_MS = 1500;

  Future<bool> _isConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<Response> _retryRequest(
      Future<Response> Function() requestFunction) async {
    int attempts = 0;
    DioError? lastError;

    while (attempts <= MAX_RETRY_ATTEMPTS) {
      try {
        if (attempts > 0) {
          log('Mencoba ulang request... Percobaan ke-$attempts', name: tag);
          await Future.delayed(Duration(milliseconds: RETRY_DELAY_MS));
        }

        return await requestFunction().timeout(
          Duration(milliseconds: DEFAULT_TIMEOUT),
          onTimeout: () {
            throw DioError(
              requestOptions: RequestOptions(path: ''),
              type: DioErrorType.connectTimeout,
              error: 'Koneksi timeout',
            );
          },
        );
      } on DioError catch (e) {
        lastError = e;
        attempts++;

        if (e.type != DioErrorType.connectTimeout &&
            e.type != DioErrorType.receiveTimeout &&
            e.type != DioErrorType.sendTimeout &&
            e.message != null && !e.message!.contains('SocketException')) {
          rethrow;
        }
      }
    }

    throw lastError!;
  }

  String _getSpecificErrorMessage(dynamic error) {
    if (error is DioError) {
      switch (error.type) {
        case DioErrorType.connectTimeout:
        case DioErrorType.sendTimeout:
          return 'Waktu koneksi habis. Periksa kecepatan internet Anda.';
        case DioErrorType.receiveTimeout:
          return 'Server membutuhkan waktu terlalu lama untuk merespons.';
        case DioErrorType.response:
          int? statusCode = error.response?.statusCode;
          if (statusCode != null) {
            if (statusCode == 401 || statusCode == 403) {
              return 'Anda tidak memiliki akses ke layanan ini.';
            } else if (statusCode == 404) {
              return 'Layanan tidak ditemukan.';
            } else if (statusCode >= 500 && statusCode < 600) {
              return 'Terjadi kendala pada server. Coba lagi nanti.';
            }
          }
          return 'Terjadi kesalahan pada jaringan.';
        case DioErrorType.cancel:
          return 'Permintaan dibatalkan.';
        case DioErrorType.other:
          if (error.message != null && error.message!.contains('SocketException')) {
            return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
          }
          return 'Terjadi kesalahan tidak dikenal.';
        default:
          return 'Terjadi kesalahan. Silakan coba lagi nanti.';
      }
    }
    return 'Terjadi kesalahan. Silakan coba lagi nanti.';
  }

  Future<ResultModel<bool>> sendOtp(String phone) async {
    assert(() {
      log('sendOtp', name: tag);
      return true;
    }());

    if (!await _isConnected()) {
      return ResultModel(
        isSuccess: false,
        error: 'Tidak ada koneksi internet. Silakan periksa jaringan Anda.',
      );
    }

    try {
      Response response = await _retryRequest(() => api.sendOtp(phone));
      var responseJson = response.data;

      if (responseJson['status'] == 'success') {
        return ResultModel(
          isSuccess: true,
          data: true,
        );
      } else {
        String errorMsg = responseJson['message'] ?? 'Gagal mengirim OTP.';
        return ResultModel(
          isSuccess: false,
          error: errorMsg,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      return ResultModel(
        isSuccess: false,
        error: _getSpecificErrorMessage(e),
      );
    }
  }

  Future<ResultModel<String>> verifyOtp(String phone, String otp) async {
    assert(() {
      log('verifyOtp', name: tag);
      return true;
    }());

    if (!await _isConnected()) {
      return ResultModel(
        isSuccess: false,
        error: 'Tidak ada koneksi internet. Silakan periksa jaringan Anda.',
      );
    }

    try {
      Response response = await _retryRequest(() => api.verifyOtp(phone, otp));
      var responseJson = response.data;

      if (responseJson['status'] == 'success') {
        Map<String, dynamic> data = responseJson['data'];
        return ResultModel(
          isSuccess: true,
          data: data['token'],
        );
      } else {
        return ResultModel(
          isSuccess: false,
          error:
              'Kode OTP tidak benar. Tolong periksa kode yang Anda masukkan.',
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      return ResultModel(
        isSuccess: false,
        error: _getSpecificErrorMessage(e),
      );
    }
  }

  Future<ResultModel<UserModel>> getOne(String token) async {
    assert(() {
      log('getOne $token', name: tag);
      return true;
    }());

    UserModel? userDb = await database.userDao.getOne();

    if (!await _isConnected()) {
      if (userDb != null) {
        log('Menggunakan data cache karena tidak ada koneksi internet',
            name: tag);
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

    try {
      Response response = await _retryRequest(() => api.getOne(token));
      var responseJson = response.data;

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
          error: responseJson['message'] ?? 'Gagal mengambil data pengguna.',
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);

      if (userDb != null) {
        log('Menggunakan data cache karena API error', name: tag);
        return ResultModel(
          isSuccess: true,
          data: userDb,
          isFromCache: true,
        );
      }

      return ResultModel(
        isSuccess: false,
        error: _getSpecificErrorMessage(e),
      );
    }
  }

  // Metode getUserRekening TELAH DIHAPUS dari UserRepository karena akan dipindahkan ke EWalletBankTujuan
  // Future<ResultModel<List<UserBankDetail>>> getUserRekening(String userId, String token) async { ... }

  // Metode getRiwayatWithdraw TELAH DIHAPUS dari UserRepository karena akan dipindahkan ke EWalletHistori
  // Future<ResultModel<List<TransactionHistory>>> getRiwayatWithdraw(String userId, String token) async { ... }

  Future<ResultModel<UserModel>> getOneDb(String token) async {
    assert(() {
      log('getOneDb', name: tag);
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
      log('updateOne', name: tag);
      return true;
    }());

    if (!await _isConnected()) {
      return ResultModel(
        isSuccess: false,
        error: 'Tidak ada koneksi internet. Silakan periksa jaringan Anda.',
      );
    }

    try {
      Response response = await _retryRequest(() => api.updateOne(token, data));
      var responseJson = response.data;

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
          error: responseJson['message'] ?? 'Gagal menyimpan data pengguna.',
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      return ResultModel(
        isSuccess: false,
        error: _getSpecificErrorMessage(e),
      );
    }
  }

  Future<ResultModel<bool>> userExists(String phone) async {
    assert(() {
      log('userExists', name: tag);
      return true;
    }());

    if (!await _isConnected()) {
      return ResultModel(
        isSuccess: false,
        error: 'Tidak ada koneksi internet. Silakan periksa jaringan Anda.',
      );
    }

    try {
      Response response = await _retryRequest(() => api.checkUserExists(phone));
      var responseJson = response.data;

      log('Response: $responseJson', name: tag);

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
          error: responseJson['message'] ?? 'Gagal memeriksa status pengguna.',
        );
      }
    } catch (e) {
      log('Error: $e', name: tag, error: e);
      return ResultModel(
        isSuccess: false,
        error: _getSpecificErrorMessage(e),
      );
    }
  }

  Future<ResultModel<bool>> saveFcmToken(String token, String fcmToken) async {
    assert(() {
      log('saveFcmToken', name: tag);
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

    try {
      Response response =
          await _retryRequest(() => api.saveFcmToken(token, fcmToken));
      var responseJson = response.data;

      if (responseJson['status'] == 'success') {
        return ResultModel(
          isSuccess: true,
          data: true,
        );
      } else {
        _saveFcmTokenLocally(token, fcmToken);
        return ResultModel(
          isSuccess: false,
          error: responseJson['message'] ?? 'Gagal menyimpan FCM token.',
          isFromCache: true,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      _saveFcmTokenLocally(token, fcmToken);
      return ResultModel(
        isSuccess: true,
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
    log('FCM token disimpan secara lokal untuk dikirim nanti', name: tag);
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
      } catch (e) {
        log('Gagal mengirim FCM token yang tertunda: $e', name: tag, error: e);
      }
    }
    return false;
  }
}


// class UserRepository extends BaseRepository {
//   static String tag = 'UserRepository';
//   UserApi api = UserApi();
//   AppDatabase database = AppDatabase();

//   Future<ResultModel<bool>> sendOtp(String phone) async {
//     assert(() {
//       log('sendOtp', name: tag);
//       return true;
//     }());
//     String finalErrorMessage =
//         'Tidak dapat mengirimkan OTP. Tolong periksa Internet Anda.';
//     try {
//       Response response = await api.sendOtp(phone);
//       var responseJson = response.data;

//       if (responseJson['status'] == 'success') {
//         return ResultModel(
//           isSuccess: true,
//           data: true,
//         );
//       } else {
//         return ResultModel(
//           isSuccess: false,
//           error: finalErrorMessage,
//         );
//       }
//     } catch (e) {
//       log(e.toString(), name: tag, error: e);
//       if (e is DioError) {
//         int? statusCode = e.response?.statusCode;
//         if (statusCode != null) {
//           if (statusCode >= 400 && statusCode < 500) {
//             // Client error
//             return ResultModel(
//               isSuccess: false,
//               error: finalErrorMessage,
//             );
//           } else if (statusCode >= 500 && statusCode < 600) {
//             // Server error
//             return ResultModel(
//               isSuccess: false,
//               error: finalErrorMessage,
//             );
//           }
//         }
//         if (e.message.contains('SocketException')) {
//           return ResultModel(
//             isSuccess: false,
//             error: finalErrorMessage,
//           );
//         }
//       }
//       return ResultModel(
//         isSuccess: false,
//         error: finalErrorMessage,
//       );
//     }
//   }

//   Future<ResultModel<String>> verifyOtp(String phone, String otp) async {
//     assert(() {
//       log('verifyOtp', name: tag);
//       return true;
//     }());
//     String finalErrorMessage =
//         'Tidak dapat memverifikasi OTP. Tolong periksa Internet Anda.';
//     try {
//       Response response = await api.verifyOtp(phone, otp);
//       var responseJson = response.data;

//       if (responseJson['status'] == 'success') {
//         Map<String, dynamic> data = responseJson['data'];
//         return ResultModel(
//           isSuccess: true,
//           data: data['token'],
//         );
//       } else {
//         return ResultModel(
//           isSuccess: false,
//           error:
//               'Kode OTP tidak benar. Tolong periksa kode yang Anda masukkan.',
//         );
//       }
//     } catch (e) {
//       log(e.toString(), name: tag, error: e);
//       if (e is DioError) {
//         int? statusCode = e.response?.statusCode;
//         if (statusCode != null) {
//           if (statusCode >= 400 && statusCode < 500) {
//             // Client error
//             return ResultModel(
//               isSuccess: false,
//               error: finalErrorMessage,
//             );
//           } else if (statusCode >= 500 && statusCode < 600) {
//             // Server error
//             return ResultModel(
//               isSuccess: false,
//               error: finalErrorMessage,
//             );
//           }
//         }
//         if (e.message.contains('SocketException')) {
//           return ResultModel(
//             isSuccess: false,
//             error: finalErrorMessage,
//           );
//         }
//       }
//       return ResultModel(
//         isSuccess: false,
//         error: finalErrorMessage,
//       );
//     }
//   }

//   Future<ResultModel<UserModel>> getOne(String token) {
//     assert(() {
//       log('getOne $token', name: tag);
//       return true;
//     }());
//     return getResultModel(
//       tag: tag,
//       getFromDb: () async {
//         UserModel? userDb = await database.userDao.getOne();
//         return userDb;
//       },
//       getFromApi: () => api.getOne(token),
//       getDataFromApiResponse: (responseJson) {
//         Map<String, dynamic> userJson = responseJson['data'];
//         int? notificationCounter = userJson['notification_counter'];
//         if (notificationCounter != null) {
//           SharedPreferencesUtil().sharedPreferences.setInt(
//                 SharedPreferencesUtil.SP_KEY_NOTIFICATION_COUNTER,
//                 notificationCounter,
//               );
//         }
//         return UserModel.fromJson(userJson);
//       },
//       removeFromDb: (user) async {
//         await database.userDao.removeAll();
//       },
//       insertToDb: (user) async {
//         await database.userDao.insert(user);
//       },
//       errorMessage: 'Gagal mengambil data user. Tolong periksa Internet Anda.',
//     );
//   }

//   Future<ResultModel<UserModel>> getOneDb(String token) async {
//     assert(() {
//       log('getOneDb', name: tag);
//       return true;
//     }());
//     UserModel? userDb = await database.userDao.getOne();
//     return ResultModel(
//       isSuccess: true,
//       data: userDb,
//     );
//   }

//   Future<ResultModel<UserModel>> updateOne(String token, dynamic data) {
//     assert(() {
//       log('updateOne', name: tag);
//       return true;
//     }());
//     return getResultModel(
//       tag: tag,
//       getFromDb: () async {
//         return null;
//       },
//       getFromApi: () => api.updateOne(token, data),
//       getDataFromApiResponse: (responseJson) {
//         Map<String, dynamic> userJson = responseJson['data'];
//         return UserModel.fromJson(userJson);
//       },
//       removeFromDb: (user) async {
//         await database.userDao.removeAll();
//       },
//       insertToDb: (user) async {
//         await database.userDao.insert(user);
//       },
//       errorMessage: 'Gagal menyimpan data user. Tolong periksa Internet Anda.',
//     );
//   }

//   Future<ResultModel<bool>> userExists(String phone) async {
//     try {
//       // Mengirimkan parameter 'telepon' sesuai dengan API
//       Response response = await api.checkUserExists(phone);
//       var responseJson = response.data;

//       // Log respons untuk debugging
//       log('Response: $responseJson');

//       // Periksa status respons
//       if (responseJson['status'] == 'success' && responseJson['data'] != null) {
//         bool exists = responseJson['data']['exists'];

//         if (!exists) {
//           return ResultModel(
//             isSuccess: false,
//             error:
//                 "Nomor Anda belum terdaftar. Silakan daftar terlebih dahulu.",
//             data: exists,
//           );
//         }

//         return ResultModel(
//           isSuccess: true,
//           data: exists,
//         );
//       } else {
//         return ResultModel(
//           isSuccess: false,
//           error: 'Gagal memeriksa status pengguna.',
//         );
//       }
//     } catch (e) {
//       log('Error: $e');
//       return ResultModel(
//         isSuccess: false,
//         error: 'Terjadi kesalahan saat memeriksa status pengguna.',
//       );
//     }
//   }

//   Future<ResultModel<bool>> saveFcmToken(String token, String fcmToken) async {
//     assert(() {
//       log('saveFcmToken: $token $fcmToken', name: tag);
//       return true;
//     }());
//     String finalErrorMessage =
//         'Tidak dapat menyimpan FCM Token terbaru. Tolong periksa Internet Anda.';
//     try {
//       Response response = await api.saveFcmToken(token, fcmToken);
//       var responseJson = response.data;

//       if (responseJson['status'] == 'success') {
//         return ResultModel(
//           isSuccess: true,
//           data: true,
//         );
//       } else {
//         return ResultModel(
//           isSuccess: false,
//           error: finalErrorMessage,
//         );
//       }
//     } catch (e) {
//       log(e.toString(), name: tag, error: e);
//       if (e is DioError) {
//         int? statusCode = e.response?.statusCode;
//         if (statusCode != null) {
//           if (statusCode >= 400 && statusCode < 500) {
//             // Client error
//             return ResultModel(
//               isSuccess: false,
//               error: finalErrorMessage,
//             );
//           } else if (statusCode >= 500 && statusCode < 600) {
//             // Server error
//             return ResultModel(
//               isSuccess: false,
//               error: finalErrorMessage,
//             );
//           }
//         }
//         if (e.message.contains('SocketException')) {
//           return ResultModel(
//             isSuccess: false,
//             error: finalErrorMessage,
//           );
//         }
//       }
//       return ResultModel(
//         isSuccess: false,
//         error: finalErrorMessage,
//       );
//     }
//   }
// }
