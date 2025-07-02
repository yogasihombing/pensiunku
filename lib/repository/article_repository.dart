
import 'package:dio/dio.dart';
import 'package:pensiunku/data/api/article_api.dart';
import 'package:pensiunku/data/db/app_database.dart';
import 'package:pensiunku/model/article_model.dart';
import 'package:pensiunku/repository/base_repository.dart';
import 'package:pensiunku/model/result_model.dart';

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
    return getResultModel(
      tag: tag,
      getFromDb: () async {
        print(
            'ArticleRepository: Mencoba ambil data artikel dari DB untuk kategori: ${articleCategory.name}');
        List<ArticleModel>? articlesDb =
            await database.articleDao.getAll(articleCategory.name);
        print(
            'ArticleRepository: Data artikel dari DB: ${articlesDb.length ?? 0} item.');
        return articlesDb;
      },
      getFromApi: () async {
        print(
            'ArticleRepository: Mencoba ambil data artikel dari API untuk kategori: ${articleCategory.name}');
        try {
          Response response = await api.getAll(articleCategory.name);
          print(
              'ArticleRepository: API getAll respons mentah: ${response.data}');
          return response;
        } on DioException catch (e) {
          print(
              'ArticleRepository: Error Dio saat ambil dari API (getAll): ${e.message}');
          rethrow;
        } catch (e) {
          print(
              'ArticleRepository: Error tak terduga saat ambil dari API (getAll): $e');
          rethrow;
        }
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
              // Jika Anda ingin artikel yang gagal parsing tidak menyebabkan seluruh list gagal
              // Anda bisa continue di sini, tapi untuk debugging lebih baik rethrow sementara
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
        // Perbaikan: removeFromDb mungkin tidak menerima 'articles', melainkan hanya nama kategori
        // Asumsi database.articleDao.removeAll() hanya perlu nama kategori
        await database.articleDao.removeAll(articleCategory.name);
      },
      insertToDb: (articles) async {
        print(
            'ArticleRepository: Memasukkan data artikel baru ke DB untuk kategori: ${articleCategory.name}. Jumlah: ${articles.length}');
        // Asumsi database.articleDao.insert() menerima List<ArticleModel>
        await database.articleDao.insert(articles);
      },
      errorMessage:
          'Gagal mengambil data artikel terbaru. Tolong periksa Internet Anda.',
    );
  }

  // getAllCategories - Dipanggil dari DashboardScreen untuk chip kategori
  Future<ResultModel<List<ArticleCategoryModel>>> getAllCategories() {
    print('ArticleRepository: getAllCategories dipanggil.');
    return getResultModel(
      tag: tag,
      getFromDb: () async {
        print('ArticleRepository: Mencoba ambil kategori dari DB.');
        List<ArticleCategoryModel>? itemsDb =
            await database.articleDao.getAllCategories();
        print(
            'ArticleRepository: Kategori dari DB: ${itemsDb.length} item.');
        return itemsDb;
      },
      getFromApi: () async {
        print('ArticleRepository: Mencoba ambil kategori dari API.');
        try {
          Response response = await api.getAllCategories();
          print(
              'ArticleRepository: API getAllCategories respons mentah: ${response.data}');
          return response;
        } on DioException catch (e) {
          print(
              'ArticleRepository: Error Dio saat ambil dari API (getAllCategories): ${e.message}');
          rethrow;
        } catch (e) {
          print(
              'ArticleRepository: Error tak terduga saat ambil dari API (getAllCategories): $e');
          rethrow;
        }
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
        // Parameter diubah menjadi _ karena tidak digunakan
        print('ArticleRepository: Menghapus kategori lama dari DB.');
        await database.articleDao.removeAllCategories();
      },
      insertToDb: (items) async {
        print(
            'ArticleRepository: Memasukkan kategori baru ke DB. Jumlah: ${items.length}');
        await database.articleDao.insertCategories(items);
      },
      errorMessage:
          'Gagal mengambil data artikel terbaru. Tolong periksa Internet Anda.',
    );
  }

  // getMobileAll - Fungsi ini tampaknya tidak dipanggil oleh ArticleList
  Future<ResultModel<List<MobileArticleModel>>> getMobileAll(
    ArticleCategoryModel articleCategory,
  ) async {
    print(
        'ArticleRepository: getMobileAll dipanggil untuk kategori: ${articleCategory.name}');
    String finalErrorMessage =
        'Tidak dapat mendapatkan data artikel. Tolong periksa Internet Anda.';

    try {
      print(
          'ArticleRepository: Memanggil api.getMobileAll untuk kategori: ${articleCategory.name}');
      Response response = await api.getMobileAll(articleCategory.name);
      var responseJson = response.data;
      print(
          'ArticleRepository: Respons mentah dari api.getMobileAll: $responseJson');

      if (responseJson['status'] == 'success') {
        print(
            'ArticleRepository: Status sukses dari api.getMobileAll. Mengurai data...');
        List<dynamic> itemsJson = responseJson['data'];
        List<MobileArticleModel> articleList = [];
        for (var value in itemsJson) {
          // Menggunakan for-in loop untuk try-catch
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
        return ResultModel(
          isSuccess: true,
          data: articleList,
        );
      } else {
        print(
            'ArticleRepository: Status API bukan sukses untuk getMobileAll. Pesan: ${responseJson['msg'] ?? 'Tidak ada pesan'}. Respons: $responseJson');
        return ResultModel(
          isSuccess: false,
          error: responseJson['msg'] ?? finalErrorMessage,
        );
      }
    } on DioException catch (e) {
      // Tangkap DioError
      print(
          'ArticleRepository: DioError saat getMobileAll: ${e.message}. Tipe: ${e.type}');
      if (e.response != null) {
        print('ArticleRepository: Respons Error Dio: ${e.response?.data}');
        print(
            'ArticleRepository: Status Kode Error Dio: ${e.response?.statusCode}');
      }
      int? statusCode = e.response?.statusCode;
      if (statusCode != null) {
        if (statusCode >= 400 && statusCode < 500) {
          print('ArticleRepository: Error Klien ($statusCode).');
          return ResultModel(
            isSuccess: false,
            error: finalErrorMessage,
          );
        } else if (statusCode >= 500 && statusCode < 600) {
          print('ArticleRepository: Error Server ($statusCode).');
          return ResultModel(
            isSuccess: false,
            error: finalErrorMessage,
          );
        }
      }
      if (e.message?.contains('SocketException') ?? false) {
        print('ArticleRepository: SocketException (masalah koneksi internet).');
        return ResultModel(
          isSuccess: false,
          error: finalErrorMessage,
        );
      }
      print('ArticleRepository: DioError lainnya: $e');
      return ResultModel(
        isSuccess: false,
        error: finalErrorMessage,
      );
    } catch (e) {
      print('ArticleRepository: Error tak terduga saat getMobileAll: $e');
      return ResultModel(
        isSuccess: false,
        error: finalErrorMessage,
      );
    }
  }

  // getMobileArticle - Mengambil detail artikel tunggal
  Future<ResultModel<MobileArticleDetailModel>> getMobileArticle(
    int articleId,
  ) async {
    print('ArticleRepository: getMobileArticle dipanggil untuk ID: $articleId');
    String finalErrorMessage =
        'Tidak dapat mendapatkan detail artikel. Tolong periksa Internet Anda.';

    try {
      Response response = await api.getArticle(articleId);
      var responseJson = response.data;
      print(
          'ArticleRepository: Respons mentah dari api.getArticle: $responseJson');

      if (responseJson['status'] == 'success') {
        print(
            'ArticleRepository: Status sukses dari api.getArticle. Mengurai data...');
        MobileArticleDetailModel parsedData;
        try {
          parsedData = MobileArticleDetailModel.fromJson(responseJson['data']);
          print(
              'ArticleRepository: Berhasil parsing MobileArticleDetailModel.');
        } catch (e) {
          print(
              '!!! ArticleRepository: ERROR parsing MobileArticleDetailModel dari data: ${responseJson['data']}. Error: $e. Type of error: ${e.runtimeType} !!!');
          rethrow;
        }

        return ResultModel(
          isSuccess: true,
          data: parsedData,
        );
      } else {
        print(
            'ArticleRepository: Status API bukan sukses untuk getMobileArticle. Pesan: ${responseJson['msg'] ?? 'Tidak ada pesan'}. Respons: $responseJson');
        return ResultModel(
          isSuccess: false,
          error: responseJson['msg'] ?? finalErrorMessage,
        );
      }
    } on DioException catch (e) {
      print(
          'ArticleRepository: DioError saat getMobileArticle: ${e.message}. Tipe: ${e.type}');
      if (e.response != null) {
        print('ArticleRepository: Respons Error Dio: ${e.response?.data}');
        print(
            'ArticleRepository: Status Kode Error Dio: ${e.response?.statusCode}');
      }
      int? statusCode = e.response?.statusCode;
      if (statusCode != null) {
        if (statusCode >= 400 && statusCode < 500) {
          print('ArticleRepository: Error Klien ($statusCode).');
          return ResultModel(
            isSuccess: false,
            error: finalErrorMessage,
          );
        } else if (statusCode >= 500 && statusCode < 600) {
          print('ArticleRepository: Error Server ($statusCode).');
          return ResultModel(
            isSuccess: false,
            error: finalErrorMessage,
          );
        }
      }
      if (e.message?.contains('SocketException') ?? false) {
        print('ArticleRepository: SocketException (masalah koneksi internet).');
        return ResultModel(
          isSuccess: false,
          error: finalErrorMessage,
        );
      }
      print('ArticleRepository: DioError lainnya: $e');
      return ResultModel(
        isSuccess: false,
        error: finalErrorMessage,
      );
    } catch (e) {
      print('ArticleRepository: Error tak terduga saat getMobileArticle: $e');
      return ResultModel(
        isSuccess: false,
        error: finalErrorMessage,
      );
    }
  }
}
