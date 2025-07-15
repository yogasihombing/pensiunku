import 'package:http/http.dart' as http;
import 'package:pensiunku/util/api_util.dart';
import 'package:pensiunku/data/api/base_api.dart'; // Import BaseApi

class EventApi extends BaseApi {
  /// Mendapatkan list events dengan filter dan pencarian opsional
  Future<http.Response> getEvents(
    String token,
    int filterIndex,
    String? searchText,
  ) async {
    final path = searchText == null
        ? '/events/$filterIndex'
        : '/events/$filterIndex/$searchText';
    return httpGet(
      path, // Path relatif saja, baseUrl akan ditambahkan oleh BaseApi
      headers: ApiUtil.getTokenHeaders(token),
    );
  }

  /// Mendapatkan detail event berdasarkan ID
  Future<http.Response> getEvent(String token, int id) async {
    return httpGet(
      '/event/$id', // Path relatif saja
      headers: ApiUtil.getTokenHeaders(token),
    );
  }
}
