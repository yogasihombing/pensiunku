import 'package:http/http.dart' as http; // Menggunakan paket http
import 'package:pensiunku/data/api/article_api.dart'; // Pastikan path ini benar

import 'package:pensiunku/data/db/app_database.dart';
import 'package:pensiunku/model/article_model.dart'; // Pastikan semua model di sini
import 'package:pensiunku/model/result_model.dart';
import 'package:pensiunku/repository/base_repository.dart';

class ArticleRepository extends BaseRepository {
  static String tag = 'ArticleRepository';
  ArticleApi api = ArticleApi();
  AppDatabase database = AppDatabase();

  // getAll - Digunakan oleh ArticleList, memanggil getResultModel
  Future<ResultModel<List<ArticleModel>>> getAll(
    ArticleCategoryModel articleCategory,
  ) {
    print(
        'ArticleRepository: getAll dipanggil untuk kategori: ${articleCategory.name}');
    return super.getResultModel<List<ArticleModel>>(
      // --- PERUBAHAN: Menggunakan super.getResultModel ---
      tag: tag,
      getFromDb: () async {
        print(
            'ArticleRepository: Mencoba ambil data artikel dari DB untuk kategori: ${articleCategory.name}');
        List<ArticleModel>? articlesDb =
            await database.articleDao.getAll(articleCategory.name);
        print(
            'ArticleRepository: Data artikel dari DB: ${articlesDb?.length ?? 0} item.'); // --- PERUBAHAN: Null-safety untuk length ---
        return articlesDb;
      },
      getFromApi: () async {
        print(
            'ArticleRepository: Mencoba ambil data artikel dari API untuk kategori: ${articleCategory.name}');
        // --- PERUBAHAN: Langsung panggil api.getAll dan kembalikan response ---
        return await api.getAll(articleCategory.name);
        // --- AKHIR PERUBAHAN ---
      },
      getDataFromApiResponse: (responseJson) {
        print(
            'ArticleRepository: Mengolah respons API untuk getAll: $responseJson');
        if (responseJson['status'] == 'success' &&
            responseJson['data'] != null) {
          List<dynamic> articlesJson = responseJson['data'];
          List<ArticleModel> articles = [];

          // --- PENTING: Tambahkan try-catch di sini untuk debugging error parsing ---
          for (var value in articlesJson) {
            try {
              articles.add(
                ArticleModel.fromJson(value),
              );
              print(
                  'ArticleRepository: Berhasil parsing artikel: ${value['title']}');
            } catch (e) {
              print(
                  '!!! ArticleRepository: ERROR parsing ArticleModel dari data: $value. Error: $e. Type of error: ${e.runtimeType} !!!');
              rethrow; // Melemparkan kembali error untuk ditangkap di level atas
            }
          }
          // --- Akhir try-catch ---

          print(
              'ArticleRepository: Data artikel berhasil diparsing: ${articles.length} item.');
          return articles;
        } else {
          print(
              'ArticleRepository: Status API bukan sukses atau data kosong. Respons: $responseJson');
          throw Exception(responseJson['msg'] ?? 'Respons API tidak valid.');
        }
      },
      removeFromDb: (articles) async {
        print(
            'ArticleRepository: Menghapus data artikel lama dari DB untuk kategori: ${articleCategory.name}');
        await database.articleDao.removeAll(articleCategory.name);
      },
      insertToDb: (articles) async {
        print(
            'ArticleRepository: Memasukkan data artikel baru ke DB untuk kategori: ${articleCategory.name}. Jumlah: ${articles?.length ?? 0}'); // Null-safety
        if (articles != null) {
          await database.articleDao.insert(articles);
        }
      },
      errorMessage:
          'Gagal mengambil data artikel terbaru. Tolong periksa Internet Anda.',
    );
  }

  // getAllCategories - Dipanggil dari DashboardScreen untuk chip kategori
  Future<ResultModel<List<ArticleCategoryModel>>> getAllCategories() {
    print('ArticleRepository: getAllCategories dipanggil.');
    return super.getResultModel<List<ArticleCategoryModel>>(
      // --- PERUBAHAN: Menggunakan super.getResultModel ---
      tag: tag,
      getFromDb: () async {
        print('ArticleRepository: Mencoba ambil kategori dari DB.');
        List<ArticleCategoryModel>? itemsDb =
            await database.articleDao.getAllCategories();
        print(
            'ArticleRepository: Kategori dari DB: ${itemsDb?.length ?? 0} item.'); // --- PERUBAHAN: Null-safety untuk length ---
        return itemsDb;
      },
      getFromApi: () async {
        print('ArticleRepository: Mencoba ambil kategori dari API.');
        // --- PERUBAHAN: Langsung panggil api.getAllCategories dan kembalikan response ---
        return await api.getAllCategories();
        // --- AKHIR PERUBAHAN ---
      },
      getDataFromApiResponse: (responseJson) {
        print(
            'ArticleRepository: Mengolah respons API untuk getAllCategories: $responseJson');
        if (responseJson['status'] == 'success' &&
            responseJson['data'] != null) {
          List<dynamic> itemsJson = responseJson['data'];
          List<ArticleCategoryModel> items = [];
          itemsJson.forEach((value) {
            items.add(
              ArticleCategoryModel.fromJson({'name': value}),
            );
          });
          print(
              'ArticleRepository: Kategori berhasil diparsing: ${items.length} item.');
          return items;
        } else {
          print(
              'ArticleRepository: Status API kategori bukan sukses atau data kosong. Respons: $responseJson');
          throw Exception(
              responseJson['msg'] ?? 'Respons API kategori tidak valid.');
        }
      },
      removeFromDb: (_) async {
        print('ArticleRepository: Menghapus kategori lama dari DB.');
        await database.articleDao.removeAllCategories();
      },
      insertToDb: (items) async {
        print(
            'ArticleRepository: Memasukkan kategori baru ke DB. Jumlah: ${items?.length ?? 0}'); // Null-safety
        if (items != null) {
          await database.articleDao.insertCategories(items);
        }
      },
      errorMessage:
          'Gagal mengambil data artikel terbaru. Tolong periksa Internet Anda.',
    );
  }

