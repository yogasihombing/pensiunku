int _parseInt(dynamic value) {
  if (value is int) {
    return value;
  } else if (value is String) {
    return int.tryParse(value) ?? 0;
  }
  return 0;
}

class CostOngkir {
  final int value;
  final String etd;
  final String? note;

  CostOngkir({required this.value, required this.etd, this.note});

  factory CostOngkir.fromJson(Map<String, dynamic> json) {
    return CostOngkir(
      value: _parseInt(json['value']), // Perubahan yang kamu buat
      etd: json['etd']?.toString() ?? '', // Perubahan yang kamu buat
      note:
          json['note']?.toString(), // Perubahan yang kamu buat: note bisa null
    );
  }
}

class CostsOngkir {
  final String service;
  final String description;
  final List<CostOngkir> costs;

  CostsOngkir({
    required this.service,
    required this.description,
    required this.costs,
  });

  factory CostsOngkir.fromJson(Map<String, dynamic> json) {
    // Perubahan yang kamu buat: Memastikan 'cost' adalah List
    List<dynamic> costsJson = json['cost'] is List ? json['cost'] : [];

    return CostsOngkir(
        service: json['service']?.toString() ?? '', // Perubahan yang kamu buat
        description:
            json['description']?.toString() ?? '', // Perubahan yang kamu buat
        costs: costsJson.map((cost) => CostOngkir.fromJson(cost)).toList());
  }
}

class ResultOngkir {
  final String code;
  final String name;
  final List<CostsOngkir> costs;

  ResultOngkir({
    required this.code,
    required this.name,
    required this.costs,
  });

  factory ResultOngkir.fromJson(Map<String, dynamic> json) {
    // Perubahan yang kamu buat: Memastikan 'costs' adalah List
    List<dynamic> costsJson = json['costs'] is List ? json['costs'] : [];

    return ResultOngkir(
      code: json['code']?.toString() ?? '', // Perubahan yang kamu buat
      name: json['name']?.toString() ?? '', // Perubahan yang kamu buat
      costs: costsJson.map((cost) => CostsOngkir.fromJson(cost)).toList(),
    );
  }
}

class StatusOngkir {
  final int code;
  final String description;

  StatusOngkir({
    required this.code,
    required this.description,
  });

  factory StatusOngkir.fromJson(Map<String, dynamic> json) {
    return StatusOngkir(
      code: _parseInt(json['code']), // Perubahan yang kamu buat
      description:
          json['description']?.toString() ?? '', // Perubahan yang kamu buat
    );
  }
}

class OngkirModel {
  final StatusOngkir statusOngkir;
  final List<ResultOngkir> resultOngkir;

  OngkirModel({required this.statusOngkir, required this.resultOngkir});

  factory OngkirModel.fromJson(Map<String, dynamic> json) {
    // Perubahan yang kamu buat: Memastikan 'results' adalah List
    List<dynamic> resultsJson = json['results'] is List ? json['results'] : [];

    return OngkirModel(
      statusOngkir: StatusOngkir.fromJson(
          json['status'] ?? {}), // Memberikan map kosong jika null
      resultOngkir:
          resultsJson.map((result) => ResultOngkir.fromJson(result)).toList(),
    );
  }
}

class ExpedisiModel {
  final String code;
  final String name;
  final String service;
  final String description;
  final int cost;
  final String estimationDate;

  ExpedisiModel(
      {required this.code,
      required this.name,
      required this.service,
      required this.description,
      required this.cost,
      required this.estimationDate});

  // Perubahan yang kamu buat: Menambahkan factory constructor fromJson
  factory ExpedisiModel.fromJson(Map<String, dynamic> json) {
    return ExpedisiModel(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      service: json['service']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      cost: _parseInt(json['cost']),
      estimationDate: json['estimationDate']?.toString() ?? '',
    );
  }
}

class PostExpeditionModel {
  final String origin;
  final String destination;
  final int weight;
  final String courier;

  PostExpeditionModel(
    this.origin,
    this.destination,
    this.weight,
    this.courier,
  );

  // Perubahan yang kamu buat: Menambahkan toJson untuk PostExpeditionModel
  Map<String, dynamic> toJson() {
    return {
      'origin': origin,
      'destination': destination,
      'weight': weight,
      'courier': courier,
    };
  }
}
