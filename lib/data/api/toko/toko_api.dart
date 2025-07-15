import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pensiunku/util/api_util.dart';
import 'package:pensiunku/config.dart'; // untuk apiHost
import 'package:pensiunku/model/toko/toko_model.dart';
import 'package:pensiunku/data/api/base_api.dart'; // Import BaseApi

class TokoApi extends BaseApi {
  // --- PERUBAHAN: Menggunakan httpGet dari BaseApi dengan queryParameters ---
  Future<http.Response> getAllProduct(int page, String token) {
    final params = <String, String>{
      'page': page.toString(),
    };
    return httpGet(
      '/api/product',
      queryParameters: params, // Menggunakan queryParameters
      headers: ApiUtil.getTokenHeaders(token),
    );
  }
  // --- AKHIR PERUBAHAN ---

  // --- PERUBAHAN: Menggunakan httpGet dari BaseApi dengan queryParameters ---
  Future<http.Response> getAllProductByCondition(
    int page,
    String token, {
    int? categoryId,
    String? title,
    int? fromPrice,
    int? toPrice,
    int? amount,
  }) {
    final params = <String, String>{
      'page': page.toString(),
      if (categoryId != null) 'category_id': categoryId.toString(),
      if (title != null) 'title': title,
      if (fromPrice != null) 'from_price': fromPrice.toString(),
      if (toPrice != null) 'to_price': toPrice.toString(),
      if (amount != null) 'amount': amount.toString(),
    };
    return httpGet(
      '/api/product', // Hapus '?' di sini, BaseApi akan menambahkannya jika ada queryParams
      queryParameters: params, // Menggunakan queryParameters
      headers: ApiUtil.getTokenHeaders(token),
    );
  }
  // --- AKHIR PERUBAHAN ---

  // --- PERUBAHAN: Menggunakan httpPost dari BaseApi dengan data sebagai body ---
  Future<http.Response> postToShoppingCart(
    String token,
    PushToShoppingCart pushToShoppingCart,
  ) {
    return httpPost(
      '/api/cart/saveproduct',
      headers: ApiUtil.getTokenHeaders(token),
      data: pushToShoppingCart.toJson(), // Langsung kirim Map, BaseApi akan encode
    );
  }
  // --- AKHIR PERUBAHAN ---

  // --- PERUBAHAN: Menggunakan httpPut dari BaseApi dengan data sebagai body ---
  Future<http.Response> putToShoppingCart(
    String token,
    PushToShoppingCart pushToShoppingCart,
  ) {
    return httpPut(
      '/api/cart/update',
      headers: ApiUtil.getTokenHeaders(token),
      data: pushToShoppingCart.toJson(), // Langsung kirim Map, BaseApi akan encode
    );
  }
  // --- AKHIR PERUBAHAN ---

  // --- PERUBAHAN: Menggunakan httpGet dari BaseApi ---
  Future<http.Response> getShoppingCart(String token) {
    return httpGet(
      '/api/cart/',
      headers: ApiUtil.getTokenHeaders(token),
    );
  }
  // --- AKHIR PERUBAHAN ---

  // --- PERUBAHAN: Menggunakan httpDelete dari BaseApi ---
  Future<http.Response> deleteShoppingCart(String token, int idCart) {
    return httpDelete(
      '/api/cart/$idCart',
      headers: ApiUtil.getTokenHeaders(token),
    );
  }
  // --- AKHIR PERUBAHAN ---

  // --- PERUBAHAN: Menggunakan httpGet dari BaseApi ---
  Future<http.Response> getShippingAddress(String token) {
    return httpGet(
      '/api/shippingAddress/',
      headers: ApiUtil.getTokenHeaders(token),
    );
  }
  // --- AKHIR PERUBAHAN ---

  // --- PERUBAHAN: Menggunakan httpGet dari BaseApi ---
  Future<http.Response> getShippingAddressPreview(String token) {
    return httpGet(
      '/api/shippingAddress/preview',
      headers: ApiUtil.getTokenHeaders(token),
    );
  }
  // --- AKHIR PERUBAHAN ---

