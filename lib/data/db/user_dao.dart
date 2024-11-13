import 'package:pensiunku/model/user_model.dart';
import 'package:sqflite/sqflite.dart';

class UserDao {
  final Database database;

  UserDao(this.database);

  static const TABLE_NAME = 'users';

  insert(UserModel user) async {
    Batch batch = database.batch();
    batch.insert(
      TABLE_NAME,
      user.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await batch.commit();
  }

  Future<UserModel?> getOne() async {
    final userJson = await database.query(
      TABLE_NAME,
    );
    if (userJson.length > 0) {
      return UserModel.fromJson(userJson[0]);
    }
    return null;
  }

  removeAll() async {
    await database.delete(
      TABLE_NAME,
    );
  }
}
