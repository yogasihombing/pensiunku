import 'dart:developer';

import 'package:pensiunku/data/api/live_update_api.dart';
import 'package:pensiunku/data/db/app_database.dart';
import 'package:pensiunku/model/live_update_model.dart';
import 'package:pensiunku/repository/base_repository.dart';
import 'package:pensiunku/model/result_model.dart';

class LiveUpdateRepository extends BaseRepository {
  static String tag = 'LiveUpdateRepository';
  LiveUpdateApi api = LiveUpdateApi();
  AppDatabase database = AppDatabase();

  Future<ResultModel<List<LiveUpdateModel>>> getAll() {
    assert(() {
      log('getAll', name: tag);
      return true;
    }());
    return getResultModel(
      tag: tag,
      getFromDb: () async {
        List<LiveUpdateModel>? liveUpdatesDb =
            await database.liveUpdateDao.getAll();
        return liveUpdatesDb;
      },
      getFromApi: () => api.getAll(),
      getDataFromApiResponse: (responseJson) {
        List<dynamic> liveUpdatesJson = responseJson['data'];
        List<LiveUpdateModel> liveUpdates = [];
        liveUpdatesJson.forEach((value) {
          liveUpdates.add(
            LiveUpdateModel.fromJson(value),
          );
        });
        return liveUpdates;
      },
      removeFromDb: (liveUpdates) async {
        await database.liveUpdateDao.removeAll();
      },
      insertToDb: (liveUpdates) async {
        await database.liveUpdateDao.insert(liveUpdates);
      },
      errorMessage:
          'Gagal mengambil data live update terbaru. Tolong periksa Internet Anda.',
    );
  }
}
