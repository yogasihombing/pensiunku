
import 'package:http/http.dart' as http;
import 'package:pensiunku/data/api/base_api.dart';
import 'package:pensiunku/util/api_util.dart';

// --- PERUBAHAN: HalopensiunApi sekarang extends BaseApi ---
class HalopensiunApi extends BaseApi {
  // final String _baseUrl; // Tidak diperlukan lagi

  // HalopensiunApi() : _baseUrl = apiHost; // Tidak diperlukan lagi

  /// Mendapatkan semua data halopensiun (butuh token)
  // --- PERUBAHAN: Menggunakan httpGet dari BaseApi ---
  Future<http.Response> getAll(String token) async {
    return httpGet(
      '/halopensiuns',
      headers: ApiUtil.getTokenHeaders(token),
    );
  }
  // --- AKHIR PERUBAHAN ---

  /// Mendapatkan data berdasarkan kategori (tanpa token)
  // --- PERUBAHAN: Menggunakan httpGet dari BaseApi ---
  Future<http.Response> getAllByCategory(int categoryId) async {
    return httpGet('/halopensiun/cid/$categoryId'); // Path relatif
  }
  // --- AKHIR PERUBAHAN ---

  /// Mendapatkan data berdasarkan keyword (tanpa token)
  // --- PERUBAHAN: Menggunakan httpGet dari BaseApi ---
  Future<http.Response> getAllByKeyword(String keyword) async {
    return httpGet('/halopensiun/search/$keyword'); // Path relatif
  }
  // --- AKHIR PERUBAHAN ---

  /// Mendapatkan data berdasarkan kategori dan keyword (opsional token)
  // --- PERUBAHAN: Menggunakan httpGet dari BaseApi dengan queryParameters ---
  Future<http.Response> getAllByCategoryAndKeyword(
    int categoryId,
    String? searchText,
    String token,
  ) async {
    final path = searchText == null
        ? '/halopensiun/$categoryId'
        : '/halopensiun/$categoryId/$searchText';
    // BaseApi akan menangani penambahan baseUrl dan queryParameters
    return httpGet(
      path,
      headers: ApiUtil.getTokenHeaders(token),
      // Jika searchText perlu dikirim sebagai query parameter terpisah, bukan di path:
      // queryParameters: searchText != null ? {'search': searchText} : null,
    );
  }
  // --- AKHIR PERUBAHAN ---
}
