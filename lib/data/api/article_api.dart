import 'package:http/http.dart' as http;
import 'package:pensiunku/data/api/base_api.dart'; // Menggunakan paket http

class ArticleApi extends BaseApi {
  /// Ambil semua artikel untuk mobile — gunakan path yang benar
  Future<http.Response> getAll(String categoryName) {
    String query = '?kategori=$categoryName';
    return httpGet('/mobile-articles$query');
  }

  // kalau mau tetap sediakan kedua versi, beri nama jelas:
  Future<http.Response> getDesktopAll(String categoryName) {
    String query = '?kategori=$categoryName';
    return httpGet('/articles$query');
  }

  Future<http.Response> getAllCategories() {
    return httpGet('/article-categories');
  }

  Future<http.Response> getMobileAll(String categoryName) {
    String query = '?kategori=$categoryName';
    return httpGet('/mobile-articles$query');
  }

  Future<http.Response> getArticle(int articleId) {
    return httpGet('/marticle/$articleId');
  }
}
