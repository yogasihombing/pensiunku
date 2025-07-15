import 'dart:developer';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:pensiunku/data/api/toko/toko-order_api.dart';
import 'package:pensiunku/model/toko/toko-order_model.dart';
import 'package:pensiunku/model/toko/toko_model.dart';
import 'package:pensiunku/repository/base_repository.dart';
import 'package:pensiunku/model/result_model.dart';

class TokoOrderRepository extends BaseRepository {
  static String tag = 'Toko Order Repository';
  TokoOrderApi api = TokoOrderApi();

  Future<ResultModel<List<OrderModel>>> getAllOrderHistory(String token) async {
    assert(() {
      log('getAllOrderHistory Repository dipanggil.', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Gagal mengambil data riwayat pemesanan. Tolong periksa Internet Anda.';

    // --- PERUBAHAN: Menggunakan super.getResultModel sepenuhnya ---
    return super.getResultModel<List<OrderModel>>(
      tag: tag,
      getFromApi: () async => await api.getAllOrderHistory(token),
      getDataFromApiResponse: (responseJson) {
        // Asumsi API ini mengembalikan { "status": "success", "orders": [...] }
        if (responseJson['status'] == 'success' && responseJson['orders'] != null) {
          log('Respons API getAllOrderHistory: ${responseJson['orders'].toString()}', name: tag);
          List<dynamic> itemsJson = responseJson['orders'];
          List<OrderModel> orderList = itemsJson.map((value) => OrderModel.fromJson(value)).toList();
          return orderList;
        } else {
          // Jika status bukan 'success' atau data 'orders' tidak ada
          throw Exception(responseJson['msg'] ?? 'Orders data is null or missing in API response.');
        }
      },
      errorMessage: finalErrorMessage,
    );
    // --- AKHIR PERUBAHAN ---
  }

  Future<ResultModel<List<OrderModel>>> getOrderHistoryById(
      String token, int id) async {
    assert(() {
      log('getOrderHistoryById Repository dipanggil.', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Gagal mengambil data riwayat pemesanan. Tolong periksa Internet Anda.';

    // --- PERUBAHAN: Menggunakan super.getResultModel sepenuhnya ---
    return super.getResultModel<List<OrderModel>>(
      tag: tag,
      getFromApi: () async => await api.getOrderHistoryById(token, id),
      getDataFromApiResponse: (responseJson) {
        // Asumsi API ini mengembalikan { "status": "success", "orderDetails": [...] }
        if (responseJson['status'] == 'success' && responseJson['orderDetails'] != null) {
          log('Respons API getOrderHistoryById: ${responseJson['orderDetails'].toString()}', name: tag);
          List<dynamic> itemsJson = responseJson['orderDetails'];
          List<OrderModel> orderList = itemsJson.map((value) => OrderModel.fromJson(value)).toList();
          return orderList;
        } else {
          throw Exception(responseJson['msg'] ?? 'Order details data is null or missing in API response.');
        }
      },
      errorMessage: finalErrorMessage,
    );
    // --- AKHIR PERUBAHAN ---
  }

  Future<ResultModel<bool>> updateStatusOrder(String token, int id,
      String status, DateTime? tanggalTerima, String? statusMessage) async {
    assert(() {
      log('updateStatusOrder Repository dipanggil.', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat mengupdate status order. Tolong periksa Internet Anda.';

    // --- PERUBAHAN: Menggunakan super.getResultModel sepenuhnya ---
    return super.getResultModel<bool>(
      tag: tag,
      getFromApi: () async => await api.putUpdateStatusOrder(token, id, status, tanggalTerima, statusMessage),
      getDataFromApiResponse: (responseJson) {
        log('Respons API updateStatusOrder: ${responseJson.toString()}', name: tag);
        // Asumsi API ini mengembalikan { "status": 1, "message": "..." }
        if (responseJson['status'] == 1) { // Asumsi 'status': 1 berarti sukses
          return true;
        } else {
          throw Exception(responseJson['message'] ?? 'Failed to update order status.');
        }
      },
      errorMessage: finalErrorMessage,
    );
    // --- AKHIR PERUBAHAN ---
  }

  Future<ResultModel<bool>> addProductsRatingandReview(
      String token, dynamic data, int orderId) async {
    assert(() {
      log('addProductsRatingandReview Repository dipanggil.', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat menambahkan review. Tolong periksa Internet Anda.';

    // --- PERUBAHAN: Menggunakan super.getResultModel sepenuhnya ---
    return super.getResultModel<bool>(
      tag: tag,
      getFromApi: () async => await api.addProductsRatingAndReview(token, data, orderId),
      getDataFromApiResponse: (responseJson) {
        log('Respons API addProductsRatingandReview: ${responseJson.toString()}', name: tag);
        // Asumsi API ini mengembalikan { "success": 1, "message": "..." }
        if (responseJson['success'] == 1) {
          return true;
        } else {
          throw Exception(responseJson['message'] ?? 'Failed to add review.');
        }
      },
      errorMessage: finalErrorMessage,
    );
    // --- AKHIR PERUBAHAN ---
  }

  Future<ResultModel<OrderCheckoutModel>> checkoutCart(
      String token, CheckoutModel data) async {
    assert(() {
      log('checkoutCart Repository dipanggil.', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat melakukan checkout. Tolong periksa Internet Anda.';

    // --- PERUBAHAN: Menggunakan super.getResultModel sepenuhnya ---
    return super.getResultModel<OrderCheckoutModel>(
      tag: tag,
      getFromApi: () async => await api.checkoutCart(token, data),
      getDataFromApiResponse: (responseJson) {
        log('Respons API checkoutCart: ${responseJson.toString()}', name: tag);
        // Asumsi API ini mengembalikan { "success": 1, "order": {...} }
        if (responseJson['success'] == 1 && responseJson['order'] != null) {
          return OrderCheckoutModel.fromJson(responseJson['order']);
        } else {
          throw Exception(responseJson['message'] ?? 'Failed to checkout cart.');
        }
      },
      errorMessage: finalErrorMessage,
    );
    // --- AKHIR PERUBAHAN ---
  }

  Future<ResultModel<ShippingAddressModel>> getShippingAddressPreviewById(
      String token, int id) async {
    assert(() {
      log('getShippingAddressPreviewById Repository dipanggil.', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Gagal mengambil data alamat pengiriman. Tolong periksa Internet Anda.';

    // --- PERUBAHAN: Menggunakan super.getResultModel sepenuhnya ---
    return super.getResultModel<ShippingAddressModel>(
      tag: tag,
      getFromApi: () async => await api.getShippingAddressPreviewById(token, id),
      getDataFromApiResponse: (responseJson) {
        log('Respons API getShippingAddressPreviewById: ${responseJson.toString()}', name: tag);
        // Asumsi API ini mengembalikan { "status": "success", "data": {...} }
        if (responseJson['status'] == 'success' && responseJson['data'] != null) {
          return ShippingAddressModel.fromJson(responseJson['data']);
        } else {
          throw Exception(responseJson['message'] ?? 'Failed to get shipping address preview.');
        }
      },
      errorMessage: finalErrorMessage,
    );
    // --- AKHIR PERUBAHAN ---
  }
}
