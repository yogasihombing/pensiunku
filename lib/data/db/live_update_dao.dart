import 'package:pensiunku/model/live_update_model.dart';
import 'package:sqflite/sqflite.dart';

class LiveUpdateDao {
  final Database database;

  LiveUpdateDao(this.database);

  static const TABLE_NAME = 'live_updates';

  insert(List<LiveUpdateModel> liveUpdates) async {
    Batch batch = database.batch();
    liveUpdates.asMap().forEach((index, liveUpdate) {
      batch.insert(
        TABLE_NAME,
        liveUpdate.toJson(index),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
    await batch.commit();
  }

  Future<List<LiveUpdateModel>> getAll() async {
    final liveUpdatesJson = await database.query(
      TABLE_NAME,
      orderBy: 'l1_millis desc',
    );
    if (liveUpdatesJson.length > 0) {
      List<LiveUpdateModel> liveUpdates = [];
      for (var i = 0; i < liveUpdatesJson.length; i++) {
        liveUpdates.add(
          LiveUpdateModel.fromJson(liveUpdatesJson[i]),
        );
      }
      return liveUpdates;
    }
    return [];
  }

  removeAll() async {
    await database.delete(
      TABLE_NAME,
    );
  }
}
