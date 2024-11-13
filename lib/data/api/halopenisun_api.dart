import 'package:dio/dio.dart';
import 'package:pensiunku/data/api/base_api.dart';
import 'package:pensiunku/util/api_util.dart';

class HalopensiunApi extends BaseApi {
  Future<Response> getAll(String token) {
    return httpGet('/halopensiuns', options: ApiUtil.getTokenOptions(token));
  }

  Future<Response> getAllByCategory(int categoryId) {
    return httpGet('/halopensiun/cid/$categoryId');
  }

  Future<Response> getAllByKeyword(String keyword) {
    return httpGet('/halopensiun/search/$keyword');
  }

  Future<Response> getAllByCategoryAndKeyword(
      int categoryId, String? searchText, String token) {
    if (searchText == null) {
      return httpGet('/halopensiun/$categoryId',
          options: ApiUtil.getTokenOptions(token));
    } else {
      return httpGet('/halopensiun/$categoryId/$searchText',
          options: ApiUtil.getTokenOptions(token));
    }
  }
}
