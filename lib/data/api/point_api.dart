import 'package:http/http.dart' as http; // Menggunakan paket http
import 'dart:convert'; // Diperlukan untuk json.encode pada POST requests
import 'package:pensiunku/model/point_model.dart'; // Pastikan path ini benar untuk PriceModel dan TopUpModel
import 'package:pensiunku/util/api_util.dart';
import 'package:pensiunku/config.dart'; // Untuk apiHost

class PointApi {
  final String _baseUrl;

  // Inisialisasi _baseUrl dari config.dart, mirip EventApi
  PointApi() : _baseUrl = apiHost;

  /// Mendapatkan data poin pengguna
  Future<http.Response> getPoint(String token) async {
    final uri = Uri.parse('$_baseUrl/point');
    return await http.get(
      uri,
      headers: ApiUtil.getTokenHeaders(token), // Menggunakan getTokenHeaders
    );
  }

  /// Mendapatkan daftar harga (price list)
  Future<http.Response> getPriceList(String token, PriceModel price) async {
    final uri = Uri.parse('$_baseUrl/point/price-list');
    return await http.post(
      uri,
      headers: ApiUtil.getTokenHeaders(token), // Menggunakan getTokenHeaders
      body: json.encode(price.toJson()), // Mengubah data ke JSON string
    );
  }

  /// Melakukan top-up poin
  Future<http.Response> pushTopUp(String token, TopUpModel topUpModel) async {
    final uri = Uri.parse('$_baseUrl/point/topup');
    return await http.post(
      uri,
      headers: ApiUtil.getTokenHeaders(token), // Menggunakan getTokenHeaders
      body: json.encode(topUpModel.toJson()), // Mengubah data ke JSON string
    );
  }

  /// Mendapatkan riwayat poin
  Future<http.Response> getPointHistory(String token) async {
    final uri = Uri.parse('$_baseUrl/point/history');
    return await http.get(
      uri,
      headers: ApiUtil.getTokenHeaders(token), // Menggunakan getTokenHeaders
    );
  }
}
