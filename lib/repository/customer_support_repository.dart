import 'dart:developer';
import 'dart:convert'; // Untuk json.decode
import 'package:http/http.dart' as http; // Menggunakan paket http
import 'package:pensiunku/data/api/customer_support_api.dart'; // Pastikan path ini benar
import 'package:pensiunku/data/api/base_api.dart'; // Import BaseApi untuk HttpException
import 'package:pensiunku/model/result_model.dart';

class CustomerSupportRepository {
  static String tag = 'CustomerSupportRepository';
  CustomerSupportApi api = CustomerSupportApi();

  Future<ResultModel<bool>> sendQuestion(String token, dynamic data) async {
    assert(() {
      log('sendQuestion:', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat mengirimkan pertanyaan. Tolong periksa Internet Anda.';
    try {
      // Mengubah tipe kembalian dari api.sendQuestion menjadi http.Response
      http.Response response = await api.sendQuestion(token, data);
      var responseJson = json.decode(response.body); // Menggunakan json.decode(response.body)

      if (responseJson['status'] == 'success') {
        return ResultModel(
          isSuccess: true,
          data: true,
        );
      } else {
        return ResultModel(
          isSuccess: false,
          error: responseJson['msg'] ?? finalErrorMessage,
        );
      }
    } on HttpException catch (e) { // Mengubah DioException menjadi HttpException
      log(e.toString(), name: tag, error: e);
      int? statusCode = e.statusCode;
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
      // Penanganan SocketException sudah dibungkus dalam HttpException di BaseApi
      // Jika ingin penanganan spesifik untuk TimeoutException, bisa ditambahkan di sini
      // if (e.message.contains('TimeoutException')) { ... }
      return ResultModel(
        isSuccess: false,
        error: finalErrorMessage,
      );
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      return ResultModel(
        isSuccess: false,
        error: finalErrorMessage,
      );
    }
  }
}