  // --- PERUBAHAN: Menggunakan httpGet dari BaseApi ---
  Future<http.Response> getShippingAddressById(String token, int id) {
    return httpGet(
      '/api/shippingAddress/$id',
      headers: ApiUtil.getTokenHeaders(token),
    );
  }
  // --- AKHIR PERUBAHAN ---

  // --- PERUBAHAN: Menggunakan httpPost dari BaseApi dengan data sebagai body ---
  Future<http.Response> postShippingAddress(
    String token,
    ShippingAddress shippingAddress,
  ) {
    return httpPost(
      '/api/shippingAddress/save',
      headers: ApiUtil.getTokenHeaders(token),
      data: shippingAddress.newAddressToJson(), // Langsung kirim Map, BaseApi akan encode
    );
  }
  // --- AKHIR PERUBAHAN ---

  // --- PERUBAHAN: Menggunakan httpPut dari BaseApi dengan data sebagai body ---
  Future<http.Response> putShippingAddress(
    String token,
    ShippingAddress shippingAddress,
  ) {
    return httpPut(
      '/api/shippingAddress/${shippingAddress.id}',
      headers: ApiUtil.getTokenHeaders(token),
      data: shippingAddress.toJson(), // Langsung kirim Map, BaseApi akan encode
    );
  }
  // --- AKHIR PERUBAHAN ---

  // --- PERUBAHAN: Menggunakan httpDelete dari BaseApi ---
  Future<http.Response> deleteShippingAddress(String token, int idShippingAddress) {
    return httpDelete(
      '/api/shippingAddress/$idShippingAddress',
      headers: ApiUtil.getTokenHeaders(token),
    );
  }
  // --- AKHIR PERUBAHAN ---

  // --- PERUBAHAN: Menggunakan httpGet dari BaseApi dengan queryParameters ---
  Future<http.Response> getAllCategories(String token, {int page = 1}) {
    final params = <String, String>{
      'page': page.toString(),
    };
    return httpGet(
      '/api/category', // Hapus '?' di sini
      queryParameters: params, // Menggunakan queryParameters
      headers: ApiUtil.getTokenHeaders(token),
    );
  }
  // --- AKHIR PERUBAHAN ---

  // --- PERUBAHAN: Menggunakan httpGet dari BaseApi dengan queryParameters ---
  Future<http.Response> getLatestProductByCategory(
    int page,
    String token,
    int category,
    String searchText,
  ) {
    final path = searchText.isEmpty
        ? '/api/product/latest-products/$category'
        : '/api/product/latest-products/$category/$searchText';
    final params = <String, String>{
      'page': page.toString(),
    };
    return httpGet(
      path, // Hapus '?' di sini
      queryParameters: params, // Menggunakan queryParameters
      headers: ApiUtil.getTokenHeaders(token),
    );
  }
  // --- AKHIR PERUBAHAN ---

  // --- PERUBAHAN: Menggunakan httpGet dari BaseApi dengan queryParameters ---
  Future<http.Response> getFeaturedProductByCategory(
    int page,
    String token,
    int category,
    String searchText,
  ) {
    final path = searchText.isEmpty
        ? '/api/product/featured-products/$category'
        : '/api/product/featured-products/$category/$searchText';
    final params = <String, String>{
      'page': page.toString(),
    };
    return httpGet(
      path, // Hapus '?' di sini
      queryParameters: params, // Menggunakan queryParameters
      headers: ApiUtil.getTokenHeaders(token),
    );
  }
  // --- AKHIR PERUBAHAN ---

  // --- PERUBAHAN: Menggunakan httpGet dari BaseApi ---
  Future<http.Response> getRelatedProductById(String token, int productId) {
    return httpGet(
      '/api/product/related-products/$productId',
      headers: ApiUtil.getTokenHeaders(token),
    );
  }
  // --- AKHIR PERUBAHAN ---
}
