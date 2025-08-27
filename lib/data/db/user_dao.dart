import 'package:pensiunku/model/user_model.dart';
import 'package:sqflite/sqflite.dart';

class UserDao {
  final Database database;

  UserDao(this.database);

  static const TABLE_NAME = 'users';

  insert(UserModel user) async {
    Batch batch = database.batch();

    // Convert bool to int (1 or 0) for SQLite storage
    var userMap = user.toJson();
    userMap['is_pensiunku_plus'] = user.isPensiunkuPlus ? 1 : 0;
    userMap['is_wallet_active'] = user.isWalletActive ? 1 : 0;

    batch.insert(
      TABLE_NAME,
      userMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await batch.commit();
  }

  Future<UserModel?> getOne() async {
    final userJson = await database.query(
      TABLE_NAME,
    );
    if (userJson.isNotEmpty) {
      // Buat salinan Map yang bisa dimodifikasi dari hasil query
      Map<String, dynamic> userMap = Map.from(userJson[0]);

      // Convert int (1 or 0) back to bool
      userMap['is_pensiunku_plus'] = (userMap['is_pensiunku_plus'] as int) == 1;
      userMap['is_wallet_active'] = (userMap['is_wallet_active'] as int) == 1;

      return UserModel.fromJson(userMap);
    }
    return null;
  }

  removeAll() async {
    await database.delete(
      TABLE_NAME,
    );
  }
}