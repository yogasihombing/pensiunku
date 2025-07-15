import 'package:http/http.dart' as http; // Menggunakan paket http
import 'package:pensiunku/data/api/base_api.dart'; // Pastikan path ini benar ke BaseApi yang sudah diubah

class WilayahApi extends BaseApi {
  Future<http.Response> getProvinsi() { // Mengubah tipe kembalian menjadi http.Response
    return httpGet('/kode-wilayah');
  }

  Future<http.Response> getWilayah(String kodeWilayah) { // Mengubah tipe kembalian menjadi http.Response
    return httpGet('/kode-wilayah/$kodeWilayah');
  }

  Future<http.Response> getKodePos(String kecamatan, String kelurahan) { // Mengubah tipe kembalian menjadi http.Response
    return httpGet('/kode-pos/$kecamatan/$kelurahan');
  }

  Future<http.Response> getNamaWilayah(String kodeWilayah) { // Mengubah tipe kembalian menjadi http.Response
    return httpGet('/nama-wilayah/$kodeWilayah');
  }
}
