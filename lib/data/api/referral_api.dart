import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:pensiunku/data/api/base_api.dart';
import 'package:pensiunku/model/referral_model.dart';
import 'package:pensiunku/util/api_util.dart';

class ReferralApi extends BaseApi {
  Future<Response> getAll(String token) {
    return httpGet(
      '/referal',
      options: ApiUtil.getTokenOptions(token),
    );
  }

  Future<Response> insert(String token, dynamic data) {
    return httpPost(
      '/referal',
      data: data,
      options: ApiUtil.getTokenOptions(token),
    );
  }

  Future<Response> uploadKtp(
    String token,
    ReferralModel referralModel,
    String ktpFile,
  ) async {
    final dataMap = {
      "foto_ktp": await MultipartFile.fromFile(ktpFile, filename: "ktp.jpg"),
      'nama_ktp': referralModel.nameKtp,
      'nik_ktp': referralModel.nikKtp,
      'alamat_ktp': referralModel.addressKtp?.replaceAll('\n', ' '),
      'pekerjaan_ktp': referralModel.jobKtp,
      'tanggal_lahir_ktp': referralModel.birthDateKtp != null
          ? DateFormat('yyyy-MM-dd').format(referralModel.birthDateKtp!)
          : null,
      'referal': referralModel.referal,
    };
    log(dataMap.toString());
    FormData data = FormData.fromMap(dataMap);
    return httpPost(
      '/referal',
      data: data,
      options: ApiUtil.getTokenOptions(token),
    );
  }
}
