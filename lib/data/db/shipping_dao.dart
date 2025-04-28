
import 'package:pensiunku/model/toko/toko_model.dart';
import 'package:sqflite/sqflite.dart';

class ShippingDao {
  final Database database;

  ShippingDao(this.database);

  static const TABLE_NAME = 'shipping';

  insert(ShippingAddress shippingAddress) async {
    int result = await database.insert(
      TABLE_NAME,
      shippingAddress.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return result;
  }

  Future<ShippingAddress?> getFirst() async {
    final shippingAddressResult = await database.query(TABLE_NAME, limit: 1);
    if (shippingAddressResult.length > 0) {
      return ShippingAddress.fromMap(shippingAddressResult[0]);
    }
    // kalau belum ada return default
    return null;
  }

  update(ShippingAddress shippingAddress) async {
    int result = await database.update(TABLE_NAME, shippingAddress.toMap(),
        where: "id = ?", whereArgs: [shippingAddress.id]);
    return result;
  }

  insertUpdate(ShippingAddress shippingAddress) async {
    late int result;
    //check apakah sudah ada atau belum
    ShippingAddress? isExist = await getFirst();
    if (isExist != null) {
      removeAll();
    }
    result = await insert(shippingAddress);
    return result;
  }

  removeAll() async {
    await database.delete(
      TABLE_NAME,
    );
  }

  removeById(int shippingAddressId) async {
    late int result;
    result = await database
        .delete(TABLE_NAME, where: "id = ?", whereArgs: [shippingAddressId]);
    return result;
  }
}
