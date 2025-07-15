bool isProd = true;

String get apiHost {
  return isProd
      ? "https://pensiunku.id/mobileapi"
      : "https://pensiunku.id/mobileapi";
}

// Konfigurasi header default untuk API
// Menggunakan Map<String, String> karena http tidak memiliki kelas Options
Map<String, String> get defaultApiHeaders {
  return {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36',
    'Accept': 'application/json',
    'Accept-Language': 'id-ID,id;q=0.9,en-US;q=0.8,en;q=0.7',
    'X-Requested-With': 'com.pensiunku.app',
    'Content-Type': 'application/json', // Pindahkan contentType ke headers
  };
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
