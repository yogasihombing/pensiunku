import 'package:http/http.dart' as http; // Menggunakan paket http
import 'package:pensiunku/data/api/base_api.dart'; // Pastikan path ini benar ke BaseApi yang sudah diubah

class UsahaApi extends BaseApi {
  Future<http.Response> getAll(int categoryId) { // Mengubah tipe kembalian menjadi http.Response
    return httpGet('/usaha/category/$categoryId');
  }

  Future<http.Response> getDetail(int usahaId) { // Mengubah tipe kembalian menjadi http.Response
    return httpGet('/usaha/$usahaId');
  }
}
