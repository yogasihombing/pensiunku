class Categories {
  final int id;
  final String nama;

  Categories({
    required this.id,
    required this.nama,
  });

  factory Categories.fromJson(Map<String, dynamic> json) {
    return Categories(
      id: _parseInt(
          json['id']), // Perubahan yang kamu buat: Memparsing 'id' dengan aman
      nama: json['nama']?.toString() ??
          '', // Perubahan yang kamu buat: Memastikan 'nama' adalah String
    );
  }
}

class ListFranchise {
  final int id;
  final String nama;
  final String logo;
  final int kategori;

  ListFranchise({
    required this.id,
    required this.nama,
    required this.logo,
    required this.kategori,
  });

  factory ListFranchise.fromJson(Map<String, dynamic> json) {
    return ListFranchise(
      id: _parseInt(
          json['id']), // Perubahan yang kamu buat: Memparsing 'id' dengan aman
      nama: json['nama']?.toString() ??
          '', // Perubahan yang kamu buat: Memastikan 'nama' adalah String
      logo: json['logo']?.toString() ??
          '', // Perubahan yang kamu buat: Memastikan 'logo' adalah String
      kategori: _parseInt(json[
          'kategori']), // Perubahan yang kamu buat: Memparsing 'kategori' dengan aman
    );
  }
}

class UsahaModel {
  // final String description; // Dikomentari di kode asli
  final List<Categories> categories;
  final List<ListFranchise> list;

  UsahaModel({
    // required this.description, // Dikomentari di kode asli
    required this.categories,
    required this.list,
  });

  factory UsahaModel.fromJson(Map<String, dynamic> json) {
    // Perubahan yang kamu buat: Memastikan 'categories' dan 'list' adalah List atau default ke list kosong
    List<dynamic> categoriesJson =
        json['categories'] is List ? json['categories'] : [];
    List<dynamic> franchiseJson = json['list'] is List ? json['list'] : [];

    return UsahaModel(
      // description: json['description']?.toString() ?? '', // Jika 'description' diaktifkan kembali
      categories:
          categoriesJson.map((json) => Categories.fromJson(json)).toList(),
      list: franchiseJson.map((json) => ListFranchise.fromJson(json)).toList(),
    );
  }
}

// Helper functions for safe parsing (sertakan di bagian atas file ini atau pastikan diimpor)
int _parseInt(dynamic value) {
  if (value is int) {
    return value;
  } else if (value is String) {
    return int.tryParse(value) ?? 0;
  }
  return 0;
}
