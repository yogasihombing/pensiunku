import 'package:http/http.dart' as http;
import 'package:pensiunku/data/api/base_api.dart'; // Menggunakan paket http


class KesehatanApi extends BaseApi {
  Future<http.Response> getAll() { // Mengubah tipe kembalian menjadi http.Response
    return httpGet('/kesehatan');
  }

  Future<http.Response> getDetail(int hospitalId) { // Mengubah tipe kembalian menjadi http.Response
    return httpGet('/kesehatan/$hospitalId');
  }
}
