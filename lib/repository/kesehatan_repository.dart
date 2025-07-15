import 'dart:developer';
import 'dart:convert'; // Untuk json.decode
import 'package:http/http.dart' as http; // Menggunakan paket http
import 'package:pensiunku/data/api/kesehatan_api.dart'; // Pastikan path ini benar
import 'package:pensiunku/data/api/base_api.dart'; // Import BaseApi untuk HttpException
import 'package:pensiunku/model/kesehatan_model.dart'; // Pastikan semua model di sini
import 'package:pensiunku/repository/base_repository.dart';
import 'package:pensiunku/model/result_model.dart';

class KesehatanRepository extends BaseRepository {
  static String tag = 'Kesehatan Repository'; // Mengubah tag agar sesuai
  KesehatanApi api = KesehatanApi();

  Future<ResultModel<KesehatanModel>> getAll() async {
    assert(() {
      log('getAll', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat mendapatkan list hospital. Tolong periksa Internet Anda.';
    try {
      // Mengubah tipe kembalian dari api.getAll() menjadi http.Response
      http.Response response = await api.getAll();
      var responseJson = json.decode(response.body); // Menggunakan json.decode(response.body)
      log(responseJson['data'].toString());

      if (responseJson['status'] == 'success') {
        return ResultModel(
          isSuccess: true,
          data: KesehatanModel.fromJson(responseJson['data']),
        );
      } else {
        return ResultModel(
          isSuccess: false,
          error: responseJson['msg'] ?? finalErrorMessage,
        );
      }
    } on HttpException catch (e) { // Mengubah DioError menjadi HttpException
      log(e.toString(), name: tag, error: e);
      int? statusCode = e.statusCode; // Mengakses statusCode langsung dari HttpException
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

  Future<ResultModel<DetailHospitalModel>> getDetail(int hospitalId) async {
    assert(() {
      log('getDetail Hospital', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat mendapatkan detail dari rumah sakit yang dipilih. Tolong periksa Internet Anda.';
    try {
      // Mengubah tipe kembalian dari api.getDetail() menjadi http.Response
      http.Response response = await api.getDetail(hospitalId);
      var responseJson = json.decode(response.body); // Menggunakan json.decode(response.body)
      log(responseJson['data'].toString());

      if (responseJson['status'] == 'success') {
        return ResultModel(
          isSuccess: true,
          data: DetailHospitalModel.fromJson(responseJson['data']),
        );
      } else {
        return ResultModel(
          isSuccess: false,
          error: responseJson['msg'] ?? finalErrorMessage,
        );
      }
    } on HttpException catch (e) { // Mengubah DioError menjadi HttpException
      log(e.toString(), name: tag, error: e);
      int? statusCode = e.statusCode; // Mengakses statusCode langsung dari HttpException
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
