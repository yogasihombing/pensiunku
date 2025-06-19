import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:pensiunku/data/api/usaha_api.dart';
import 'package:pensiunku/model/usaha_detail_model.dart';
import 'package:pensiunku/model/usaha_model.dart';
import 'package:pensiunku/repository/base_repository.dart';
import 'package:pensiunku/model/result_model.dart';

class UsahaRepository extends BaseRepository {
  static String tag = 'Usaha Repository';
  UsahaApi api = UsahaApi();

  Future<ResultModel<UsahaModel>> getAll(int categoryId) async {
    assert(() {
      log('getAll', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat mendapatkan list franchise yang terdaftar. Tolong periksa Internet Anda.';
    try {
      Response response = await api.getAll(categoryId);
      var responseJson = response.data;
      log(responseJson['data'].toString());

      if (responseJson['status'] == 'success') {
        return ResultModel(
          isSuccess: true,
          data: UsahaModel.fromJson(responseJson['data']),
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

  Future<ResultModel<DetailUsaha>> getDetail(int usahaId) async {
    assert(() {
      log('getAll', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat mendapatkan detail dari franchise yang dipilih. Tolong periksa Internet Anda.';
    try {
      Response response = await api.getDetail(usahaId);
      var responseJson = response.data;
      log(responseJson['data'].toString());

      if (responseJson['status'] == 'success') {
        return ResultModel(
          isSuccess: true,
          data: DetailUsaha.fromJson(responseJson['data']),
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
