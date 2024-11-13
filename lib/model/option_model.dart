
class OptionModel {
  final int id;
  final String text;

  OptionModel({
    required this.id,
    required this.text,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
    };
  }

  factory OptionModel.fromJson(Map<String, dynamic> json){
    return OptionModel(
      id: json['id'],
      text: json['text']
    );
  }

  factory OptionModel.fromProvinsiJson(Map<String, dynamic> json){
    return OptionModel(
      id: int.parse(json['provinsi']),
      text: json['nama_provinsi']
    );
  }

  factory OptionModel.fromKabupatenJson(Map<String, dynamic> json){
    return OptionModel(
      id: int.parse(json['kabupaten']),
      text: json['nama_kabupaten']
    );
  }

  factory OptionModel.fromKecamatanJson(Map<String, dynamic> json){
    return OptionModel(
      id: int.parse(json['kecamatan']),
      text: json['nama_kecamatan']
    );
  }

  factory OptionModel.fromKelurahanJson(Map<String, dynamic> json){
    return OptionModel(
      id: int.parse(json['kelurahan']),
      text: json['nama_kelurahan']
    );
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
