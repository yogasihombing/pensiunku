import 'package:dio/dio.dart';
import 'package:pensiunku/data/api/base_api.dart';

class FaqApi extends BaseApi {
  Future<Response> getAll() {
    return httpGet('/faq');
  }
}
