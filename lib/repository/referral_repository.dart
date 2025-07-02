import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:pensiunku/data/api/referral_api.dart';
import 'package:pensiunku/data/db/app_database.dart';
import 'package:pensiunku/model/referral_model.dart';
import 'package:pensiunku/repository/base_repository.dart';
import 'package:pensiunku/model/result_model.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;

class ReferralRepository extends BaseRepository {
  static String tag = 'ReferralRepository';
  ReferralApi api = ReferralApi();
  AppDatabase database = AppDatabase();

  Future<ResultModel<ReferralModel>> getAll(String token) async {
    assert(() {
      log('Referral Repository: $token', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Belum ada data referral. Silahkan mengambil Foto KTP dan mengisi data referral.';
    try {
      Response response = await api.getAll(token);
      var responseJson = response.data;
      log(responseJson['data'].toString());

      if (responseJson['status'] == 'success') {
        if(responseJson['data'] != null){
          return ResultModel(
            isSuccess: true,
            data: ReferralModel.fromJson(responseJson['data']),
          );
        } else {
          return ResultModel(
              isSuccess: true,
              data: null
          );
        }
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
        if (e.message?.contains('SocketException') ?? false) {
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

  Future<ResultModel<ReferralModel>> uploadKtp(
      String token,
      ReferralModel referralModel,
      String ktpFile,
      ) async {
    assert(() {
      log('uploadKtp', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat mengirimkan data referal. Tolong periksa Internet Anda.';
    try {
      Response response = await api.uploadKtp(token, referralModel, ktpFile);
      var responseJson = response.data;

      if (responseJson['status'] == 'success') {
        ReferralModel dataReferal = ReferralModel.fromJson(responseJson['data']);
        // log('foto KTP : ' + dataReferal.fotoKtp.toString());
        // String newFolder = await createFolder('fotos');
        // log('is folder created ${newFolder}');
        if(File(ktpFile).existsSync()){
          log('copy file');
          final appDir = await SharedPreferencesUtil.getAppDir();
          File(ktpFile).copySync(path.join(appDir.path, dataReferal.fotoKtp.toString()));
          log('cek foto ktp sudah ada atau tidak : ' + File(path.join(appDir.path, dataReferal.fotoKtp.toString())).existsSync().toString());
        } else {
          log('tidak bisa copy file');
        }
        return ResultModel(
          isSuccess: true,
          data: ReferralModel.fromJson(responseJson['data']),
        );
      } else {
        return ResultModel(
          isSuccess: false,
          error: responseJson['msg'] ?? finalErrorMessage,
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
        if (e.message?.contains('SocketException') ?? false) {
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

  Future<String> createFolder(String cow) async {
    final folderName = cow;
    final path = Directory(SharedPreferencesUtil.getAppDir().toString() + "/" + folderName);
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    if ((await path.exists())) {
      return path.path;
    } else {
      path.create();
      return path.path;
    }
  }
}