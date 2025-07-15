import 'package:http/http.dart' as http; // Menggunakan paket http
import 'package:pensiunku/data/api/base_api.dart'; // Pastikan path ini benar ke BaseApi yang sudah diubah

class PromoApi extends BaseApi {
  Future<http.Response> getAll() { // Mengubah tipe kembalian menjadi http.Response
    return httpGet('/promos');
  }
}
