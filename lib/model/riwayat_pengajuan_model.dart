class RiwayatPengajuanOrangLainModel {
  final String nama;
  final String tanggal;
  final String tiket;

  RiwayatPengajuanOrangLainModel({
    required this.nama,
    required this.tanggal,
    required this.tiket,
  });

  factory RiwayatPengajuanOrangLainModel.fromJson(Map<String, dynamic> json) {
    print('Model: Parsing JSON: $json');
    return RiwayatPengajuanOrangLainModel(
      nama: json['nama'] as String,
      tanggal: json['tanggal'] as String,
      tiket: json['tiket'] as String,
    );
  }
}
