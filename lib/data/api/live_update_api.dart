import 'package:dio/dio.dart';
import 'package:pensiunku/data/api/base_api.dart';

class LiveUpdateApi extends BaseApi {
  Future<Response> getAll() {
    return httpGet('/updates');
  }
}
