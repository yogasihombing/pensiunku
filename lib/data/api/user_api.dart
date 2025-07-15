// data/api/user_api.dart
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pensiunku/util/api_util.dart';
import 'package:pensiunku/config.dart'; // berisi baseUrl, isProd, dsb.

class UserApi {
  final String _baseUrl;

  UserApi() : _baseUrl = apiHost; // misal apiHost = 'https://api.pensiunku.id'

  Future<http.Response> getOne(String token) async {
    final uri = Uri.parse('$_baseUrl/user');
    return await http.get(
      uri,
      headers: ApiUtil.getTokenHeaders(token),
    );
  }

  Future<http.Response> updateOne(String token, dynamic data) async {
    final uri = Uri.parse('$_baseUrl/user/update');
    return await http.post(
      uri,
      headers: ApiUtil.getTokenHeaders(token),
      body: jsonEncode(data),
    );
  }

  Future<http.Response> sendOtp(String phone) async {
    final uri = Uri.parse('$_baseUrl/user/verify-phone');
    final payload = isProd
        ? {'phone': phone}
        : {'phone': phone, 'test': 'testing'};
    return await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
  }

  Future<http.Response> verifyOtp(String phone, String otp) async {
    final uri = Uri.parse('$_baseUrl/user/verify-otp');
    final payload = {'phone': phone, 'otp': otp};
    return await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
  }

  Future<http.Response> saveFcmToken(String token, String fcmToken) async {
    final uri = Uri.parse('$_baseUrl/user-notification/token');
    final payload = {'token': fcmToken};
    return await http.post(
      uri,
      headers: ApiUtil.getTokenHeaders(token),
      body: jsonEncode(payload),
    );
  }

  Future<http.Response> checkUserExists(String phone) async {
    // URL absolut di domain berbeda
    final uri = Uri.parse('https://api.pensiunku.id/new.php/cekNomorTelepon');
    final payload = {'telepon': phone};
    return await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
  }
}
