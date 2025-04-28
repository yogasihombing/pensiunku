class CostOngkir{
  final int value;
  final String etd;
  final String? note;

  CostOngkir({
    required this.value,
    required this.etd,
    this.note
  });

  factory CostOngkir.fromJson(Map<String, dynamic> json){
    return CostOngkir(
      value: json['value'], 
      etd: json['etd'],
      note: json['note'] != null ? json['note'] : '',
    );
  }
}

class CostsOngkir{
  final String service;
  final String description;
  final List<CostOngkir> costs;

  CostsOngkir({
    required this.service,
    required this.description,
    required this.costs,
  });

  factory CostsOngkir.fromJson(Map<String, dynamic> json){
    List<dynamic> costsJson = json['cost'];

    return CostsOngkir(
      service: json['service'], 
      description: json['description'],
      costs: costsJson.map((cost) => CostOngkir.fromJson(cost)).toList()
    );
  }
}

class ResultOngkir{
  final String code;
  final String name;
  final List<CostsOngkir> costs;

  ResultOngkir({
    required this.code,
    required this.name,
    required this.costs,
  });

  factory ResultOngkir.fromJson(Map<String, dynamic> json){
    List<dynamic> costsJson = json['costs'];

    return ResultOngkir(
      code: json['code'], 
      name: json['name'], 
      costs: costsJson.map((cost) => CostsOngkir.fromJson(cost)).toList(),
    );
  }
}

class StatusOngkir{
  final int code;
  final String description;

  StatusOngkir({
    required this.code,
    required this.description,
  });

  factory StatusOngkir.fromJson(Map<String, dynamic> json){
    return StatusOngkir(
      code: json['code'], 
      description: json['description'],
    );
  }
}

class OngkirModel{
  final StatusOngkir statusOngkir;
  final List<ResultOngkir> resultOngkir;

  OngkirModel({
    required this.statusOngkir,
    required this.resultOngkir
  });

  factory OngkirModel.fromJson(Map<String, dynamic> json){
    List<dynamic> resultsJson = json['results'];

    return OngkirModel(
      statusOngkir: StatusOngkir.fromJson(json['status']), 
      resultOngkir: resultsJson.map((result) => ResultOngkir.fromJson(result)).toList(),
    );
  }
}

class ExpedisiModel{
  final String code;
  final String name;
  final String service;
  final String description;
  final int cost;
  final String estimationDate;

  ExpedisiModel({
    required this.code,
    required this.name,
    required this.service,
    required this.description,
    required this.cost,
    required this.estimationDate
  });

}

class PostExpeditionModel{
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
}