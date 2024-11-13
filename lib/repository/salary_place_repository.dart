import 'dart:developer';

import 'package:pensiunku/data/api/salary_place_api.dart';
import 'package:pensiunku/data/db/app_database.dart';
import 'package:pensiunku/model/salary_place_model.dart';
import 'package:pensiunku/repository/base_repository.dart';
import 'package:pensiunku/repository/result_model.dart';

// class SalaryPlaceRepository extends BaseRepository {
//   static List<SalaryPlaceModel> getAllDb() {
//     return [
//       SalaryPlaceModel(id: 1, text: 'Laki-laki'),
//       SalaryPlaceModel(id: 2, text: 'Perempuan'),
//       SalaryPlaceModel(id: 3, text: 'Tidak Ingin Memberi Tahu'),
//     ];
//   }
// }

class SalaryPlaceRepository extends BaseRepository {
  static String tag = 'SalaryPlaceRepository';
  SalaryPlaceApi api = SalaryPlaceApi();
  AppDatabase database = AppDatabase();

  Future<ResultModel<List<SalaryPlaceModel>>> getAll() {
    assert(() {
      log('getAll', name: tag);
      return true;
    }());
    return getResultModel(
      tag: tag,
      getFromDb: () async {
        List<SalaryPlaceModel>? itemsDb =
            await database.salaryPlaceDao.getAll();
        return itemsDb;
      },
      getFromApi: () => api.getAll(),
      getDataFromApiResponse: (responseJson) {
        List<dynamic> itemsJson = responseJson['data'];
        List<SalaryPlaceModel> items = [];
        itemsJson.asMap().forEach((index, value) {
          items.add(
            SalaryPlaceModel.fromJson({
              'id': index + 1,
              'text': value,
            }),
          );
        });
        // items.add(
        //   SalaryPlaceModel(id: 1, text: 'Bank BNI'),
        // );
        // items.add(
        //   SalaryPlaceModel(id: 2, text: 'Bank BTPN'),
        // );
        // items.add(
        //   SalaryPlaceModel(id: 3, text: 'Bank BJB'),
        // );
        // items.add(
        //   SalaryPlaceModel(id: 4, text: 'Bank KB Bukopin'),
        // );
        // items.add(
        //   SalaryPlaceModel(id: 5, text: 'Bank BRI'),
        // );
        // items.add(
        //   SalaryPlaceModel(id: 6, text: 'Bank MANDIRI'),
        // );
        // items.add(
        //   SalaryPlaceModel(id: 7, text: 'Bank MANTAP'),
        // );
        // items.add(
        //   SalaryPlaceModel(id: 8, text: 'Bank BPR'),
        // );
        // items.add(
        //   SalaryPlaceModel(id: 9, text: 'Kantor Pos'),
        // );
        // items.add(
        //   SalaryPlaceModel(id: 10, text: 'Bank Daerah'),
        // );
        // items.add(
        //   SalaryPlaceModel(id: 11, text: 'Bank Yudha Bakti'),
        // );
        // items.add(
        //   SalaryPlaceModel(id: 12, text: 'Bank Lain'),
        // );
        return items;
      },
      removeFromDb: (items) async {
        await database.salaryPlaceDao.removeAll();
      },
      insertToDb: (items) async {
        await database.salaryPlaceDao.insert(items);
      },
      errorMessage:
          'Gagal mengambil data bank terbaru. Tolong periksa Internet Anda.',
    );
  }

  Future<ResultModel<List<SalaryPlaceModel>>> getAllDb() async {
    assert(() {
      log('getAllDb', name: tag);
      return true;
    }());
    List<SalaryPlaceModel>? itemsDb = await database.salaryPlaceDao.getAll();
    return ResultModel(
      isSuccess: true,
      data: itemsDb,
    );
  }
}
