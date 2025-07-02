import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:pensiunku/data/db/app_database.dart';
import 'package:pensiunku/model/theme_model.dart';
import 'package:pensiunku/repository/base_repository.dart';
import 'package:pensiunku/model/result_model.dart';

class ThemeRepository extends BaseRepository {
  static String tag = 'ThemeRepository';
  AppDatabase database = AppDatabase();

  Future<ResultModel<ThemeModel>> get() async {
    assert(() {
      log('getTheme', name: tag);
      return true;
    }());
    ThemeModel? themeDb = await database.themeDao.get('darkMode');
    if (themeDb == null) {
      ThemeModel theme = ThemeModel(parameter: 'darkMode', value: 'false');
      return ResultModel(
        isSuccess: true,
        data: theme,
      );
    } else {
      return ResultModel(
        isSuccess: true,
        data: themeDb,
      );
    }
  }

  Future<ResultModel<ThemeModel>> update(dynamic data) async {
    assert(() {
      log('update', name: tag);
      return true;
    }());

    String finalErrorMessage = 'Tidak dapat mengupdate tema';

    try {
      int result = database.themeDao.insertUpdate(data);
      late ThemeModel theme;
      if (result == 1) {
        theme = ThemeModel(parameter: 'darkMode', value: 'true');
      } else {
        theme = ThemeModel(parameter: 'darkMode', value: 'false');
      }

      return ResultModel(
        isSuccess: true,
        data: theme,
      );
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is DioException) {
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
        if (e.message?.contains('SocketException')?? false) {
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
