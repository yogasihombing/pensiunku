import 'dart:developer';
import 'dart:io'; // Import untuk SocketException
import 'dart:convert'; // Import untuk json.decode

import 'package:http/http.dart' as http; // Ganti Dio dengan http
import 'package:pensiunku/data/api/monitoring_pengajuan.dart';
import 'package:pensiunku/model/monitoring_pengajuan_model.dart';
import 'package:pensiunku/repository/base_repository.dart';
import 'package:pensiunku/model/result_model.dart';

class MonitoringRepository extends BaseRepository {
  static String tag = 'Monitoring Repository';
  MonitoringApi api = MonitoringApi();

  Future<ResultModel<MonitoringPengajuanModel>> getMonitoring(
      String token) async {
    assert(() {
      log('Monitoring Repository: $token', name: tag);
      return true;
    }());

    String finalErrorMessage =
        'Tidak dapat mendapatkan monitoring pengajuan terbaru. Tolong periksa Internet Anda.';

    try {
      // Menggunakan http.Response dari MonitoringApi
      http.Response response = await api.getMonitoring(token);

      // Decoding response.body ke Map
      var responseJson = json.decode(response.body);

      if (response.statusCode == 200 && responseJson['status'] == 'success') {
        return ResultModel(
          isSuccess: true,
          data: MonitoringPengajuanModel.fromJson(responseJson["data"]),
        );
      } else {
        // Jika status code bukan 200 atau 'status' di body bukan 'success'
        // Anda bisa menambahkan log untuk melihat responseJson['message'] jika ada
        log('API Response Error: ${responseJson['message'] ?? 'Unknown Error'}', name: tag);
        return ResultModel(
          isSuccess: false,
          error: finalErrorMessage,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);

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