  // getMobileAll - Fungsi ini tampaknya tidak dipanggil oleh ArticleList
  // --- PERUBAHAN: Menggunakan super.getResultModel ---
  Future<ResultModel<List<MobileArticleModel>>> getMobileAll(
    ArticleCategoryModel articleCategory,
  ) {
    print(
        'ArticleRepository: getMobileAll dipanggil untuk kategori: ${articleCategory.name}');
    String finalErrorMessage =
        'Tidak dapat mendapatkan data artikel. Tolong periksa Internet Anda.';

    return super.getResultModel<List<MobileArticleModel>>(
      tag: tag,
      getFromApi: () async {
        print(
            'ArticleRepository: Memanggil api.getMobileAll untuk kategori: ${articleCategory.name}');
        return await api.getMobileAll(articleCategory.name);
      },
      getDataFromApiResponse: (responseJson) {
        print(
            'ArticleRepository: Respons mentah dari api.getMobileAll: $responseJson');
        if (responseJson['status'] == 'success' &&
            responseJson['data'] != null) {
          print(
              'ArticleRepository: Status sukses dari api.getMobileAll. Mengurai data...');
          List<dynamic> itemsJson = responseJson['data'];
          List<MobileArticleModel> articleList = [];
          for (var value in itemsJson) {
            try {
              articleList.add(
                MobileArticleModel.fromJson(value),
              );
              print(
                  'ArticleRepository: Berhasil parsing mobile article: ${value['title']}');
            } catch (e) {
              print(
                  '!!! ArticleRepository: ERROR parsing MobileArticleModel dari data: $value. Error: $e. Type of error: ${e.runtimeType} !!!');
              rethrow;
            }
          }
          print(
              'ArticleRepository: MobileArticleModel berhasil diparsing: ${articleList.length} item.');
          return articleList;
        } else {
          print(
              'ArticleRepository: Status API bukan sukses untuk getMobileAll. Pesan: ${responseJson['msg'] ?? 'Tidak ada pesan'}. Respons: $responseJson');
          throw Exception(responseJson['msg'] ?? 'Respons API tidak valid.');
        }
      },
      errorMessage: finalErrorMessage,
    );
  }
  // --- AKHIR PERUBAHAN ---

  // getMobileArticle - Mengambil detail artikel tunggal
  // --- PERUBAHAN: Menggunakan super.getResultModel ---
  Future<ResultModel<MobileArticleDetailModel>> getMobileArticle(
    int articleId,
  ) {
    print('ArticleRepository: getMobileArticle dipanggil untuk ID: $articleId');
    String finalErrorMessage =
        'Tidak dapat mendapatkan detail artikel. Tolong periksa Internet Anda.';

    return super.getResultModel<MobileArticleDetailModel>(
      tag: tag,
      getFromApi: () async {
        print(
            'ArticleRepository: Memanggil api.getArticle untuk ID: $articleId');
        return await api.getArticle(articleId);
      },
      getDataFromApiResponse: (responseJson) {
        print(
            'ArticleRepository: Respons mentah dari api.getArticle: $responseJson');
        if (responseJson['status'] == 'success' &&
            responseJson['data'] != null) {
          print(
              'ArticleRepository: Status sukses dari api.getArticle. Mengurai data...');
          MobileArticleDetailModel parsedData;
          try {
            parsedData =
                MobileArticleDetailModel.fromJson(responseJson['data']);
            print(
                'ArticleRepository: Berhasil parsing MobileArticleDetailModel.');
          } catch (e) {
            print(
                '!!! ArticleRepository: ERROR parsing MobileArticleDetailModel dari data: ${responseJson['data']}. Error: $e. Type of error: ${e.runtimeType} !!!');
            rethrow;
          }

          return parsedData;
        } else {
          print(
              'ArticleRepository: Status API bukan sukses untuk getMobileArticle. Pesan: ${responseJson['msg'] ?? 'Tidak ada pesan'}. Respons: $responseJson');
          throw Exception(responseJson['msg'] ?? 'Respons API tidak valid.');
        }
      },
      errorMessage: finalErrorMessage,
    );
  }
  // --- AKHIR PERUBAHAN ---
}
