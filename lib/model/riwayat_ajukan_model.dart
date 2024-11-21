class RiwayatPengajuanModel {
  // Properti model yang sesuai dengan data API
  final String id;
  final String tiket;
  final String nama;
  final String telepon;
  final String alamat;
  final String nip;
  final String tanggal;

  // Constructor untuk menginisialisasi properti model
  RiwayatPengajuanModel({
    required this.id,
    required this.tiket,
    required this.nama,
    required this.telepon,
    required this.alamat,
    required this.nip,
    required this.tanggal,
  });

  // Factory untuk membuat instance model dari JSON
  factory RiwayatPengajuanModel.fromJson(Map<String, dynamic> json) {
  if (!json.containsKey('id') ||
      !json.containsKey('tiket') ||
      !json.containsKey('nama')) {
    throw Exception('Data JSON tidak lengkap: $json');
  }
  return RiwayatPengajuanModel(
    id: json['id'] ?? '',
    tiket: json['tiket'] ?? '',
    nama: json['nama'] ?? '',
    telepon: json['telepon'] ?? '',
    alamat: json['alamat'] ?? '',
    nip: json['nip'] ?? '',
    tanggal: json['tanggal'] ?? '',
  );
}

}
