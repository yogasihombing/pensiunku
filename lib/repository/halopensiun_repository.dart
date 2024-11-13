import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:pensiunku/data/api/halopenisun_api.dart';
import 'package:pensiunku/model/halopensiun_model.dart';
import 'package:pensiunku/repository/base_repository.dart';
import 'package:pensiunku/repository/result_model.dart';

class HalopensiunRepository extends BaseRepository {
  static String tag = 'Halopensiun Repository';
  HalopensiunApi api = HalopensiunApi();

  Future<ResultModel<HalopensiunModel>> getHalopensiuns(
      int categoryId, String? searchText, String token) async {
    assert(() {
      log('getHalopensiuns Repository', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat mendapatkan data halopensiun terbaru. Tolong periksa Internet Anda.';
    try {
      Response response =
          await api.getAllByCategoryAndKeyword(categoryId, searchText, token);
      var responseJson = response.data;
      log(responseJson['data'].toString(), name: tag);

      if (responseJson['status'] == 'success') {
        return ResultModel(
          isSuccess: true,
          data: HalopensiunModel.fromJson(responseJson['data']),
        );
      } else {
        log('message:' + responseJson.toString());
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

  Future<ResultModel<HalopensiunModel>> getAllHalopensiuns(String token) async {
    assert(() {
      log('getHalopensiuns Repository', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat mendapatkan data halopensiun terbaru. Tolong periksa Internet Anda.';
    try {
      Response response = await api.getAll(token);
      var responseJson = response.data;
      log(responseJson['data'].toString(), name: tag);

      if (responseJson['status'] == 'success') {
        return ResultModel(
          isSuccess: true,
          data: HalopensiunModel.fromJson(responseJson['data']),
        );
      } else {
        log('message:' + responseJson.toString());
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
