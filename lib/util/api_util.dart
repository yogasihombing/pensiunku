import 'package:dio/dio.dart';

class ApiUtil {
  static Options getTokenOptions(String token) {
    var options = Options(
      headers: {
        'Authorization': token,
      },
    );
    return options;
  }
}
