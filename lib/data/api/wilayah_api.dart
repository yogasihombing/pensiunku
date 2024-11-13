import 'package:dio/dio.dart';
import 'package:pensiunku/data/api/base_api.dart';

class WilayahApi extends BaseApi {
  Future<Response> getProvinsi() {
    return httpGet('/kode-wilayah');
  }

  Future<Response> getWilayah(String kodeWilayah) {
    return httpGet('/kode-wilayah/$kodeWilayah');
  }

  Future<Response> getKodePos(String kecamatan, String kelurahan) {
    return httpGet('/kode-pos/$kecamatan/$kelurahan');
  }

  Future<Response> getNamaWilayah(String kodeWilayah) {
    return httpGet('/nama-wilayah/$kodeWilayah');
  }
}
