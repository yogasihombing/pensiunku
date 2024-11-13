import 'package:dio/dio.dart';
import 'package:pensiunku/data/api/base_api.dart';

class SalaryPlaceApi extends BaseApi {
  Future<Response> getAll() {
    return httpGet('/banks');
  }
}
