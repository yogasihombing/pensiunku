class SalaryPlaceModel {
  final int id;
  final String text;

  SalaryPlaceModel({
    required this.id,
    required this.text,
  });

  factory SalaryPlaceModel.fromJson(Map<String, dynamic> json) {
    return SalaryPlaceModel(
      id: json['id'],
      text: json['text'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
    };
  }
}
