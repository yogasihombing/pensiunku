// ignore_for_file: non_constant_identifier_names

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';

class PointModel {
  final int totalPoint;
  final String description;
  final LayananModel layanan;

  PointModel(
      {required this.totalPoint,
      required this.description,
      required this.layanan});

  factory PointModel.fromJson(Map<String, dynamic> json) {
    return PointModel(
        totalPoint: json['total_point'],
        description: json['description'],
        layanan: LayananModel.fromJson(json['layanan']));
  }

  String getTotalPointFormatted() {
    return CurrencyTextInputFormatter(
      locale: 'id',
      decimalDigits: 0,
      symbol: '',
    ).format(totalPoint.toString());
  }
}

class LayananModel {
  final LayananDetailModel pulsa;
  final LayananDetailModel paketData;
  final LayananDetailModel ovo;
  final LayananDetailModel shopeepay;
  final LayananDetailModel gopay;
  final LayananDetailModel dana;

  LayananModel({
    required this.pulsa,
    required this.paketData,
    required this.ovo,
    required this.shopeepay,
    required this.gopay,
    required this.dana,
  });

  factory LayananModel.fromJson(Map<String, dynamic> json) {
    LayananDetailModel pulsaJson = LayananDetailModel.fromJson(json['pulsa']);
    LayananDetailModel paketDataJson =
        LayananDetailModel.fromJson(json['paketData']);
    LayananDetailModel ovoJson = LayananDetailModel.fromJson(json['ovo']);
    LayananDetailModel shopeepayJson =
        LayananDetailModel.fromJson(json['shopeepay']);
    LayananDetailModel gopayJson = LayananDetailModel.fromJson(json['gopay']);
    LayananDetailModel danaJson = LayananDetailModel.fromJson(json['dana']);

    return LayananModel(
        pulsa: pulsaJson,
        paketData: paketDataJson,
        ovo: ovoJson,
        shopeepay: shopeepayJson,
        gopay: gopayJson,
        dana: danaJson);
  }
}

class LayananDetailModel {
  final String topup;
  final String jenis;
  final String nama;
  final String logo;

  LayananDetailModel(
      {required this.topup,
      required this.jenis,
      required this.nama,
      required this.logo});

  factory LayananDetailModel.fromJson(Map<String, dynamic> json) {
    return LayananDetailModel(
        topup: json['topup'],
        jenis: json['jenis'],
        nama: json['nama'],
        logo: json['logo']);
  }

  String getNama() {
    return this.nama;
  }
}

class PriceListModel {
  final String? status;
  final String? nominal;
  final String? harga;
  final String? telepon;
  final dynamic logo;
  final String? layanan;
  final String? detail;
  final String? total;
  final String? pulsa_code;
  final String? pulsa_nominal;

  PriceListModel(
      {required this.status,
      required this.nominal,
      required this.harga,
      required this.telepon,
      required this.logo,
      required this.layanan,
      required this.detail,
      required this.total,
      required this.pulsa_code,
      required this.pulsa_nominal});

  factory PriceListModel.fromJson(Map<String, dynamic> json) {
    return PriceListModel(
        status: json['status'],
        nominal: json['nominal'],
        harga: json['harga'],
        telepon: json['telepon'],
        logo: json['logo'],
        layanan: json['layanan'],
        detail: json['detail'],
        total: json['total'],
        pulsa_code: json['pulsa_code'],
        pulsa_nominal: json['pulsa_nominal']);
  }

  String getHargaFormatted() {
    return CurrencyTextInputFormatter(
      locale: 'id',
      decimalDigits: 0,
      symbol: '',
    ).format(harga.toString()) + " pts";
  }
}

class PriceModel {
  final String telepon;
  final String topup;
  final String jenis;
  final String nama;

  PriceModel(
      {required this.telepon,
      required this.topup,
      required this.jenis,
      required this.nama});

  Map<String, dynamic> toJson() {
    return {
      'telepon': telepon,
      'topup': topup,
      'jenis': jenis,
      'nama': nama,
    };
  }
}

class TopUpModel {
  final String telepon;
  final String harga;
  final String pulsaCode;
  final String pulsaNominal;
  final String layanan;

  TopUpModel(
      {required this.telepon,
      required this.harga,
      required this.pulsaCode,
      required this.pulsaNominal,
      required this.layanan});

  Map<String, dynamic> toJson() {
    return {
      'telepon': telepon,
      'harga': harga,
      'pulsa_code': pulsaCode,
      'pulsa_nominal': pulsaNominal,
      'layanan': layanan
    };
  }
}

class MessageSuccessModel{
  final String message;

  MessageSuccessModel(
    {required this.message}
  );

  factory MessageSuccessModel.fromJson(Map<String, dynamic> json) {
    return MessageSuccessModel(
        message: json['message'],);
  }

}

class PointHistoryModel {
  final String? layanan;
  final String telepon;
  final String nominal;
  final String updatedDatetime;
  final String message;

  PointHistoryModel(
      {this.layanan,
      required this.telepon,
      required this.nominal,
      required this.updatedDatetime,
      required this.message});

  factory PointHistoryModel.fromJson(Map<String, dynamic> json) {
    return PointHistoryModel(
        layanan: json['layanan'] != null ? json['layanan'] : null,
        telepon: json['telepon'],
        nominal: json['nominal'],
        updatedDatetime: json['updated_datetime'],
        message: json['message']);
  }
}