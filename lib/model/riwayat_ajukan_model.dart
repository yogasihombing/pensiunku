class RiwayatPengajuanModel {
  final String nama;
  final String tanggal;
  final String tiket;

  RiwayatPengajuanModel({
    required this.nama,
    required this.tanggal,
    required this.tiket,
  });

  factory RiwayatPengajuanModel.fromJson(Map<String, dynamic> json) {
    print('Model: Parsing JSON: $json');
    return RiwayatPengajuanModel(
      nama: json['nama'] as String,
      tanggal: json['tanggal'] as String,
      tiket: json['tiket'] as String,
    );
  }
}

