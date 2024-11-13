import 'package:dio/dio.dart';
import 'package:pensiunku/data/api/base_api.dart';
import 'package:pensiunku/util/api_util.dart';

class NotificationApi extends BaseApi {
  Future<Response> getAll(String token) {
    return httpGet(
      '/user-notification',
      options: ApiUtil.getTokenOptions(token),
    );
  }

  Future<Response> readNotification(String token, int id) {
    return httpPost(
      '/user-notification',
      data: {
        'id': id,
      },
      options: ApiUtil.getTokenOptions(token),
    );
  }
}
