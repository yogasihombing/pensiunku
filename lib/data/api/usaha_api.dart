import 'package:dio/dio.dart';
import 'package:pensiunku/data/api/base_api.dart';

class UsahaApi extends BaseApi {
  Future<Response> getAll(int categoryId) {
    return httpGet('/usaha/category/$categoryId');
  }

  Future<Response> getDetail(int usahaId) {
    return httpGet('/usaha/$usahaId');
  }
}
