import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:pensiunku/data/api/kesehatan_api.dart';
import 'package:pensiunku/model/kesehatan_model.dart';
import 'package:pensiunku/repository/base_repository.dart';
import 'package:pensiunku/model/result_model.dart';

class KesehatanRepository extends BaseRepository {
  static String tag = 'Usaha Repository';
  KesehatanApi api = KesehatanApi();

  Future<ResultModel<KesehatanModel>> getAll() async {
    assert(() {
      log('getAll', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat mendapatkan list hospital. Tolong periksa Internet Anda.';
    try {
      Response response = await api.getAll();
      var responseJson = response.data;
      log(responseJson['data'].toString());

      if (responseJson['status'] == 'success') {
        return ResultModel(
          isSuccess: true,
          data: KesehatanModel.fromJson(responseJson['data']),
        );
      } else {
        return ResultModel(
          isSuccess: false,
          error: finalErrorMessage,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      // ignore: deprecated_member_use
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
        if (e.message?.contains('SocketException') ?? false) {
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

  Future<ResultModel<DetailHospitalModel>> getDetail(int hospitalId) async {
    assert(() {
      log('getDetail Hospital', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat mendapatkan detail dari rumah sakit yang dipilih. Tolong periksa Internet Anda.';
    try {
      Response response = await api.getDetail(hospitalId);
      var responseJson = response.data;
      log(responseJson['data'].toString());

      if (responseJson['status'] == 'success') {
        return ResultModel(
          isSuccess: true,
          data: DetailHospitalModel.fromJson(responseJson['data']),
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
        if (e.message?.contains('SocketException') ?? false) {
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
