import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:pensiunku/data/api/notification_api.dart';
import 'package:pensiunku/data/db/app_database.dart';
import 'package:pensiunku/model/notification_model.dart';
import 'package:pensiunku/repository/base_repository.dart';
import 'package:pensiunku/model/result_model.dart';

class NotificationRepository extends BaseRepository {
  static String tag = 'NotificationRepository';
  NotificationApi api = NotificationApi();
  AppDatabase database = AppDatabase();

  Future<ResultModel<List<NotificationModel>>> getAll(String token) {
    assert(() {
      developer.log('getAll', name: tag);
      return true;
    }());
    return getResultModel(
      tag: tag,
      getFromDb: () async {
        List<NotificationModel>? itemsDb =
            await database.notificationDao.getAll();
        return itemsDb;
      },
      getFromApi: () => api.getAll(token),
      getDataFromApiResponse: (responseJson) {
        List<dynamic> itemsJson = responseJson['data'];
        List<NotificationModel> items = [];
        itemsJson.forEach((value) {
          items.add(
            NotificationModel.fromJson(value),
          );
        });
        return items;
      },
      removeFromDb: (items) async {
        await database.notificationDao.removeAll();
      },
      insertToDb: (items) async {
        await database.notificationDao.insert(items);
      },
      errorMessage:
          'Gagal mengambil data notifikasi terbaru. Tolong periksa Internet Anda.',
    );
  }

  Future<ResultModel<bool>> readNotification(String token, int id) async {
    assert(() {
      developer.log('readNotification: $token $id', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat menandai notifikasi dibaca. Tolong periksa Internet Anda.';
    try {
      Response response = await api.readNotification(token, id);
      var responseJson = response.data;

      if (responseJson['status'] == 'success') {
        return ResultModel(
          isSuccess: true,
          data: true,
        );
      } else {
        return ResultModel(
          isSuccess: false,
          error: finalErrorMessage,
        );
      }
    } catch (e) {
      developer.log(e.toString(), name: tag, error: e);
      if (e is DioError) {
        int? statusCode = e.response?.statusCode;
        if (statusCode != null) {
          if (statusCode >= 400 && statusCode < 500) {
            // Client error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          } else if (statusCode >= 500 && statusCode < 600) {
            // Server error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          }
        }
        if (e.message.contains('SocketException')) {
          return ResultModel(
            isSuccess: false,
            error: finalErrorMessage,
          );
        }
      }
      return ResultModel(
        isSuccess: false,
        error: finalErrorMessage,
      );
    }
  }
}
