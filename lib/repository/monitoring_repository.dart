import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:pensiunku/data/api/monitoring_pengajuan.dart';
import 'package:pensiunku/model/monitoring_pengajuan_model.dart';
import 'package:pensiunku/repository/base_repository.dart';
import 'package:pensiunku/repository/result_model.dart';

class MonitoringRepository extends BaseRepository {
  static String tag = 'Monitoring Repository';
  MonitoringApi api = MonitoringApi();

  Future<ResultModel<MonitoringPengajuanModel>> getMonitoring(
      String token) async {
    assert(() {
      log('Monitoring Repository: $token', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat mendapatkan monitoring pengajuan terbaru. Tolong periksa Internet Anda.';
    try {
      Response response = await api.getMonitoring(token);
      var responseJson = response.data;

      if (responseJson['status'] == 'success') {
        return ResultModel(
          isSuccess: true,
          data: MonitoringPengajuanModel.fromJson(responseJson["data"]),
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
