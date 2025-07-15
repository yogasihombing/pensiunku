import 'package:http/http.dart' as http; // Menggunakan paket http
import 'package:pensiunku/data/api/base_api.dart'; // Pastikan path ini benar ke BaseApi yang sudah diubah
import 'package:pensiunku/util/api_util.dart'; // Import ApiUtil

class NotificationApi extends BaseApi {
  Future<http.Response> getAll(String token) { // Mengubah tipe kembalian menjadi http.Response
    return httpGet(
      '/user-notification',
      headers: ApiUtil.getTokenHeaders(token), // Menggunakan headers bukan options
    );
  }

  Future<http.Response> readNotification(String token, int id) { // Mengubah tipe kembalian menjadi http.Response
    return httpPost(
      '/user-notification',
      data: {
        'id': id,
      },
      headers: ApiUtil.getTokenHeaders(token), // Menggunakan headers bukan options
    );
  }
}
