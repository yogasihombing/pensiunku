import 'dart:developer';

import 'package:pensiunku/data/api/halopenisun_api.dart';
import 'package:pensiunku/model/halopensiun_model.dart';
import 'package:pensiunku/repository/base_repository.dart';
import 'package:pensiunku/model/result_model.dart';

class HalopensiunRepository extends BaseRepository {
  static const String _tag = 'HalopensiunRepository';
  final HalopensiunApi _api = HalopensiunApi();
  Future<ResultModel<HalopensiunModel>> getHalopensiuns(
      int categoryId, String? searchText, String token) async {
    assert(() {
      log('HalopensiunRepository: getHalopensiuns Repository dipanggil. Category ID: $categoryId, Search Text: $searchText',
          name: _tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat mendapatkan data halopensiun terbaru. Tolong periksa Internet Anda.';

    return super.getResultModel<HalopensiunModel>(
      tag: _tag,
      getFromApi: () async =>
          await _api.getAllByCategoryAndKeyword(categoryId, searchText, token),
      getDataFromApiResponse: (responseJson) {
        log('HalopensiunRepository: Mengolah respons API untuk getHalopensiuns: $responseJson',
            name: _tag);
        if (responseJson['status'] == 'success' &&
            responseJson['data'] != null) {
          return HalopensiunModel.fromJson(responseJson['data']);
        } else {
          throw Exception(responseJson['message'] ??
              'Respons API tidak valid atau data kosong.');
        }
      },
      errorMessage: finalErrorMessage,
    );
  }

  Future<ResultModel<HalopensiunModel>> getAllHalopensiuns(String token) async {
    assert(() {
      log('HalopensiunRepository: getAllHalopensiuns Repository dipanggil.',
          name: _tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat mendapatkan semua data halopensiun. Tolong periksa Internet Anda.';

    return super.getResultModel<HalopensiunModel>(
      tag: _tag,
      getFromApi: () async => await _api.getAll(token),
      getDataFromApiResponse: (responseJson) {
        log('HalopensiunRepository: Mengolah respons API untuk getAllHalopensiuns: $responseJson',
            name: _tag);
        if (responseJson['status'] == 'success' &&
            responseJson['data'] != null) {
          return HalopensiunModel.fromJson(responseJson['data']);
        } else {
          throw Exception(responseJson['message'] ??
              'Respons API tidak valid atau data kosong.');
        }
      },
      errorMessage: finalErrorMessage,
    );
  }
}
