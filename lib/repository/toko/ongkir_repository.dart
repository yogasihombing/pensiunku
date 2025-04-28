import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:pensiunku/data/api/toko/ongkir_api.dart';
import 'package:pensiunku/model/toko/ongkir_model.dart';
import 'package:pensiunku/repository/base_repository.dart';
import 'package:pensiunku/repository/result_model.dart';

class OngkirRepository extends BaseRepository {
  static String tag = 'Ongkir Repository';
  OngkirApi api = new OngkirApi();

  Future<ResultModel<List<ExpedisiModel>>> getCost(String origin,
      String destination, int weight, List<String> courier) async {
    assert(() {
      log('getCost', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat mendapatkan list ongkir. Tolong periksa Internet Anda.';
    try {
      Response responseTiki =
          await api.costHttpPost(origin, destination, weight, courier[0]);
      Response responseJne =
          await api.costHttpPost(origin, destination, weight, courier[1]);
      Response responsePos =
          await api.costHttpPost(origin, destination, weight, courier[2]);
      var responseTikiJson = responseTiki.data;
      var responseJneJson = responseJne.data;
      var responsePosJson = responsePos.data;
      log(responseTikiJson['rajaongkir'].toString());

      List<ExpedisiModel> expedisiModel = [];

      if (responseTikiJson['rajaongkir'] != null) {
        // transform format
        OngkirModel ongkirModel =
            OngkirModel.fromJson(responseTikiJson['rajaongkir']);
        String code = ongkirModel.resultOngkir[0].code;
        String name = ongkirModel.resultOngkir[0].name;
        List<CostsOngkir> costs = ongkirModel.resultOngkir[0].costs;
        costs.asMap().forEach(
          (key, value) {
            expedisiModel.add(ExpedisiModel(
                code: code,
                name: name,
                service: value.service,
                description: value.description,
                cost: value.costs[0].value,
                estimationDate: value.costs[0].etd));
          },
        );
      }

      if (responseJneJson['rajaongkir'] != null) {
        // transform format
        OngkirModel ongkirModel =
            OngkirModel.fromJson(responseJneJson['rajaongkir']);
        String code = ongkirModel.resultOngkir[0].code;
        String name = ongkirModel.resultOngkir[0].name;
        List<CostsOngkir> costs = ongkirModel.resultOngkir[0].costs;
        costs.asMap().forEach(
          (key, value) {
            expedisiModel.add(ExpedisiModel(
                code: code,
                name: name,
                service: value.service,
                description: value.description,
                cost: value.costs[0].value,
                estimationDate: value.costs[0].etd));
          },
        );
      }

      if (responsePosJson['rajaongkir'] != null) {
        // transform format
        OngkirModel ongkirModel =
            OngkirModel.fromJson(responsePosJson['rajaongkir']);
        String code = ongkirModel.resultOngkir[0].code;
        String name = ongkirModel.resultOngkir[0].name;
        List<CostsOngkir> costs = ongkirModel.resultOngkir[0].costs;
        costs.asMap().forEach(
          (key, value) {
            expedisiModel.add(ExpedisiModel(
                code: code,
                name: name,
                service: value.service,
                description: value.description,
                cost: value.costs[0].value,
                estimationDate: value.costs[0].etd));
          },
        );
      }
      if (expedisiModel.length > 0) {
        return ResultModel(
          isSuccess: true,
          data: expedisiModel,
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
