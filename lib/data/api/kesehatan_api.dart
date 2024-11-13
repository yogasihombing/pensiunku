import 'package:dio/dio.dart';
import 'package:pensiunku/data/api/base_api.dart';

class KesehatanApi extends BaseApi {
  Future<Response> getAll() {
    return httpGet('/kesehatan');
  }

  Future<Response> getDetail(int hospitalId) {
    return httpGet('/kesehatan/$hospitalId');
  }
}
