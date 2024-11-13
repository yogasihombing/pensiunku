import 'dart:developer';

import 'package:pensiunku/data/api/faq_api.dart';
import 'package:pensiunku/data/db/app_database.dart';
import 'package:pensiunku/model/faq_category_model.dart';
import 'package:pensiunku/repository/base_repository.dart';
import 'package:pensiunku/repository/result_model.dart';

class FaqRepository extends BaseRepository {
  static String tag = 'FaqRepository';
  FaqApi api = FaqApi();
  AppDatabase database = AppDatabase();

  Future<ResultModel<List<FaqCategoryModel>>> getAll() {
    assert(() {
      log('getAll', name: tag);
      return true;
    }());
    return getResultModel(
      tag: tag,
      getFromDb: () async {
        List<FaqCategoryModel>? faqCategoriesDb =
            await database.faqDao.getAll();
        return faqCategoriesDb;
      },
      getFromApi: () => api.getAll(),
      getDataFromApiResponse: (responseJson) {
        Map<String, dynamic> faqCategoriesJson = responseJson['data'];
        List<FaqCategoryModel> faqCategories = [];
        int order = 1;
        faqCategoriesJson.forEach((key, value) {
          faqCategories.add(
            FaqCategoryModel.fromJson(
              {
                'name': key,
                'item_order': order,
              },
              value,
            ),
          );
          order++;
        });

        return faqCategories;
      },
      removeFromDb: (faqCategories) async {
        await database.faqDao.removeAll();
      },
      insertToDb: (faqCategories) async {
        await database.faqDao.insert(faqCategories);
      },
      errorMessage:
          'Gagal mengambil data FAQ terbaru. Tolong periksa Internet Anda.',
    );
  }
}
