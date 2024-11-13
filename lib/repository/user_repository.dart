import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:pensiunku/data/api/user_api.dart';
import 'package:pensiunku/data/db/app_database.dart';
import 'package:pensiunku/model/user_model.dart';
import 'package:pensiunku/repository/base_repository.dart';
import 'package:pensiunku/repository/result_model.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';

class UserRepository extends BaseRepository {
  static String tag = 'UserRepository';
  UserApi api = UserApi();
  AppDatabase database = AppDatabase();

  Future<ResultModel<bool>> sendOtp(String phone) async {
    assert(() {
      log('sendOtp', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat mengirimkan OTP. Tolong periksa Internet Anda.';
    try {
      Response response = await api.sendOtp(phone);
      var responseJson = response.data;

      if (responseJson['status'] == 'success') {
        return ResultModel(
          isSuccess: true,
          data: true,
        );
      } else {
        return ResultModel(
          isSuccess: false,
          error: finalErrorMessage,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is DioError) {
        int? statusCode = e.response?.statusCode;
        if (statusCode != null) {
          if (statusCode >= 400 && statusCode < 500) {
            // Client error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          } else if (statusCode >= 500 && statusCode < 600) {
            // Server error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          }
        }
        if (e.message.contains('SocketException')) {
          return ResultModel(
            isSuccess: false,
            error: finalErrorMessage,
          );
        }
      }
      return ResultModel(
        isSuccess: false,
        error: finalErrorMessage,
      );
    }
  }

  Future<ResultModel<String>> verifyOtp(String phone, String otp) async {
    assert(() {
      log('verifyOtp', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat memverifikasi OTP. Tolong periksa Internet Anda.';
    try {
      Response response = await api.verifyOtp(phone, otp);
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
      if (e is DioError) {
        int? statusCode = e.response?.statusCode;
        if (statusCode != null) {
          if (statusCode >= 400 && statusCode < 500) {
            // Client error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          } else if (statusCode >= 500 && statusCode < 600) {
            // Server error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          }
        }
        if (e.message.contains('SocketException')) {
          return ResultModel(
            isSuccess: false,
            error: finalErrorMessage,
          );
        }
      }
      return ResultModel(
        isSuccess: false,
        error: finalErrorMessage,
      );
    }
  }

  Future<ResultModel<UserModel>> getOne(String token) {
    assert(() {
      log('getOne $token', name: tag);
      return true;
    }());
    return getResultModel(
      tag: tag,
      getFromDb: () async {
        UserModel? userDb = await database.userDao.getOne();
        return userDb;
      },
      getFromApi: () => api.getOne(token),
      getDataFromApiResponse: (responseJson) {
        Map<String, dynamic> userJson = responseJson['data'];
        int? notificationCounter = userJson['notification_counter'];
        if (notificationCounter != null) {
          SharedPreferencesUtil().sharedPreferences.setInt(
                SharedPreferencesUtil.SP_KEY_NOTIFICATION_COUNTER,
                notificationCounter,
              );
        }
        return UserModel.fromJson(userJson);
      },
      removeFromDb: (user) async {
        await database.userDao.removeAll();
      },
      insertToDb: (user) async {
        await database.userDao.insert(user);
      },
      errorMessage: 'Gagal mengambil data user. Tolong periksa Internet Anda.',
    );
  }

  Future<ResultModel<UserModel>> getOneDb(String token) async {
    assert(() {
      log('getOneDb', name: tag);
      return true;
    }());
    UserModel? userDb = await database.userDao.getOne();
    return ResultModel(
      isSuccess: true,
      data: userDb,
    );
  }

  Future<ResultModel<UserModel>> updateOne(String token, dynamic data) {
    assert(() {
      log('updateOne', name: tag);
      return true;
    }());
    return getResultModel(
      tag: tag,
      getFromDb: () async {
        return null;
      },
      getFromApi: () => api.updateOne(token, data),
      getDataFromApiResponse: (responseJson) {
        Map<String, dynamic> userJson = responseJson['data'];
        return UserModel.fromJson(userJson);
      },
      removeFromDb: (user) async {
        await database.userDao.removeAll();
      },
      insertToDb: (user) async {
        await database.userDao.insert(user);
      },
      errorMessage: 'Gagal menyimpan data user. Tolong periksa Internet Anda.',
    );
  }

  Future<ResultModel<bool>> saveFcmToken(String token, String fcmToken) async {
    assert(() {
      log('saveFcmToken: $token $fcmToken', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat menyimpan FCM Token terbaru. Tolong periksa Internet Anda.';
    try {
      Response response = await api.saveFcmToken(token, fcmToken);
      var responseJson = response.data;

      if (responseJson['status'] == 'success') {
        return ResultModel(
          isSuccess: true,
          data: true,
        );
      } else {
        return ResultModel(
          isSuccess: false,
          error: finalErrorMessage,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is DioError) {
        int? statusCode = e.response?.statusCode;
        if (statusCode != null) {
          if (statusCode >= 400 && statusCode < 500) {
            // Client error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          } else if (statusCode >= 500 && statusCode < 600) {
            // Server error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          }
        }
        if (e.message.contains('SocketException')) {
          return ResultModel(
            isSuccess: false,
            error: finalErrorMessage,
          );
        }
      }
      return ResultModel(
        isSuccess: false,
        error: finalErrorMessage,
      );
    }
  }
}
