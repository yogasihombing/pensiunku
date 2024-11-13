import 'package:pensiunku/model/notification_model.dart';
import 'package:sqflite/sqflite.dart';

class NotificationDao {
  final Database database;

  NotificationDao(this.database);

  static const TABLE_NAME = 'notifications';

  insert(List<NotificationModel> notifications) async {
    Batch batch = database.batch();
    notifications.forEach((notification) {
      batch.insert(
        TABLE_NAME,
        notification.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
    await batch.commit();
  }

  Future<List<NotificationModel>> getAll() async {
    final notificationsJson = await database.query(
      TABLE_NAME,
      orderBy: 'created_at desc',
    );
    if (notificationsJson.length > 0) {
      List<NotificationModel> notifications = [];
      for (var i = 0; i < notificationsJson.length; i++) {
        notifications.add(
          NotificationModel.fromJson(notificationsJson[i]),
        );
      }
      return notifications;
    }
    return [];
  }

  removeAll() async {
    await database.delete(
      TABLE_NAME,
    );
  }
}
