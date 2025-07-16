class Categories {
  final int id;
  final String nama;

  Categories({
    required this.id,
    required this.nama,
  });

  factory Categories.fromJson(Map<String, dynamic> json) {
    // Perubahan: Pastikan 'id' diurai dengan aman sebagai int
    int parsedId;
    final idValue = json['id'];
    if (idValue is int) {
      parsedId = idValue;
    } else if (idValue is String) {
      parsedId =
          int.tryParse(idValue) ?? 0; // Coba parse, default ke 0 jika gagal
    } else {
      parsedId = 0; // Default jika bukan int atau String
    }

    return Categories(
      id: parsedId, // Gunakan id yang sudah di-parse dengan aman
      nama: json['nama']?.toString() ??
          '', // Perbaikan: Pastikan string tidak null
    );
  }
}

class ListHalopensiun {
  int? id;
  final int idKategori;
  final String judul;
  final String? infografis; // --- PERUBAHAN: infografis bisa null ---

  ListHalopensiun({
    this.id,
    required this.idKategori,
    required this.judul,
    this.infografis, // --- PERUBAHAN: infografis bisa null ---
  });

  factory ListHalopensiun.fromJson(Map<String, dynamic> json) {
    int? parsedId;
    final idValue = json['id'];
    if (idValue is int) {
      parsedId = idValue;
    } else if (idValue is String) {
      parsedId = int.tryParse(idValue); // parsedId bisa null jika gagal parse
    }

    final idKategoriValue = json['id_kategori'];
    int parsedIdKategori;
    if (idKategoriValue is int) {
      parsedIdKategori = idKategoriValue;
    } else if (idKategoriValue is String) {
      parsedIdKategori = int.tryParse(idKategoriValue) ??
          0; // Coba parse, default ke 0 jika gagal
    } else {
      parsedIdKategori = 0; // Default jika bukan int atau String
    }

    return ListHalopensiun(
      id: parsedId, // Gunakan id yang sudah di-parse dengan aman
      idKategori:
          parsedIdKategori, // Gunakan idKategori yang sudah di-parse dengan aman
      judul: json['judul']?.toString() ??
          '', // Perbaikan: Pastikan string tidak null
      infografis: json['infografis']
          ?.toString(), // --- PERUBAHAN: infografis bisa null ---
    );
  }
}

class HalopensiunModel {
  final List<Categories> categories;
  final List<ListHalopensiun> list;

  HalopensiunModel({
    required this.categories,
    required this.list,
  });

  factory HalopensiunModel.fromJson(Map<String, dynamic> json) {
    List<dynamic> categoriesJson =
        json['categories'] is List ? json['categories'] : [];
    List<dynamic> halopensiunJson = json['list'] is List ? json['list'] : [];

    return HalopensiunModel(
      categories:
          categoriesJson.map((json) => Categories.fromJson(json)).toList(),
      list: halopensiunJson
          .map((json) => ListHalopensiun.fromJson(json))
          .toList(),
    );
  }
}
