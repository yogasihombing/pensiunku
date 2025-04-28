import 'package:dio/dio.dart';
import 'package:pensiunku/data/api/base_api.dart';
import 'package:pensiunku/model/toko/toko_model.dart';
import 'package:pensiunku/util/api_util.dart';


class TokoApi extends BaseApi {
  Future<Response> getAllProduct(int page, String token) {
    return httpGet(
      '/api/product/?page=$page',
      options: ApiUtil.getTokenOptions(token),
    );
  }

  Future<Response> getAllProductByCondition(int page, String token,
      {int? categoryId,
      String? title,
      int? fromPrice,
      int? toPrice,
      int? amount}) {
    String searchParameter = '';
    if (categoryId != null) {
      searchParameter =
          searchParameter + 'category_id=' + categoryId.toString();
    }
    if (title != null) {
      searchParameter = searchParameter + 'title=' + title;
    }
    if (fromPrice != null) {
      searchParameter = searchParameter + 'from_price=' + fromPrice.toString();
    }
    if (toPrice != null) {
      searchParameter = searchParameter + 'to_price=' + toPrice.toString();
    }
    if (amount != null) {
      searchParameter = searchParameter + 'amount=' + amount.toString();
    }

    return httpGet(
      '/api/product/?page=$page&$searchParameter',
      options: ApiUtil.getTokenOptions(token),
    );
  }

  Future<Response> postToShoppingCart(
      String token, PushToShoppingCart pushToShoppingCart) {
    return httpPost(
      '/api/cart/saveproduct',
      data: pushToShoppingCart.toJson(),
      options: ApiUtil.getTokenOptions(token),
    );
  }

  Future<Response> putToShoppingCart(
      String token, PushToShoppingCart pushToShoppingCart) {
    final int idCart = pushToShoppingCart.id;
    final int stok = pushToShoppingCart.stok;
    return httpPut(
      '/api/cart/update?id=$idCart&stok=$stok',
      data: pushToShoppingCart.toJson(),
      options: ApiUtil.getTokenOptions(token),
    );
  }

  Future<Response> getShoppingCart(String token) {
    return httpGet(
      '/api/cart/',
      options: ApiUtil.getTokenOptions(token),
    );
  }

  Future<Response> deleteShoppingCart(String token, int idCart) {
    return httpDelete(
      '/api/cart/$idCart',
      options: ApiUtil.getTokenOptions(token),
    );
  }

  Future<Response> getShippingAddress(String token) {
    return httpGet(
      '/api/shippingAddress/',
      options: ApiUtil.getTokenOptions(token),
    );
  }

  Future<Response> getShippingAddressPreview(String token) {
    return httpGet(
      '/api/shippingAddress/preview',
      options: ApiUtil.getTokenOptions(token),
    );
  }

  Future<Response> getShippingAddressById(String token, int id) {
    return httpGet(
      '/api/shippingAddress/$id',
      options: ApiUtil.getTokenOptions(token),
    );
  }

  Future<Response> postShippingAddress(
      String token, ShippingAddress shippingAddress) {
    return httpPost(
      '/api/shippingAddress/save',
      data: shippingAddress.newAddressToJson(),
      options: ApiUtil.getTokenOptions(token),
    );
  }

  Future<Response> putShippingAddress(
      String token, ShippingAddress shippingAddress) {
    // String parameters = '';
    final int id = shippingAddress.id!;
    return httpPut(
      '/api/shippingAddress/$id',
      data: shippingAddress.toJson(),
      options: ApiUtil.getTokenOptions(token),
    );
  }

  Future<Response> deleteShippingAddress(String token, int idShippingAddress) {
    return httpDelete(
      '/api/shippingAddress/$idShippingAddress',
      options: ApiUtil.getTokenOptions(token),
    );
  }

  Future<Response> getAllCategories(String token, {int? page = 1}) {
    return httpGet(
      '/api/category?page=$page',
      options: ApiUtil.getTokenOptions(token),
    );
  }

  Future<Response> getLatestProductByCategory(
      int page, String token, int category, String searchText) {
    if (searchText == '') {
      return httpGet(
        '/api/product/latest-products/$category?page=$page',
        options: ApiUtil.getTokenOptions(token),
      );
    } else {
      return httpGet(
        '/api/product/latest-products/$category/$searchText?page=$page',
        options: ApiUtil.getTokenOptions(token),
      );
    }
  }

  Future<Response> getFeaturedProductByCategory(
      int page, String token, int category, String searchText) {
    if (searchText == '') {
      return httpGet(
        '/api/product/featured-products/$category?page=$page',
        options: ApiUtil.getTokenOptions(token),
      );
    } else {
      return httpGet(
        '/api/product/featured-products/$category/$searchText?page=$page',
        options: ApiUtil.getTokenOptions(token),
      );
    }
  }

  Future<Response> getRelatedProductById(String token, int productId) {
    return httpGet(
      '/api/product/related-products/$productId',
      options: ApiUtil.getTokenOptions(token),
    );
  }
}
