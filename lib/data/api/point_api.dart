import 'package:dio/dio.dart';
import 'package:pensiunku/data/api/base_api.dart';
import 'package:pensiunku/model/point_model.dart';
import 'package:pensiunku/util/api_util.dart';

class PointApi extends BaseApi {
  Future<Response> getPoint(String token) {
    return httpGet(
      '/point',
      options: ApiUtil.getTokenOptions(token),
    );
  }

  Future<Response> getPriceList(String token, PriceModel price) {
    return httpPost(
      '/point/price-list',
      data: price.toJson(),
      options: ApiUtil.getTokenOptions(token),
    );
  }

  Future<Response> pushTopUp(String token, TopUpModel topUpModel) {
    return httpPost(
      '/point/topup',
      data: topUpModel.toJson(),
      options: ApiUtil.getTokenOptions(token),
    );
  }

  Future<Response> getPointHistory(String token) {
    return httpGet(
      '/point/history',
      options: ApiUtil.getTokenOptions(token),
    );
  }
}
