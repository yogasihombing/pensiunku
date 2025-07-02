import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:pensiunku/data/api/point_api.dart';
import 'package:pensiunku/model/point_model.dart';
import 'package:pensiunku/repository/base_repository.dart';
import 'package:pensiunku/model/result_model.dart';

class PointRepository extends BaseRepository {
  static String tag = 'Point Repository';
  PointApi api = PointApi();

  Future<ResultModel<PointModel>> getPoint(String token) async {
    assert(() {
      log('Point Repository: $token', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat mendapatkan data point terbaru. Tolong periksa Internet Anda.';
    try {
      Response response = await api.getPoint(token);
      var responseJson = response.data;
      log(responseJson['data'].toString(), name: tag);

      if (responseJson['status'] == 'success') {
        return ResultModel(
          isSuccess: true,
          data: PointModel.fromJson(responseJson["data"]),
        );
      } else {
        return ResultModel(
          isSuccess: false,
          error: finalErrorMessage,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is DioException) {
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

  Future<ResultModel<List<PriceListModel>>> getPriceList(
      String token, PriceModel price) async {
    assert(() {
      log('PriceList Repository: $token', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat mendapatkan pricelist terbaru. Tolong periksa Internet Anda.';
    try {
      Response response = await api.getPriceList(token, price);
      var responseJson = response.data;

      if (responseJson['status'] == 'success') {
        List<dynamic> itemsJson = responseJson['data'];
        List<PriceListModel> priceLists = [];
        itemsJson.forEach((value) {
          priceLists.add(
            PriceListModel.fromJson(value),
          );
        });
        return ResultModel(
          isSuccess: true,
          data: priceLists,
        );
      } else {
        return ResultModel(
          isSuccess: false,
          error: finalErrorMessage,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is DioException) {
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

  Future<ResultModel<MessageSuccessModel>> pushTopUp(
      String token, TopUpModel topUpModel) async {
    assert(() {
      log('Topup Repository: $token', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat melakukan topup. Tolong periksa Internet Anda.';
    try {
      Response response = await api.pushTopUp(token, topUpModel);
      var responseJson = response.data;

      if (responseJson['status'] == 'success') {
        dynamic itemsJson = responseJson['data'];
        MessageSuccessModel message = MessageSuccessModel.fromJson(itemsJson);

        return ResultModel(
          isSuccess: true,
          data: message,
        );
      } else {
        return ResultModel(
          isSuccess: false,
          error: finalErrorMessage,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is DioException) {
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

  Future<ResultModel<List<PointHistoryModel>>> getPointHistory(
      String token) async {
    assert(() {
      log('Point History Repository: $token', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat mendapatkan data history point terbaru. Tolong periksa Internet Anda.';
    try {
      Response response = await api.getPointHistory(token);
      var responseJson = response.data;
      log(responseJson['data'].toString(), name: tag);

      if (responseJson['status'] == 'success') {
        List<dynamic> itemsJson = responseJson['data'];
        List<PointHistoryModel> pointHistory = [];
        itemsJson.forEach((value) {
          pointHistory.add(
            PointHistoryModel.fromJson(value),
          );
        });
        return ResultModel(
          isSuccess: true,
          data: pointHistory,
        );
      } else {
        return ResultModel(
          isSuccess: false,
          error: finalErrorMessage,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is DioException) {
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
