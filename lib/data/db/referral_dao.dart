import 'package:pensiunku/model/referral_model.dart';
import 'package:sqflite/sqflite.dart';

class ReferralDao {
  final Database database;

  ReferralDao(this.database);

  static const TABLE_NAME = 'referal';

  insert(List<ReferralModel> referal) async {
    Batch batch = database.batch();
    referal.asMap().forEach((index, referal) {
      batch.insert(
        TABLE_NAME,
        referal.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
    await batch.commit();
  }

  Future<List<ReferralModel>> getAll() async {
    final referalsJson = await database.query(
      TABLE_NAME,
      orderBy: 'id asc',
    );
    if (referalsJson.length > 0) {
      List<ReferralModel> referals = [];
      for (var i = 0; i < referalsJson.length; i++) {
        referals.add(
          ReferralModel.fromJson(referalsJson[i]),
        );
      }
      return referals;
    }
    return [];
  }

  Future<ReferralModel?> getOne() async {
    final referalJson = await database.query(
      TABLE_NAME,
    );
    if (referalJson.length > 0) {
      return ReferralModel.fromJson(referalJson[0]);
    }
    return null;
  }

  removeAll() async {
    await database.delete(
      TABLE_NAME,
    );
  }
}
