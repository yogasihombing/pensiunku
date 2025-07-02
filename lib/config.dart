//Change this condition before build production
//Change this condition before build production
import 'package:dio/dio.dart';

// Ubah ini sebelum build production
bool isProd = true;

String get apiHost {
  return isProd 
      ? "https://pensiunku.id/mobileapi" 
      : "https://pensiunku.id/mobileapi";
}

// Konfigurasi header default untuk API
Options get defaultApiOptions {
  return Options(
    headers: {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36',
      'Accept': 'application/json',
      'Accept-Language': 'id-ID,id;q=0.9,en-US;q=0.8,en;q=0.7',
      'X-Requested-With': 'com.pensiunku.app',
    },
    contentType: 'application/json',
    responseType: ResponseType.json,
    receiveTimeout: Duration(seconds: 15),
    sendTimeout: Duration(seconds: 15),
  );
}

String get midtransClientKey {
  if (isProd) {
    return "Mid-client-llVRmNSMo9lb55Hy";
  }
  return "SB-Mid-client-MMXu7Jv2IGOQV7KT";
}

String get midtransMerchantBaseUrl {
  if (isProd) {
    return "https://pensiunku.id/mobileapi/";
  }
  return "https://pensiunku.id/mobileapi/";
}

String get midtransURL {
  if (isProd) {
    return "$apiHost/api/payments/";
  }
  return "$apiHost/api/payments/";
}