import 'package:dio/dio.dart';
import 'package:pensiunku/data/api/base_api.dart';
import 'package:pensiunku/util/api_util.dart';
import 'package:pensiunku/config.dart';

class UserApi extends BaseApi {
  Future<Response> getOne(String token) {
    return httpGet(
      '/user',
      options: ApiUtil.getTokenOptions(token),
    );
  }

  Future<Response> updateOne(String token, dynamic data) {
    return httpPost(
      '/user/update',
      data: data,
      options: ApiUtil.getTokenOptions(token),
    );
  }

  Future<Response> sendOtp(String phone) {
    return httpPost(
      '/user/verify-phone',
      data: isProd
          ? {
              'phone': phone,
            }
          : {
              'phone': phone,
              'test': 'testing',
            },
    );
  }

  Future<Response> verifyOtp(String phone, String otp) {
    return httpPost(
      '/user/verify-otp',
      data: {
        'phone': phone,
        'otp': otp,
      },
    );
  }

  Future<Response> saveFcmToken(String token, String fcmToken) {
    return httpPost(
      '/user-notification/token',
      data: {
        'token': fcmToken,
      },
      options: ApiUtil.getTokenOptions(token),
    );
  }

  // Endpoint baru untuk mengecek keberadaan pengguna
  Future<Response> checkUserExists(String phone) {
    return httpPost(
      'https://api.pensiunku.id/new.php/cekNomorTelepon', // Endpoint baru
      data: {
        'telepon':
            phone, // Menggunakan 'telepon' sebagai parameter sesuai dengan API
      },
    );
  }
}
