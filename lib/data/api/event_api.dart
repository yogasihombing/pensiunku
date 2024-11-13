import 'package:dio/dio.dart';
import 'package:pensiunku/data/api/base_api.dart';
import 'package:pensiunku/util/api_util.dart';

class EventApi extends BaseApi {
  Future<Response> getEvents(
      String token, int filterIndex, String? searchText) {
    if (searchText == null) {
      return httpGet('/events/$filterIndex',
          options: ApiUtil.getTokenOptions(token));
    } else {
      return httpGet('/events/$filterIndex/$searchText',
          options: ApiUtil.getTokenOptions(token));
    }
  }

  Future<Response> getEvent(String token, int id) {
    return httpGet('/event/$id', options: ApiUtil.getTokenOptions(token));
  }
}
