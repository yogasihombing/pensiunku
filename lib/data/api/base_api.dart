import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:pensiunku/config.dart' show apiHost;

class BaseApi {
  static String tag = 'BaseApi';
  static String? baseUrl = apiHost;
  static int connectTimeout = 10000;
  static int receiveTimeout = 5000;

  Future<Response> httpGet(
    String url, {
    Options? options,
  }) async {
    String fullUrl = '$baseUrl$url';
    assert(() {
      log('HTTP GET: $fullUrl', name: tag);
      return true;
    }());
    var finalOptions = options;

    var dio = Dio();
    dio.options.connectTimeout = connectTimeout;
    dio.options.receiveTimeout = receiveTimeout;
    return dio.get(fullUrl, options: finalOptions);
  }

  Future<Response> httpPost(
    String url, {
    dynamic data,
    Options? options,
  }) async {
    String fullUrl = '$baseUrl$url';
    assert(() {
      log('HTTP POST: $fullUrl', name: tag);
      log('Data POST: $data');
      return true;
    }());
    var finalOptions = options;

    var dio = Dio();
    dio.options.connectTimeout = connectTimeout;
    dio.options.receiveTimeout = receiveTimeout;
    return dio.post(fullUrl, data: data, options: finalOptions);
  }

  Future<Response> httpDelete(
    String url, {
    Options? options,
  }) async {
    String fullUrl = '$baseUrl$url';
    assert(() {
      log('HTTP DELETE: $fullUrl', name: tag);
      return true;
    }());
    var finalOptions = options;

    var dio = Dio();
    dio.options.connectTimeout = connectTimeout;
    dio.options.receiveTimeout = receiveTimeout;
    return dio.delete(fullUrl, options: finalOptions);
  }

  Future<Response> httpPut(
    String url, {
    dynamic data,
    Options? options,
  }) async {
    String fullUrl = '$baseUrl$url';
    assert(() {
      log('HTTP PUT: $fullUrl', name: tag);
      log('Data PUT: $data');
      return true;
    }());
    var finalOptions = options;

    var dio = Dio();
    dio.options.connectTimeout = connectTimeout;
    dio.options.receiveTimeout = receiveTimeout;
    return dio.put(fullUrl, data: data, options: finalOptions);
  }
}
