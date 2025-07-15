// data/api/simulation_api.dart
import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:pensiunku/util/api_util.dart';
import 'package:pensiunku/config.dart'; // berisi apiHost
import 'package:pensiunku/model/simulation_form_model.dart';

class SimulationApi {
  final String _baseUrl;

  SimulationApi() : _baseUrl = apiHost;

  /// Menyiapkan payload pengajuan form
  Map<String, dynamic> preparePengajuanForm(PengajuanFormModel formModel) {
    return {
      'produk': 'pengajuan',
      'usia': formModel.usia,
      'domisili': formModel.domisili,
      'instansi': formModel.instansi,
      'nip': formModel.nip,
      'ktp': formModel.ktp,
      'npwp': formModel.npwp,
    };
  }

  /// Memanggil endpoint simulasi pengajuan
  Future<http.Response> simulatePengajuanForm(
    String token,
    PengajuanFormModel formModel,
  ) async {
    final uri = Uri.parse('$_baseUrl/simulation');
    final data = preparePengajuanForm(formModel);

    log('simulatePengajuanForm payload: $data');

    return await http.post(
      uri,
      headers: ApiUtil.getTokenHeaders(token),
      body: jsonEncode(data),
    );
  }
}
