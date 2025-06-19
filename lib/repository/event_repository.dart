import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:pensiunku/data/api/event_api.dart';
import 'package:pensiunku/model/event_model.dart';
import 'package:pensiunku/repository/base_repository.dart';
import 'package:pensiunku/model/result_model.dart';

class EventRepository extends BaseRepository {
  static String tag = 'Point Repository';
  EventApi api = EventApi();

  Future<ResultModel<List<EventModel>>> getEvents(
      String token, int filterIndex, String? searchText) async {
    assert(() {
      log('Event Repository: $token', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat mendapatkan data event terbaru. Tolong periksa Internet Anda.';
    try {
      Response response = await api.getEvents(token, filterIndex, searchText);
      var responseJson = response.data;
      log(responseJson['data'].toString(), name: tag);

      if (responseJson['status'] == 'success') {
        List<dynamic> itemsJson = responseJson['data'];
        List<EventModel> eventList = [];
        itemsJson.forEach((value) {
          eventList.add(
            EventModel.fromJson(value),
          );
        });
        return ResultModel(
          isSuccess: true,
          data: eventList,
        );
      } else {
        log('message:' + responseJson.toString());
        return ResultModel(
          isSuccess: false,
          error: finalErrorMessage,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
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

  Future<ResultModel<EventDetailModel>> getEventDetail(
      String token, int id) async {
    assert(() {
      log('Event Detail Repository: $token', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat mendapatkan data detail event. Tolong periksa Internet Anda.';
    try {
      Response response = await api.getEvent(token, id);
      var responseJson = response.data;
      log(responseJson['data'].toString(), name: tag);

      if (responseJson['status'] == 'success') {
        dynamic itemsJson = responseJson['data'];
        EventDetailModel eventDetailModel =
            EventDetailModel.fromJson(itemsJson);

        return ResultModel(
          isSuccess: true,
          data: eventDetailModel,
        );
      } else {
        return ResultModel(
          isSuccess: false,
          error: finalErrorMessage,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
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
