import 'package:dio/dio.dart';
import 'package:pensiunku/data/api/base_api.dart';
import 'package:pensiunku/util/api_util.dart';
import 'package:pensiunku/config.dart';

class UserApi extends BaseApi {
  // Konstruktor memanggil super() tanpa parameter.
  UserApi() : super();

  // Endpoint yang menggunakan baseUrl dari config.dart (misal mobileapi)
  Future<Response> getOne(String token) {
    return httpGet(
      '/user', // Path relatif, akan digabungkan dengan BaseApi.baseUrl
      options: ApiUtil.getTokenOptions(token),
    );
  }

  Future<Response> updateOne(String token, dynamic data) {
    return httpPost(
      '/user/update', // Path relatif
      data: data,
      options: ApiUtil.getTokenOptions(token),
    );
  }

  Future<Response> sendOtp(String phone) {
    return httpPost(
      '/user/verify-phone', // Path relatif
      data: isProd // isProd dari config.dart
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
      '/user/verify-otp', // Path relatif
      data: {
        'phone': phone,
        'otp': otp,
      },
    );
  }

  Future<Response> saveFcmToken(String token, String fcmToken) {
    return httpPost(
      '/user-notification/token', // Path relatif
      data: {
        'token': fcmToken,
      },
      options: ApiUtil.getTokenOptions(token),
    );
  }

  // Endpoint yang menggunakan URL absolut karena berada di domain yang berbeda (new.php)
  Future<Response> checkUserExists(String phone) {
    return httpPost(
      'https://api.pensiunku.id/new.php/cekNomorTelepon', // URL absolut
      data: {
        'telepon': phone,
      },
    );
  }
}