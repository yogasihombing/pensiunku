import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:pensiunku/data/api/article_api.dart';
import 'package:pensiunku/data/db/app_database.dart';
import 'package:pensiunku/model/article_model.dart';
import 'package:pensiunku/repository/base_repository.dart';
import 'package:pensiunku/repository/result_model.dart';

class ArticleRepository extends BaseRepository {
  static String tag = 'ArticleRepository';
  ArticleApi api = ArticleApi();
  AppDatabase database = AppDatabase();

  Future<ResultModel<List<ArticleModel>>> getAll(
    ArticleCategoryModel articleCategory,
  ) {
    assert(() {
      log('getAll', name: tag);
      return true;
    }());
    return getResultModel(
      tag: tag,
      getFromDb: () async {
        List<ArticleModel>? articlesDb =
            await database.articleDao.getAll(articleCategory.name);
        return articlesDb;
      },
      getFromApi: () => api.getAll(articleCategory.name),
      getDataFromApiResponse: (responseJson) {
        List<dynamic> articlesJson = responseJson['data'];
        List<ArticleModel> articles = [];
        articlesJson.forEach((value) {
          articles.add(
            ArticleModel.fromJson(value),
          );
        });
        return articles;
      },
      removeFromDb: (articles) async {
        await database.articleDao.removeAll(articleCategory.name);
      },
      insertToDb: (articles) async {
        await database.articleDao.insert(articles);
      },
      errorMessage:
          'Gagal mengambil data artikel terbaru. Tolong periksa Internet Anda.',
    );
  }

  Future<ResultModel<List<ArticleCategoryModel>>> getAllCategories() {
    assert(() {
      log('getAllCategories', name: tag);
      return true;
    }());
    return getResultModel(
      tag: tag,
      getFromDb: () async {
        List<ArticleCategoryModel>? itemsDb =
            await database.articleDao.getAllCategories();
        return itemsDb;
      },
      getFromApi: () => api.getAllCategories(),
      getDataFromApiResponse: (responseJson) {
        List<dynamic> itemsJson = responseJson['data'];
        List<ArticleCategoryModel> items = [];
        itemsJson.forEach((value) {
          items.add(
            ArticleCategoryModel.fromJson({'name': value}),
          );
        });
        return items;
      },
      removeFromDb: (_) async {
        await database.articleDao.removeAllCategories();
      },
      insertToDb: (items) async {
        await database.articleDao.insertCategories(items);
      },
      errorMessage:
          'Gagal mengambil data artikel terbaru. Tolong periksa Internet Anda.',
    );
  }

  Future<ResultModel<List<MobileArticleModel>>> getMobileAll(
    ArticleCategoryModel articleCategory,
  ) async {
    assert(() {
      log('getMobileAll', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat mendapatkan data artikel. Tolong periksa Internet Anda.';

    try {
      Response response = await api.getMobileAll(articleCategory.name);
      var responseJson = response.data;
      log(responseJson['data'].toString(), name: tag);

      if (responseJson['status'] == 'success') {
        List<dynamic> itemsJson = responseJson['data'];
        List<MobileArticleModel> articleList = [];
        itemsJson.forEach((value) {
          articleList.add(
            MobileArticleModel.fromJson(value),
          );
        });
        return ResultModel(
          isSuccess: true,
          data: articleList,
        );
      } else {
        log('message:' + responseJson.toString());
        return ResultModel(
          isSuccess: false,
          error: finalErrorMessage,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is DioError) {
        int? statusCode = e.response?.statusCode;
        if (statusCode != null) {
          if (statusCode >= 400 && statusCode < 500) {
            // Client error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          } else if (statusCode >= 500 && statusCode < 600) {
            // Server error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          }
        }
        if (e.message.contains('SocketException')) {
          return ResultModel(
            isSuccess: false,
            error: finalErrorMessage,
          );
        }
      }
      return ResultModel(
        isSuccess: false,
        error: finalErrorMessage,
      );
    }
  }

  Future<ResultModel<MobileArticleDetailModel>> getMobileArticle(
    int articleId,
  ) async {
    assert(() {
      log('getMobileArticle', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat mendapatkan data artikel. Tolong periksa Internet Anda.';

    try {
      Response response = await api.getArticle(articleId);
      var responseJson = response.data;
      log(responseJson['data'].toString(), name: tag);

      if (responseJson['status'] == 'success') {
        return ResultModel(
          isSuccess: true,
          data: MobileArticleDetailModel.fromJson(responseJson['data']),
        );
      } else {
        log('message:' + responseJson.toString());
        return ResultModel(
          isSuccess: false,
          error: finalErrorMessage,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is DioError) {
        int? statusCode = e.response?.statusCode;
        if (statusCode != null) {
          if (statusCode >= 400 && statusCode < 500) {
            // Client error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          } else if (statusCode >= 500 && statusCode < 600) {
            // Server error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          }
        }
        if (e.message.contains('SocketException')) {
          return ResultModel(
            isSuccess: false,
            error: finalErrorMessage,
          );
        }
      }
      return ResultModel(
        isSuccess: false,
        error: finalErrorMessage,
      );
    }
  }
}
