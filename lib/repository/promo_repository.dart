import 'dart:developer';

import 'package:pensiunku/data/api/promo_api.dart';
import 'package:pensiunku/data/db/app_database.dart';
import 'package:pensiunku/model/promo_model.dart';
import 'package:pensiunku/repository/base_repository.dart';
import 'package:pensiunku/repository/result_model.dart';

class PromoRepository extends BaseRepository {
  static String tag = 'PromoRepository';
  PromoApi api = PromoApi();
  AppDatabase database = AppDatabase();

  Future<ResultModel<List<PromoModel>>> getAll() {
    assert(() {
      log('getAllPromo', name: tag);
      return true;
    }());
    return getResultModel(
      tag: tag,
      getFromDb: () async {
        List<PromoModel>? itemsDb = await database.promoDao.getAll();
        return itemsDb;
      },
      getFromApi: () => api.getAll(),
      getDataFromApiResponse: (responseJson) {
        List<dynamic> itemsJson = responseJson['data'];
        List<PromoModel> items = [];
        itemsJson.forEach((value) {
          items.add(
            PromoModel.fromJson(value),
          );
        });
        return items;
      },
      removeFromDb: (items) async {
        await database.promoDao.removeAll();
      },
      insertToDb: (items) async {
        await database.promoDao.insert(items);
      },
      errorMessage:
          'Gagal mengambil data promo terbaru. Tolong periksa Internet Anda.',
    );
  }
}
