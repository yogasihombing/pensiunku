import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:pensiunku/data/api/customer_support_api.dart';
import 'package:pensiunku/repository/result_model.dart';

class CustomerSupportRepository {
  static String tag = 'CustomerSupportRepository';
  CustomerSupportApi api = CustomerSupportApi();

  Future<ResultModel<bool>> sendQuestion(String token, dynamic data) async {
    assert(() {
      log('sendQuestion:', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat mengirimkan pertanyaan. Tolong periksa Internet Anda.';
    try {
      Response response = await api.sendQuestion(token, data);
      var responseJson = response.data;

      if (responseJson['status'] == 'success') {
        return ResultModel(
          isSuccess: true,
          data: true,
        );
      } else {
        return ResultModel(
          isSuccess: false,
          error: responseJson['msg'] ?? finalErrorMessage,
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
