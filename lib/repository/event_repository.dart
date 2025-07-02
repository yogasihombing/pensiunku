import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:pensiunku/data/api/event_api.dart';
import 'package:pensiunku/model/event_model.dart';
import 'package:pensiunku/repository/base_repository.dart';
import 'package:pensiunku/model/result_model.dart';

class EventRepository extends BaseRepository {
  // Perbedaan 1: Nama tag disesuaikan agar lebih spesifik dan konsisten.
  static String tag = 'Event Repository';
  EventApi api = EventApi();

  /// Mengambil daftar event berdasarkan token, filter, dan teks pencarian.
  Future<ResultModel<List<EventModel>>> getEvents(
      String token, int filterIndex, String? searchText) async {
    assert(() {
      // Perbedaan 2: Log awal disederhanakan, tanpa mencetak token langsung di string.
      // Ini lebih konsisten dengan gaya di HalopensiunRepository.
      log('getEvents Repository', name: tag);
      return true;
    }());

    // Pesan error standar untuk semua kasus kegagalan.
    String finalErrorMessage =
        'Tidak dapat mendapatkan data event terbaru. Tolong periksa Internet Anda.';

    try {
      Response response = await api.getEvents(token, filterIndex, searchText);
      var responseJson = response.data;
      log(responseJson.toString(), name: tag); // Log seluruh respon JSON

      if (responseJson['status'] == 'success') {
        List<dynamic> itemsJson = responseJson['data'];
        List<EventModel> eventList = [];
        // Menggunakan map untuk parsing list, yang sedikit lebih modern dan fungsional.
        eventList =
            itemsJson.map((value) => EventModel.fromJson(value)).toList();

        return ResultModel(
          isSuccess: true,
          data: eventList,
        );
      } else {
        // Log pesan error dari respons jika status bukan 'success'.
        log('Error response: ${responseJson.toString()}', name: tag);
        return ResultModel(
          isSuccess: false,
          error: finalErrorMessage,
        );
      }
    } catch (e) {
      // Perbedaan 3: Blok catch diseragamkan sepenuhnya.
      // Ini adalah bagian paling penting untuk konsistensi penanganan error.
      log(e.toString(), name: tag, error: e);
      if (e is DioException) {
        int? statusCode = e.response?.statusCode;
        if (statusCode != null) {
          if (statusCode >= 400 && statusCode < 500) {
            // Error client (misalnya, Bad Request, Unauthorized)
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          } else if (statusCode >= 500 && statusCode < 600) {
            // Error server (misalnya, Internal Server Error)
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          }
        }
        // Penanganan SocketException (masalah koneksi internet)
        if (e.message?.contains('SocketException') ?? false) {
          return ResultModel(
            isSuccess: false,
            error: finalErrorMessage,
          );
        }
      }
      // Penanganan error lain yang tidak spesifik DioError atau tidak memiliki statusCode
      return ResultModel(
        isSuccess: false,
        error: finalErrorMessage,
      );
    }
  }

  /// Mengambil detail event berdasarkan token dan ID event.
  Future<ResultModel<EventDetailModel>> getEventDetail(
      String token, int id) async {
    assert(() {
      // Perbedaan 2: Log awal disederhanakan.
      log('getEventDetail Repository', name: tag);
      return true;
    }());

    // Pesan error standar untuk semua kasus kegagalan.
    String finalErrorMessage =
        'Tidak dapat mendapatkan data detail event. Tolong periksa Internet Anda.';

    try {
      Response response = await api.getEvent(token, id);
      var responseJson = response.data;
      log(responseJson.toString(), name: tag); // Log seluruh respon JSON

      if (responseJson['status'] == 'success') {
        dynamic itemsJson = responseJson['data'];
        EventDetailModel eventDetailModel =
            EventDetailModel.fromJson(itemsJson);

        return ResultModel(
          isSuccess: true,
          data: eventDetailModel,
        );
      } else {
        // Log pesan error dari respons jika status bukan 'success'.
        log('Error response: ${responseJson.toString()}', name: tag);
        return ResultModel(
          isSuccess: false,
          error: finalErrorMessage,
        );
      }
    } catch (e) {
      // Perbedaan 3: Blok catch diseragamkan sepenuhnya.
      log(e.toString(), name: tag, error: e);
      if (e is DioError) {
        int? statusCode = e.response?.statusCode;
        if (statusCode != null) {
          if (statusCode >= 400 && statusCode < 500) {
            // Error client
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          } else if (statusCode >= 500 && statusCode < 600) {
            // Error server
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          }
        }
        // Penanganan SocketException
        if (e.message?.contains('SocketException') ?? false) {
          return ResultModel(
            isSuccess: false,
            error: finalErrorMessage,
          );
        }
      }
      // Penanganan error lain
      return ResultModel(
        isSuccess: false,
        error: finalErrorMessage,
      );
    }
  }
}
