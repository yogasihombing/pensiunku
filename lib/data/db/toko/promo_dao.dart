
import 'package:pensiunku/model/toko/promo_model.dart';
import 'package:sqflite/sqflite.dart';

class PromoDao {
  final Database database;

  PromoDao(this.database);

  static const TABLE_NAME = 'banners';

  insert(List<PromoModel> promos) async {
    Batch batch = database.batch();
    promos.asMap().forEach((index, promo) {
      batch.insert(
        TABLE_NAME,
        promo.toJson(index),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
    await batch.commit();
  }

  Future<List<PromoModel>> getAll() async {
    final promosJson = await database.query(
      TABLE_NAME,
      orderBy: 'item_order asc',
    );
    if (promosJson.length > 0) {
      List<PromoModel> promos = [];
      for (var i = 0; i < promosJson.length; i++) {
        promos.add(
          PromoModel.fromJson(promosJson[i]),
        );
      }
      return promos;
    }
    return [];
  }

  removeAll() async {
    await database.delete(
      TABLE_NAME,
    );
  }
}
