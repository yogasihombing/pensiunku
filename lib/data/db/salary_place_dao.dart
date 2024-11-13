import 'package:pensiunku/model/salary_place_model.dart';
import 'package:sqflite/sqflite.dart';

class SalaryPlaceDao {
  final Database database;

  SalaryPlaceDao(this.database);

  static const TABLE_NAME = 'salary_places';

  insert(List<SalaryPlaceModel> salaryPlaces) async {
    Batch batch = database.batch();
    salaryPlaces.asMap().forEach((index, salaryPlace) {
      batch.insert(
        TABLE_NAME,
        salaryPlace.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
    await batch.commit();
  }

  Future<List<SalaryPlaceModel>> getAll() async {
    final salaryPlacesJson = await database.query(
      TABLE_NAME,
      orderBy: 'id asc',
    );
    if (salaryPlacesJson.length > 0) {
      List<SalaryPlaceModel> salaryPlaces = [];
      for (var i = 0; i < salaryPlacesJson.length; i++) {
        salaryPlaces.add(
          SalaryPlaceModel.fromJson(salaryPlacesJson[i]),
        );
      }
      return salaryPlaces;
    } else {
      List<SalaryPlaceModel> salaryPlaces = [];
      for (var i = 0; i < salaryPlacesJson.length; i++) {
        salaryPlaces.add(
          SalaryPlaceModel.fromJson(salaryPlacesJson[i]),
        );
      }
      return salaryPlaces;
    }
  }

  removeAll() async {
    await database.delete(
      TABLE_NAME,
    );
  }
}
