import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:pensiunku/data/api/submission_api.dart';
import 'package:pensiunku/data/db/app_database.dart';
import 'package:pensiunku/model/submission_model.dart';
import 'package:pensiunku/repository/base_repository.dart';
import 'package:pensiunku/model/result_model.dart';

class SubmissionRepository extends BaseRepository {
  static String tag = 'SubmissionRepository';
  SubmissionApi api = SubmissionApi();
  AppDatabase database = AppDatabase();

  Future<ResultModel<SubmissionModel>> uploadSelfie(
      String token, SubmissionModel submissionModel, String selfieFile,
      {required String idUser}
      ) async {
    print('=== Repository.uploadSelfie started ===');

    try {
      // Mengambil userId dari submissionModel dan mengonversinya ke String
      Response response = await api.uploadSelfie(
        token,
        selfieFile,
        idUser, // menempelkan User ID
      );
      print('Raw response: ${response.data}');

      if (response.statusCode != 200) {
        return ResultModel(
          isSuccess: false,
          error: 'Server error: ${response.statusCode}',
        );
      }

      var responseData = response.data;
      print('Response type: ${responseData.runtimeType}');
      print('Response content: $responseData');

      // Jika response masih berupa String, coba parse ke JSON
      if (responseData is String) {
        try {
          responseData = jsonDecode(responseData);
          print('Parsed JSON response: $responseData');
        } catch (e) {
          print('Failed to parse response as JSON: $e');
        }
      }

      // Tangani berbagai format response
      if (responseData is Map) {
        if (responseData.containsKey('text') &&
            responseData['text'] is Map &&
            responseData['text']['message'] == 'success') {
          print('Response success ditemukan');
          return ResultModel(
            isSuccess: true,
            data: submissionModel,
          );
        }

        if (responseData.containsKey('text') &&
            responseData['text'] is Map &&
            responseData['text']['message'] != null &&
            responseData['text']['message'] != 'success') {
          final errorMessage = responseData['text']['message'].toString();
          print('Error message from server: $errorMessage');
          return ResultModel(
            isSuccess: false,
            error: errorMessage,
          );
        }

        if (responseData['status'] == 'success' &&
            responseData['data'] != null) {
          return ResultModel(
            isSuccess: true,
            data: SubmissionModel.fromJson(responseData['data']),
          );
        }
      }

      if (responseData is String && responseData.contains('success')) {
        print('String response contains "success"');
        return ResultModel(
          isSuccess: true,
          data: submissionModel,
        );
      }

      return ResultModel(
        isSuccess: false,
        error: 'Format response tidak valid: $responseData',
      );
    } catch (e) {
      print('Error di repository: $e');
      return ResultModel(
        isSuccess: false,
        error: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }
}