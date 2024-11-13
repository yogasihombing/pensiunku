import 'package:dio/dio.dart';
import 'package:pensiunku/data/api/base_api.dart';
import 'package:pensiunku/util/api_util.dart';

class CustomerSupportApi extends BaseApi {
  Future<Response> sendQuestion(String token, dynamic data) {
    return httpPost(
      '/contact',
      data: data,
      options: ApiUtil.getTokenOptions(token),
    );
  }
}
