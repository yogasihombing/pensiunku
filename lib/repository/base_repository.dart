import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:pensiunku/repository/result_model.dart';

class BaseRepository {
  Future<ResultModel<T>> getResultModel<T>({
    required String tag,
    required Future<T?> Function() getFromDb,
    required Future<Response> Function() getFromApi,
    required T Function(dynamic responseJson) getDataFromApiResponse,
    required Future<void> Function(T dataApi) removeFromDb,
    required Future<void> Function(T dataApi) insertToDb,
    required String errorMessage,
  }) async {
    String finalErrorMessage = errorMessage;
    T? dataDb = await getFromDb();
    try {
      Response response = await getFromApi();
      var responseJson = response.data;

      if (responseJson['status'] == 'success') {
        T dataApi = getDataFromApiResponse(responseJson);

        await removeFromDb(dataApi);

        // Insert to database
        await insertToDb(dataApi);

        dataDb = await getFromDb();

        return ResultModel(
          isSuccess: true,
          data: dataDb,
        );
      } else {
        return ResultModel(
          isSuccess: false,
          error: finalErrorMessage,
          data: dataDb,
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
              data: dataDb,
            );
          } else if (statusCode >= 500 && statusCode < 600) {
            // Server error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
              data: dataDb,
            );
          }
        }
        if (e.message.contains('SocketException')) {
          return ResultModel(
            isSuccess: false,
            error: finalErrorMessage,
            data: dataDb,
          );
        }
      }
      return ResultModel(
        isSuccess: false,
        error: finalErrorMessage,
        data: dataDb,
      );
    }
  }
}
