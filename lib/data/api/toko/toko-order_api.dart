import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pensiunku/util/api_util.dart';
import 'package:pensiunku/data/api/base_api.dart'; // Import BaseApi

// --- PERUBAHAN: TokoOrderApi sekarang extends BaseApi ---
class TokoOrderApi extends BaseApi {
  // final String _baseUrl; // Tidak diperlukan lagi

  // TokoOrderApi() : _baseUrl = apiHost; // Tidak diperlukan lagi

  // --- PERUBAHAN: Menggunakan httpGet dari BaseApi ---
  Future<http.Response> getAllOrderHistory(String token) async {
    return httpGet(
      '/api/orders/',
      headers: ApiUtil.getTokenHeaders(token),
    );
  }
  // --- AKHIR PERUBAHAN ---

  // --- PERUBAHAN: Menggunakan httpGet dari BaseApi ---
  Future<http.Response> getOrderHistoryById(String token, int id) async {
    return httpGet(
      '/api/orders/$id',
      headers: ApiUtil.getTokenHeaders(token),
    );
  }
  // --- AKHIR PERUBAHAN ---

  // --- PERUBAHAN: Menggunakan httpPut dari BaseApi ---
  Future<http.Response> putUpdateStatusOrder(
    String token,
    int id,
    String status,
    DateTime? tanggalTerima,
    String? statusMessage,
  ) async {
    final tanggal = tanggalTerima?.toIso8601String() ?? '';
    final queryParameters = {
      'status': status,
      'tanggal_diterima': tanggal,
      'status_message': statusMessage ?? '',
    };
    // Perhatikan: http.put dengan queryParameters di URI tidak umum.
    // Jika API mengharapkan ini di body, Anda perlu mengubah 'data' parameter.
    // Untuk saat ini, asumsikan API menerima via query.
    return httpPut('/api/orders/$id',
      data: queryParameters, // Mengirimkan sebagai body
      headers: ApiUtil.getTokenHeaders(token),
      // body: jsonEncode(queryParameters), // Jika API mengharapkan di body
    );
  }
  // --- AKHIR PERUBAHAN ---

  // --- PERUBAHAN: Menggunakan httpPost dari BaseApi ---
  Future<http.Response> addProductsRatingAndReview(
    String token,
    dynamic data,
    int orderId,
  ) async {
    // Perhatikan: queryParameters di POST tidak umum.
    // Jika API mengharapkan orderId di body, Anda perlu mengubah 'data' parameter.
    // Untuk saat ini, asumsikan API menerima via query.
    return httpPost( // 'queryParameters' is not a valid parameter for httpPost
      '/api/reviews/savereview?orderId=${orderId.toString()}', // Pass orderId in the URL
      headers: ApiUtil.getTokenHeaders(token),
      data: jsonEncode(data),
    );
  }
  // --- AKHIR PERUBAHAN ---

  // --- PERUBAHAN: Menggunakan httpPost dari BaseApi ---
  Future<http.Response> checkoutCart(String token, dynamic data) async {
    return httpPost(
      '/api/orders/checkout',
      headers: ApiUtil.getTokenHeaders(token),
      data: jsonEncode(data),
    );
  }
  // --- AKHIR PERUBAHAN ---

  // --- PERUBAHAN: Menggunakan httpGet dari BaseApi ---
  Future<http.Response> getShippingAddressPreviewById(
    String token,
    int id,
  ) async {
    return httpGet(
      '/api/shippingAddress/preview/$id',
      headers: ApiUtil.getTokenHeaders(token),
    );
  }
  // --- AKHIR PERUBAHAN ---
}
