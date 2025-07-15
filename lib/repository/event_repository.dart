import 'dart:developer';
import 'dart:convert'; // Untuk json.decode
import 'package:http/http.dart' as http; // Menggunakan paket http
import 'package:pensiunku/data/api/event_api.dart'; // Pastikan path ini benar
import 'package:pensiunku/data/api/base_api.dart'; // Import BaseApi untuk HttpException
import 'package:pensiunku/model/event_model.dart'; // Pastikan semua model di sini
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
      // Perbedaan 2: Log awal disederhanakan.
      log('getEvents Repository', name: tag);
      return true;
    }());

    // Pesan error standar untuk semua kasus kegagalan.
    String finalErrorMessage =
        'Tidak dapat mendapatkan data event terbaru. Tolong periksa Internet Anda.';

    // --- PERUBAHAN: Menggunakan getResultModel dari BaseRepository ---
    return super.getResultModel<List<EventModel>>(
      tag: tag,
      getFromApi: () => api.getEvents(token, filterIndex, searchText),
      getDataFromApiResponse: (responseJson) {
        List<dynamic> itemsJson = responseJson['data'];
        // Menggunakan map untuk parsing list, yang sedikit lebih modern dan fungsional.
        return itemsJson.map((value) => EventModel.fromJson(value)).toList();
      },
      errorMessage: finalErrorMessage,
    );
    // --- AKHIR PERUBAHAN ---
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

    // --- PERUBAHAN: Menggunakan getResultModel dari BaseRepository ---
    return super.getResultModel<EventDetailModel>(
      tag: tag,
      getFromApi: () => api.getEvent(token, id),
      getDataFromApiResponse: (responseJson) {
        dynamic itemsJson = responseJson['data'];
        return EventDetailModel.fromJson(itemsJson);
      },
      errorMessage: finalErrorMessage,
    );
    // --- AKHIR PERUBAHAN ---
  }
}
