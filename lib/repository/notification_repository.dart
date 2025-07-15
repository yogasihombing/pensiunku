import 'dart:developer' as developer;
import 'dart:io'; // Import untuk SocketException
import 'dart:convert'; // Import untuk json.decode

import 'package:http/http.dart' as http; // Ganti Dio dengan http
import 'package:pensiunku/data/api/notification_api.dart'; // Sesuaikan path
import 'package:pensiunku/data/db/app_database.dart'; // Sesuaikan path
import 'package:pensiunku/model/notification_model.dart'; // Sesuaikan path
import 'package:pensiunku/repository/base_repository.dart'; // Sesuaikan path
import 'package:pensiunku/model/result_model.dart'; // Sesuaikan path

class NotificationRepository extends BaseRepository {
  static String tag = 'NotificationRepository';
  NotificationApi api = NotificationApi();
  AppDatabase database = AppDatabase();

  @override // Pastikan ini ada jika getResultModel ada di BaseRepository
  Future<ResultModel<List<NotificationModel>>> getAll(String token) {
    assert(() {
      developer.log('getAll', name: tag);
      return true;
    }());

    // Karena getResultModel adalah abstraksi, penanganan http.Response
    // dan error akan dilakukan di dalamnya. Kita hanya perlu memastikan
    // `getFromApi` mengembalikan Future<http.Response> dan
    // `getDataFromApiResponse` bisa mengurai hasilnya.
    return getResultModel(
      tag: tag,
      getFromDb: () async {
        List<NotificationModel>? itemsDb =
            await database.notificationDao.getAll();
        return itemsDb;
      },
      // getFromApi harus mengembalikan Future<http.Response>
      getFromApi: () => api.getAll(token),
      // getDataFromApiResponse harus menerima response body yang sudah di-decode
      getDataFromApiResponse: (responseBody) { // responseBody di sini adalah hasil json.decode
        List<dynamic> itemsJson = responseBody['data'];
        List<NotificationModel> items = [];
        for (var value in itemsJson) {
          items.add(
            NotificationModel.fromJson(value),
          );
        }
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
      // Menggunakan http.Response dari NotificationApi
      http.Response response = await api.readNotification(token, id);

      // Decoding response.body ke Map
      var responseJson = json.decode(response.body);

      // Periksa status code HTTP terlebih dahulu, lalu logika bisnis
      if (response.statusCode == 200 && responseJson['status'] == 'success') {
        return ResultModel(
          isSuccess: true,
          data: true,
        );
      } else {
        // Jika status code bukan 200 atau 'status' di body bukan 'success'
        developer.log('API Response Error: ${responseJson['message'] ?? 'Unknown Error'}', name: tag);
        return ResultModel(
          isSuccess: false,
          error: responseJson['message'] ?? finalErrorMessage,
        );
      }
    } catch (e) {
      developer.log(e.toString(), name: tag, error: e);

      // Penanganan error untuk package http
      if (e is SocketException) {
        // Ini adalah error jaringan (tidak ada koneksi, DNS lookup gagal, dll.)
        return ResultModel(
          isSuccess: false,
          error: 'Tidak ada koneksi internet. Mohon periksa jaringan Anda.',
        );
      }
      // Anda bisa menambahkan penanganan error lain jika diperlukan,
      // seperti FormatException jika json.decode gagal.

      // Default error message untuk error yang tidak teridentifikasi
      return ResultModel(
        isSuccess: false,
        error: finalErrorMessage,
      );
    }
  }
}