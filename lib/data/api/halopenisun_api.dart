import 'package:http/http.dart' as http;
import 'package:pensiunku/data/api/base_api.dart';
import 'package:pensiunku/util/api_util.dart';

class HalopensiunApi extends BaseApi {

  Future<http.Response> getAll(String token) async {
    print('HalopensiunApi: getAll dipanggil. Endpoint: /halopensiuns');
    return httpGet(
      '/halopensiuns', // Perhatikan, ini tidak menggunakan _basePath
      headers: ApiUtil.getTokenHeaders(token),
    );
  }

  Future<http.Response> getAllByCategory(int categoryId) async {
    print('HalopensiunApi: getAllByCategory dipanggil. Endpoint: /halopensiun/cid/$categoryId');
    return httpGet('/halopensiun/cid/$categoryId'); // Path relatif
  }

  Future<http.Response> getAllByKeyword(String keyword) async {
    print('HalopensiunApi: getAllByKeyword dipanggil. Endpoint: /halopensiun/search/$keyword');
    return httpGet('/halopensiun/search/$keyword'); // Path relatif
  }

  Future<http.Response> getAllByCategoryAndKeyword(
    int categoryId,
    String? searchText,
    String token,
  ) async {
    final path = searchText == null || searchText.isEmpty
        ? '/halopensiun/$categoryId'
        : '/halopensiun/$categoryId/$searchText';
    print('HalopensiunApi: getAllByCategoryAndKeyword dipanggil. Endpoint: $path');
    return httpGet(
      path,
      headers: ApiUtil.getTokenHeaders(token),
    );
  }
}