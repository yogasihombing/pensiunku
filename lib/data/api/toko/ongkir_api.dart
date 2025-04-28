import 'dart:developer';
import 'dart:io';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';

class OngkirApi {
  static String tag = 'OngkirApi';
  static String? baseUrl = 'https://api.rajaongkir.com/starter/';
  static int connectTimeout = 10000;
  static int receiveTimeout = 5000;
  static String token = '23bc37900459a8ccc0ba4396896a5795';

  Future<Response> costHttpPost(
      String origin, String destination, int weight, String courier) async {
    String costUrl = 'cost';
    String fullUrl = '$baseUrl$costUrl';
    Options options = Options(
      headers: {
        'key': token,
      },
    );
    assert(() {
      log('HTTP POST: $fullUrl', name: tag);
      log('origin POST: $origin');
      log('destination POST: $destination');
      log('weight POST: $weight');
      log('courier POST: $courier');
      return true;
    }());
    Map<String, dynamic> data = {
      'origin': origin,
      'destination': destination,
      'weight': weight,
      'courier': courier
    };

    var dio = Dio();
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
    dio.options.connectTimeout = connectTimeout;
    dio.options.receiveTimeout = receiveTimeout;
    return dio.post(fullUrl, data: data, options: options);
  }
}
