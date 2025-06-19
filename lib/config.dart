//Change this condition before build production
bool isProd = true;
String get apiHost {
  if (isProd) {
    return "https://pensiunku.id/mobileapi";
  }

  return "https://pensiunku.id/mobileapi";
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
    // return "https://app.midtrans.com/snap/v2/vtweb/";
    return "$apiHost/api/payments/";
  }
  // return "https://app.sandbox.midtrans.com/snap/v2/vtweb/";
  return "$apiHost/api/payments/";
}