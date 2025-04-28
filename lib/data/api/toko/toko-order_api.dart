import 'package:dio/dio.dart';
import 'package:pensiunku/data/api/base_api.dart';
import 'package:pensiunku/util/api_util.dart';



class TokoOrderApi extends BaseApi {
  Future<Response> getAllOrderHistory(String token) {
    return httpGet('/api/orders/', options: ApiUtil.getTokenOptions(token));
  }

  Future<Response> getOrderHistoryById(String token, int id) {
    return httpGet('/api/orders/$id', options: ApiUtil.getTokenOptions(token));
  }

  Future<Response> putUpdateStatusOrder(String token, int id, String status,
      DateTime? tanggalTerima, String? statusMessage) {
    return httpPut(
        '/api/orders/$id?status=$status&tanggal_diterima=$tanggalTerima&status_message=$statusMessage',
        options: ApiUtil.getTokenOptions(token));
  }

  Future<Response> addProductsRatingandReview(
      String token, dynamic data, int orderId) {
    return httpPost(
      '/api/reviews/savereview?orderId=$orderId',
      data: data,
      options: ApiUtil.getTokenOptions(token),
    );
  }

  Future<Response> checkoutCart(String token, dynamic data) {
    return httpPost(
      '/api/orders/checkout',
      data: data,
      options: ApiUtil.getTokenOptions(token),
    );
  }

  Future<Response> getShippingAddressPreviewById(String token, int id) {
    return httpGet(
      '/api/shippingAddress/preview/$id',
      options: ApiUtil.getTokenOptions(token),
    );
  }
}
