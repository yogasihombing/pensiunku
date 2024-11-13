import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:pensiunku/data/api/toko-order_api.dart';
import 'package:pensiunku/model/toko-order_model.dart';
import 'package:pensiunku/model/toko_model.dart';
import 'package:pensiunku/repository/base_repository.dart';
import 'package:pensiunku/repository/result_model.dart';

class TokoOrderRepository extends BaseRepository {
  static String tag = 'Toko Order Repository';
  TokoOrderApi api = TokoOrderApi();

  Future<ResultModel<List<OrderModel>>> getAllOrderHistory(String token) async {
    assert(() {
      log('getAllOrderHistory', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Gagal mengambil data riwayat pemesanan. Tolong periksa Internet Anda.';
    try {
      Response response = await api.getAllOrderHistory(token);

      if (response.statusCode == 200) {
        var responseJson = response.data;
        List<dynamic> itemsJson = responseJson['orders'];
        List<OrderModel> orderList = [];
        itemsJson.forEach((value) {
          orderList.add(
            OrderModel.fromJson(value),
          );
        });
        return ResultModel(
          isSuccess: true,
          data: orderList,
        );
      } else {
        return ResultModel(
          isSuccess: false,
          error: finalErrorMessage,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is DioError) {
        int? statusCode = e.response?.statusCode;
        if (statusCode != null) {
          if (statusCode >= 400 && statusCode < 500) {
            // Client error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          } else if (statusCode >= 500 && statusCode < 600) {
            // Server error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          }
        }
        if (e.message.contains('SocketException')) {
          return ResultModel(
            isSuccess: false,
            error: finalErrorMessage,
          );
        }
      }
      return ResultModel(
        isSuccess: false,
        error: finalErrorMessage,
      );
    }
  }

  Future<ResultModel<List<OrderModel>>> getOrderHistoryById(
      String token, int id) async {
    assert(() {
      log('getOrderHistoryById', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Gagal mengambil data riwayat pemesanan. Tolong periksa Internet Anda.';
    try {
      Response response = await api.getOrderHistoryById(token, id);

      if (response.statusCode == 200) {
        var responseJson = response.data;
        List<dynamic> itemsJson = responseJson['orderDetails'];
        List<OrderModel> orderList = [];
        itemsJson.forEach((value) {
          orderList.add(
            OrderModel.fromJson(value),
          );
        });
        return ResultModel(
          isSuccess: true,
          data: orderList,
        );
      } else {
        return ResultModel(
          isSuccess: false,
          error: finalErrorMessage,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is DioError) {
        int? statusCode = e.response?.statusCode;
        if (statusCode != null) {
          if (statusCode >= 400 && statusCode < 500) {
            // Client error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          } else if (statusCode >= 500 && statusCode < 600) {
            // Server error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          }
        }
        if (e.message.contains('SocketException')) {
          return ResultModel(
            isSuccess: false,
            error: finalErrorMessage,
          );
        }
      }
      return ResultModel(
        isSuccess: false,
        error: finalErrorMessage,
      );
    }
  }

  Future<ResultModel<bool>> updateStatusOrder(
      String token, int id, String status, DateTime? tanggalTerima, String? statusMessage) async {
    assert(() {
      log('updateStatusOrder:', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat mengupdate status order. Tolong periksa Internet Anda.';
    try {
      Response response = await api.putUpdateStatusOrder(token, id, status, tanggalTerima, statusMessage);
      var responseJson = response.data;
      log(responseJson['order']);

      if (responseJson['status'] == 1) {
        return ResultModel(
          isSuccess: true,
          data: true,
        );
      } else {
        return ResultModel(
          isSuccess: false,
          error: finalErrorMessage,
          data: false,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is DioError) {
        int? statusCode = e.response?.statusCode;
        if (statusCode != null) {
          if (statusCode >= 400 && statusCode < 500) {
            // Client error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          } else if (statusCode >= 500 && statusCode < 600) {
            // Server error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          }
        }
        if (e.message.contains('SocketException')) {
          return ResultModel(
            isSuccess: false,
            error: finalErrorMessage,
          );
        }
      }
      return ResultModel(
        isSuccess: false,
        error: finalErrorMessage,
      );
    }
  }

  Future<ResultModel<bool>> addProductsRatingandReview(
      String token, dynamic data, int orderId) async {
    assert(() {
      log('addProductsRatingandReview:', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat menambahkan review. Tolong periksa Internet Anda.';

    try {
      Response response =
          await api.addProductsRatingandReview(token, data, orderId);
      print(response.statusCode);
      var responseJson = response.data;
      log(responseJson.toString());

      if (responseJson['success'] == 1) {
        return ResultModel(
          isSuccess: true,
          data: true,
        );
      } else {
        return ResultModel(
          isSuccess: false,
          error: finalErrorMessage,
          data: false,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is DioError) {
        int? statusCode = e.response?.statusCode;
        if (statusCode != null) {
          if (statusCode >= 400 && statusCode < 500) {
            // Client error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          } else if (statusCode >= 500 && statusCode < 600) {
            // Server error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          }
        }
        if (e.message.contains('SocketException')) {
          return ResultModel(
            isSuccess: false,
            error: finalErrorMessage,
          );
        }
      }
      return ResultModel(
        isSuccess: false,
        error: finalErrorMessage,
      );
    }
  }

  Future<ResultModel<OrderCheckoutModel>> checkoutCart(
      String token, CheckoutModel data) async {
    assert(() {
      log('checkoutCart:', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat melakukan checkout. Tolong periksa Internet Anda.';
    try {
      Response response = await api.checkoutCart(token, data);
      var responseJson = response.data;
      log(responseJson.toString());

      if (responseJson['success'] == 1) {
        return ResultModel(
          isSuccess: true,
          data: OrderCheckoutModel.fromJson(responseJson['order']),
        );
      } else {
        return ResultModel(
          isSuccess: false,
          error: finalErrorMessage,
          data: null,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is DioError) {
        int? statusCode = e.response?.statusCode;
        if (statusCode != null) {
          if (statusCode >= 400 && statusCode < 500) {
            // Client error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          } else if (statusCode >= 500 && statusCode < 600) {
            // Server error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          }
        }
        if (e.message.contains('SocketException')) {
          return ResultModel(
            isSuccess: false,
            error: finalErrorMessage,
          );
        }
      }
      return ResultModel(
        isSuccess: false,
        error: finalErrorMessage,
      );
    }
  }

  Future<ResultModel<ShippingAddressModel>> getShippingAddressPreviewById(
      String token, int id) async {
    assert(() {
      log('getShippingAddressPreviewById', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Gagal mengambil data alamat pengiriman. Tolong periksa Internet Anda.';
    try {
      Response response = await api.getShippingAddressPreviewById(token, id);
      var responseJson = response.data;
      log('getShippingAddressPreviewById' + responseJson.toString());

      if (responseJson['status'] == 'success') {
        ShippingAddressModel shippingAddressModel =
            ShippingAddressModel.fromJson(responseJson['data']);

        return ResultModel(
          isSuccess: true,
          data: shippingAddressModel,
        );
      } else {
        return ResultModel(
          isSuccess: false,
          error: finalErrorMessage,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is DioError) {
        int? statusCode = e.response?.statusCode;
        if (statusCode != null) {
          if (statusCode >= 400 && statusCode < 500) {
            // Client error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          } else if (statusCode >= 500 && statusCode < 600) {
            // Server error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          }
        }
        if (e.message.contains('SocketException')) {
          return ResultModel(
            isSuccess: false,
            error: finalErrorMessage,
          );
        }
      }
      return ResultModel(
        isSuccess: false,
        error: finalErrorMessage,
      );
    }
  }
}
