class ThemeModel {
  final String parameter;
  final String value;

  ThemeModel({
    required this.parameter,
    required this.value,
  });

  factory ThemeModel.fromJson(Map<String, dynamic> json) {
    return ThemeModel(
      parameter: json['parameter'],
      value: json['value']
    );
  }

  factory ThemeModel.fromMap(Map<String, dynamic> map) {
    return ThemeModel(
      parameter: map['parameter'],
      value: map['value']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parameter': parameter,
      'value': value
    };
  }

  Map<String, dynamic> toMap(){
    return <String, dynamic>{
      "parameter": parameter,
      "value": value,
    };
  }

  @override
  String toString() {
    return toJson().toString();
  }
}