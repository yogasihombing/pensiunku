import 'package:dio/dio.dart';
import 'package:pensiunku/data/api/base_api.dart';
import 'package:pensiunku/util/api_util.dart';

class MonitoringApi extends BaseApi {
  Future<Response> getMonitoring(String token) {
    return httpGet(
      '/pengajuan/monitoring',
      options: ApiUtil.getTokenOptions(token),
    );
  }
}
