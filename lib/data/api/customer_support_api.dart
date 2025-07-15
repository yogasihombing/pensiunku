import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pensiunku/util/api_util.dart';
import 'package:pensiunku/config.dart'; // untuk apiHost

class CustomerSupportApi {
  final String _baseUrl;

  CustomerSupportApi() : _baseUrl = apiHost;

  /// Mengirim pertanyaan ke endpoint contact
  Future<http.Response> sendQuestion(String token, dynamic data) async {
    final uri = Uri.parse('$_baseUrl/contact');
    return await http.post(
      uri,
      headers: ApiUtil.getTokenHeaders(token),
      body: jsonEncode(data),
    );
  }
}
