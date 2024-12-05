class RiwayatPengajuanAndaModel {
  final String nama;
  final String tanggal;
  final String tiket;

  RiwayatPengajuanAndaModel({
    required this.nama,
    required this.tanggal,
    required this.tiket,
  });

  factory RiwayatPengajuanAndaModel.fromJson(Map<String, dynamic> json) {
    print('Model: Parsing JSON: $json');
    return RiwayatPengajuanAndaModel(
      nama: json['nama'] as String,
      tanggal: json['tanggal'] as String,
      tiket: json['tiket'] as String,
    );
  }
}

