import 'dart:developer';
import 'package:pensiunku/data/api/point_api.dart';
import 'package:pensiunku/model/point_model.dart';
import 'package:pensiunku/repository/base_repository.dart';
import 'package:pensiunku/model/result_model.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';


class PointRepository extends BaseRepository {
  static String tag = 'Point Repository';
  PointApi api = PointApi();

  Future<ResultModel<PointModel>> getPoint(String token) async {
    assert(() {
      log('Point Repository: $token', name: tag);
      return true;
    }());

    String finalErrorMessage =
        'Tidak dapat mendapatkan data point terbaru. Mohon periksa internet Anda.';

    try {
      // Menggunakan http.Response dari PointApi
      http.Response response = await api.getPoint(token);
      
      // Decoding response.body ke Map
      var responseJson = json.decode(response.body);

      // Periksa status code HTTP terlebih dahulu, lalu logika bisnis
      if (response.statusCode == 200 && responseJson['status'] == 'success') {
        log(responseJson['data'].toString(), name: tag);
        return ResultModel(
          isSuccess: true,
          data: PointModel.fromJson(responseJson["data"]),
        );
      } else {
        // Jika status code bukan 200 atau 'status' di body bukan 'success'
        log('API Response Error: ${responseJson['message'] ?? 'Unknown Error'}', name: tag);
        return ResultModel(
          isSuccess: false,
          error: responseJson['message'] ?? finalErrorMessage, // Gunakan pesan dari API jika ada
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);

      // Penanganan error untuk package http
      if (e is SocketException) {
        // Ini adalah error jaringan (tidak ada koneksi, DNS lookup gagal, dll.)
        return ResultModel(
          isSuccess: false,
          error: 'Tidak ada koneksi internet. Mohon periksa jaringan Anda.',
        );
      }
      // Tangani FormatException jika respons bukan JSON yang valid
      if (e is FormatException) {
        return ResultModel(
          isSuccess: false,
          error: 'Respons dari server tidak valid (bukan format JSON).',
        );
      }
      
      // Default error message untuk error yang tidak teridentifikasi
      return ResultModel(
        isSuccess: false,
        error: finalErrorMessage,
      );
    }
  }

  Future<ResultModel<List<PriceListModel>>> getPriceList(
      String token, PriceModel price) async {
    assert(() {
      log('PriceList Repository: $token', name: tag);
      return true;
    }());

    String finalErrorMessage =
        'Tidak dapat mendapatkan pricelist terbaru. Mohon periksa internet Anda.';

    try {
      // Menggunakan http.Response dari PointApi
      http.Response response = await api.getPriceList(token, price);
      
      // Decoding response.body ke Map
      var responseJson = json.decode(response.body);

      if (response.statusCode == 200 && responseJson['status'] == 'success') {
        List<dynamic> itemsJson = responseJson['data'];
        List<PriceListModel> priceLists = [];
        for (var value in itemsJson) {
          priceLists.add(
            PriceListModel.fromJson(value),
          );
        }
        return ResultModel(
          isSuccess: true,
          data: priceLists,
        );
      } else {
        log('API Response Error: ${responseJson['message'] ?? 'Unknown Error'}', name: tag);
        return ResultModel(
          isSuccess: false,
          error: responseJson['message'] ?? finalErrorMessage,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is SocketException) {
        return ResultModel(
          isSuccess: false,
          error: 'Tidak ada koneksi internet. Mohon periksa jaringan Anda.',
        );
      }
      if (e is FormatException) {
        return ResultModel(
          isSuccess: false,
          error: 'Respons dari server tidak valid (bukan format JSON).',
        );
      }
      return ResultModel(
        isSuccess: false,
        error: finalErrorMessage,
      );
    }
  }

  Future<ResultModel<MessageSuccessModel>> pushTopUp(
      String token, TopUpModel topUpModel) async {
    assert(() {
      log('Topup Repository: $token', name: tag);
      return true;
    }());

    String finalErrorMessage =
        'Tidak dapat melakukan topup. Mohon periksa internet Anda.';

    try {
      // Menggunakan http.Response dari PointApi
      http.Response response = await api.pushTopUp(token, topUpModel);
      
      // Decoding response.body ke Map
      var responseJson = json.decode(response.body);

      if (response.statusCode == 200 && responseJson['status'] == 'success') {
        dynamic itemsJson = responseJson['data'];
        MessageSuccessModel message = MessageSuccessModel.fromJson(itemsJson);

        return ResultModel(
          isSuccess: true,
          data: message,
        );
      } else {
        log('API Response Error: ${responseJson['message'] ?? 'Unknown Error'}', name: tag);
        return ResultModel(
          isSuccess: false,
          error: responseJson['message'] ?? finalErrorMessage,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is SocketException) {
        return ResultModel(
          isSuccess: false,
          error: 'Tidak ada koneksi internet. Mohon periksa jaringan Anda.',
        );
      }
      if (e is FormatException) {
        return ResultModel(
          isSuccess: false,
          error: 'Respons dari server tidak valid (bukan format JSON).',
        );
      }
      return ResultModel(
        isSuccess: false,
        error: finalErrorMessage,
      );
    }
  }

  Future<ResultModel<List<PointHistoryModel>>> getPointHistory(
      String token) async {
    assert(() {
      log('Point History Repository: $token', name: tag);
      return true;
    }());

    String finalErrorMessage =
        'Tidak dapat mendapatkan data riwayat point terbaru. Mohon periksa internet Anda.';

    try {
      // Menggunakan http.Response dari PointApi
      http.Response response = await api.getPointHistory(token);
      
      // Decoding response.body ke Map
      var responseJson = json.decode(response.body);

      if (response.statusCode == 200 && responseJson['status'] == 'success') {
        log(responseJson['data'].toString(), name: tag);
        List<dynamic> itemsJson = responseJson['data'];
        List<PointHistoryModel> pointHistory = [];
        for (var value in itemsJson) {
          pointHistory.add(
            PointHistoryModel.fromJson(value),
          );
        }
        return ResultModel(
          isSuccess: true,
          data: pointHistory,
        );
      } else {
        log('API Response Error: ${responseJson['message'] ?? 'Unknown Error'}', name: tag);
        return ResultModel(
          isSuccess: false,
          error: responseJson['message'] ?? finalErrorMessage,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is SocketException) {
        return ResultModel(
          isSuccess: false,
          error: 'Tidak ada koneksi internet. Mohon periksa jaringan Anda.',
        );
      }
      if (e is FormatException) {
        return ResultModel(
          isSuccess: false,
          error: 'Respons dari server tidak valid (bukan format JSON).',
        );
      }
      return ResultModel(
        isSuccess: false,
        error: finalErrorMessage,
      );
    }
  }
}