import 'package:http/http.dart' as http; // Menggunakan paket http
import 'package:pensiunku/data/api/base_api.dart'; // Pastikan path ini benar ke BaseApi yang sudah diubah
import 'package:pensiunku/util/api_util.dart'; // Import ApiUtil

class MonitoringApi extends BaseApi {
  Future<http.Response> getMonitoring(String token) { // Mengubah tipe kembalian menjadi http.Response
    return httpGet(
      '/pengajuan/monitoring',
      headers: ApiUtil.getTokenHeaders(token), // Menggunakan headers bukan options
    );
  }
}
