class BankModel {
  final String id;
  final String name;
  final String? fotoUrl; // Tambahkan properti untuk URL foto

  BankModel({required this.id, required this.name, this.fotoUrl});

  factory BankModel.fromJson(Map<String, dynamic> json) {
    final String idValue = (json['id'] ?? '').toString();
    final String nameValue = (json['nama'] as String? ?? 'Nama Tidak Diketahui');
    final String? fotoUrlValue = json['foto'] as String?; // Ambil URL foto

    return BankModel(
      id: idValue,
      name: nameValue,
      fotoUrl: fotoUrlValue, // Inisialisasi fotoUrl
    );
  }
}
