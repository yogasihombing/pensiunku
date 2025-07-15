import 'package:http/http.dart' as http;
import 'package:pensiunku/data/api/base_api.dart';

class LiveUpdateApi extends BaseApi {
  Future<http.Response> getAll() { // Mengubah tipe kembalian menjadi http.Response
    return httpGet('/updates');
  }
}