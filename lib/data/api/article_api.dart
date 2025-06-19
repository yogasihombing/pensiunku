import 'package:dio/dio.dart';
import 'package:pensiunku/data/api/base_api.dart';

class ArticleApi extends BaseApi {
  /// Ambil semua artikel untuk mobile — gunakan path yang benar
  Future<Response> getAll(String categoryName) {
    String query = '?kategori=$categoryName';
    return httpGet('/mobile-articles$query');
  }

  // kalau mau tetap sediakan kedua versi, beri nama jelas:
  Future<Response> getDesktopAll(String categoryName) {
    String query = '?kategori=$categoryName';
    return httpGet('/articles$query');
  }

  Future<Response> getAllCategories() {
    return httpGet('/article-categories');
  }

  Future<Response> getMobileAll(String categoryName) {
    String query = '?kategori=$categoryName';
    return httpGet('/mobile-articles$query');
  }

  Future<Response> getArticle(int articleId) {
    return httpGet('/marticle/$articleId');
  }
}
