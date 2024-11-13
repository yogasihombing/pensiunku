class Categories {
  final int id;
  final String nama;

  Categories({
    required this.id,
    required this.nama,
  });

  factory Categories.fromJson(Map<String, dynamic> json) {
    return Categories(
      id: json['id'],
      nama: json['nama'],
    );
  }
}

class ListHalopensiun {
  int? id;
  final int idKategori;
  final String judul;
  final String infografis;

  ListHalopensiun({
    this.id,
    required this.idKategori,
    required this.judul,
    required this.infografis,
  });

  factory ListHalopensiun.fromJson(Map<String, dynamic> json) {
    return ListHalopensiun(
      id: json.containsKey('id') ? json['id'] : null, 
      idKategori: json['id_kategori'],
      judul: json['judul'],
      infografis: json['infografis'],
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
    List<dynamic> categoriesJson = json['categories'];
    List<dynamic> halopensiunJson = json['list'];

    return HalopensiunModel(
      categories: categoriesJson.map((json) => Categories.fromJson(json)).toList(),
      list: halopensiunJson.map((json) => ListHalopensiun.fromJson(json)).toList(),
    );
  }
}