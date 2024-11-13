import 'package:pensiunku/model/theme_model.dart';
import 'package:sqflite/sqflite.dart';

class ThemeDao {
  final Database database;

  ThemeDao(this.database);

  static const TABLE_NAME = 'theme';

  insert(ThemeModel theme) async {
    int result = await database.insert(
      TABLE_NAME,
      theme.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return result;
  }

  update(ThemeModel theme) async {
    int result = await database.update(TABLE_NAME, theme.toMap(),
        where: "parameter = ?", whereArgs: [theme.parameter]);
    return result;
  }

  insertUpdate(ThemeModel theme) async {
    late int result;
    //check apakah sudah ada atau belum
    ThemeModel? isExist = await get(theme.parameter);
    if (isExist != null) {
      result = await update(theme);
      return result;
    } else {
      result = await insert(theme);
      return result;
    }
  }

  Future<ThemeModel?> get(String parameter) async {
    final themeResult = await database
        .query(TABLE_NAME, where: "parameter = ?", whereArgs: [parameter]);
    if (themeResult.length > 0) {
      return ThemeModel.fromMap(themeResult[0]);
    }
    // kalau belum ada return default
    return null;
  }

  removeAll() async {
    await database.delete(
      TABLE_NAME,
    );
  }
}
